require 'rails_helper'

RSpec.describe PlanMovement, :type => :model do
  it { should be_a_kind_of ActiveRecord::Base }
  it { should belong_to :license_movement }
  it { should belong_to :customer }
  it { should define_enum_for :plano_tipo }
  it { should validate_presence_of :customer_id }
  it { should validate_presence_of :quantidade_sms }
  it { should validate_presence_of :plano_valor_total }
  it { should validate_presence_of :validade_inicio }
  it { should validate_presence_of :validade_fim }
  it { should validate_numericality_of :quantidade_sms }
  it { should validate_numericality_of :plano_valor_total }

  describe ".filter" do
    let(:plano_descricao) { "Descrição Legal" }
    let(:nome_customer) { "John Doe" }
    let(:filtro_sem_sentido) { "sIUHD IhdIuyguDABGY CUguasdg" }

    before do
      create :plan_movement, plano_descricao: plano_descricao, customer: create(:customer, nome: nome_customer)
    end

    context "quando pesquisado por descrição do plano" do
      it "deve retornar um registro que possui o filtro informado" do
        expect(PlanMovement.joins(:customer).filter(plano_descricao).count).to eq(1)
      end

      it "não deve retornar um registro que não possui o filtro informado" do
        expect(PlanMovement.joins(:customer).filter(filtro_sem_sentido).count).to eq(0)
      end
    end

    context "quando pesquisado por nome do cliente" do
      it "deve retornar um registro que possui o filtro informado" do
        expect(PlanMovement.joins(:customer).filter(nome_customer).count).to eq(1)
      end

      it "não deve retornar um registro que não possui o filtro informado" do
        expect(PlanMovement.joins(:customer).filter(filtro_sem_sentido).count).to eq(0)
      end
    end
  end

  describe ".por_status" do
    let(:confirmadas) { "confirmadas" }
    let(:aguardando) { "aguardando" }
    let(:todas) { "todas" }

    context "quando o parâmetro passado pedir as que foram confirmadas" do
      before do
        create :plan_movement_avulso, :pagamento_confirmado
      end

      it "deve retornar as movimentações de planos confirmadas" do
        expect(PlanMovement.por_status(confirmadas).count).to eq 1
      end

      it "deve ignorar as movimentações de planos que não foram confirmadas" do
        create :plan_movement_avulso
        expect(PlanMovement.por_status(confirmadas).count).to eq 1
      end
    end

    context "quando o parâmetro passado pedir as que não foram confirmadas" do
      before do
        create :plan_movement_avulso
      end

      it "deve retornar as movimentações de planos que estão aguardando pagamento" do
        expect(PlanMovement.por_status(aguardando).count).to eq 1
      end

      it "deve ignorar as movimentações de planos que foram confirmadas" do
        create :plan_movement_avulso, :pagamento_confirmado
        expect(PlanMovement.por_status(confirmadas).count).to eq 1
      end
    end

    context "quando o parâmetro passado pedir todas" do
      it "deve retornar todas as movimentações de planos" do
        create :plan_movement_avulso, :pagamento_confirmado
        create :plan_movement_avulso
        expect(PlanMovement.por_status(todas).count).to eq 2
      end
    end

    context "quando nenhum parâmetro for passado" do
      it "deve retornar todas as movimentações de planos" do
        create :plan_movement_avulso, :pagamento_confirmado
        create :plan_movement_avulso
        expect(PlanMovement.por_status("").count).to eq 2
      end
    end
  end
end
