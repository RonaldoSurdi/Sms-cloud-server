class Message < ActiveRecord::Base
  extend EnumerateIt
  include Formatador

  MAX_ATTEMPTS_LIMIT = 10
  MAX_ATTEMPTS = 3
  MAX_PERCENT = 100
  MAX_MINUTES_IN_SENDING = 60
  MAX_CHARACTERES = 152
  CHART_PERIODS = { six_months: 0, thirty_days: 1 }

  before_update :check_attempts
  before_save :default_values
  before_create :generate_uuid

  has_enumeration_for :status, with: MessageStatus, create_helpers: true
  has_enumeration_for :message_type, with: MessageType, create_helpers: true

  belongs_to :customer
  belongs_to :message_group

  validates :message, presence: true
  validate :validate_phone
  validates :to, presence: true, if: :sent?

  scope :to_send, -> {
    where(status: MessageStatus::PENDING, message_type: MessageType::SENT)
  }

  scope :messages_with_possible_problem, -> {
    where(message_type: MessageType::SENT)
      .where("status = :pending Or status = :sending", sending: MessageStatus::SENDING, pending: MessageStatus::PENDING)
      .where("schedule Is Null Or schedule < ?", DateTime.current)
      .where("updated_at < ?", DateTime.current - MAX_MINUTES_IN_SENDING.minutes)
  }

  scope :per_range_date_sent, -> (start_date, end_date) {
    where("(date_time_sent Between :start_date And :end_date And status = :success) Or (status = :sending Or status = :pending)",
            start_date:   start_date.at_beginning_of_day,
              end_date:   end_date.at_end_of_day,
               success:   MessageStatus::SUCCESS,
               sending:   MessageStatus::SENDING,
               pending:   MessageStatus::PENDING)
  }

  scope :agrouped_by_message_group, -> {
    select("message_group_id AS grupo,
            COUNT(*) AS quantidade_total,
            message_groups.created_at AS data_criacao,
            (SELECT COUNT(*) FROM messages AS m WHERE m.message_group_id = messages.message_group_id AND m.status = #{MessageStatus::PENDING}) AS quantidade_pendente,
            (SELECT COUNT(*) FROM messages AS m WHERE m.message_group_id = messages.message_group_id AND m.status = #{MessageStatus::SENDING}) AS quantidade_enviando,
            (SELECT COUNT(*) FROM messages AS m WHERE m.message_group_id = messages.message_group_id AND m.status = #{MessageStatus::SUCCESS}) AS quantidade_sucesso,
            (SELECT COUNT(*) FROM messages AS m WHERE m.message_group_id = messages.message_group_id AND m.status = #{MessageStatus::ERROR}) AS quantidade_erro,
            (SELECT COUNT(*) FROM messages AS m WHERE m.message_group_id = messages.message_group_id AND
              (m.status = #{MessageStatus::SUCCESS} Or (status = #{MessageStatus::ERROR} AND attempts >= #{Message::MAX_ATTEMPTS}))) AS quantidade_enviado,
            (SELECT COUNT(*) FROM messages AS m WHERE m.message_group_id = messages.message_group_id) AS quantidade_total")
    .joins(:message_group)
    .group("message_group_id, message_groups.created_at")
  }

  scope :preparing_to_send_or_sending, -> {
    where("messages.status = :sending Or (messages.status = :pending And schedule Is Null)",
      pending: MessageStatus::PENDING, sending: MessageStatus::SENDING)
  }

  scope :per_month_and_year_of_message_group, -> (month = nil, year = nil) {
    where("EXTRACT(MONTH FROM message_groups.created_at) = :month AND
            EXTRACT(YEAR FROM message_groups.created_at) = :year",
            month: month || Date.today.month, year: year || Date.today.year)
  }

  def to=(to)
    write_attribute(:to, to ? to.gsub(/[^+\d]/,"") : to)
  end

  def from=(from)
    write_attribute(:from, from ? from.gsub(/[^+\d]/,"") : from)
  end

  def formatted_to
    formatar_telefone self.to
  end

  def status_key
    MessageStatus.key_for(status).to_s.upcase
  end

  def self.prepare_to_send!
    Message.transaction do
      cache_balances = {}
      messages_to_send = []
      Message.to_send.find_each do |message|
        if Message.pre_process_schedule_message(message, cache_balances)
          if message.schedule.blank? || message.schedule <= DateTime.current
            message.update! status: MessageStatus::SENDING
          else
            message.status_will_change!
          end

          messages_to_send << message
        else
          Rails.logger.info "Saldo insuficiente para envio de SMS, customer_id #{message.customer_id}"
          message.update! status: MessageStatus::ERROR, attempts: MAX_ATTEMPTS_LIMIT
        end
      end

      messages_to_send
    end
  end

  def generate_for(params, saldo)
    self.assign_attributes status: MessageStatus::PENDING,
                            message_type: MessageType::SENT,
                            message: params[:message]

    scheduled = params[:agendamento].try(:to_bool)

    if scheduled
      date = params["schedule(3i)"] + '/' + params["schedule(2i)"] + '/' + params["schedule(1i)"]
      time = params["schedule(4i)"] + ':' + params["schedule(5i)"]
      datetime = Time.zone.parse(date + " " + time)

      if datetime.past?
        scheduled = false
      else
        self.schedule = datetime
      end
    end

    if scheduled || saldo >= params[:cellphones].size
      Message.transaction do
        self.message_group = MessageGroup.create!

        params[:cellphones].each_with_index do |cellphone, i|
          nome = params[:contatos_nomes].try(:[], i).blank? ? nil : params[:contatos_nomes][i]

          new_message = self.dup
          new_message.assign_attributes to: cellphone, contato_nome: nome
          new_message.save!
        end
      end
    else
      false
    end
  end

  def porcentagem_enviados
    if self.try(:quantidade_total) && self.try(:quantidade_enviado)
      ((Message::MAX_PERCENT * self.quantidade_enviado) / self.quantidade_total).floor
    end
  end

  private

  def default_values
    self.status ||= MessageStatus::PENDING
    self.message_type ||= MessageType::SENT
  end

  def validate_phone
    errors.add(:to, "Telefone inválido") if !self.to.blank? && self.to.length < 10
    errors.add(:from, "Telefone inválido") if !self.from.blank? && self.from.length < 10
  end

  def check_attempts
    if self.error?
      self.attempts = self.attempts.to_i + 1
      self.status = MessageStatus::PENDING if self.attempts < MAX_ATTEMPTS
    end
    self.date_time_sent = DateTime.current if self.success?
  end

  def generate_uuid
    begin
      self.uuid = SecureRandom.uuid
    end while self.class.where(uuid: self.uuid).exists?
  end

  def self.pre_process_schedule_message(message, cache_balances)
    return true unless message.schedule?

    cache_balances[message.customer_id] ||= message.customer.saldo_sms
    cache_balances[message.customer_id] -= 1

    cache_balances[message.customer_id] >= 0
  end
end
