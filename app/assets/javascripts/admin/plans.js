$(document).on("page:change", function(e) {
  if (!$("body").hasClass("plans")) return;

  $("#plan_valor_total, #plan_quantidade_sms").on("keyup", function() {
    var valorUnitario = $("#plan_valor_unitario");

    try {
      var valorTotal = parseFloat($("#plan_valor_total").attr("value").replace("R$ ", "").replace(".", "").replace(",", "."));
      var quantidade = parseFloat($("#plan_quantidade_sms").attr("value"));

      if (quantidade <= 0 || valorTotal <= 0 || isNaN(quantidade) || isNaN(valorTotal) ) {
        valorUnitario.attr("value", "R$ 0,00000");
      } else {
        valorUnitario.attr("value", "R$ " + String((valorTotal / quantidade).toFixed(5)).replace(/\./, ','));
      }
    }
    catch(e) {
      valorUnitario.attr("value", "R$ 0,00000");
    }
  });
});