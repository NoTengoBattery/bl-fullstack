# frozen_string_literal: true

# Controller for user dashboards.
# Provides different views for members and librarians.
class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    if current_user.librarian?
      render_librarian_dashboard
    else
      render_member_dashboard
    end
  end

  private

  def render_librarian_dashboard
    render(inertia: 'dashboard/librarian', props: {
             stats: librarian_stats,
             overdue_borrowings: librarian_overdue_borrowings,
             due_today_borrowings: librarian_due_today_borrowings,
             members_with_overdue: members_with_overdue_books
           })
  end

  def render_member_dashboard
    render(inertia: 'dashboard/member', props: {
             borrowings: member_borrowings
           })
  end

  # Librarian dashboard data

  def librarian_stats
    {
      total_books: Book.kept.count,
      total_borrowed: Borrowing.active.count,
      overdue_count: Borrowing.overdue.count,
      due_today_count: Borrowing.active.where(due_on: Date.current).count
    }
  end

  def librarian_overdue_borrowings
    borrowings = Borrowing.overdue
                          .includes(:book, :user)
                          .order(due_on: :asc)
                          .limit(20)
    BorrowingBlueprint.render_as_hash(borrowings, view: :librarian)
  end

  def librarian_due_today_borrowings
    borrowings = Borrowing.active
                          .where(due_on: Date.current)
                          .includes(:book, :user)
                          .order(:created_at)
    BorrowingBlueprint.render_as_hash(borrowings, view: :librarian)
  end

  def members_with_overdue_books
    users = User.joins(:borrowings)
                .where(borrowings: { status: :active, due_on: ...Date.current })
                .distinct
                .limit(20)
    UserBlueprint.render_as_hash(users, view: :extended)
  end

  # Member dashboard data

  def member_borrowings
    borrowings = current_user.borrowings
                             .active
                             .includes(:book)
                             .order(due_on: :asc)
    BorrowingBlueprint.render_as_hash(borrowings, view: :member)
  end
end
