class Notifications < ActionMailer::Base

  def forgot_password(recipient, new_pass)
    @subject    = 'Boomy.cz: Zapomenuté heslo'
    @body       = {:user => recipient, :new_pass => new_pass}
    @recipients = recipient.email
    @from       = 'no-reply@boomy.cz'
    @sent_on    = Time.now
    @headers    = {}
  end
  
end
