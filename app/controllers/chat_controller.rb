class ChatController < ApplicationController
 before_action :authenticate_user!, only: [:create]

  def index
    @conversations = current_user.conversations if user_signed_in?
    @conversation = Conversation.new 
    session[:conversation_history] ||= []
    @conversation_history = session[:conversation_history].reject { |msg| msg[:role].nil? || msg[:text].nil? }
    @assistant_response = session[:assistant_response]  
    @user = current_user

  end
  
  def ask
  session[:conversation_history] ||= []
  user_input = params[:text]
  save_conversation = params[:save_conversation] == "1"

  if user_input.present?
    # Add the user's message to the history
    session[:conversation_history] << { role: "user", text: user_input }

    # Get the AI response
    conversation_history = session[:conversation_history].map { |msg| "#{msg[:role]}: #{msg[:text]}" }.join("\n")
    api_key = ENV['MY_API_KEY']
    response = HTTParty.post('https://api.anthropic.com/v1/complete',
                              headers: {
                                'x-api-key' => api_key,
                                'content-type' => 'application/json'
                              },
                              body: {
                                prompt: conversation_history + "\n\nHuman: #{user_input}\n\nAssistant: ",
                                model: "claude-v1",
                                max_tokens_to_sample: 300,
                                stop_sequences: ["\n\nHuman:"]
                              }.to_json)

    if response['completion']
      assistant_response = response['completion']
      session[:conversation_history] << { role: 'Assistant', text: assistant_response }
      session[:assistant_response] = assistant_response
    else
      session[:assistant_response] = "Error: Couldn't get a response from Claude. Please try again later."
    end

    # Save the conversation if the user is signed in and save_conversation is true
    if user_signed_in? && save_conversation
      @conversation = current_user.conversations.build(prompt: user_input, response: assistant_response)
      if @conversation.save
        flash[:notice] = "Conversation saved successfully"
      else
        flash[:alert] = "Failed to save the conversation"
      end
    end
  end

  redirect_to chat_index_path
end
  

   def delete_thread
    session[:conversation_history] = []
    session[:assistant_response] = nil
    redirect_to root_path
  end

  def download_latest_response
  @latest_response = session[:conversation_history].last
  respond_to do |format|
    format.pdf do
      render pdf: "latest_response",
             template: "chat/latest_response",
             layout: 'pdf'
    end
  end
end

   private

  def conversation_params
  parsed_params = JSON.parse(params.require(:conversation))
  ActionController::Parameters.new(parsed_params).permit(:prompt, :response)
  end

end
