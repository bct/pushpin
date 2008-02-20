class StaticController < ApplicationController
  def index
    @title = 'PushPin!'
    @entry = Atom::Entry.new
  end

  def signup
    @title = 'how do I sign up for PushPin?'
  end
end
