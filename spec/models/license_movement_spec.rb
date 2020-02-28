require 'rails_helper'

RSpec.describe LicenseMovement, :type => :model do
  it { should be_a_kind_of ActiveRecord::Base }
  it { should belong_to :license }
  it { should belong_to :representative }
  it { should belong_to :customer }
  it { should have_many :plan_movements }
  it { should define_enum_for :licenca_tipo }

  context "Métodos de classe" do
    subject { LicenseMovement }

    context "Métodos de filtro" do
      subject { LicenseMovement.joins(:representative) }

      before do
        create :license_movement

        create :license_movement,
                license: create(:license, descricao: palavra_filtro),
                representative: create(:representative, nome_fantasia: nome_filtro)
      end

      let :nome_filtro do
        "$$nome license movement teste para filtro$$"
      end

      let :palavra_filtro do
        "$$palavra_license_movement_teste_para_filtro$$"
      end

      let :unique_token do
        Faker::Internet.password(30)
      end

      let :partial_size do
        if nome_filtro < palavra_filtro
          (nome_filtro.size / 2).round
        else
          (palavra_filtro.size / 2).round
        end
      end

      describe ".filter" do
        it "deve retornar todos os registros se o filtro estiver em branco" do
          expect(subject.filter("").count).to eql(2)
        end

        it "deve retornar o registro que possuir a descricão a ser filtrada" do
          expect(subject.filter(palavra_filtro).count).to eql(1)
        end

        it "deve retornar o registro que possuir o filtro do nome fantasia do representante" do
          expect(subject.filter(nome_filtro).count).to eql(1)
        end

        it "deve retornar o registro que possuir a descricão parcial a ser filtrada" do
          expect(subject.filter(palavra_filtro[0..partial_size]).count).to eql(1)
        end

        it "deve retornar o registro que possuir o filtro do nome fantasia parcial do representante" do
          expect(subject.filter(nome_filtro[0..partial_size]).count).to eql(1)
        end

        it "não deve retornar nenhum registro caso o filtro não possa ser encontrado" do
          expect(subject.filter(unique_token).count).to eql(0)
        end
      end

      describe ".representative_filter" do
        it "deve retornar todos os registros se o filtro estiver em branco" do
          expect(subject.representative_filter("").count).to eql(2)
        end

        it "deve retornar o registro que possuir a descrição a ser filtrada" do
          expect(subject.representative_filter(palavra_filtro).count).to eql(1)
        end

        it "deve retornar o registro que possuir a descrição parcial a ser filtrada" do
          expect(subject.representative_filter(palavra_filtro[0..partial_size]).count).to eql(1)
        end

        it "não deve retornar nenhum registro caso o filtro não possa ser encontrado" do
          expect(subject.representative_filter(unique_token).count).to eql(0)
        end
      end
    end

    describe ".por_status" do
      before do
        LicenseMovement.transaction do
          create :sold_license_movement
          2.times { create :confirmed_license_movement }
          3.times { create :license_movement }
        end
      end

      it "deve retornar todos os registros se o status estiver em branco" do
        expect(subject.por_status("").count).to eql(6)
      end

      it "deve retornar todos os registros se o status for 'todas'" do
        expect(subject.por_status(:todas).count).to eql(6)
      end

      it "deve retornar os registros que podem ser vendidos se for solicitado" do
        expect(subject.por_status(:para_venda).count).to eql(2)
      end

      it "deve retornar os registros vendidos se for solicitado" do
        expect(subject.por_status(:vendidas).count).to eql(1)
      end

      it "deve retornar os registros de compra não confirmada se for solicitado" do
        expect(subject.por_status(:aguardando).count).to eql(3)
      end
    end

    describe ".unicas" do
      before do
        LicenseMovement.transaction do
          create :confirmed_license_movement, representative: representative
          3.times { create :confirmed_license_movement, license: license, representative: representative }
        end
      end

      let :license do
        create(:license)
      end

      let :representative do
        create :representative, endereco: nil
      end

      it "deve retornar todas as movimentações de licença que possuem as licenças iguais agrupadas" do
        expect(subject.unicas.order('quantidade DESC')[0].quantidade).to eq(3)
      end

      it "deve retornar todas as movimentações de licença que possuem as licenças diferentes" do
        expect(subject.unicas.size.size).to eq(2)
      end
    end
  end

  context "Métodos de instância" do
    subject { build :confirmed_license_movement }

    describe "#confirmada?" do
      it "deve retornar 'true' para uma licença confirmada" do
        expect(subject.confirmada?).to be true
      end
    end

    describe "#licenca_reserva?" do
      subject { create :sold_license_movement, :reserva }

      it "deve retornar 'true' para uma licença reserva" do
        expect(subject.licenca_reserva?).to be true
      end
    end

    describe "#confirmar" do
      subject { build :license_movement }

      before do
        subject.confirmar
      end

      it "deve confirmar corretamente a movimentação de licença" do
        expect(LicenseMovement.where.not(confirmado_pagamento_em: nil).count).to eq(1)
      end
    end
  end
end
