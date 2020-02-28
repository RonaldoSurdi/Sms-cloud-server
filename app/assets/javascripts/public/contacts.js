$(document).on('page:change', function() {
  if ($(".new_contact, .edit_contact").length == 0) return;

  window.openModalContactGroups = function() {
    if ($(".select2-dropdown-open").length == 0) return;

    $("#new_contact_modal, #edit_contact_modal").modal("show");
    $("select.select2").select2("close");
    setTimeout(function() { $("#contact_group_descricao").focus() }, 500);
  }

  if ($("#btn-new-contact-group").length == 0) {
    var buttonCriarNovo = $("<button>")
    .addClass("btn btn-primary btn-sm")
    .text("Criar Novo")
    .attr("id", "btn-new-contact-group")
    .attr("onclick", "openModalContactGroups()");

    var wrapper = $("<div>")
    .addClass("text-center")
    .css("margin", "10px")
    .append(buttonCriarNovo)
    .appendTo(".select2-drop");
  };
});

$(document).on('page:change', function() {
  if ($(".index_contacts").length == 0) return;

  window.alphabet = ['a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z','1'];

  $('#slider').sliderNav({items:alphabet, height:'522'});

  $('a[alt=#'
    .concat(window.alphabet[window.alphabet.length - 1])
    .concat(']'))
      .text("#");

  $("select.select2").select2({
    placeholder: "Filtrar por grupo...",
    allowClear: true
  }).select2("enable");
});
