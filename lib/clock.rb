require 'clockwork'
include Clockwork

every(1.minute, "Enviando Mensagens") {
  Dir.chdir ENV['APP_ROOT'] if ENV['APP_ROOT'].present?
  `rake messages:resend_with_error`
  `rake messages:send`
}

every(1.day, "Enviando mensagens de aniversário", at: '11:30') {
  Dir.chdir ENV['APP_ROOT'] if ENV['APP_ROOT'].present?
  `rake messages:create_for_birthdays`
}
