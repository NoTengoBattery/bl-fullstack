# frozen_string_literal: true

require 'rails_helper'

RSpec.describe('Dashboard') do
  let(:member) { create(:user_spec, :member) }
  let(:librarian) { create(:user_spec, :librarian) }

  describe 'GET /dashboard' do
    context 'when not authenticated' do
      it 'redirects to login' do
        get '/dashboard'

        expect(response).to(redirect_to('/login'))
      end
    end

    context 'when authenticated as member' do
      before { sign_in_as(member) }

      it 'renders the member dashboard' do
        get '/dashboard'

        expect(response).to(have_http_status(:ok))
        expect(inertia_component).to(eq('dashboard/member'))
      end

      it 'includes borrowings in props' do
        book = create(:book_spec)
        create(:borrowing_spec, :active, user: member, book:)

        get '/dashboard'

        props = inertia_props
        expect(props['borrowings']).to(be_an(Array))
        expect(props['borrowings'].size).to(eq(1))
      end

      it 'only shows active borrowings' do
        book = create(:book_spec)
        create(:borrowing_spec, :active, user: member, book:, due_on: 1.week.from_now)
        # Create returned borrowing without validation since member already has an active borrowing
        returned = build(:borrowing_spec, :returned, user: member, book: create(:book_spec))
        returned.save(validate: false)

        get '/dashboard'

        props = inertia_props
        expect(props['borrowings'].size).to(eq(1))
      end

      it 'includes due date and overdue status' do
        book = create(:book_spec)
        create(:borrowing_spec, :overdue, user: member, book:)

        get '/dashboard'

        props = inertia_props
        borrowing = props['borrowings'].first
        expect(borrowing).to(include('due_on', 'overdue', 'days_until_due'))
        expect(borrowing['overdue']).to(be(true))
      end
    end

    context 'when authenticated as librarian' do
      before { sign_in_as(librarian) }

      it 'renders the librarian dashboard' do
        get '/dashboard'

        expect(response).to(have_http_status(:ok))
        expect(inertia_component).to(eq('dashboard/librarian'))
      end

      it 'includes stats in props' do
        get '/dashboard'

        props = inertia_props
        expect(props['stats']).to(include(
                                    'total_books',
                                    'total_borrowed',
                                    'overdue_count',
                                    'due_today_count'
                                  ))
      end

      it 'calculates correct total books count' do
        create_list(:book_spec, 5, :kept)
        create(:book_spec, :discarded) # Should not be counted

        get '/dashboard'

        props = inertia_props
        expect(props['stats']['total_books']).to(eq(5))
      end

      it 'calculates correct total borrowed count' do
        book = create(:book_spec, total_copies: 4)
        create_list(:borrowing_spec, 3, :active, book:)
        create(:borrowing_spec, :returned, book:) # Should not be counted

        get '/dashboard'

        props = inertia_props
        expect(props['stats']['total_borrowed']).to(eq(3))
      end

      it 'includes overdue borrowings' do
        book = create(:book_spec)
        create(:borrowing_spec, :overdue, user: member, book:)

        get '/dashboard'

        props = inertia_props
        expect(props['overdue_borrowings']).to(be_an(Array))
        expect(props['overdue_borrowings'].size).to(eq(1))
      end

      it 'includes borrowings due today' do
        book = create(:book_spec)
        create(:borrowing_spec, :active, user: member, book:, due_on: Date.current)

        get '/dashboard'

        props = inertia_props
        expect(props['due_today_borrowings']).to(be_an(Array))
        expect(props['due_today_borrowings'].size).to(eq(1))
      end

      it 'includes members with overdue books' do
        book = create(:book_spec)
        create(:borrowing_spec, :overdue, user: member, book:)

        get '/dashboard'

        props = inertia_props
        expect(props['members_with_overdue']).to(be_an(Array))
        expect(props['members_with_overdue'].size).to(eq(1))
        expect(props['members_with_overdue'].first['email_address']).to(eq(member.email_address))
      end
    end
  end
end
