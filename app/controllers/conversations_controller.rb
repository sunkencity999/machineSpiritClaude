class ConversationsController < ApplicationController
  before_action :authenticate_user!

  def destroy
  @conversation = Conversation.find(params[:id])
  if @conversation.user == current_user
    @conversation.destroy
    flash[:notice] = "Conversation deleted successfully."
  else
    flash[:alert] = "You are not authorized to delete this conversation."
  end
  redirect_to root_path
end




end

