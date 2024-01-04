class ArticlesController < ApplicationController
  
  def index
    @q = Article.ransack(params[:q])
    @articles = @q.result(distinct: true)


    # Check if the query params include sorting by average rating
    if params[:q] && params[:q][:s] == 'average_rating asc'
      @articles = @articles.sort_by { |article| article.average_rating || 3.5 }
    elsif params[:q] && params[:q][:s] == 'average_rating desc'
      @articles = @articles.sort_by { |article| article.average_rating || 3.5 }.reverse
    else
      @articles = @articles.order(created_at: :desc)
    end
  end

  def show
    @article = Article.find(params[:id])
    @average_rating = @article.ratings.average(:score)
    @user_rating = @article.ratings.find_by(user: current_user)
    @comments = @article.comments.includes(:likes).sort_by { |comment| comment.likes.count }.reverse
  end

  def new
    @article = Article.new
  end
  
  def edit
    @article = Article.find(params[:id])
  end

  def update
    @article = Article.find(params[:id])

    create_or_delete_articles_tags(@article, params[:article][:tags],)

    if @article.update(article_params.except(:tags))
      redirect_to @article
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def create
    @article = Article.new(article_params.except(:tags))

    create_or_delete_articles_tags(@article, params[:article][:tags],)

    if @article.save
      redirect_to @article
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  def destroy
    @article = Article.find(params[:id])
    if @article.destroy
      flash[:success] = "Article was successfully deleted."
      redirect_to articles_path
    else
      flash[:error] = "There was an error deleting the article."
      redirect_to @article
    end
  end

  private
    def article_params
      params.require(:article).permit(:title, :body, :year, :status, :tags, :Oid)
    end

    def create_or_delete_articles_tags(article, tags)
      article.taggables.destroy_all
      tags = tags.strip.split('|')
      tags.each do |tag|
        article.tags << Tag.find_or_create_by(name: tag)
      end
    end
end
