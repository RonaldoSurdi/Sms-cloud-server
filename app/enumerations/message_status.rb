class MessageStatus < EnumerateIt::Base
  associate_values(
    pending: [1, "Pendente"],
    sending: [2, "Enviando"],
    success: [3, "Sucesso"],
    error: [4, "Erro"]
  )
end