class ChangeScoreToFloatInRatings < ActiveRecord::Migration[7.1]
  def change
    change_column :ratings, :score, :float
  end
end