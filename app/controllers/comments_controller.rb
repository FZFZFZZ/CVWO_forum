class CommentsController < ApplicationController

  def show
    @comment = Comment.find(params[:id])
  end

  def create
    @article = Article.find(params[:article_id])
    @comment = @article.comments.new(comment_params)
    @comment.user = current_user

    if @comment.save
      redirect_to article_path(@article)
    else
    end
  end

  def update
    @article = Article.find(params[:article_id])  # Find the parent article
    @comment = @article.comments.find(params[:id]) # Find the comment
  
    if @comment.user == current_user
      if @comment.update(comment_params)
        redirect_to article_path(@comment.article), notice: 'Comment was successfully updated.'
      else
        render :edit
      end
    else
      redirect_to article_path(@article), alert: 'You can only edit your own comments.', status: :forbidden
    end
  end

  def edit
    @article = Article.find(params[:article_id])
    @comment = @article.comments.find(params[:id])
  end

  def destroy
    @article = Article.find(params[:article_id])
    @comment = @article.comments.find(params[:id])

    if @comment.user == current_user
      @comment.destroy
      redirect_to article_path(@article), notice: 'Comment was successfully deleted.', status: :see_other
    else
      redirect_to article_path(@article), alert: 'You can only delete your own comments.', status: :forbidden
    end
  end

  private
    def comment_params
      params.require(:comment).permit(:commenter, :body, :status)
    end


end
