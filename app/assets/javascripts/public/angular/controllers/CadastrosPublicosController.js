ronaldosurdi
  .controller("CadastrosPublicosController", ["$scope", "$http", function($scope, $http) {
    $scope.address = {};
    $scope.cepSearch = {};

    $scope.$watch('cepSearch.loading', function(loading) {
      if (loading) {
        loader.show();
      } else {
        loader.hide();
      }
    });

    $scope.loadCepInfo = function(cep) {
      if (!cep || cep.length < 8) return;

      $scope.cepSearch.loading = true;
      loader.show();

      $http.get(Routes.cep_path(cep))
        .success(function(data) {
          console.log(data);
          var address = {
            logradouro: data.tipo_logradouro + " " + data.logradouro,
            bairro: data.bairro,
            cidade: data.cidade,
            uf: data.uf
          };

          $.extend($scope.address, address);
          $scope.cepSearch = {};
          $("input[id*='logradouro']:first").focus();
        })
        .error(function(data) {
          $scope.cepSearch.loading = false;
          $scope.cepSearch.error = true;
          alert(data.message);
          $("input[id*='cidade']:first").focus();
        });
    };
  }]);