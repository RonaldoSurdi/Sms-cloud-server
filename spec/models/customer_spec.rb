require 'rails_helper'

RSpec.describe Customer, :type => :model do
  it { should be_a_kind_of ActiveRecord::Base }
  it { should belong_to :endereco }
  it { should belong_to :representative }
  it { should have_many :license_movements }
  it { should have_many :plan_movements }
  it { should have_many :messages }
  it { should have_many :contacts }
  it { should have_many :contact_groups }
  it { should have_one :configuration }
  it { should define_enum_for :status }
  it { should define_enum_for :tipo_pessoa }
  it { should accept_nested_attributes_for :endereco }
  it { should validate_presence_of :nome }
  it { should validate_presence_of :telefone }
  it { should validate_presence_of :email }
  it { should validate_presence_of :tipo_pessoa }
  it { should validate_presence_of :cpf_cnpj }
  it { should validate_length_of :telefone }
  it { should validate_length_of :celular }

  context "Métodos de classe" do
    subject { Customer }

    describe ".pode_comprar_licenca" do
      it "não deve retornar nenhum cliente" do
        expect(subject.pode_comprar_licenca.count).to eq(0)
      end

      it "deve retornar todos clientes que estiverem sem licença" do
        create(:customer)
        expect(subject.pode_comprar_licenca.count).to eq(1)
      end

      it "não deve retornar cliente que estiver com licença ativa" do
        create(:sold_license_movement)
        expect(subject.pode_comprar_licenca.count).to eq(0)
      end

      it "deve retornar cliente que estiver com licença vencida" do
        create(:sold_license_movement, :vencida)
        expect(subject.pode_comprar_licenca.count).to eq(1)
      end

      it "deve retornar cliente que estiver com licença vencendo" do
        representative = create(:sold_license_movement, :vencida_a_muito_tempo).representative
        customer = subject.first
        representative.customers << customer
        create(:sold_license_movement, :vencida, representative: representative, customer: customer)
        create(:sold_license_movement, :vencendo, representative: representative, customer: customer)

        create(:sold_license_movement, representative: representative)

        expect(representative.customers.pode_comprar_licenca.email_confirmado.status_ok.count).to eq(1)
      end

      it "não deve retornar cliente que estiver com licença vencendo e que já adquiriu licença" do
        create(:license_movement, :vencendo, :com_licenca_reserva)
        expect(subject.pode_comprar_licenca.count).to eq(0)
      end
    end

    describe ".com_licenca" do
      it "deve retornar um cliente que tiver licença" do
        create(:sold_license_movement)
        expect(subject.com_licenca.count).to eq(1)
      end

      it "não deve retornar um cliente que tiver licença vencida" do
        create(:sold_license_movement, :vencida)
        expect(subject.com_licenca.count).to eq(0)
      end

      it "deve retornar um cliente que tiver licença vencendo" do
        create(:sold_license_movement, :vencendo)
        expect(subject.com_licenca.count).to eq(1)
      end
    end

    describe ".sem_licenca" do
      it "deve retornar um cliente sem licença" do
        create(:customer)
        expect(subject.sem_licenca.count).to eq(1)
      end

      it "não deve retornar um cliente com licença" do
        create(:customer)
        create(:sold_license_movement)
        expect(subject.sem_licenca.count).to eq(1)
      end

      it "deve retornar um cliente com licença vencida" do
        create(:sold_license_movement, :vencida)
        create(:sold_license_movement)
        expect(subject.sem_licenca.count).to eq(1)
      end
    end

    context "Testes de filtros" do
      before do
        create :customer
      end

      let :palavra_filtro do
        "$$palavra_customer_teste_para_filtro$$"
      end

      let :email_filtro  do
        "email_customer_teste_para_filtro@hotmail.com"
      end

      let :cpf_telefone_filtro  do
        BrFaker::Cpf.cpf(false)
      end

      let :unique_token do
        Faker::Internet.password(30)
      end

      let :partial_size do
        if (palavra_filtro < email_filtro && palavra_filtro < cpf_telefone_filtro)
          (palavra_filtro.size / 2).round
        elsif (email_filtro < palavra_filtro && email_filtro < cpf_telefone_filtro)
          (email_filtro.size / 2).round
        else
          (cpf_telefone_filtro.size / 2).round
        end
      end

      describe ".filter" do

        it "deve retornar todos os registros se o filtro estiver em branco" do
          create :customer
          expect(subject.filter("").count).to eql(2)
        end

        it "deve retornar o registro que possuir o nome a ser filtrado" do
          create :customer, nome: palavra_filtro
          expect(subject.filter(palavra_filtro).count).to eql(1)
        end

        it "deve retornar o registro que possuir o cpf_cnpj a ser filtrado" do
          create :customer, cpf_cnpj: cpf_telefone_filtro
          expect(subject.filter(cpf_telefone_filtro).count).to eql(1)
        end

        it "deve retornar o registro que possuir o telefone a ser filtrado" do
          create :customer, telefone: cpf_telefone_filtro
          expect(subject.filter(cpf_telefone_filtro).count).to eql(1)
        end

        it "deve retornar o registro que possuir o email a ser filtrado" do
          create :customer, email: email_filtro
          expect(subject.filter(email_filtro).count).to eql(1)
        end

        it "deve retornar o registro que possuir o nome_fantasia de seu representante a ser filtrado" do
          representative = build :representative, nome_fantasia: palavra_filtro
          create :customer, representative: representative
          expect(subject.filter(palavra_filtro).count).to eql(1)
        end

        it "deve retornar o registro que possuir o nome parcial a ser filtrado" do
          create :customer, nome: palavra_filtro
          expect(subject.filter(palavra_filtro[0..partial_size]).count).to eql(1)
        end

        it "deve retornar o registro que possuir o cpf_cnpj parcial a ser filtrado" do
          create :customer, cpf_cnpj: cpf_telefone_filtro
          expect(subject.filter(cpf_telefone_filtro[0..partial_size]).count).to eql(1)
        end

        it "deve retornar o registro que possuir o telefone parcial a ser filtrado" do
          create :customer, telefone: cpf_telefone_filtro
          expect(subject.filter(cpf_telefone_filtro[0..partial_size]).count).to eql(1)
        end

        it "deve retornar o registro que possuir o email parcial a ser filtrado" do
          create :customer, email: email_filtro
          expect(subject.filter(email_filtro[0..partial_size]).count).to eql(1)
        end

        it "não deve retornar nenhum registro caso o filtro não possa ser encontrado" do
          expect(subject.filter(unique_token).count).to eql(0)
        end
      end

      describe ".representatives_filter" do

        it "deve retornar todos os registros se o filtro estiver em branco" do
          create :customer
          expect(subject.representatives_filter("").count).to eql(2)
        end

        it "deve retornar o registro que possuir o nome a ser filtrado" do
          create :customer, nome: palavra_filtro
          expect(subject.representatives_filter(palavra_filtro).count).to eql(1)
        end

        it "deve retornar o registro que possuir o cpf_cnpj a ser filtrado" do
          create :customer, cpf_cnpj: cpf_telefone_filtro
          expect(subject.representatives_filter(cpf_telefone_filtro).count).to eql(1)
        end

        it "deve retornar o registro que possuir o telefone a ser filtrado" do
          create :customer, telefone: cpf_telefone_filtro
          expect(subject.representatives_filter(cpf_telefone_filtro).count).to eql(1)
        end

        it "deve retornar o registro que possuir o email a ser filtrado" do
          create :customer, email: email_filtro
          expect(subject.representatives_filter(email_filtro).count).to eql(1)
        end

        it "deve retornar o registro que possuir o nome parcial a ser filtrado" do
          create :customer, nome: palavra_filtro
          expect(subject.representatives_filter(palavra_filtro[0..partial_size]).count).to eql(1)
        end

        it "deve retornar o registro que possuir o cpf_cnpj parcial a ser filtrado" do
          create :customer, cpf_cnpj: cpf_telefone_filtro
          expect(subject.representatives_filter(cpf_telefone_filtro[0..partial_size]).count).to eql(1)
        end

        it "deve retornar o registro que possuir o telefone parcial a ser filtrado" do
          create :customer, telefone: cpf_telefone_filtro
          expect(subject.representatives_filter(cpf_telefone_filtro[0..partial_size]).count).to eql(1)
        end

        it "deve retornar o registro que possuir o email parcial a ser filtrado" do
          create :customer, email: email_filtro
          expect(subject.representatives_filter(email_filtro[0..partial_size]).count).to eql(1)
        end

        it "não deve retornar nenhum registro caso o filtro não possa ser encontrado" do
          expect(subject.representatives_filter(unique_token).count).to eql(0)
        end
      end
    end

    describe ".por_status_venda" do
      before do
        create :sold_license_movement
        2.times { create :customer }
      end

      it "deve retornar os clientes com licença ao buscar os que possuem licença" do
        expect(subject.por_status_venda(:com_licenca).count).to eq(1)
      end

      it "deve retornar os clientes sem licença ao buscar os que não possuem licença" do
        expect(subject.por_status_venda(:sem_licenca).count).to eq(2)
      end

      it "deve retornar todos clientes quando não for passado nenhum parâmetro" do
        expect(subject.por_status_venda.count).to eq(3)
      end
    end

    describe ".confirm_by_token" do
      let :customer do
        customer = create :customer, representative: nil, endereco: nil
      end

      before do
        @raw_token, customer.confirmation_token = Devise.token_generator.generate(subject, :confirmation_token)
        customer.save
      end

      it "deve confirmar o cliente que possuir o token de confirmação correto" do
        expect(subject.confirm_by_token(@raw_token).id).to_not be_nil
      end

      it "não deve confirmar o cliente que possuir o token de confirmação incorreto" do
        expect(subject.confirm_by_token(@raw_token + "123").id).to be_nil
      end

      it "não deve confirmar o cliente que possuir o token de confirmação correto, porém outro cliente confirmado já ter seu cpf_cnpj" do
        customer2 = build :customer, razao_social: "abcdefg", tipo_pessoa: customer.tipo_pessoa, cpf_cnpj: customer.cpf_cnpj
        customer2.save

        expect(subject.confirm_by_token(@raw_token).errors).to_not be_blank
      end
    end

    context "Métodos de classe de status gerais e status de cadastro" do
      before do
        3.times { create :customer }
        subject.first.update! confirmed_at: nil, status: :eliminado
      end

      describe ".email_confirmado" do
        it "deve retornar apenas os clientes confirmados" do
          expect(subject.email_confirmado.count).to eq(2)
        end
      end

      describe ".nao_eliminado" do
        it "deve retornar apenas os clientes não eliminados" do
          expect(subject.nao_eliminado.count).to eq(2)
        end
      end

      describe ".status_ok" do
        it "deve retornar apenas os clientes eliminados" do
          expect(subject.status_ok.count).to eq(2)
        end
      end
    end
  end

  context "Métodos de instância" do
    context "Métodos relacionados a licença do cliente" do
      subject { create(:sold_license_movement).customer }

      let :customer_without_license do
        build :customer
      end

      let :customer_with_backup_license do
        create(:sold_license_movement, :com_licenca_reserva).customer
      end

      let :customer_with_expired_license do
        create(:sold_license_movement, :vencida).customer
      end

      describe "#pode_comprar_licenca?" do
        it "deve retornar true caso não tenha licença" do
          customer = create :customer
          expect(customer.pode_comprar_licenca?).to be true
        end

        context "Com Licenças" do

          it "deve retornar true caso tenha licenças vencidas" do
            customer = create(:sold_license_movement, :vencida).customer
            expect(customer.pode_comprar_licenca?).to be true
          end

          it "deve retornar true caso tenha licença vencendo" do
            customer = create(:sold_license_movement, :vencendo).customer
            expect(customer.pode_comprar_licenca?).to be true
          end

          it "deve retornar false caso tenha uma licença atual" do
            customer = create(:sold_license_movement).customer
            expect(customer.pode_comprar_licenca?).to be false
          end

          it "deve retornar false caso tenha uma licença vencendo e uma licença reserva" do
            customer = create(:sold_license_movement, :vencendo, :com_licenca_reserva).customer
            expect(customer.pode_comprar_licenca?).to be false
          end
        end
      end

      describe "#current_license_movement" do
        it "deve retornar a licença atual ao possuir uma licença recém comprada" do
          expect(Date.today).to be_between(customer_with_backup_license.current_license_movement.validade_inicio,
                                            customer_with_backup_license.current_license_movement.validade_fim)
        end

        it "deve retornar a licença atual ao possuir uma licença vencida" do
          create :sold_license_movement, :vencida, :com_licenca_reserva, customer: subject
          expect(Date.today).to be_between(subject.current_license_movement.validade_inicio, subject.current_license_movement.validade_fim)
        end

        it "deve retornar nil caso não possua uma licença válida" do
          expect(customer_with_expired_license.current_license_movement).to be_nil
        end
      end

      context "Métodos de saldo" do
        subject { create(:sold_license_movement, :com_movimentacao_de_planos).customer }

        describe "#current_plan_movements" do
          it "deve retornar o plano atual se possuir um plano" do
            expect(subject.current_plan_movements.size).to eq(1)
          end
        end

        describe "#saldo_sms" do
          before do
            subject.current_plan_movements.first.update! quantidade_sms: 150
          end

          it "deve retornar 150 sms se não houver nenhuma mensagem enviada" do
            expect(subject.saldo_sms).to eq(150)
          end

          it "deve retornar 110 sms se houverem 40 mensagens enviadas com sucesso" do
            Message.transaction do
              40.times do
                create :message, status: MessageStatus::SUCCESS, date_time_sent: DateTime.current, customer: subject
              end
            end

            expect(subject.saldo_sms).to eq(110)
          end

          it "deve retornar 115 sms se houverem 25 mensagens enviadas com sucesso, 10 enviando e 5 com erro" do
            Message.transaction do
              25.times do
                create :message, status: MessageStatus::SUCCESS, date_time_sent: DateTime.current, customer: subject
              end

              10.times do
                create :message, status: MessageStatus::SENDING, date_time_sent: DateTime.current, customer: subject
              end

              5.times do
                create :message, status: MessageStatus::ERROR, date_time_sent: DateTime.current, customer: subject
              end
            end

            expect(subject.saldo_sms).to eq(115)
          end
        end
      end

      describe "#possui_licenca_reserva?" do
        it "deve retornar nil se o cliente não tiver nenhuma licença" do
          expect(customer_without_license.possui_licenca_reserva?).to be_nil
        end

        it "deve retornar false se o cliente tiver apenas uma licença atual" do
          expect(subject.possui_licenca_reserva?).to be false
        end

        it "deve retornar false se o cliente tiver apenas uma licença vencendo" do
          customer = create(:sold_license_movement, :vencendo).customer
          expect(customer.possui_licenca_reserva?).to be false
        end

        it "deve retornar false se o cliente tiver apenas uma licença vencida" do
          expect(customer_with_expired_license.possui_licenca_reserva?).to be false
        end

        it "deve retornar true para o cliente que possui uma licença reserva" do
          expect(customer_with_backup_license.possui_licenca_reserva?).to be true
        end
      end
    end

    context "Métodos relacionados aos contatos do cliente" do
      subject { create :customer, :com_contatos, representative: nil, endereco: nil }

      describe "#contacts_with_groups_per_first_letter" do
        it "deve separar os contatos por grupos de ordem alfabética" do
          primeiro_grupo = subject.contacts_with_groups_per_first_letter.first
          contatos_do_primeiro_grupo = primeiro_grupo.last

          quantidade_inicial_de_contatos_no_grupo = contatos_do_primeiro_grupo.size
          letra_do_grupo = primeiro_grupo.first

          create :contact, customer: subject, nome: "#{letra_do_grupo} resto do nome"

          expect(subject.contacts_with_groups_per_first_letter.first.last.size).to eq(quantidade_inicial_de_contatos_no_grupo + 1)
        end
      end
    end

    context "Métodos comuns" do
      subject { build(:customer, representative: nil, endereco: nil) }

      describe "#cpf_cnpj_formatado" do
        it "deve formatar corretamente um CPF" do
          expect(subject.cpf_cnpj_formatado.size).to eq(14)
        end

        it "deve formatar corretamente um CNPJ" do
          cliente = build :customer, :pessoa_juridica
          expect(cliente.cpf_cnpj_formatado.size).to eq(18)
        end
      end

      describe "#telefone_formatado" do
        it "deve formatar corretamente um telefone" do
          expect(subject.telefone_formatado.size).to be_between(14, 15)
        end
      end

      describe "#celular_formatado" do
        it "deve formatar corretamente um celular" do
          subject.celular = Faker::PhoneNumber.phone_number
          expect(subject.celular_formatado.size).to be_between(14, 15)
        end

        it "deve retornar vazio se não houver um celular cadastrado" do
          subject.celular = nil
          expect(subject.celular_formatado).to eq("")
        end
      end

      describe "#destroy" do
        let :customer do
          create :customer
        end

        before do
          customer.destroy
        end

        it "não deve deletar a cliente do banco" do
          expect(Customer.count).to eq(1)
        end

        it "deve marcar o cliente como eliminado" do
          expect(customer.status).to eq("eliminado")
        end
      end

      describe "#authenticate_password" do
        subject { create :customer, representative: nil, endereco: nil }

        before do
          subject.valid_current_password = true
        end

        it "deve ser válido caso a senha atual informada seja idêntica à verdadeira senha atual" do
          subject.current_password = "connect123"
          expect(subject).to be_valid
        end

        it "não deve ser válido caso a senha atual informada não seja idêntica à verdadeira senha atual" do
          subject.current_password = "connect1234"
          expect(subject).to_not be_valid
        end

        it "deve ser válido caso não seja especificada a troca de senha" do
          subject.valid_current_password = false
          subject.current_password = "connect123"
          expect(subject).to be_valid
        end
      end

      describe "#add_configuration" do
        subject(:customer) { create :customer }

        it "deve criar uma configuração para o cliente após sua criação" do
          expect(customer.try(:configuration)).not_to be_nil
        end

        it "não deve criar uma configuração para o cliente após sua atualização" do
          configuration = customer.configuration
          customer.update nome: 'Johns'
          expect(customer.configuration.id).to eq configuration.id
        end
      end
    end
  end

  describe ".to_send_for_birthdays" do
    before do
      create :customer, contacts: [create(:contact)], configuration: create(:configuration, send_birthdays: true, text_birthdays: 'Hello World!')
      create :customer, contacts: [create(:contact)]
      create :customer, contacts: [create(:contact)]
    end

    it "deve retornar todos os clientes que concordaram em enviar sms's para aniversariantes" do
      expect(Customer.to_send_for_birthdays.count).to eq 1
    end
  end

  describe ".contacts_in_birthday" do
    subject(:customer) { create :customer }
    before do
      2.times { |i| create :contact, nascimento: 3.days.ago, customer: customer }
      create :contact, nascimento: 2.days.ago, customer: customer
    end

    it "deve retornar todos os clientes que concordaram em enviar sms's para aniversariantes" do
      Timecop.travel(2.days.ago) do
        expect(Customer.contacts_in_birthday.count).to eq 1
      end
    end
  end
end
