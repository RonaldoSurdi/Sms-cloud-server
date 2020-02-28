$(document).on("page:change", function() {
  if ($(".pricing-tables").length == 0 && $("body.license_movements").length == 0) return;

  var total = function() {
    var valores = $(".pricing-tables *[data-valor]");
    var total = 0;

    for (var i = 0; i < valores.length; i++) {
      total += parseFloat($(valores[i]).attr("data-valor"));
    }

    $("[data-total]").text(formatarValor(total));
  }

  var atualizar = function(elemento) {
    var subtotal = parseFloat(elemento.data("valor-unitario")) * parseInt(elemento.val());
    if (subtotal > 0) {
      elemento
        .next("[data-subtotal]")
        .attr("data-valor", subtotal)
        .text(formatarValor(subtotal));
    } else {
      elemento.attr("value", 0);
      elemento
        .next("[data-subtotal]")
        .attr("data-valor", 0)
        .html("&nbsp;");
    }
    total();
  }

  var formatarValor = function(valor) {
    var valorString = String(valor.toFixed(2).replace(".", ","))
    var valorPreVirgula = valorString.split(",")[0]
    var valorPosVirgula = valorString.split(",")[1]
    var valorPontuado = "";

    valorPreVirgula = valorPreVirgula.split("").reverse().join("");

    if (valorPreVirgula.length > 3) {
      for (var i = 1; i <= valorPreVirgula.length; i++) {
        stringParaConcatenar = valorPreVirgula[i-1];

        if ((i % 3) == 0) {
          stringParaConcatenar = "." + stringParaConcatenar;
        }

        valorPontuado = stringParaConcatenar + valorPontuado;
      }

      if (valorPreVirgula.length > 3) {
        if (valorPontuado[0] == ".") {
          valorPontuado = valorPontuado.slice(1)
        }
        valorPontuado = "R$ " + valorPontuado + "," + valorPosVirgula;
      }
    } else {
      valorPontuado = "R$ " + valorString;
    }

    return valorPontuado;
  }

  $(".pricing-tables input[data-valor-unitario]").on("change keyup", function() {
    atualizar($(this));
  });

  $("[data-valor-unitario]").on("click", function() {
    $(this).select();
  });

  var elementos = $(".pricing-tables input[data-valor-unitario]");
  for (var i = 0; i < elementos.length; i++) {
    atualizar($(elementos[i]));
  };
  app.clearDirty();
});