# frozen_string_literal: true

class BorrowingPolicy < ApplicationPolicy
  # Only logged in users can view borrowings list
  def index? = logged_in?

  # Users can view their own borrowings, librarians can view all
  def show? = librarian? || owner?

  # Members can create (borrow books)
  def create? = logged_in?

  # Only librarians can update (mark as returned)
  def update? = librarian?

  # No one can destroy borrowings (audit trail)
  def destroy? = false

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user&.librarian?
        # Librarians can see all borrowings
        scope.all
      elsif user
        # Members can only see their own borrowings
        scope.where(user:)
      else
        # Guests see nothing
        scope.none
      end
    end
  end

  private

  def owner? = user && record.user_id == user.id
end
