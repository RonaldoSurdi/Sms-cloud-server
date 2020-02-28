class MessageChartService
  LIMIT_DAYS_TO_DAYS_CHART = 30

  def initialize(start_date)
    @start_date = start_date
  end

  def start_date
    group_by_month? ? @start_date.at_beginning_of_month : @start_date.at_beginning_of_day
  end

  def group_by_month?
    @start_date.at_beginning_of_day < LIMIT_DAYS_TO_DAYS_CHART.days.ago.at_beginning_of_day
  end

  def format
    group_by_month? ? "'MM/YY'" : "'DD/MM'"
  end

  def exec
    Message.select("Count(Erro) As total_erro,
            Count(*) As total, To_Char(data, #{format}) group_name")
      .from("(Select (Case When status = #{MessageStatus::ERROR} then 1 else null end) As Erro,
                        Coalesce(date_time_sent, schedule, created_at) As data From messages Where Status In (#{MessageStatus::SUCCESS}, #{MessageStatus::ERROR})) As dados")
      .where('data Between :start And :end', start: start_date, end: Time.zone.now)
      .group("To_Char(data, #{format})")
      .order("to_date(To_Char(data, #{format}), #{format}) ASC")
  end
end
