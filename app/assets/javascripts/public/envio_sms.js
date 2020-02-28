$(document).on("page:change", function() {
  if ($("body.envios").length === 0) return;

  $("#selecionar_contatos").on("click", function() {
    $('#selecionar_contatos_envio_modal').modal();

    window.setTimeout(function() {
      $("#selecionar_contatos_envio_modal input:first").focus();
    }, 500);
  });

  $("#adicionar_numero").on("click", function() {
    $('#adicionar_numero_envio_modal').modal();

    window.setTimeout(function() {
      $("#adicionar_numero_envio_modal input:first").focus();
    }, 500);
  });

  $("select.select2").each(function() {
    $(this).select2({
      allowClear: true
    });
  });

  $("#filtro_aniversario_mes").on("change", function() {
    var filtroMes = $(this);
    var filtroDia = $("#filtro_aniversario_dia");
    filtroDia.empty();

    if (filtroMes.val() !== "") {
      filtroDia.removeAttr("disabled");

      for (var i = 0; i < daysInMonth(parseInt(filtroMes.attr("value"))); i++) {
        filtroDia.append($("<option>").attr("value", i + 1).append(i + 1));
      };
    } else {
      filtroDia.attr("disabled", "disabled");
    }

    filtroDia.trigger('change');
  });

  $("th.only-checkbox").on("click", function(e) {
    $($(e.target).children()[0]).click();
  });

  $("select.datetime").on("change", function() {
    var objMinutos = $("#message_schedule_5i");
    var objHoras = $("#message_schedule_4i");
    var objDia = $("#message_schedule_3i");
    var objMes = $("#message_schedule_2i");
    var objAno = $("#message_schedule_1i");

    var date = objAno.val() + '-' + objMes.val() + '-' + objDia.val();
    var time = objHoras.val() + ':' + objMinutos.val();
    var datetime = date + " " + time;


    if (moment().isAfter(datetime)) {
      objMinutos.val(moment().format("mm"));
      objHoras.val(moment().format("HH"));
      objDia.val(moment().format("D"));
      objMes.val(moment().format("M"));
      objAno.val(moment().format("YYYY"));
    }
  });

  var daysInMonth = function(month) {
    return new Date(new Date().getFullYear(), month, 0).getDate();
  }
});