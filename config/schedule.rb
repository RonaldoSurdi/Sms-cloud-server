#############################################################
### NÃO FUNCIONA NO HEROKU, DEVE SER UTILIZADO O CLOCK.rb ###
#############################################################

set :output, "log/cron_log.log"

every(1.minute, "Enviando Mensagens") do
  rake "messages:resend_with_error"
  rake "messages:send"
end

every(1.day, "Enviando mensagens de aniversário", at: "11:30") do
  rake "messages:create_for_birthdays"
end
