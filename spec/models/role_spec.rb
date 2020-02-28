require 'rails_helper'

RSpec.describe Role, :type => :model do
  it { should be_a_kind_of ActiveRecord::Base }
  it { should have_and_belong_to_many :administrators }
  it { should have_many :permissions }
  it { should accept_nested_attributes_for :permissions }
  it { should validate_presence_of :description }

  context "Métodos de classe" do
    subject { Role }

    describe ".filter" do
      before do
        create :role
      end

      let :description_filter do
        "$&descricao para o filtro&$"
      end

      let :partial_size do
        (description_filter.size / 2).round
      end

      let :unique_token do
        Faker::Internet.password(30)
      end

      it "deve retornar todos os registros se o filtro estiver em branco" do
        create :role
        expect(subject.filter("").count).to eql(2)
      end

      it "deve retornar o registro que possuir a descrição a ser filtrada" do
        create :role, description: description_filter
        expect(subject.filter(description_filter).count).to eql(1)
      end

      it "deve retornar o registro que possuir parte da descrição a ser filtrada" do
        create :role, description: description_filter
        expect(subject.filter(description_filter[0..partial_size]).count).to eql(1)
      end

      it "não deve retornar nenhum registro caso o filtro não possa ser encontrado" do
        expect(subject.filter(unique_token).count).to eql(0)
      end
    end
  end

  context "Métodos de instância" do
    describe "#destroy" do
      subject { create :role }

      it "deve eliminar o registro se não for a role principal" do
        subject.destroy
        expect(Role.count).to eq(0)
      end

      it "não deve eliminar o registro se for a role principal" do
        subject.full_control = true
        subject.destroy
        expect(Role.count).to eq(1)
      end
    end
  end
end
