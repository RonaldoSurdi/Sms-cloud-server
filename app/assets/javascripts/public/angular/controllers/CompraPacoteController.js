sendmy
  .controller("CompraPacoteController", ["$scope", "$http", "$window", function($scope, $http, $window) {
  $scope.buscando = false;
  $scope.pacote;

  $scope.enviarForm = function($event, pacoteId) {
    if ($window.confirm("Você tem certeza que deseja adquirir este pacote?"))
      $scope.pacoteSelecionadoId = pacoteId;
    else
      $event.preventDefault();
  };

  $scope.buscarPacotePorCodigoPagSeguro = function(codigoPagSeguro) {
    $scope.buscando = true;

    $http.get(Routes.compra_pacote_path({id: codigoPagSeguro, format: "json"}))
    .success(function(data) {
      $scope.pacote = data;
      $scope.buscando = false;
    })
    .error(function() {
      $scope.buscando = false;
    });
  };

  $scope.capitalize = function(word) {
    if (word)
      return word.slice(0, 1).toUpperCase() + word.slice(1);
    else
      return word;
  };
}]);