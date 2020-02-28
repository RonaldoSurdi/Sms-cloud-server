module ApplicationHelper
  def order(order_params)
    order = OpenStruct.new

    split = order_params.to_s.split(" ")
    if split.length == 2
      order.field = split[0]
      order.asc_desc = split[1]
    else
      order.field = split[0]
      order.asc_desc = "asc"
    end

    order
  end

  def init_angular(params)
    ret = [
      "filters.order=\"#{@order} #{@asc_desc}\"",
      "filtersPaginate.order=\"#{@order} #{@asc_desc}\"",
    ]

    ret = ret + params.collect do |param|
      valor = instance_values[param.to_s]
      valor = if valor.is_a?(Hash) || valor.is_a?(Array)
        serialize_json_angular(valor)
      else
        "\"#{valor}\""
      end

      [
        "filters.#{param.to_s}=#{valor}",
        "filtersPaginate.#{param.to_s}=#{valor}"
      ]
    end

    ret.join(";")
  end

  def url_template_paginacao
    "#{ENV["RAILS_RELATIVE_URL_ROOT"].to_s}/angular-templates/paginate.html"
  end

  def normalize_periodo(periodo)
    if periodo.present?
      split = periodo.split("-");
      ret = [split[0].strip.to_date, split[1].strip.to_date]
    end
  end

  def serialize_json_angular(obj)
    ret = obj
    ret = ret.to_json unless obj.is_a?(String)
    ret.gsub(/[']/,"\\\\\'")
  end


  ICONES_DE_STATUS = {
    MessageStatus::PENDING => 'icon-time',
    MessageStatus::SENDING => 'icon-envelope',
    MessageStatus::SUCCESS => 'icon-ok',
    MessageStatus::ERROR => 'icon-remove'
  }

  CORES_DE_STATUS = {
    MessageStatus::PENDING => 'text-purple',
    MessageStatus::SENDING => 'text-primary',
    MessageStatus::SUCCESS => 'text-success',
    MessageStatus::ERROR => 'text-danger'
  }

  def icone_para_status(status)
    ICONES_DE_STATUS[status]
  end

  def cor_texto_para_status(status)
    CORES_DE_STATUS[status]
  end

  def cor_texto_e_icone_para_status(status)
    icone_para_status(status) + ' ' + cor_texto_para_status(status)
  end
end
