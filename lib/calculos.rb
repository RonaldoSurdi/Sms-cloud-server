module Calculos
  def calcular_valor_unitario(valor_total, quantidade)
    if valor_total.to_f > 0 && quantidade.to_f > 0
      valor_total.to_f / quantidade.to_f
    else
      0
    end
  end
end