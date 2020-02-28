sendmy
  .controller("CustomerController", ["$scope", "$http", "Ordering", function($scope, $http, Ordering) {
    $scope.representantes = [];
    $scope.filters = {};

    $scope.pesquisar = function() {
      $scope.filtersPaginate = angular.copy($scope.filters);
    }

    $scope.limparFiltros = function() {
      $scope.filters = {order: "nome asc"}
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