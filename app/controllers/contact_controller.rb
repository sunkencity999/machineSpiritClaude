class ContactController < ApplicationController
  def index
  end

  def create
    ContactMailer.send_contact_email(params[:name], params[:email], params[:message]).deliver_now
    redirect_to contact_path, notice: 'Your message was sent successfully.'
  end
end

