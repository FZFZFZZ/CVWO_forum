class RatingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_article

  def create
    @rating = @article.ratings.new(rating_params)
    @rating.user = current_user

    if @rating.save
      redirect_to @article, notice: 'Your rating was successfully submitted.'
    else
      redirect_to articles_path
    end
  end

  def edit
    @rating = @article.ratings.find_by(user: current_user)
  end

  def update
    @rating = @article.ratings.find_by(user: current_user)
    if @rating.update(rating_params)
      redirect_to @article, notice: 'Rating updated successfully'
    else
      render :edit
    end
  end

  private

  def set_article
    @article = Article.find(params[:article_id])
  end

  def rating_params
    params.require(:rating).permit(:score)
  end
end
