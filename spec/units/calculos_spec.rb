require 'rails_helper'

RSpec.describe Calculos, type: :unit do
  include Calculos

  describe "#calcular_valor_unitario" do
    it "deve retornar 5 quando o valor for 10 e a quantidade for 2" do
      expect(calcular_valor_unitario(10, 2)).to eq(5)
    end

    it "deve retornar 2 quando o valor for 20 e a quantidade for 10" do
      expect(calcular_valor_unitario(20, 10)).to eq(2)
    end

    it "deve retornar 15 quando o valor for 1500 e a quantidade for 100" do
      expect(calcular_valor_unitario(1500, 100)).to eq(15)
    end

    it "deve retornar 2.5 quando o valor for 10 e a quantidade for 4" do
      expect(calcular_valor_unitario(10, 4)).to eq(2.5)
    end

    it "deve retornar 0 quando valor e a quantidade forem zero" do
      expect(calcular_valor_unitario(0, 0)).to eq(0)
    end

    it "deve retornar 0 quando a quantidade for zero" do
      expect(calcular_valor_unitario(10, 0)).to eq(0)
    end

    it "deve retornar 0 quando valor for zero" do
      expect(calcular_valor_unitario(0, 10)).to eq(0)
    end
  end
end
