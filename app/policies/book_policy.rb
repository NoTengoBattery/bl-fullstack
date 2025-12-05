# frozen_string_literal: true

class BookPolicy < ApplicationPolicy
  # Everyone can read/search books
  def index? = true

  def show? = true

  def search? = true

  # Only librarians can create/update/destroy
  def create? = librarian?

  def update? = librarian?

  def destroy? = librarian?

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user&.librarian?
        # Librarians can see all books including discarded
        scope.all
      else
        # Regular users only see kept (non-discarded) books
        scope.kept
      end
    end
  end
end
