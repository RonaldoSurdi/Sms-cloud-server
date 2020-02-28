ronaldosurdi
  .controller("RepresentativeController", ["$scope", "$http", "Ordering", function($scope, $http, Ordering) {
    $scope.representatives = [];
    $scope.filters = {};

    $scope.pesquisar = function() {
      $scope.filtersPaginate = angular.copy($scope.filters);
    }

    $scope.limparFiltros = function() {
      $scope.filters = {order: "nome_fantasia asc"}
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