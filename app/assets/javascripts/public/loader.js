loader = {
  qtd: 0,
  show: function() {
    loader.qtd++;
    $("#bg-loader").removeClass("hide").focus();
  },
  hide: function() {
    loader.qtd--;
    if (loader.qtd <= 0) {
      loader.qtd = 0;
      $("#bg-loader").addClass("hide");
    }
  }
}