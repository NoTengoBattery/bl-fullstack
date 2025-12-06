# frozen_string_literal: true

require 'rails_helper'

RSpec.describe('Books') do
  let(:member) { create(:user_spec, :member) }
  let(:librarian) { create(:user_spec, :librarian) }
  let!(:book) { create(:book_spec, :kept, :multiple_copies) }

  describe 'GET /books' do
    it 'renders the books index page' do
      get '/books'

      expect(response).to(have_http_status(:ok))
      expect(inertia_component).to(eq('books/index'))
    end

    it 'includes books in the props' do
      get '/books'

      props = inertia_props
      expect(props['books']).to(be_an(Array))
      expect(props['pagination']).to(include('current_page', 'total_pages'))
    end

    context 'with search query' do
      let(:matching_book) { create(:book_spec, :kept, title: 'Ruby Programming') }
      let(:non_matching_book) { create(:book_spec, :kept, title: 'Python Guide') }

      it 'filters books by search term' do
        matching_book
        non_matching_book
        get '/books', params: { query: 'Ruby' }

        expect(response).to(have_http_status(:ok))
        props = inertia_props
        titles = props['books'].pluck('title')
        expect(titles).to(include('Ruby Programming'))
        expect(titles).not_to(include('Python Guide'))
      end
    end

    context 'with pagination' do
      before do
        create_list(:book_spec, 10)
        create_list(:book_spec, 5)
      end

      it 'paginates results' do
        get '/books', params: { page: 2 }

        expect(response).to(have_http_status(:ok))
        props = inertia_props
        expect(props['pagination']['current_page']).to(eq(2))
      end
    end
  end

  describe 'GET /books/:id' do
    it 'renders the book show page' do
      get "/books/#{book.id}"

      expect(response).to(have_http_status(:ok))
      expect(inertia_component).to(eq('books/show'))
    end

    it 'includes book details in the props' do
      get "/books/#{book.id}"

      props = inertia_props
      expect(props['book']['id']).to(eq(book.id))
      expect(props['book']['title']).to(eq(book.title))
      expect(props['user_has_active_borrowing']).to(be(false))
    end

    context 'when user has active borrowing' do
      before do
        sign_in_as(member)
        create(:borrowing_spec, :active, user: member, book:)
      end

      it 'indicates user has active borrowing' do
        get "/books/#{book.id}"

        props = inertia_props
        expect(props['user_has_active_borrowing']).to(be(true))
      end
    end
  end

  describe 'GET /books/new' do
    context 'when not authenticated' do
      it 'redirects to login' do
        get '/books/new'

        expect(response).to(redirect_to('/login'))
      end
    end

    context 'when authenticated as member' do
      before { sign_in_as(member) }

      it 'returns forbidden' do
        get '/books/new'

        expect(response).to(redirect_to('/'))
      end
    end

    context 'when authenticated as librarian' do
      before { sign_in_as(librarian) }

      it 'renders the new book page' do
        get '/books/new'

        expect(response).to(have_http_status(:ok))
        expect(inertia_component).to(eq('books/new'))
      end
    end
  end

  describe 'POST /books' do
    let(:book_params) do
      {
        book: {
          title: 'New Test Book',
          author: 'Test Author',
          genre: 'Fiction',
          isbn: '1234567890123',
          total_copies: 5
        }
      }
    end

    context 'when not authenticated' do
      it 'redirects to login' do
        post '/books', params: book_params

        expect(response).to(redirect_to('/login'))
      end
    end

    context 'when authenticated as member' do
      before { sign_in_as(member) }

      it 'returns forbidden (403)' do
        post '/books', params: book_params

        expect(response).to(redirect_to('/'))
      end

      it 'does not create a book' do
        expect do
          post('/books', params: book_params)
        end.not_to(change(Book, :count))
      end
    end

    context 'when authenticated as librarian' do
      before { sign_in_as(librarian) }

      it 'creates a new book' do
        expect do
          post('/books', params: book_params)
        end.to(change(Book, :count).by(1))
      end

      it 'redirects to the new book page' do
        post '/books', params: book_params

        expect(response).to(redirect_to(%r{/books/}))
      end

      context 'with invalid params' do
        let(:invalid_params) { { book: { title: '', author: '' } } }

        it 'does not create a book' do
          expect do
            post('/books', params: invalid_params)
          end.not_to(change(Book, :count))
        end

        it 'redirects back with errors' do
          post '/books', params: invalid_params

          expect(response).to(redirect_to('/books/new'))
        end
      end
    end
  end

  describe 'PATCH /books/:id' do
    let(:update_params) { { book: { title: 'Updated Title' } } }

    context 'when not authenticated' do
      it 'redirects to login' do
        patch "/books/#{book.id}", params: update_params

        expect(response).to(redirect_to('/login'))
      end
    end

    context 'when authenticated as member' do
      before { sign_in_as(member) }

      it 'returns forbidden' do
        patch "/books/#{book.id}", params: update_params

        expect(response).to(redirect_to('/'))
      end

      it 'does not update the book' do
        patch "/books/#{book.id}", params: update_params

        expect(book.reload.title).not_to(eq('Updated Title'))
      end
    end

    context 'when authenticated as librarian' do
      before { sign_in_as(librarian) }

      it 'updates the book' do
        patch "/books/#{book.id}", params: update_params

        expect(book.reload.title).to(eq('Updated Title'))
      end

      it 'redirects to the book page' do
        patch "/books/#{book.id}", params: update_params

        expect(response).to(redirect_to("/books/#{book.id}"))
      end

      context 'with StaleObjectError (optimistic locking)' do
        let(:stale_params) do
          current_version = book.lock_version
          book.update!(title: 'Changed Title') # bump lock_version to simulate concurrent update

          { book: { title: 'Updated Title', lock_version: current_version } }
        end

        it 'redirects back with flash alert' do
          patch "/books/#{book.id}", params: stale_params

          expect(response).to(redirect_to(root_path))
          follow_redirect!
          expect(flash[:alert]).to(eq('The book was modified by someone else. Please try again.'))
        end
      end
    end
  end

  describe 'DELETE /books/:id' do
    context 'when not authenticated' do
      it 'redirects to login' do
        delete "/books/#{book.id}"

        expect(response).to(redirect_to('/login'))
      end
    end

    context 'when authenticated as member' do
      before { sign_in_as(member) }

      it 'returns forbidden' do
        delete "/books/#{book.id}"

        expect(response).to(redirect_to('/'))
      end

      it 'does not soft delete the book' do
        delete "/books/#{book.id}"

        expect(book.reload.discarded?).to(be(false))
      end
    end

    context 'when authenticated as librarian' do
      before { sign_in_as(librarian) }

      it 'soft deletes the book' do
        delete "/books/#{book.id}"

        expect(book.reload.discarded?).to(be(true))
      end

      it 'redirects to books index' do
        delete "/books/#{book.id}"

        expect(response).to(redirect_to('/books'))
      end

      context 'when book has active borrowings' do
        let(:member) { create(:user_spec, :member) }

        before do
          create(:borrowing_spec, :active, book:, user: member)
        end

        it 'does not soft delete the book' do
          delete "/books/#{book.id}"

          expect(book.reload.discarded?).to(be(false))
        end

        it 'redirects back to book show page with alert' do
          delete "/books/#{book.id}"

          expect(response).to(redirect_to(book_path(book)))
        end

        it 'shows alert message about active borrowings' do
          delete "/books/#{book.id}"
          follow_redirect!

          expect(flash[:alert]).to(include('Cannot remove a book with active borrowings'))
        end
      end

      context 'when book has only returned borrowings' do
        let(:member) { create(:user_spec, :member) }

        before do
          create(:borrowing_spec, :returned, book:, user: member)
        end

        it 'soft deletes the book' do
          delete "/books/#{book.id}"

          expect(book.reload.discarded?).to(be(true))
        end
      end
    end
  end
end
