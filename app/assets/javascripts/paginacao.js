$(document).on("page:change", function() {
  $("body").on("click", ".paginate-anything .pagination a", function() {
    $("body").scrollTop(0);
  });
});