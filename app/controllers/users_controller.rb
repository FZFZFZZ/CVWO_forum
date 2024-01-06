class UsersController < ApplicationController

  require 'open3'
  require 'csv'

  def show
    @user = User.find(params[:id])
  
    @rated_articles = @user.ratings.includes(:article).map(&:article)
    @ratings = @user.ratings.includes(:article)
    @liked_articles = @user.liked_articles
    @recently_commented_articles = @user.commented_articles.order('comments.created_at DESC').limit(10)
  
  end

  def show_python_output
    @user = User.find(params[:id])
    
    generate_ratings_csv(@user)

    y_file_path = Rails.root.join('csv', 'Y_forTraining_read_only.csv')
    r_file_path = Rails.root.join('csv', 'R_forTraining_read_only.csv')
    u_file_path = Rails.root.join('csv', 'new_user.csv')
    script_path = Rails.root.join('lib', 'assets', 'python', 'collaborative_filtering_original.py')
    output = `python #{script_path} #{y_file_path} #{r_file_path} #{u_file_path}`

    article_ids = output.tr('[]', '').split(',').map(&:to_i)
    @articles = Article.where(id: article_ids)
  end


  private

  def generate_ratings_csv(user)
    csv_file_path = Rails.root.join('csv', 'new_user.csv')

    CSV.open(csv_file_path, 'wb') do |csv|
      csv << ['Movie ID', 'Rating Score']  # CSV headers

      user.ratings.each do |rating|
        csv << [rating.article.id, rating.score]  # Replace 'article.title' with your actual method name
      end
    end
  end

  
end