class ChatController < ApplicationController
  
  def index
  session[:conversation_history] ||= []
  @conversation_history = session[:conversation_history].reject { |msg| msg[:role].nil? || msg[:text].nil? }
  @assistant_response = session[:assistant_response]
end

  def ask
  session[:conversation_history] ||= []
  user_input = params[:user_input]

  conversation_history = session[:conversation_history].map { |msg| "#{msg[:role]}: #{msg[:text]}" }.join("\n")

  api_key = ENV['MY_API_KEY']
  prompt = params[:user_input]

  response = HTTParty.post('https://api.anthropic.com/v1/complete',
                            headers: {
                              'x-api-key' => api_key,
                              'content-type' => 'application/json'
                            },
                            body: {
                              prompt: conversation_history + "\n\nHuman: #{prompt}\n\nAssistant: ",
                              model: "claude-v1",
                              max_tokens_to_sample: 300,
                              stop_sequences: ["\n\nHuman:"]
                            }.to_json)

  if response['completion']
    assistant_response = response['completion']
    p "Before adding messages:"
    p session[:conversation_history]
    session[:conversation_history] << { role: 'User', text: prompt }
    session[:conversation_history] << { role: 'Assistant', text: assistant_response }
    p "After adding messages:"
    p session[:conversation_history]
  else
    assistant_response = "Error: Couldn't get a response from Claude. Please try again later."
  end

  session[:assistant_response] = assistant_response
  redirect_to root_path
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


end
