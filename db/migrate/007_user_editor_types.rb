class UserEditorTypes < ActiveRecord::Migration
  def self.up
    remove_column :collections, :editor
    add_column :users, :editor, :string, :null => false, :default => 'basic_markdown'
  end

  def self.down
    add_column :collections, :editor, :string, :null => false, :default => 'basic_markdown'
    remove_column :users, :editor
  end
end
