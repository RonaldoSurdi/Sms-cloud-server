$(document).on("page:change", function() {
  if ($(".marcar-todas-acoes").length == 0) return;

  $(".marcar-todas-acoes").on("click", function(e) {
    e.preventDefault();
    $(this).parent().find("input[type=checkbox]").prop('checked', true);
  });

  $(".desmarcar-todas-acoes").on("click", function(e) {
    e.preventDefault();
    $(this).parent().find("input[type=checkbox]").prop('checked', false);
  });
});