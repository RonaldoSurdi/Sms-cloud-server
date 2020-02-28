require 'rails_helper'

RSpec.describe Plan, :type => :model do
  it { should be_a_kind_of ActiveRecord::Base }
  it { should have_many :licenses }
  it { should define_enum_for :tipo }
  it { should validate_presence_of :tipo }
  it { should validate_presence_of :valor_total }
  it { should validate_presence_of :descricao }
  it { should validate_presence_of :quantidade_sms }
  it { should validate_numericality_of :quantidade_sms }

  context "Métodos de classe" do
    subject { Plan }

    describe ".filter" do

      before do
        create :plan
        create :plan, descricao: descricao_filtro
      end

      let :descricao_filtro do
        "$&descricao para o filtro&$"
      end

      let :partial_size do
        (descricao_filtro.size / 2).round
      end

      let :unique_token do
        Faker::Internet.password(30)
      end

      it "deve retornar todos os registros se o filtro estiver em branco" do
        expect(subject.filter("").count).to eql(2)
      end

      it "deve retornar o registro que possuir a descrição a ser filtrada" do
        expect(subject.filter(descricao_filtro).count).to eql(1)
      end

      it "deve retornar o registro que possuir parte da descrição a ser filtrada" do
        expect(subject.filter(descricao_filtro[0..partial_size]).count).to eql(1)
      end

      it "não deve retornar nenhum registro caso o filtro não possa ser encontrado" do
        expect(subject.filter(unique_token).count).to eql(0)
      end
    end
  end

  context "Métodos de instância" do
    subject { build :plan }

    describe "#valor_unitario" do
      it "deve retornar o resultado com cinco casas decimais" do
        casas_decimais = subject.valor_unitario.split(',').last
        expect(casas_decimais.size).to eq(5)
      end
    end

    describe "#validade" do
      it "deve retornar que a validade é de um ano" do
        expect(subject.validade).to eq(1.year)
      end
    end
  end
end
