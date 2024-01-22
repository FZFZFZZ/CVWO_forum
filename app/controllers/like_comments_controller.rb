class LikeCommentsController < ApplicationController
  def create
    comment = Comment.find(params[:comment_id])
    like = comment.like_comments.build(user: current_user)

    if !like.save
      flash[:notice] = @like.errors.full_messages.to_sentence
    end

    redirect_back(fallback_location: articles_url)
  end

  def destroy
    like = current_user.like_comments.find(params[:id])
    like.destroy
    redirect_to article_path(like.comment.article)
  end
end