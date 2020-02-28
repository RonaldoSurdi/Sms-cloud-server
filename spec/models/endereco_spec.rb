require 'rails_helper'

RSpec.describe Endereco, :type => :model do
  it { should be_a_kind_of ActiveRecord::Base }
  it { should validate_presence_of :logradouro }
  it { should validate_presence_of :bairro }
  it { should validate_presence_of :cep }

  describe "#cep_formatado" do
    subject { build :endereco, cep: "99700000" }

    it "deve retornar o cep formatado corretamente" do
      expect(subject.cep_formatado).to eq("99700-000")
    end
  end
end
