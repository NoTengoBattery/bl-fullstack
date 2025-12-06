# frozen_string_literal: true

# Controller for managing book borrowings.
# Members can borrow books, librarians can process returns.
class BorrowingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_borrowing, only: %i[show update]

  def index
    authorize(Borrowing)

    borrowings = fetch_borrowings
    view = current_user.librarian? ? :librarian : :member

    render(inertia: 'borrowings/index', props: {
             borrowings: BorrowingBlueprint.render_as_hash(borrowings, view:),
             pagination: pagination_props(borrowings)
           })
  end

  def show
    authorize(@borrowing)

    render(inertia: 'borrowings/show', props: {
             borrowing: BorrowingBlueprint.render_as_hash(@borrowing, view: :extended)
           })
  end

  # Member borrows a book
  def create
    authorize(Borrowing)

    book = Book.kept.find(params[:book_id])
    result = BorrowBookService.new(user: current_user, book:).call

    if result.success?
      redirect_to(book_path(book), notice: 'Book borrowed successfully.')
    else
      redirect_to(book_path(book), alert: result.error)
    end
  end

  # Librarian returns a book
  def update
    authorize(@borrowing)

    result = ReturnBookService.new(borrowing: @borrowing, librarian: current_user).call

    if result.success?
      redirect_to(borrowings_path, notice: 'Book returned successfully.')
    else
      redirect_to(borrowings_path, alert: result.error)
    end
  end

  private

  def set_borrowing
    @borrowing = Borrowing.find(params[:id])
  end

  def fetch_borrowings
    policy_scope(Borrowing)
      .includes(:book, :user)
      .order(created_at: :desc)
      .page(params[:page])
      .per(20)
  end

  def pagination_props(borrowings)
    {
      current_page: borrowings.current_page,
      total_pages: borrowings.total_pages,
      total_count: borrowings.total_count,
      per_page: borrowings.limit_value
    }
  end
end
