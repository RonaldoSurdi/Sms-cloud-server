class Endereco < ActiveRecord::Base
  only_digits :cep

  validates :logradouro, :bairro, :cep, presence: true

  def cep_formatado
    "#{self.cep[0..4]}-#{self.cep[5..8]}"
  end
end
