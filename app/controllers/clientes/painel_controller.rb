class Clientes::PainelController < Clientes::BaseController

  respond_to :html, :json

  def index
    @transacao = current_customer.messages
                  .agrouped_by_message_group
                  .preparing_to_send_or_sending
                  .order("data_criacao ASC")
                  .limit(1)[0]

    if @transacao.present?
      @mensagem_texto = current_customer.messages
                          .find_by(message_group_id: @transacao.grupo)
                          .message
    end

    respond_with [@transacao, @mensagem_texto]
  end
end
