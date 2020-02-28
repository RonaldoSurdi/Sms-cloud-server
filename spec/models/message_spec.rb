require 'rails_helper'

RSpec.describe Message, type: :model do
  it "deve ter uma factory válida" do
    expect(FactoryGirl.build(:message)).to be_valid
  end

  context "validações" do
    it "deve requerer message" do
      message = FactoryGirl.build(:message, message: nil)
      expect(message).to_not be_valid
    end

    it "deve requerer to quando type for sent" do
      message = FactoryGirl.build(:message, to: nil, message_type: MessageType::SENT)
      expect(message).to_not be_valid
    end

    it "não deve requerer to quando type for diferente de sent" do
      message = FactoryGirl.build(:message, to: nil, message_type: MessageType::RECEIVED)
      expect(message).to be_valid
    end

    context "deve requerer telefone válido" do
      it "telefone from válido" do
        message = FactoryGirl.build(:message, from: "5499118599")
        expect(message).to be_valid
      end

      it "telefone from inválido" do
        message = FactoryGirl.build(:message, from: "655497")
        expect(message).to_not be_valid
      end

      it "telefone to válido" do
        message = FactoryGirl.build(:message, to: "5499118599")
        expect(message).to be_valid
      end

      it "telefone to inválido" do
        message = FactoryGirl.build(:message, to: "655497")
        expect(message).to_not be_valid
      end
    end
  end

  it "deve setar o campo status como padrão pending" do
    message = FactoryGirl.create(:message, status: nil)
    expect(message.status).to eq(MessageStatus::PENDING)
  end

  context "deve remover formatação dos campos de telefone" do
    subject do
      FactoryGirl.build(:message, to: "+55 (54) 33211854", from: "+55 (54) 33211854")
    end

    it "deve retornar campo to sem formatação" do
      expect(subject.to).to eq("+555433211854")
    end

    it "deve retornar campo from sem formatação" do
      expect(subject.from).to eq("+555433211854")
    end
  end

  it "deve retornar mensagens para enviar" do
    FactoryGirl.create(:message)
    FactoryGirl.create(:message)
    FactoryGirl.create(:message, schedule: DateTime.current + 1.day)
    FactoryGirl.create(:message, schedule: DateTime.current - 1.day)
    FactoryGirl.create(:message, status: MessageStatus::ERROR)
    FactoryGirl.create(:message, status: MessageStatus::SENDING)
    FactoryGirl.create(:message, message_type: MessageType::RECEIVED)

    expect(Message.to_send.size).to eq(4)
  end

  it "deve ter um escopo para retornar mensagens que para envio" do
    FactoryGirl.create(:message)
    FactoryGirl.create(:message, status: MessageStatus::ERROR)
    expect(Message).to respond_to(:to_send)
    expect(Message.to_send.size).to eq(1)
  end

  it "deve ter um customer" do
    message = FactoryGirl.create(:message)
    expect(message).to respond_to(:customer)
  end

  describe ".per_range_date_sent" do
    subject { Message.per_range_date_sent(DateTime.current.at_beginning_of_month, DateTime.current.at_end_of_month) }

    it "deve listar mensagens no mês atual enviadas com sucesso" do
      create :message, :success, created_at: 1.month.ago, updated_at: 1.month.ago, date_time_sent: 1.month.ago
      2.times { create :message, :success, date_time_sent: DateTime.current }
      expect(subject.count).to eq(2)
    end

    it "deve listar todas as mensagens com status sending" do
      2.times { create :message, :sending }
      expect(subject.count).to eq(2)
    end
  end

  describe "#generate_for" do
    subject { create :customer, endereco: nil, representative: nil }

    let :params do
      {message: "Mensagem", agendamento: "false", cellphones: (["1234567890"] * 3)}
    end

    let :params_with_schedule do
      {
        message: "Mensagem", agendamento: "true", cellphones: (["1234567890"] * 3),
        "schedule(5i)" => "30", "schedule(4i)" => "08", "schedule(3i)" => Date.tomorrow.day.to_s,
        "schedule(2i)" => Date.tomorrow.month.to_s, "schedule(1i)" => Date.tomorrow.year.to_s
      }
    end

    let :params_with_past_schedule do
      {
        message: "Mensagem", agendamento: "true", cellphones: (["1234567890"] * 3),
        "schedule(5i)" => "30", "schedule(4i)" => "08", "schedule(3i)" => Date.yesterday.day.to_s,
        "schedule(2i)" => Date.yesterday.month.to_s, "schedule(1i)" => Date.yesterday.year.to_s
      }
    end

    it "deve gerar mensagens de acordo com a quantidade de celulares informada" do
      subject.messages.build.generate_for(params, 10)
      expect(subject.messages.count).to eq(3)
    end

    it "não deve gerar mensagens se não possuir saldo para a quantidade de mensagens a ser gerada" do
      expect(subject.messages.build.generate_for(params, 2)).to be false
    end

    it "deve mensagens sem se importar com o saldo caso as mesmas sejam agendadas" do
      subject.messages.build.generate_for(params_with_schedule, 2)
      expect(subject.messages.count).to eq(3)
    end

    it "não deve permitir que mensagens sejam agendadas em um tempo passado" do
      subject.messages.build.generate_for(params_with_past_schedule, 3)
      expect(subject.messages.last.schedule).to be_nil
    end
  end
end
