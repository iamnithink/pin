class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_tournament
  before_action :set_comment, only: [:update, :destroy]
  before_action :authorize_comment_action, only: [:update, :destroy]

  def create
    @comment = @tournament.comments.build(comment_params)
    @comment.user = current_user

    if @comment.save
      # Reload tournament with eager loaded comments to avoid N+1
      @tournament.reload
      @tournament = Tournament.includes(
        top_level_comments: { user: {}, replies: :user }
      ).find(@tournament.id)
      
      respond_to do |format|
        format.html { redirect_to tournament_path(@tournament.slug), notice: 'Comment added successfully.' }
        format.json { render json: { success: true, comment: comment_json(@comment) }, status: :created }
        format.turbo_stream { render :create, status: :created }
      end
    else
      respond_to do |format|
        format.html { redirect_to tournament_path(@tournament.slug), alert: @comment.errors.full_messages.join(', ') }
        format.json { render json: { success: false, errors: @comment.errors.full_messages }, status: :unprocessable_entity }
        format.turbo_stream { 
          form_id = @comment.parent_id.present? ? "reply-form-#{@comment.parent_id}" : 'comment-form'
          render turbo_stream: turbo_stream.replace(
            form_id, 
            partial: 'comments/form', 
            locals: { comment: @comment, tournament: @tournament }
          )
        }
      end
    end
  end

  def update
    if @comment.update(comment_params)
      # Reload comment with user association
      @comment.reload
      respond_to do |format|
        format.html { redirect_to tournament_path(@tournament.slug), notice: 'Comment updated successfully.' }
        format.json { render json: { success: true, comment: comment_json(@comment) } }
        format.turbo_stream { render :update, status: :ok }
      end
    else
      respond_to do |format|
        format.html { redirect_to tournament_path(@tournament.slug), alert: @comment.errors.full_messages.join(', ') }
        format.json { render json: { success: false, errors: @comment.errors.full_messages }, status: :unprocessable_entity }
        format.turbo_stream { 
          render turbo_stream: turbo_stream.replace(
            "comment-form-#{@comment.id}", 
            partial: 'comments/form', 
            locals: { comment: @comment, tournament: @tournament }
          )
        }
      end
    end
  end

  def destroy
    was_top_level = @comment.is_top_level?
    @comment.destroy
    @tournament.reload if was_top_level
    
    respond_to do |format|
      format.html { redirect_to tournament_path(@tournament.slug), notice: 'Comment deleted successfully.' }
      format.json { render json: { success: true, message: 'Comment deleted successfully.' } }
      format.turbo_stream { render :destroy, status: :ok }
    end
  end

  private

  def set_tournament
    @tournament = Tournament.friendly.find(params[:tournament_slug] || params[:tournament_id])
    authorize! :read, @tournament
  rescue ActiveRecord::RecordNotFound
    respond_to do |format|
      format.html { redirect_to root_path, alert: 'Tournament not found.' }
      format.turbo_stream { head :not_found }
      format.json { render json: { success: false, message: 'Tournament not found.' }, status: :not_found }
    end
  end

  def set_comment
    @comment = @tournament.comments.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    respond_to do |format|
      format.html { redirect_to tournament_path(@tournament.slug), alert: 'Comment not found.' }
      format.turbo_stream { head :not_found }
      format.json { render json: { success: false, message: 'Comment not found.' }, status: :not_found }
    end
  end

  def comment_params
    params.require(:comment).permit(:body, :parent_id)
  end

  def authorize_comment_action
    unless @comment.can_be_edited_by?(current_user) || @comment.can_be_deleted_by?(current_user)
      respond_to do |format|
        format.html { redirect_to tournament_path(@tournament.slug), alert: 'You do not have permission to perform this action.' }
        format.json { render json: { success: false, message: 'You do not have permission to perform this action.' }, status: :forbidden }
        format.turbo_stream { head :forbidden }
      end
    end
  end

  def comment_json(comment)
    {
      id: comment.id,
      body: comment.body,
      user: {
        id: comment.user.id,
        name: comment.user.name,
        email: comment.user.email
      },
      parent_id: comment.parent_id,
      created_at: comment.created_at,
      updated_at: comment.updated_at,
      is_reply: comment.is_reply?,
      can_edit: comment.can_be_edited_by?(current_user),
      can_delete: comment.can_be_deleted_by?(current_user)
    }
  end
end
