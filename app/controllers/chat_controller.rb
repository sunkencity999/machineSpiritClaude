class ChatController < ApplicationController
  before_action :authenticate_user!, only: [:create]

  def index
  @conversations = current_user.conversations if user_signed_in?
  @conversation = Conversation.new
  session[:conversation_history] ||= []
  if user_signed_in? && @conversations.present?
    # Load the last conversation from the database into the session
    last_conversation = @conversations.last
    session[:conversation_history] << { role: current_user.id, text: last_conversation.prompt }
    session[:conversation_history] << { role: 'Assistant', text: last_conversation.response }
  end
  @conversation_history = session[:conversation_history].reject { |msg| msg[:role].nil? || msg[:text].nil? }
  @assistant_response = session[:assistant_response]
  @user = current_user
  end
  

   def save_base64_images_to_files(base64_images)
    base64_images.each_with_index.map do |base64_image, index|
      save_image_to_disk(base64_image, index)
    end
  end

 def save_image_to_disk(base64_image, index)
  file_name = "generated_image_#{index}_#{Time.now.to_i}.png"

  # Ensure the directory exists
  dir_path = Rails.root.join('public', 'generated_images')
  Dir.mkdir(dir_path) unless Dir.exist?(dir_path)

  # Now we can save the image
   file_path = Rails.root.join('public', 'generated_images', file_name)

  File.open(file_path, 'wb') do |file|
    file.write(Base64.decode64(base64_image))
  end

  file_name
end
 
    def ask
  session[:conversation_history] ||= []
  user_input = params[:text]
  generate_image = params[:generate_image] == "1"
  save_conversation = params[:save_conversation] == "1"
  uploaded_file = params[:document]

  if user_input.present?
    # Handling uploaded file
    if uploaded_file.present?
      file_content = extract_text_from_file(uploaded_file.path)
      user_input = user_input + "\n\n" + file_content
    end

    # Add the user's message to the history
    session[:conversation_history] << { role: user_signed_in? ? current_user.id : "User", text: user_input }

    if generate_image
      base64_images = request_images_from_stable_diffusion(user_input)

      if base64_images
        file_paths = save_base64_images_to_files(base64_images).map { |path| "/generated_images/#{path}" }
        session[:generated_image_urls] = file_paths
        assistant_response = "Here are the images you requested."
      else
        session[:generated_image_urls] = nil
        assistant_response = "Error: Couldn't generate images. Please try again later."
      end

      session[:conversation_history] << { role: 'Assistant', text: assistant_response }
      session[:assistant_response] = assistant_response

      # Reset the generated_image_url
      session[:generated_images_base64] = nil
    else
       
    # Get the AI response
    api_key = ENV['OPENAI_API_KEY']

    # Build the conversation history for the chat models
    messages = session[:conversation_history].map do |msg|
     { 'role' => msg[:role] == "User" ? 'user' : 'assistant', 'content' => msg[:text] }      
    end
    messages << { 'role' => 'user', 'content' => user_input }
    
    subject_expert_mode = params[:subjectExpertMode] == "true"
    creative_mode = params[:creativeMode] == "true"

    temperature = 0.7 # default value, balanced responses
    if subject_expert_mode
      temperature = 0.02 # strict, authoritative responses like a subject matter expert
    elsif creative_mode
      temperature = 1.8 # creative responses, with a fair amount of chaos
    end

    response = HTTParty.post('https://api.openai.com/v1/chat/completions',
      headers: {
        'Authorization' => "Bearer #{api_key}",
        'Content-Type' => 'application/json'
      },
      body: {
        'model' => 'gpt-3.5-turbo',
        'messages' => messages,
        'temperature' => temperature,
        'max_tokens' => 3000,
      }.to_json)

    if response.parsed_response['choices']
      assistant_response = response.parsed_response['choices'][0]['message']['content'].strip
      session[:conversation_history] << { role: 'Assistant', text: assistant_response }
      session[:assistant_response] = assistant_response
    else
      session[:assistant_response] = "Error: Couldn't get a response from the Assistant. Please try again later."
    end

    # Reset the generated_image_url
    session[:generated_image_urls] = nil
  end

  redirect_to chat_index_path
end

  def delete_thread
  session[:conversation_history] = []
  session[:generated_image_urls] = []
  session[:assistant_response] = nil
  Rails.logger.info("Session variables after reset: #{session.inspect}")

  @user = current_user
  @conversation = @user.conversations.last
  @conversation.destroy if @conversation

  image_urls = session.delete(:generated_image_urls) || []
  image_urls.each do |image_url|
    begin
      File.delete(Rails.root.join('public', image_url))
    rescue => e
      Rails.logger.error("Error deleting file #{image_url}: #{e.message}")
    end
  end 
  current_user.conversations.destroy_all
  redirect_to chat_index_path, notice: 'Thread deleted.', turbolinks: [:replace, true]
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


  def extract_text_from_pdf(file)
  require 'pdf/reader'
  require 'rtesseract'

  text = ''
  PDF::Reader.open(file.path) do |reader|
    reader.pages.each do |page|
      if page.text.empty?
        image = page.to_image(format: 'png')
        ocr = RTesseract.new(image.path)
        extracted_text = ocr.to_s
      else
        extracted_text = page.text
      end
      text += extracted_text
      end
    end
    text
  end
  end

  private

  def conversation_params
  parsed_params = JSON.parse(params.require(:conversation))
  ActionController::Parameters.new(parsed_params).permit(:prompt, :response)
  end


def request_images_from_stable_diffusion(prompt)
  api_key = ENV['STABLE_API_KEY']
    response = HTTParty.post("https://api.stability.ai/v1/generation/stable-diffusion-v1-5/text-to-image",
                              headers: {
                                'Content-Type' => 'application/json',
                                'Accept' => 'application/json', # Change this line
                                'Authorization' => "Bearer #{api_key}"
                              },
                              body: {
                                height: 512,
                                width: 512,
                                text_prompts: [{ text: prompt }],
                                samples: 4,
                                steps: 50
                              }.to_json)


    if response.code == 200
    json_response = JSON.parse(response.body)
    if json_response["artifacts"]
    base64_images = json_response["artifacts"].map { |img| img["base64"] }
    puts "Received images: #{base64_images}"
    return base64_images
    else
    puts "Error: Images not found in the JSON response"
    return []
    end
    else
    puts "Error: Request failed with code #{response.code}"
    return []
    end
  end
end


