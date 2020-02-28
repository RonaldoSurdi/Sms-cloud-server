require 'rails_helper'

RSpec.describe License, :type => :model do
  it { should be_a_kind_of ActiveRecord::Base }
  it { should belong_to :plan }
  it { should define_enum_for :tipo }
  it { should validate_presence_of :descricao }
  it { should validate_presence_of :tipo }
  it { should validate_presence_of :valor_unitario }
  it { should validate_presence_of :valor_sugerido }
  it { should validate_presence_of :plan_id }

  context "Métodos de filtro" do
    subject { License }

    describe ".filter" do
      subject { License.joins(:plan) }

      before do
        create :license
        create :license, descricao: descricao_filtro, plan: create(:plan, descricao: plano_descricao_filtro)
      end

      let :descricao_filtro do
        "$&descricao para o filtro&$"
      end

      let :plano_descricao_filtro do
        "$&descricao do plano para o filtro&$"
      end

      let :partial_size do
        if (descricao_filtro < plano_descricao_filtro)
          (descricao_filtro.size / 2).round
        else
          (plano_descricao_filtro.size / 2).round
        end
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

      it "deve retornar o registro que possuir a descrição do plano a ser filtrada" do
        expect(subject.filter(plano_descricao_filtro).count).to eql(1)
      end

      it "deve retornar o registro que possuir parte da descrição a ser filtrada" do
        expect(subject.filter(descricao_filtro[0..partial_size]).count).to eql(1)
      end

      it "deve retornar o registro que possuir parte da descrição do plano a ser filtrada" do
        expect(subject.filter(plano_descricao_filtro[0..partial_size]).count).to eql(1)
      end

      it "não deve retornar nenhum registro caso o filtro não possa ser encontrado" do
        expect(subject.filter(unique_token).count).to eql(0)
      end
    end

    describe ".por_tipo" do
      before do
        License.transaction do
          create :license, tipo: subject.tipos[:nova]
          2.times { create :license, tipo: subject.tipos[:renovacao] }
        end
      end

      it "deve retornar todos os registros se o tipo estiver em branco" do
        expect(subject.por_tipo("").count).to eql(3)
      end

      it "deve retornar os registros de tipo 'nova' se for solicitado" do
        expect(subject.por_tipo(:nova).count).to eql(1)
      end

      it "deve retornar os registros de tipo 'renovacao' se for solicitado" do
        expect(subject.por_tipo(:renovacao).count).to eql(2)
      end
    end
  end
end
