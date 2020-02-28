sendmy
  .controller("ProfileController", ["$scope", "$http", function($scope, $http) {
    $scope.address = {};
    $scope.cepSearch = {};

    $scope.loadCepInfo = function(cep) {
      if (!cep || cep.length < 8) return;

      $scope.cepSearch.loading = true;

      $http.get(Routes.cep_path(cep))
        .success(function(data) {
          var address = {
            logradouro: data.tipo_logradouro + " " + data.logradouro,
            bairro: data.bairro,
            cidade: data.cidade,
            uf: data.uf
          };

          $.extend($scope.address, address);
          $scope.cepSearch = {};
          $("#representative_endereco_attributes_logradouro").focus();
        })
        .error(function(data) {
          $scope.cepSearch.loading = false;
          $scope.cepSearch.error = true;
          alert(data.message);
          $("#representative_endereco_attributes_cidade").focus();
        });
    };
  }]);