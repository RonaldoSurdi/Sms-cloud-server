class Clientes::RelatoriosController < Clientes::BaseController

  before_action :filters, only: [:index]

  def index
    @mensagens_agrupadas = current_customer.messages
                            .agrouped_by_message_group
                            .per_month_and_year_of_message_group(@month_filter, @year_filter)
                            .order("data_criacao DESC")
  end

  def show
    @transacao = current_customer.messages
                  .agrouped_by_message_group
                  .find_by(message_group_id: params[:id])

    respond_to do |format|

      format.json {
        render json: @transacao
      }

      format.html {
        @mensagens = current_customer.messages
                      .where(message_group: @transacao.grupo)
      }
    end
  end

  private

  def filters
    if params[:date] || (get_controller_config(:month_filter) && get_controller_config(:year_filter))
      @month_filter = params[:date].try(:[], :month) || get_controller_config(:month_filter)
      @year_filter = params[:date].try(:[], :year) || get_controller_config(:year_filter)

      store_controller_config(:month_filter, @month_filter)
      store_controller_config(:year_filter, @year_filter)
    end
  end
end
