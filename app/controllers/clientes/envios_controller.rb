class Clientes::EnviosController < Clientes::BaseController

  skip_before_action :verify_authenticity_token, only: [:create]
  before_action :initialize_action_new, only: [:new]

  def create
    customer = current_customer

    if customer.messages.build.generate_for(envio_params, customer.saldo_sms)
      respond_to do |format|
        format.html {
          mensagem = envio_params[:agendamento].to_bool ? "Suas mensagens foram agendadas!" : "Suas mensagens foram criadas e em breve serão enviadas!"
          redirect_to painel_index_path, notice: mensagem
        }

        format.json { render json: "Mensagem cadastrada e em breve será enviada!" }
      end
    else
      respond_to do |format|
        format.html {
          initialize_action_new
          flash[:alert] = "Erro ao criar/agendar mensagens."
          render :new
        }

        format.json { render json: "Erro ao criar mensagem." }
      end
    end
  end

  private
    def envio_params
      params.require(:message).permit(:message, :schedule, :agendamento, cellphones: [], contatos_nomes: [])
    end

    def initialize_action_new
      @mensagem = Message.new
      @grupos = current_customer.contact_groups
      @meses = Date::MONTHNAMES.collect {|v| [v, Date::MONTHNAMES.index(v)] }[1, 12]
    end
end
