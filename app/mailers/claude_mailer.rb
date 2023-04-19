class ClaudeMailer < ApplicationMailer
  
  def welcome_email(user)
    @user = user
    mail(to: @user.email, subject: 'Welcome!')
  end


  def prompt_response_email(user)
    @user = user
    mail(to: @user.email, subject: 'Your Prompt Response')
  end



end
