class DropCommentReactionsTable < ActiveRecord::Migration[7.1]
  def up
    drop_table :comment_reactions
  end

  def down
    create_table :comment_reactions do |t|
      t.integer :user_id, null: false
      t.integer :comment_id, null: false
      t.string :reaction_type
      t.timestamps
    end
  end
end