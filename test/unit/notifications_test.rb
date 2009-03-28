require File.dirname(__FILE__) + '/../test_helper'

class NotificationsTest < Test::Unit::TestCase
  FIXTURES_PATH = File.dirname(__FILE__) + '/../fixtures'
  CHARSET = "utf-8"

  include ActionMailer::Quoting
  
  help_testing User, :nick => "john", :email => "john@nekde.cz", :password => "passsword",
    :password_confirmation => "passsword"  

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []

    @expected = TMail::Mail.new
    @expected.set_content_type "text", "plain", { "charset" => CHARSET }
    @expected.mime_version = '1.0'
  end

  def test_forgot_password
    @user = create_user
    @expected.subject = 'Boomy.cz: Zapomenuté heslo'
    @expected.from    = 'no-reply@boomy.cz'
    @expected.body    = read_fixture('forgot_password')
    @expected.date    = Time.now

    assert_equal @expected.body, Notifications.create_forgot_password(@user, "nove_heslo").body
  end

  private
    def read_fixture(action)
      IO.readlines("#{FIXTURES_PATH}/notifications/#{action}")
    end

    def encode(subject)
      quoted_printable(subject, CHARSET)
    end
end
