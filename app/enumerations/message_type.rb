class MessageType < EnumerateIt::Base
  associate_values(
    sent: [1, "Enviada"],
    received: [2, "Recebida"]
  )
end