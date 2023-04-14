module ApplicationHelper

  def bootstrap_alert_class_for(type)
  case type.to_sym
  when :notice, :success
    "alert-success"
  when :alert, :error, :danger
    "alert-danger"
  when :warning
    "alert-warning"
  else
    "alert-info"
  end
end


end
