require 'rails_helper'

RSpec.describe Formatador, type: :unit do
  include Formatador

  describe ".formatar_dinheiro" do
    it "deve retornar número de casas decimais especificadas" do
      expect(formatar_dinheiro(1, 5)).to eq("R$ 1,00000")
      expect(formatar_dinheiro(1.25, 1)).to eq("R$ 1,2")
      expect(formatar_dinheiro(1.99999991, 10)).to eq("R$ 1,9999999100")
    end

    it "deve retornar 0 quando informado nil" do
      expect(formatar_dinheiro(nil, 2)).to eq("R$ 0,00")
    end

    it "deve retornar 0 quando for informando um número negativo" do
      expect(formatar_dinheiro(-10, 2)).to eq("R$ 0,00")
    end
  end
end
