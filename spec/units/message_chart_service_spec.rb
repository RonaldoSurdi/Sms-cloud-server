require 'rails_helper'

RSpec.describe MessageChartService, type: :unit do
  subject(:data_trinta_dias) { MessageChartService.new(30.days.ago) }
  subject(:data_seis_meses) { MessageChartService.new(5.months.ago.at_beginning_of_month) }

  let :trinta_dias_atras_no_inicio_do_dia do
    30.days.ago.at_beginning_of_day
  end

  let :seis_meses_atras_inicio_do_primeiro_dia_do_mes do
    6.months.ago.at_beginning_of_month.at_beginning_of_day
  end

  describe "#start_date" do
    it "deve retornar uma data no começo do dia à trinta dias atrás, se a data não for maior que 30 dias" do
      expect(data_trinta_dias.start_date).to eq trinta_dias_atras_no_inicio_do_dia
    end

    it "deve retornar uma data no começo do primeiro dia do mês à seis meses atrás" do
      expect(data_seis_meses.start_date).to eq seis_meses_atras_inicio_do_primeiro_dia_do_mes
    end
  end

  describe "#group_by_month?" do
    it "deve retornar true se a data de início fornecida passar de 30 dias" do
      expect(MessageChartService.new(31.days.ago).group_by_month?).to be true
    end

    it "deve retornar false se a data de início fornecida não passar de 30 dias" do
      expect(data_trinta_dias.group_by_month?).to be false
    end
  end

  describe "#format" do
    it "deve retornar o formato 'MM/YY' se a data de início ultrapassar 30 dias" do
      expect(MessageChartService.new(31.days.ago).format.upcase).to eq "'MM/YY'"
    end

    it "deve retornar o formato 'DD/MM' se a data de início não ultrapassar 30 dias" do
      expect(data_trinta_dias.format.upcase).to eq "'DD/MM'"
    end
  end

  describe "#exec" do
    context "quando agrupado por meses" do
      before do
        create :message, status: MessageStatus::SUCCESS, date_time_sent: 6.month.ago

        create :message, status: MessageStatus::SUCCESS, schedule: 2.month.ago
        create :message, created_at: 2.month.ago

        create :message, status: MessageStatus::ERROR, attempts: 3, date_time_sent: 1.month.ago
        create :message, status: MessageStatus::SUCCESS, schedule: 1.month.ago

        2.times { create :message, status: MessageStatus::SUCCESS }
      end

      it "deve retornar os meses que possuem mensagens enviadas com erro ou sucesso" do
        expect(data_seis_meses.exec.length).to eq 4
      end

      it "deve retornar as quantidades de mensagens corretas para os meses que possuem mensagens enviadas com erro ou sucesso" do
        contagem = data_seis_meses.exec

        expect(contagem.first.total).to eq 1
        expect(contagem.first.total_erro).to eq 0

        expect(contagem.second.total).to eq 1
        expect(contagem.second.total_erro).to eq 0

        expect(contagem.third.total).to eq 2
        expect(contagem.third.total_erro).to eq 1

        expect(contagem.fourth.total).to eq 2
        expect(contagem.fourth.total_erro).to eq 0
      end
    end

    context "quando agrupado por dias" do
      before do
        create :message, status: MessageStatus::SUCCESS, date_time_sent: 29.days.ago

        create :message, status: MessageStatus::SUCCESS, schedule: 20.days.ago
        create :message, created_at: 20.days.ago

        create :message, status: MessageStatus::ERROR, attempts: 3, date_time_sent: 5.days.ago
        create :message, status: MessageStatus::SUCCESS, schedule: 5.days.ago

        2.times { create :message, status: MessageStatus::SUCCESS }
      end

      it "deve retornar os dias que possuem mensagens enviadas com erro ou sucesso" do
        expect(data_trinta_dias.exec.length).to eq 4
      end

      it "deve retornar as quantidades de mensagens corretas para os meses que possuem mensagens enviadas com erro ou sucesso" do
        contagem = data_trinta_dias.exec

        expect(contagem.first.total).to eq 1
        expect(contagem.first.total_erro).to eq 0

        expect(contagem.second.total).to eq 1
        expect(contagem.second.total_erro).to eq 0

        expect(contagem.third.total).to eq 2
        expect(contagem.third.total_erro).to eq 1

        expect(contagem.fourth.total).to eq 2
        expect(contagem.fourth.total_erro).to eq 0
      end
    end
  end
end
