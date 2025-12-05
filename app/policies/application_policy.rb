# frozen_string_literal: true

class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index? = false
  def show? = false
  def create? = false
  def new? = create?
  def update? = false
  def edit? = update?
  def destroy? = false

  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve = raise(NoMethodError, "You must define #resolve in #{self.class}")

    private

    attr_reader :user, :scope
  end

  private

  def librarian? = user&.librarian?

  def member? = user&.member?

  def logged_in? = user.present?
end
