sendmy
  .controller("RoleController", ["$scope", "$http", "Ordering", function($scope, $http, Ordering) {
    $scope.roles = [];
    $scope.filters = {};

    $scope.pesquisar = function() {
      $scope.filtersPaginate = angular.copy($scope.filters);
    }

    $scope.limparFiltros = function() {
      $scope.filters = {order: "description asc"}
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