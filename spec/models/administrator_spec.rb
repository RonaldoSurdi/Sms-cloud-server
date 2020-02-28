require 'rails_helper'

RSpec.describe Administrator, :type => :model do
  it { should be_a_kind_of(ActiveRecord::Base) }

  context "É necessário validar os campos obrigatórios e não obrigatórios corretamente" do
    subject { build :administrator }

    describe "#name" do
      it "deve ser válido caso possua um nome" do
        expect(subject).to be_valid
      end

      it "não deve ser válido caso não possua um nome" do
        subject.name = nil
        expect(subject).to_not be_valid
      end
    end

    describe "#authenticate_password" do
      subject { create :administrator }

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

  context "Métodos de classe" do
    subject { Administrator }

    describe ".filter" do
      before do
        create :administrator
      end

      let :nome_filtro do
        "$&nome para o filtro&$"
      end

      let :email_filtro do
        "adm_email_filtro@email.com"
      end

      let :partial_size do
        if nome_filtro.size <= email_filtro.size
          (nome_filtro.size / 2).round
        else
          (email_filtro.size / 2).round
        end
      end

      let :unique_token do
        Faker::Internet.password(30)
      end

      it "deve retornar todos os registros se o filtro estiver em branco" do
        create :administrator
        expect(subject.filter("").count).to eql(2)
      end

      it "deve retornar o registro que possuir o nome a ser filtrado" do
        create :administrator, name: nome_filtro
        expect(subject.filter(nome_filtro).count).to eql(1)
      end

      it "deve retornar o registro que possuir o email a ser filtrado" do
        create :administrator, email: email_filtro
        expect(subject.filter(email_filtro).count).to eql(1)
      end

      it "deve retornar o registro que possuir parte do nome a ser filtrado" do
        create :administrator, name: nome_filtro
        expect(subject.filter(nome_filtro[0..partial_size]).count).to eql(1)
      end

      it "deve retornar o registro que possuir parte do email a ser filtrado" do
        create :administrator, email: email_filtro
        expect(subject.filter(email_filtro[0..partial_size]).count).to eql(1)
      end

      it "não deve retornar nenhum registro caso o filtro não possa ser encontrado" do
        expect(subject.filter(unique_token).count).to eql(0)
      end
    end
  end
end
