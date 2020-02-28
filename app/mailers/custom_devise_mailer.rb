class CustomDeviseMailer < Devise::Mailer
  helper :mailer
  include Devise::Controllers::UrlHelpers # Optional. eg. `confirmation_url`
  default template_path: 'devise/mailer' # to make sure that your mailer uses the devise viewsCustomDeviseMailer
end
