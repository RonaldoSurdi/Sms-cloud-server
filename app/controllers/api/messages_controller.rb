class Api::MessagesController < Api::BaseController
  skip_before_action :restrict_access
  before_filter :set_message, only: [:show, :update]

  def index
    @messages = Message
      .where(status: params[:status].to_i)
      .order(:id)

    @messages = @messages.where(message_type: params[:message_type].to_i) if params[:message_type]
    @messages = @messages.where("created_at >= ?", params[:created_at].to_time) if params[:created_at]
    @messages = @messages.where(to: params[:to]) if params[:to]
    @messages = @messages.where("\"from\" like ?", "%#{params[:from]}%") if params[:from]

    if params[:status].to_i == MessageStatus::PENDING
      scope = @messages.dup
      @messages.to_a # Load Collection
      scope.update_all(status: MessageStatus::SENDING)
    end
  end

  def create
    @message = Message.new(message_params)

    if @message.save
      render :show, status: :created
    else
      render json: @message.errors, status: :unprocessable_entity
    end
  end

  def update
    if @message.update(message_params)
      render :show
    else
      render json: @message.errors, status: :unprocessable_entity
    end
  end

  def status
    puts "====> Setting message #{params[:id]} the status #{MessageService::ZENVIA_STATUSES[params[:status]]}"
    MessageService.set_status(params)
    render nothing: true
  end

  private

  def set_message
    @message = Message.find(params[:id])
  end

  def message_params
    params.require(:message).permit(:status, :to, :from, :schedule, :message, :id, :message_type)
  end
end
