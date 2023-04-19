class EmailsController < ApplicationController

  def send_prompt_response
    user = User.find(params[:user_id])
    ClaudeMailer.prompt_response_email(user).deliver_now
    flash[:notice] = "Email Sent Successfully!"
    redirect_to root_path, notice: "Prompt response sent!"
  end



end
