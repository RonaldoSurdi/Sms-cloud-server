$(document).on("page:change", function(e) {
  $("select.select2").each(function() {
    if ($("body.customers").length > 0) {
      $(this).select2({
        allowClear: true,
        placeholder: "Preencha caso tenha sido indicado por um dos nossos representantes"
      });
    }
  });

  if ($("body").hasClass("importacao")) {
    var rows = $(".sync-height-row");


    for (var i = 0; i < rows.length; i++) {
      var boxes = $(rows[i]).children().children(".sync-height-boxes");
      var height = 0;

      for (var i = 0; (i + 1) < boxes.length; i++) {
        var box1 = $(boxes[i]);
        var box2 = $(boxes[i+1]);

        if (box1.outerHeight() > box2.outerHeight() && box1.outerHeight() > height)
          height = box1.outerHeight();
        else if (box2.outerHeight() > height)
          height = box2.outerHeight();
      };

      for (var i = 0; i < boxes.length; i++) {
        $(boxes[i]).attr("style", "height: " + height + "px;");
      };
    };
  }
});