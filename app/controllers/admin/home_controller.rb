class Admin::HomeController < Admin::BaseController
  skip_load_and_authorize_resource
  before_action :set_period, only: [:index]

  respond_to :html, :json

  def index
    @contagem_mensagens = MessageChartService.new(@period).exec
    respond_with(@contagem_mensagens)
  end

  private

  def set_period
    @period = (params[:periodo].to_i == Message::CHART_PERIODS[:six_months]) ? 5.months.ago.at_beginning_of_month : 29.days.ago.at_beginning_of_day
  end
end
