class UsersController < ApplicationController

  require 'open3'
  require 'csv'

  def show
    @user = User.find(params[:id])
    @rated_articles = @user.ratings.includes(:article).map(&:article)
    @ratings = @user.ratings.includes(:article)
    
    generate_ratings_csv(@user)

    redirect_to articles_path, alert: "Access denied." unless @user == current_user
    if @user != current_user
      redirect_to articles_path, alert: "Access denied."
    else
      @liked_articles = @user.liked_articles
    end
    if @user != current_user
      redirect_to articles_path, alert: "Access denied."
    else
      @recently_commented_articles = @user.commented_articles.order('comments.created_at DESC').limit(10)
    end
  end

  def show_python_output
    @user = User.find(params[:id])

    y_file_path = Rails.root.join('csv', 'Y_forTraining_read_only.csv')
    r_file_path = Rails.root.join('csv', 'R_forTraining_read_only.csv')
    u_file_path = Rails.root.join('csv', 'new_user.csv')
    script_path = Rails.root.join('lib', 'assets', 'python', 'collaborative_filtering_original.py')
    output = `python #{script_path} #{y_file_path} #{r_file_path} #{u_file_path}`

    # command = "python #{script_path} #{y_file_path} #{r_file_path} #{u_file_path}"
    # @script_output = `#{command}`

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