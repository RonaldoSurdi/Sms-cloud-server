$(document).on("page:change", function(e) {
  customer = {};

  customer.init = function() {
    if (!$("section").hasClass("cadastro-clientes")) return;
    $("#customer_tipo_pessoa_fisica").on("change", customer.atualizarTipoPessoa);
    $("#customer_tipo_pessoa_juridica").on("change", customer.atualizarTipoPessoa);
    $("#customer_endereco_attributes_cep").on("change", customer.loadCep);

    $("#new_customer").on("submit", function() {
        $("#customer_endereco_attributes_uf").removeAttr("disabled");
    });
    $("#edit_customer").on("submit", function() {
        $("#customer_endereco_attributes_uf").removeAttr("disabled");
    });

    //esconder erro de cpf/cnpj caso troque de tipo de pessoa
    $("span.radio").on("click", function() {
      var cpfCnpj = $(".customer_cpf_cnpj.has-error");
      cpfCnpj.children("span.help-block").hide();
      cpfCnpj.removeClass("has-error");
    });

    var params = window.location.search.replace(/^\?/, '').split('&');
    for (var i = 0; i < params.length; i++) {
      var key = params[i].split('=')[0];
      var value = params[i].split('=')[1];
      if (key && value) {
        $("#customer_" + key).val(value);
      }
    }

    customer.atualizarTipoPessoa();
  };

  customer.atualizarTipoPessoa = function() {
    var fisica = $("#customer_tipo_pessoa_fisica");
    var juridica = $("#customer_tipo_pessoa_juridica")
    var labelNome = $("label[for=customer_nome]");
    var labelCpfCnpj = $("label[for=customer_cpf_cnpj]");
    var input = $("#customer_cpf_cnpj");
    var razaoSocial = $("#customer_razao_social");
    var requiredText = '<abbr title="requerido">*</abbr>&nbsp;'

    if ($("#customer_tipo_pessoa_fisica").prop("checked") === true) {
      labelNome.html(requiredText + "Nome completo");
      labelCpfCnpj.html(requiredText + "CPF");
      input.mask(App.masks.CPF);
      razaoSocial.removeAttr("required").parents("div.form-group").hide();
      } else {
      labelNome.html(requiredText + "Nome Fantasia");
      labelCpfCnpj.html(requiredText + "CNPJ");
      input.mask(App.masks.CNPJ);
      razaoSocial.attr("required", "required").parents("div.form-group").show();
    }
  }

  customer.loadCep = function() {
    loader.show();
    $("new_customer *").attr("disabled", true);
    $("edit_customer *").attr("disabled", true);

    $.ajax({
      url: Routes.public_cep_path($(this).val()),
      type: "GET",
      complete: function() {
        loader.hide();
        $("new_customer *").removeAttr("disabled");
        $("edit_customer *").removeAttr("disabled");
        if ($("#customer_endereco_attributes_cidade").val() !== "") {
          $("#customer_endereco_attributes_logradouro").focus();
        } else {
          $("#customer_endereco_attributes_cep").focus();
        }
      }
    });
  }

  customer.init();
});
