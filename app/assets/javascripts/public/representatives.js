$(document).on("page:change", function(e) {
  window.representatives = {};

  representatives.init = function() {
    $("#representative_endereco_attributes_cep").on("change", representatives.loadCep);
    $("#new_representative").on("submit", function() {
        $("#representative_endereco_attributes_uf").removeAttr("disabled");
    });
  };

  representatives.loadCep = function() {
    loader.show();
    $("new_representative *").attr("disabled", true);
    $.ajax({
      url: Routes.public_cep_path($(this).val()),
      type: "GET",
      complete: function() {
        loader.hide();
        $("new_representative *").removeAttr("disabled");
        if ($("#representative_endereco_attributes_cidade").val() !== "") {
          $("#representative_endereco_attributes_logradouro").focus();
        } else {
          $("#representative_endereco_attributes_cep").focus();
        }
      }
    });
  }

  representatives.init();
});
