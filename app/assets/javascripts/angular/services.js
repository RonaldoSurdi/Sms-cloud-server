angular.module("sendmy.services", [])

.factory("Ordering",function() {
  return {
    order: function(newOrder, oldOrder) {
      var ret;

      if (oldOrder.indexOf(newOrder) >= 0) {
        ret = newOrder + " " + (oldOrder.indexOf(" desc") >= 0 ? "asc" : "desc");
      } else {
        ret = newOrder + " asc";
      }

      return ret;
    },
    orderClass: function(field, order) {
      var ret = "order";

      if (order.match(new RegExp("^" + field + "[$\\s]"))) {
        ret += " " + (order.indexOf(" desc") >= 0 ? "order-desc-active" : "order-asc-active");
      }

      return ret;
    }
  }
})

.factory("Formating", function() {
  return {
    phoneFormat: function(phoneOnlyNumbers) {
      if (phoneOnlyNumbers != null && phoneOnlyNumbers != "") {
        return phoneOnlyNumbers.replace(/([0-9]{2})([0-9]{4})([0-9]+)/, '($1) $2-$3');
      } else {
        return "";
      }
    },
    dateBrFormat: function(dateEnglish) {
      if (dateEnglish != null && dateEnglish != "") {
        return dateEnglish.split("-").reverse().join("/");
      } else {
        return "";
      }
    },
    dateTimeBrFormat: function(dateTimeEnglish) {
      if (dateTimeEnglish) {
        return moment(Date.parse("2014-08-14T19:13:51.000-03:00")).format("DD/MM/YYYY mm:ss");
      } else {
        return "";
      }
    },
    titleFormat: function(title) {
      var formattedTitle = "";

      if (title) {
        title.split(" ").forEach(function(word) {
          formattedTitle = word[0].toUpperCase() + word.slice(1);
        });
      }

      return formattedTitle;
    }
  };
});