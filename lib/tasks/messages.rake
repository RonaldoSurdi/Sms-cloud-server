# encoding: utf-8

require "rake"

namespace "messages" do
  desc "Reenviar sms com problemas"
  task resend_with_error:  [:environment]  do
    MessageService.resend_with_error
  end

  desc "Enviar SMS"
  task send: [:environment] do
    MessageService.send
  end

  desc "Criar mensagens de aniversário"
  task create_for_birthdays: [:environment] do
    MessageService.create_for_birthdays
  end
end
