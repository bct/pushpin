class CreateCollections < ActiveRecord::Migration
  def self.up
    create_table :collections do |t|
      t.column :user_id, :integer, :null => false
      t.column :url, :string, :null => false
      t.column :title, :string
    end
  end

  def self.down
    drop_table :collections
  end
end
