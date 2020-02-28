module MailerHelper
  def total_movements_values(movements)
    movements.values.collect(&:to_i).inject(:+)
  end

  def calcular_valor_total_licenca(licencas, movimentacoes_quantidades)
    soma = 0
    licencas.each do |licenca|
      soma += movimentacoes_quantidades[licenca.id.to_s].to_i * licenca.valor_unitario
    end
    soma.reais_contabeis
  end
end