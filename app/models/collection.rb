class Collection < ActiveRecord::Base
  belongs_to :user

  def title
    (super or self.url)
  end

  validates_uniqueness_of :url, :on => :create, :scope => [ :user_id ]

  # #http= must be set to use any of the HTTP stuff
  attr_accessor :http

  def get_atom
    @atom ||= Atom::Collection.new self.url, @http
  end

  def update!
    get_atom

    @atom.update!

    unless new_record? or not @atom.title or (@atom.title.html == self.title)
      self.title = @atom.title.html
      self.save
    end
  end

  def post! *args
    get_atom

    @atom.post! *args
  end

  include Enumerable

  def each &block
    @atom.each &block
  end

  def empty?
    @atom.empty?
  end

  def self.kinds
    ['basic entry', 'link', 'comment', 'media']
  end
end
