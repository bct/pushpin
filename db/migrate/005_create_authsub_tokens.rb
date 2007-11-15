class CreateAuthsubTokens < ActiveRecord::Migration
  def self.up
    create_table :authsub_tokens do |t|
      t.column :user_id, :integer, :null => false
      t.column :token, :string, :null => false
    end
  end

  def self.down
    drop_table :authsub_tokens
  end
end
