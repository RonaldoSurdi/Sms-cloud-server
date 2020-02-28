class PublicMailer < BaseMailer
  default to: "SendMy <#{EMAIL_CONTATO}>"

  def fale_conosco_mensagem(informacoes_contato)
    @nome = informacoes_contato["nome"]
    @email = informacoes_contato["email"]
    @telefone = informacoes_contato["telefone"]
    @mensagem = informacoes_contato["mensagem"]
    mail subject: "Mensagem Pública - #{@nome}"
  end
end
