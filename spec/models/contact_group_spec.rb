require 'rails_helper'

RSpec.describe ContactGroup, :type => :model do
  it { should be_a_kind_of(ActiveRecord::Base) }
  it { should belong_to(:customer) }

  context "É necessário validar os campos obrigatórios e não obrigatórios corretamente" do
    subject { build :contact_group }

    describe "#descricao" do
      it "deve ser válido caso possua um descrição" do
        expect(subject).to be_valid
      end

      it "não deve ser válido caso não possua um descrição" do
        subject.descricao = nil
        expect(subject).to_not be_valid
      end
    end

    describe "#observacao" do
      it "deve ser válido caso possua uma observação" do
        subject.observacao = "Observação teste"
        expect(subject).to be_valid
      end

      it "deve ser válido caso não possua uma observação" do
        subject.observacao = nil
        expect(subject).to be_valid
      end
    end
  end
end
