require 'rails_helper'

RSpec.describe Representative, :type => :model do
  it { should be_a_kind_of ActiveRecord::Base }
  it { should belong_to :endereco }
  it { should accept_nested_attributes_for :endereco }
  it { should have_many :customers }
  it { should have_many :license_movements }
  it { should validate_presence_of :razao_social }
  it { should validate_presence_of :nome_fantasia }
  it { should validate_presence_of :cnpj }
  it { should validate_presence_of :responsavel }
  it { should validate_presence_of :telefone }
  it { should validate_length_of :telefone }
  it { should validate_length_of :celular }
  it { should validate_length_of :inscricao_estadual }

  context "Métodos de classe" do
    subject { Representative }

    describe ".filter" do
      before do
        create :representative
      end

      let :palavra_filtro do
        "$$palavra_representative teste_para_filtro$$"
      end

      let :email_filtro  do
        "email_representative_teste_para_filtro@hotmail.com"
      end

      let :cnpj_telefone_filtro  do
        BrFaker::Cnpj.cnpj(false)
      end

      let :unique_token do
        Faker::Internet.password(30)
      end

      let :partial_size do
        if (palavra_filtro < email_filtro && palavra_filtro < cnpj_telefone_filtro)
          (palavra_filtro.size / 2).round
        elsif (email_filtro < palavra_filtro && email_filtro < cnpj_telefone_filtro)
          (email_filtro.size / 2).round
        else
          (cnpj_telefone_filtro.size / 2).round
        end
      end

      it "deve retornar todos os registros se o filtro estiver em branco" do
        create :representative
        expect(subject.filter("").count).to eql(2)
      end

      it "deve retornar o registro que possuir o nome a ser filtrado" do
        create :representative, nome_fantasia: palavra_filtro
        expect(subject.filter(palavra_filtro).count).to eql(1)
      end

      it "deve retornar o registro que possuir a razão social a ser filtrada" do
        create :representative, razao_social: palavra_filtro
        expect(subject.filter(palavra_filtro).count).to eql(1)
      end

      it "deve retornar o registro que possuir o CNPJ a ser filtrado" do
        create :representative, cnpj: cnpj_telefone_filtro
        expect(subject.filter(cnpj_telefone_filtro).count).to eql(1)
      end

      it "deve retornar o registro que possuir o responsável a ser filtrado" do
        create :representative, responsavel: cnpj_telefone_filtro
        expect(subject.filter(cnpj_telefone_filtro).count).to eql(1)
      end

      it "deve retornar o registro que possuir o telefone a ser filtrado" do
        create :representative, telefone: cnpj_telefone_filtro
        expect(subject.filter(cnpj_telefone_filtro).count).to eql(1)
      end

      it "deve retornar o registro que possuir o email a ser filtrado" do
        create :representative, email: email_filtro
        expect(subject.filter(email_filtro).count).to eql(1)
      end

      it "deve retornar o registro que possuir o nome parcial a ser filtrado" do
        create :representative, nome_fantasia: palavra_filtro
        expect(subject.filter(palavra_filtro[0..partial_size]).count).to eql(1)
      end

      it "deve retornar o registro que possuir a razão social parcial a ser filtrada" do
        create :representative, razao_social: palavra_filtro
        expect(subject.filter(palavra_filtro[0..partial_size]).count).to eql(1)
      end

      it "deve retornar o registro que possuir o CNPJ parcial a ser filtrado" do
        create :representative, cnpj: cnpj_telefone_filtro
        expect(subject.filter(cnpj_telefone_filtro[0..partial_size]).count).to eql(1)
      end

      it "deve retornar o registro que possuir o responsável parcial a ser filtrado" do
        create :representative, responsavel: cnpj_telefone_filtro
        expect(subject.filter(cnpj_telefone_filtro[0..partial_size]).count).to eql(1)
      end

      it "deve retornar o registro que possuir o telefone parcial a ser filtrado" do
        create :representative, telefone: cnpj_telefone_filtro
        expect(subject.filter(cnpj_telefone_filtro[0..partial_size]).count).to eql(1)
      end

      it "deve retornar o registro que possuir o email parcial a ser filtrado" do
        create :representative, email: email_filtro
        expect(subject.filter(email_filtro[0..partial_size]).count).to eql(1)
      end

      it "não deve retornar nenhum registro caso o filtro não possa ser encontrado" do
        expect(subject.filter(unique_token).count).to eql(0)
      end
    end

    describe ".por_status" do
      before do
        Representative.transaction do
          create :representative, cadastro_aprovado: true
          2.times { create :representative, cadastro_aprovado: false }
        end
      end

      it "deve retornar todos os registros se o tipo estiver em branco" do
        expect(subject.por_status("").count).to eql(3)
      end

      it "deve retornar todos os registros se o tipo for 'todos'" do
        expect(subject.por_status(:todos).count).to eql(3)
      end

      it "deve retornar os registros de tipo 'aprovado' se for solicitado" do
        expect(subject.por_status(:aprovado).count).to eql(1)
      end

      it "deve retornar os registros de tipo 'nao_aprovado' se for solicitado" do
        expect(subject.por_status(:nao_aprovado).count).to eql(2)
      end
    end

    describe ".por_uf" do
      before do
        Representative.transaction do
          create :representative, representante_principal: true, endereco: create(:endereco, uf: 'RS')
          create :representative, endereco: create(:endereco, uf: 'RN')
          2.times { create :representative, endereco: create(:endereco, uf: 'PR') }
        end
      end

      it "deve retornar o representante principal se o estado não existir" do
        expect(subject.joins(:endereco).por_uf("XX").count).to eql(1)
      end

      it "deve retornar todos os registros com o estado 'RS'" do
        expect(subject.joins(:endereco).por_uf("RS").count).to eql(1)
      end

      it "deve retornar os registros com estado 'PR' e o representante principal" do
        expect(subject.joins(:endereco).por_uf("PR").count).to eql(3)
      end
    end

    describe ".confirm_by_token" do
      let :representative do
        create :representative, endereco: nil
      end

      before do
        @raw_token, representative.confirmation_token = Devise.token_generator.generate(subject, :confirmation_token)
        representative.save
      end

      it "deve confirmar o representante que possuir o token de confirmação correto" do
        expect(subject.confirm_by_token(@raw_token).id).to_not be_nil
      end

      it "não deve confirmar o representante que possuir o token de confirmação incorreto" do
        expect(subject.confirm_by_token(@raw_token + "123").id).to be_nil
      end

      it "não deve confirmar o representante que possuir o token de confirmação correto, porém outro representante confirmado já ter seu cnpj" do
        representative2 = build :representative, cnpj: representative.cnpj
        representative2.save

        expect(subject.confirm_by_token(@raw_token).errors).to_not be_blank
      end
    end
  end

  context "Métodos de instância" do
    subject { build(:representative, endereco: nil) }

    describe "#cnpj_formatado" do
      it "deve formatar corretamente um CNPJ" do
        expect(subject.cnpj_formatado.size).to eq(18)
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

    describe "#authenticate_password" do
      subject { create :representative, endereco: nil }

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
  end
end
