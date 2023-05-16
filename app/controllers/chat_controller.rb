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
  generate_image = params[:generate_image] == "1"
  save_conversation = params[:save_conversation] == "1"
  uploaded_file = params[:document]

  if user_input.present?
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
    else
 

    # Get the AI response
      conversation_history = session[:conversation_history].map { |msg| "#{msg[:role]}: #{msg[:text]}" }.join("\n")
      api_key = ENV['MY_API_KEY']

      response = HTTParty.post('https://api.anthropic.com/v1/complete',
                        headers: {
                          'x-api-key' => api_key,
                          'content-type' => 'application/json'
                        },
                        body: {
                          prompt: conversation_history.encode('UTF-8', invalid: :replace, undef: :replace, replace: '') + "\n\nHuman: #{user_input.encode('UTF-8', invalid: :replace, undef: :replace, replace: '')}\n\nAssistant: ",
                          model: "claude-v1",
                          max_tokens_to_sample: 2000,
                          stop_sequences: ["\n\nHuman:"]
                        }.to_json)

      if response['completion']
        assistant_response = response['completion']
        session[:conversation_history] << { role: 'Assistant', text: assistant_response }
        session[:assistant_response] = assistant_response
      else
        session[:assistant_response] = "Error: Couldn't get a response from Claude. Please try again later."
      end

      # Reset the generated_image_url
      session[:generated_images_base64] = nil
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
  session[:generated_image_urls] = []
  session[:assistant_response] = nil  # add this line

  image_urls = session.delete(:generated_image_urls) || []
  image_urls.each do |image_url|
    begin
      File.delete(Rails.root.join('public', image_url))
    rescue => e
      puts "Error deleting file #{image_url}: #{e.message}"
    end
  end

  redirect_to chat_index_path
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

