module Formatador
  def formatar_dinheiro(valor, quantidade_casas_decimais)
    sprintf("R$ %.#{quantidade_casas_decimais}f", [0, valor.to_f].max.to_s).gsub(/\./, ',')
  end

  def formatar_telefone(telefone_so_numeros = "")
    telefone_so_numeros.present? ? sprintf("(%.2s) %.4s-%.5s", telefone_so_numeros[0..2], telefone_so_numeros[2..6], telefone_so_numeros[6..11]) : ""
  end
end