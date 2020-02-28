require 'rails_helper'

RSpec.describe Contact, :type => :model do
  it { should be_a_kind_of(ActiveRecord::Base) }
  it { should belong_to(:customer) }
  it { should validate_presence_of(:nome) }
  it { should validate_presence_of(:celular) }
  it { should validate_presence_of(:sexo) }

  context "É necessário validar os campos obrigatórios e não obrigatórios corretamente" do
    subject { build :contact }

    describe "#nome" do
      it "deve ser válido caso possua um nome" do
        expect(subject).to be_valid
      end

      it "não deve ser válido caso não possua um nome" do
        subject.nome = nil
        expect(subject).to_not be_valid
      end
    end

    describe "#celular" do
      it "deve ser válido caso possua um celular" do
        expect(subject).to be_valid
      end

      it "não deve ser válido caso não possua um celular" do
        subject.celular = nil
        expect(subject).to_not be_valid
      end

      it "não deve ser válido caso o celular tenha menos de 10 caracteres" do
        subject.celular = "1"*9
        expect(subject).to_not be_valid
      end
    end

    describe "#email" do
      it "deve ser válido caso possua um email correto" do
        subject.email = "testeblabla@teste.com"
        expect(subject).to be_valid
      end

      it "deve ser válido caso não possua um email" do
        subject.email = nil
        expect(subject).to be_valid
      end

      it "não deve ser válido caso possua um email em formato incorreto" do
        subject.email = "formato@incorreto"
        expect(subject).to_not be_valid
      end
    end

    describe "#empresa" do
      it "deve ser válido caso possua uma empresa" do
        subject.empresa = "Empresa bla"
        expect(subject).to be_valid
      end

      it "deve ser válido caso não possua uma empresa" do
        subject.empresa = nil
        expect(subject).to be_valid
      end
    end

    describe "#nascimento" do
      it "deve ser válido caso possua uma data de nascimento válida" do
        subject.nascimento = Date.today
        expect(subject).to be_valid
      end

      it "deve ser válido caso não possua uma data de nascimento" do
        subject.nascimento = nil
        expect(subject).to be_valid
      end

      it "não deve ser válido caso a data de nascimento seja futura" do
        subject.nascimento = 2.days.since
        expect(subject).to_not be_valid
      end
    end

    describe "#grupos" do
      let :cliente_com_grupo do
        build :contact, :com_grupo
      end

      it "deve ser válido caso possua um grupo" do
        expect(cliente_com_grupo).to be_valid
      end

      it "deve ser válido caso não possua um grupo" do
        expect(subject).to be_valid
      end
    end
  end

  context "Métodos de instância" do
    subject { build :contact }

    describe "#celular_formatado" do
      it "deve formatar corretamente um celular" do
        expect(subject.celular_formatado.size).to be_between(14, 15)
      end

      it "deve retornar vazio se não houver um celular cadastrado" do
        subject.celular = nil
        expect(subject.celular_formatado).to eq("")
      end
    end
  end

  context "Métodos de classe" do
    describe ".gerar_por_string_csv" do

      subject(:customer) { create :customer, endereco: nil, representative: nil }
      subject(:string_csv_virgula) { "Tia Maria,F,5499863462,maria.conceicao@yahoo.com.br,Dona de Casa,11/10/1978" }
      subject(:string_csv_ponto_e_virgula) { "Tia Maria;F;5499863462;maria.conceicao@yahoo.com.br;Dona de Casa;11/10/1978" }
      subject(:string_csv_tab) { "Tia Maria\tF\t5499863462\tmaria.conceicao@yahoo.com.br\tDona de Casa\t11/10/1978" }

      it "deve gerar um contato com string csv correta, separada por vírgulas" do
        c = Contact.gerar_por_string_csv(string_csv_virgula, customer, {col_sep: ",", encoding: Encoding::UTF_8})
        expect(Contact.count).to eq(1)
      end

      it "deve gerar um contato com string csv correta, separada por ponto e vírgulas" do
        Contact.gerar_por_string_csv(string_csv_ponto_e_virgula, customer, {col_sep: ";", encoding: Encoding::UTF_8})
        expect(Contact.count).to eq(1)
      end

      it "deve gerar um contato com string csv correta, separada por tabulação" do
        Contact.gerar_por_string_csv(string_csv_tab, customer, col_sep: "\t", encoding: Encoding::UTF_8)
        expect(Contact.count).to eq(1)
      end

      it "deve inserir dois registros se os mesmos forem separados por quebra de linha" do
        Contact.gerar_por_string_csv("#{string_csv_virgula}\n" * 2, customer)
        expect(Contact.count).to eq(2)
      end

      it "não deve permitir um separador inválido ao separador que foi informado" do
        Contact.gerar_por_string_csv(string_csv_virgula, customer, col_sep: "\t")
        expect(Contact.count).to eq(0)
      end

      it "não deve permitir um formato inválido para sexo" do
        Contact.gerar_por_string_csv("John Doe,Macho,5499863462", customer)
        expect(Contact.count).to eq(0)
      end

      it "não deve permitir um formato inválido para data de nascimento" do
        Contact.gerar_por_string_csv("John Doe,M,5499863462,,,11/10/92", customer)
        expect(Contact.count).to eq(0)
      end

      it "deve retornar erro para o nome caso o mesmo seja inválido" do
        erros = Contact.gerar_por_string_csv(",M,5499863462\n" + string_csv_virgula, customer)
        expect(erros.first.first.last[:nome].size).to eq(1)
      end
    end
  end
end
