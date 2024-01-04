class RatingsController < ApplicationController
  before_action :authenticate_user!

  def create
    @article = Article.find(params[:article_id])
    @rating = @article.ratings.new(rating_params)
    @rating.user = current_user

    if @rating.save
      redirect_to @article, notice: 'Your rating was successfully submitted.'
    else
      # Handle errors, such as re-rendering the article's show page with error messages
    end
  end

  private

  def rating_params
    params.require(:rating).permit(:score)
  end
end
