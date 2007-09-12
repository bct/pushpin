class StaticController < ApplicationController
  def index
    @entry = Atom::Entry.new
  end
end
