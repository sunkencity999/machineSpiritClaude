class ContactMailer < ApplicationMailer
  default from: 'daemon@machinespiritcloud.com'

  def send_contact_email(name, email, message)
    @name = name
    @email = email
    @message = message

    mail(to: 'ai@machinespiritclaude.com', subject: 'New Contact Message')
  end
end
