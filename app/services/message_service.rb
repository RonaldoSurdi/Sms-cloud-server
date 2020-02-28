class MessageService
  ZENVIA_CALLBACK_TYPES = {
    none: 0,
    final_status: 1,
    all_statuses: 2
  }

  ZENVIA_STATUSES = {
    '100' => :message_queued,
    '110' => :message_sent_to_operator,
    '111' => :message_reception_unavailable,
    '120' => :message_received_by_mobile,
    '140' => :mobile_number_not_covered,
    '145' => :mobile_number_inactive,
    '150' => :message_expired_in_operator,
    '160' => :operator_network_error,
    '161' => :message_rejected_by_operator,
    '162' => :message_cancelled_or_blocked_by_operator,
    '170' => :bad_message,
    '171' => :bad_number,
    '130' => :message_blocked,
    '131' => :message_blocked_by_predictive_cleansing,
    '141' => :international_sending_not_allowed,
    '180' => :message_id_not_found,
    '190' => :unknown_error,
    '900' => :authentication_error,
    '990' => :account_limit_reached,
    '998' => :wrong_operation_requested,
    '999' => :unknown_error
  }

  def self.send
    puts "#{Time.zone.now} Enviando SMS's"
    if Rails.env.production?
      Message.prepare_to_send!.map do |delivery|
        sms = Zenvia::SMS.new(id: delivery.uuid, to: "55#{delivery.to.gsub(/^0/, '')}", message: delivery.message, callback: ZENVIA_CALLBACK_TYPES[:all_statuses])

        begin
          delivery.schedule.present? ? sms.schedule(delivery.schedule) : sms.deliver
        rescue => exception
          puts "====> Error when sending Message #{delivery.uuid}"
          puts exception.inspect
          delivery.update! status: MessageStatus::ERROR
        end
      end
    end
  end

  def self.resend_with_error
    puts "Verificando mensagens com problemas"

    Message.transaction do
      Message.messages_with_possible_problem.each do |message|
        message.update! status: MessageStatus::PENDING
      end
    end
  end

  def self.create_for_birthdays
    Customer.transaction do
      scope = Customer
                .to_send_for_birthdays
                .contacts_in_birthday
                .joins(:configuration, :contacts)
                .includes(:configuration, :contacts)
                .references(:all)

      scope.find_each(batch_size: 50) do |customer|
        params = {
          message: customer.configuration.text_birthdays,
          cellphones: customer.contacts.collect(&:celular),
          contatos_nomes: customer.contacts.collect(&:nome)
        }

        customer.messages.build.generate_for(params, customer.saldo_sms)
      end
    end
  end

  def self.set_status(zenvia_message)
    status = ZENVIA_STATUSES[zenvia_message[:status]]
    message = Message.find_by!(uuid: zenvia_message[:id])

    return if message.status == MessageStatus::SUCCESS

    if [:message_received_by_mobile, :message_reception_unavailable].include?(status)
      message.update! status: MessageStatus::SUCCESS
    elsif ![:message_queued, :message_sent_to_operator].include?(status)
      message.update! status: MessageStatus::ERROR
    end
  end
end
