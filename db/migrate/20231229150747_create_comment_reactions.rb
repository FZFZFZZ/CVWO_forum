class CreateCommentReactions < ActiveRecord::Migration[7.1]
  def change
    create_table :comment_reactions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :comment, null: false, foreign_key: true
      t.string :reaction_type

      t.timestamps
    end
  end
end
