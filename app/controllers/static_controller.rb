class StaticController < ApplicationController
  def index
    @title = 'PushPin!'
    @entry = Atom::Entry.new

    redirect_to user_path()
  end

  def signup
    @title = 'how do I sign up for PushPin?'
  end
end
