angular.module("ronaldosurdi.filters", [])
  .filter("customJson", function() {
    return function(lista, keys, names) {
      var ret = [];

      for (var i = 0; i < lista.length; i++) {
        var object = lista[i];
        var novo = {}
        var j = 0;
        for (k in  object) {
          if (keys.indexOf(k) >= 0) {
            novo[names && names.length > j ? names[j] :  k] = (object[k] == "$index" ? i : object[k]);
          }

          j++;
        }

        ret.push(novo);
      };

      return JSON.stringify(ret);
    };
  });