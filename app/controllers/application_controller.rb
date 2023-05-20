class ApplicationController < ActionController::Base

before_action :configure_permitted_parameters, if: :devise_controller?
before_action :show_loading_screen

protected

def configure_permitted_parameters
  devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
  devise_parameter_sanitizer.permit(:account_update, keys: [:name])
end


  private

  def show_loading_screen
    ActiveSupport::Notifications.subscribe(
      'action_controller.render_template.start',
      &method(:show_loading_screen_for_template)
    )
  end

  def show_loading_screen_for_template(_name, _start, _finish, _exception)
    # Show the loading screen
    render :partial => 'layouts/loadingscreen'
  end


end
