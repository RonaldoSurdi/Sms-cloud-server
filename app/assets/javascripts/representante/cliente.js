$(document).on("page:change", function(e) {
  if ($(".pricing-tables").length == 0 && $("body.customers").length == 0) return;
  $("#s2id_sale_customer_id .select2-chosen").text("");

  if ($("[data-select]").length > 0 && $("[data-select]").attr("data-select") !== "") {
    $("[data-select]").select2("val", $("[data-select]").attr("data-select"));
    $("[data-select]").trigger("change");
  }
});