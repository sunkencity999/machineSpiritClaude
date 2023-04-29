class TextToSpeechController < ApplicationController
  ## protect_from_forgery with: :null_session, if: -> { request.format.json? }
  ## skip_before_action :verify_authenticity_token
  require 'net/http'
  require 'uri'

  def create
  Rails.logger.debug "Request Params: #{params.inspect}"
  text = text_to_speech_params[:text]
  voice_id = text_to_speech_params[:voice_id]
  api_key = ENV['ELEVENLABS_API_KEY']

  uri = URI.parse("https://api.elevenlabs.io/v1/text-to-speech/#{voice_id}")
  request = Net::HTTP::Post.new(uri)
  request['xi-api-key'] = api_key
  request['Content-Type'] = 'application/json'
  request.body = { text: text }.to_json

  response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') do |http|
    http.request(request)
  end

  if response.code == "200"
    send_data response.body, type: 'audio/mpeg', disposition: 'inline'
  else
    Rails.logger.debug "API Error Response: #{response.inspect}"
    Rails.logger.debug "API Error Response Body: #{response.body}"
    render json: { error: 'Failed to request audio from Eleven Labs API.' }, status: :unprocessable_entity
  end
end


  def api_key
    render json: { api_key: ENV['ELEVENLABS_API_KEY'] }
  end


  private

 
  def text_to_speech_params
    params.permit(:text, :voice_id)
  end

end

