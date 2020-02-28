module Representante::LicenseMovementsHelper

  def sequencial_color
    @number ||= 0
    number_of_this_time = @number

    colors = %w{blue orange red purple}

    if @number < (colors.size - 1)
      @number += 1
    else
      @number = 0
    end

    colors[number_of_this_time]
  end

  def sequencial_background
    "#{sequencial_color}-background"
  end

  def licenses_tipo(tipo)
    License
      .includes(:plan)
      .order("licenses.tipo")
      .order("licenses.descricao ASC")
      .where("licenses.tipo = ?", License.tipos[tipo.to_sym])
  end
end