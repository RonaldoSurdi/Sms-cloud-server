ronaldosurdi
  .controller("LicenseMovementController", ["$scope", "$http", "Ordering", function($scope, $http, Ordering) {
    $scope.movimentacaoLicencas = [];
    $scope.filters = {};

    $scope.pesquisar = function() {
      $scope.filtersPaginate = angular.copy($scope.filters);
    }

    $scope.limparFiltros = function() {
      $scope.filters = {order: "licenca_descricao asc"}
      $scope.filtersPaginate = {clear: true};
    }

    $scope.order = function(order) {
      $scope.filters.order = Ordering.order(order, $scope.filters.order);
      $scope.pesquisar();
    }

    $scope.orderClass = function(order) {
      return Ordering.orderClass(order, $scope.filters.order);
    }
  }]);