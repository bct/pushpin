class CollectionTypes < ActiveRecord::Migration
  def self.up
    add_column :collections, :editor, :string, :null => false, :default => 'basic_markdown'
    add_column :collections, :kind, :string, :null => false, :default => 'basic_entry'
  end

  def self.down
    remove_column :collections, :kind
    remove_column :collections, :editor
  end
end
