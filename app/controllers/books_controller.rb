# frozen_string_literal: true

# Controller for managing books in the library system.
# Handles CRUD operations with authorization checks.
class BooksController < ApplicationController
  before_action :authenticate_user!, except: %i[index show]
  before_action :set_book, only: %i[show edit update destroy]

  def index
    books = policy_scope(Book)
            .search_by_term(params[:query])
            .order(title: :asc)
            .page(params[:page])
            .per(12)

    render(inertia: 'books/index', props: {
             books: BookBlueprint.render_as_hash(books, view: :card),
             pagination: pagination_props(books),
             query: params[:query]
           })
  end

  def show
    authorize(@book)

    render(inertia: 'books/show', props: {
             book: book_with_borrowing_info,
             user_has_active_borrowing: user_has_active_borrowing?
           })
  end

  def new
    authorize(Book)
    render(inertia: 'books/new')
  end

  def edit
    authorize(@book)
    render(inertia: 'books/edit', props: {
             book: BookBlueprint.render_as_hash(@book)
           })
  end

  def create
    @book = Book.new(book_params)
    authorize(@book)

    if @book.save
      redirect_to(book_path(@book), notice: 'Book was successfully created.')
    else
      redirect_to(new_book_path, inertia: { errors: @book.errors.to_hash })
    end
  end

  def update
    authorize(@book)

    if @book.update(book_params)
      redirect_to(book_path(@book), notice: 'Book was successfully updated.')
    else
      redirect_to(edit_book_path(@book), inertia: { errors: @book.errors.to_hash })
    end
  end

  def destroy
    authorize(@book)

    # Check if book can be deleted
    unless @book.can_be_deleted?
      return redirect_to(book_path(@book), alert: 'Cannot remove a book with active borrowings.')
    end

    # Soft delete using Discard gem
    @book.discard

    redirect_to(books_path, notice: 'Book was successfully removed.')
  end

  private

  def set_book
    @book = policy_scope(Book).find(params[:id])
  end

  def book_params
    params.expect(book: %i[title author genre isbn total_copies lock_version])
  end

  def pagination_props(books)
    {
      current_page: books.current_page,
      total_pages: books.total_pages,
      total_count: books.total_count,
      per_page: books.limit_value
    }
  end

  def book_with_borrowing_info
    view = current_user&.librarian? ? :with_status : :default
    BookBlueprint.render_as_hash(@book, view:)
  end

  def user_has_active_borrowing?
    return false unless current_user

    Borrowing.exists?(user: current_user, book: @book, returned_at: nil)
  end
end
