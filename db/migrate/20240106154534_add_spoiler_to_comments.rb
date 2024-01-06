class AddSpoilerToComments < ActiveRecord::Migration[7.1]
  def change
    add_column :comments, :spoiler, :boolean, default: false
  end
end
