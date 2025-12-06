# frozen_string_literal: true

require 'rails_helper'

RSpec.describe('Borrowings') do
  let(:member) { create(:user_spec, :member) }
  let(:librarian) { create(:user_spec, :librarian) }
  let(:book) { create(:book_spec, :kept, :multiple_copies) }

  describe 'GET /borrowings' do
    context 'when not authenticated' do
      it 'redirects to login' do
        get '/borrowings'

        expect(response).to(redirect_to('/login'))
      end
    end

    context 'when authenticated as member' do
      before do
        sign_in_as(member)
        create(:borrowing_spec, :active, user: member, book:)
      end

      it 'renders the borrowings index page' do
        get '/borrowings'

        expect(response).to(have_http_status(:ok))
        expect(inertia_component).to(eq('borrowings/index'))
      end

      it 'only shows own borrowings' do
        other_member = create(:user_spec, :member)
        create(:borrowing_spec, :active, user: other_member)

        get '/borrowings'

        props = inertia_props
        borrowings = props['borrowings']
        expect(borrowings.size).to(eq(1))
        expect(borrowings.first['book']['id']).to(eq(book.id))
      end
    end

    context 'when authenticated as librarian' do
      before { sign_in_as(librarian) }

      it 'shows all borrowings' do
        create(:borrowing_spec, :active, user: member, book:)
        other_member = create(:user_spec, :member)
        other_book = create(:book_spec)
        create(:borrowing_spec, :active, user: other_member, book: other_book)

        get '/borrowings'

        props = inertia_props
        expect(props['borrowings'].size).to(eq(2))
      end
    end
  end

  describe 'POST /borrowings (borrow a book)' do
    context 'when not authenticated' do
      it 'redirects to login' do
        post '/borrowings', params: { book_id: book.id }

        expect(response).to(redirect_to('/login'))
      end
    end

    context 'when authenticated as member' do
      before { sign_in_as(member) }

      context 'when book is available' do
        it 'creates a borrowing' do
          expect do
            post('/borrowings', params: { book_id: book.id })
          end.to(change(Borrowing, :count).by(1))
        end

        it 'redirects to book page with success message' do
          post '/borrowings', params: { book_id: book.id }

          expect(response).to(redirect_to("/books/#{book.id}"))
          follow_redirect!
          expect(flash[:notice]).to(eq('Book borrowed successfully.'))
        end

        it 'sets the correct due date (2 weeks from now)' do
          freeze_time do
            post '/borrowings', params: { book_id: book.id }

            borrowing = Borrowing.last
            expect(borrowing.due_on).to(eq(2.weeks.from_now.to_date))
          end
        end

        it 'sets the borrowed_at timestamp' do
          freeze_time do
            post '/borrowings', params: { book_id: book.id }

            borrowing = Borrowing.last
            expect(borrowing.borrowed_at).to(be_within(1.second).of(Time.current))
          end
        end
      end

      context 'when book is not available (no copies)' do
        let(:unavailable_book) { create(:book_spec, :kept, :no_copies) }

        it 'does not create a borrowing' do
          expect do
            post('/borrowings', params: { book_id: unavailable_book.id })
          end.not_to(change(Borrowing, :count))
        end

        it 'redirects with error message' do
          post '/borrowings', params: { book_id: unavailable_book.id }

          expect(response).to(redirect_to("/books/#{unavailable_book.id}"))
          follow_redirect!
          expect(flash[:alert]).to(eq('Book is not available'))
        end
      end

      context 'when user already has active borrowing for this book' do
        before do
          create(:borrowing_spec, :active, user: member, book:)
        end

        it 'does not create a borrowing' do
          expect do
            post('/borrowings', params: { book_id: book.id })
          end.not_to(change(Borrowing, :count))
        end

        it 'redirects with error message' do
          post '/borrowings', params: { book_id: book.id }

          expect(response).to(redirect_to("/books/#{book.id}"))
          follow_redirect!
          expect(flash[:alert]).to(include('already has an active borrowing'))
        end
      end
    end

    context 'when authenticated as librarian' do
      before { sign_in_as(librarian) }

      it 'can also borrow books' do
        expect do
          post('/borrowings', params: { book_id: book.id })
        end.to(change(Borrowing, :count).by(1))
      end
    end
  end

  describe 'PATCH /borrowings/:id (return a book)' do
    let!(:borrowing) { create(:borrowing_spec, :active, user: member, book:) }

    context 'when not authenticated' do
      it 'redirects to login' do
        patch "/borrowings/#{borrowing.id}"

        expect(response).to(redirect_to('/login'))
      end
    end

    context 'when authenticated as member' do
      before { sign_in_as(member) }

      it 'is not authorized to return books' do
        patch "/borrowings/#{borrowing.id}"

        expect(response).to(redirect_to('/'))
      end

      it 'does not update the borrowing' do
        patch "/borrowings/#{borrowing.id}"

        expect(borrowing.reload.status).to(eq('active'))
      end
    end

    context 'when authenticated as librarian' do
      before { sign_in_as(librarian) }

      it 'marks the borrowing as returned' do
        patch "/borrowings/#{borrowing.id}"

        expect(borrowing.reload.status).to(eq('returned'))
      end

      it 'sets the returned_at timestamp' do
        freeze_time do
          patch "/borrowings/#{borrowing.id}"

          expect(borrowing.reload.returned_at).to(be_within(1.second).of(Time.current))
        end
      end

      it 'redirects with success message' do
        patch "/borrowings/#{borrowing.id}"

        expect(response).to(redirect_to('/borrowings'))
        follow_redirect!
        expect(flash[:notice]).to(eq('Book returned successfully.'))
      end

      context 'when book is already returned' do
        before { borrowing.update!(status: :returned, returned_at: 1.day.ago) }

        it 'returns error' do
          patch "/borrowings/#{borrowing.id}"

          expect(response).to(redirect_to('/borrowings'))
          follow_redirect!
          expect(flash[:alert]).to(eq('This book has already been returned'))
        end
      end
    end
  end
end
