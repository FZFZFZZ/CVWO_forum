class ArticlesController < ApplicationController
  before_action :check_admin, only: [:new, :destroy, :create]
  require 'net/http'

  def index
    # Ransack search initialization
    @q = Article.ransack(params[:q])
    articles_query = @q.result(distinct: true)
    
    if params.dig(:q, :title_cont)
      search_terms = params[:q][:title_cont].downcase
      articles_query = articles_query.where(Article.arel_table[:title].lower.matches("%#{search_terms}%"))
    end
  
    # Apply sorting
    if params[:q] && params[:q][:s].present? && params[:q][:s].include?('average_rating')
      articles_query = sort_by_average_rating(articles_query, params[:q][:s])
    else
      articles_query = articles_query.order(created_at: :desc)
    end
  
    # Apply pagination with kaminari
    @articles = articles_query.page(params[:page]).per(30)
  end

  
  def show

    # Refresh the movie page once after entering. 
    # This is for tackling with an unknown bug, which causes REACT component not showing up unless refreshed.
    # So sorry that I tried my best to solve the bug but failed. It may due to some imcompatiability issue of REACT, TS, JS and so on.
    # unless session[:page_refreshed]
    # session[:page_refreshed] = true
    # else
    # Clear the flag after the initial reload
    # session.delete(:page_refreshed)
    # end

    # Define Variables
    @article = Article.find(params[:id])
    @average_rating = @article.ratings.average(:score)
    @user_rating = @article.ratings.find_by(user: current_user)

    @sort_order = params[:sort_order] == 'newest_first' ? 'newest_first' : 'likes'
  
    if @sort_order == 'newest_first'
      @comments = @article.comments.order(created_at: :desc)
    else
      @comments = @article.comments.includes(:like_comments)
                            .sort_by { |comment| -comment.like_comments.count }
    end

    @search = @article.title.gsub(" ", "%20")

    #initialise info searching on TMDB#
    @movie_data, @poster_url = fetch_movie_data_and_poster(@article.title)
    unless @movie_data
      flash[:alert] = 'Movie data not found on TMDB.'
    end

    data = [
      @article.ratings.where(score: 0.0...1.0).count,
      @article.ratings.where(score: 1.0...2.0).count,
      @article.ratings.where(score: 2.0...3.0).count,
      @article.ratings.where(score: 3.0...4.0).count,
      @article.ratings.where(score: 4.0...5.01).count
    ]

    @chart_data = data

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



    def fetch_movie_data_and_poster(movie_title)

      api_key = '02b5038b15929363b9e32356dc01dad8'
      search_url = URI("https://api.themoviedb.org/3/search/movie?query=#{CGI.escape(movie_title)}&api_key=#{api_key}")
      search_response = Net::HTTP.get(search_url)
      search_result = JSON.parse(search_response)
  
      if search_result['results'].present?
        movie_id = search_result['results'].first['id']
  
        details_url = URI("https://api.themoviedb.org/3/movie/#{movie_id}?api_key=#{api_key}")
        details_response = Net::HTTP.get(details_url)
        movie_data = JSON.parse(details_response)
  
        poster_url = fetch_movie_poster_url(movie_data['poster_path'])
        return movie_data, poster_url
      else
        return nil, nil
      end

    end



    def fetch_movie_poster_url(poster_path)
  
      return "https://image.tmdb.org/t/p/original#{poster_path}" if poster_path.present?
  
    end



    def article_params

      params.require(:article).permit(:title, :body, :year, :status, :tags)

    end



    def create_or_delete_articles_tags(article, tags)

      article.taggables.destroy_all
      tags = tags.to_s.strip.split('|')

      tags.each do |tag|
        article.tags << Tag.find_or_create_by(name: tag)
      end

    end



    def check_admin

      unless admin_user?
        flash[:alert] = "You are not authorized to access this page."
        redirect_to articles_path
      end

    end



    def sort_by_average_rating(query, sort_order)
      direction = sort_order == 'average_rating asc' ? 'ASC' : 'DESC'
      query.joins('LEFT JOIN ratings ON ratings.article_id = articles.id')
           .group('articles.id')
           .select('articles.*, COALESCE(AVG(ratings.score), 3.5) as computed_avg_rating')
           .order("computed_avg_rating #{direction}")
    end


    
end
