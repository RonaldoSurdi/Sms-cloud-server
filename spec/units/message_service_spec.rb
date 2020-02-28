require 'rails_helper'

RSpec.describe MessageService, type: :unit do
  describe ".create_for_birthdays" do
    it "deve gerar mensagens para os clientes aniversariantes uma vez por dia" do
      2.times do
        create :customer,
          configuration: create(:configuration, send_birthdays: true, text_birthdays: 'Hi!'),
          contacts: [create(:contact, nascimento: '09/04/2017'.in_time_zone), create(:contact, nascimento: '08/04/2017'.in_time_zone)]
      end

      create(:sold_license_movement, :com_movimentacao_de_planos, validade_inicio: '09/04/2017'.in_time_zone)
        .customer
        .update configuration: create(:configuration, send_birthdays: true, text_birthdays: 'Hi!'),
        contacts: [create(:contact, nascimento: '09/04/2017'.in_time_zone), create(:contact, nascimento: '08/04/2017'.in_time_zone)]

      Customer.last.current_plan_movements.first.update! quantidade_sms: 1

      Timecop.travel('09/04/2017'.in_time_zone.change(hour: 7)) { MessageService.create_for_birthdays }
      Timecop.travel('09/04/2017'.in_time_zone.change(hour: 8)) { MessageService.create_for_birthdays }

      expect(Message.count).to eq 1
    end
  end
end
