class AddContatoNomeToMessages < ActiveRecord::Migration
  def up
    add_column :messages, :contato_nome, :string

    Message.transaction do
      Message.all.each do |msg|
        contato_nome = Contact.where(celular: msg.to).first.try(:nome)
        contato_nome = contato_nome.present? ? contato_nome : nil
        msg.update! contato_nome: contato_nome
      end
    end
  end

  def down
    remove_column :messages, :contato_nome, :string
  end
end
