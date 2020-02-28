ronaldosurdi
  .controller("LicenseMovementController", ["$scope", "$http", "Ordering", "filterFilter", function($scope, $http, Ordering, filterFilter) {
    $scope.movimentacaoLicencas = [];
    $scope.filters = {};
    $scope.marcados = {};

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

    var updateCheckAll = function() {
      if (!$scope.license_movements) return;

      $scope.checkAll = true;
      for (var i = 0; $scope.checkAll && i < $scope.license_movements.length; i++) {
        var license_movement = $scope.license_movements[i];
        $scope.checkAll = $scope.checkAll && license_movement.marcado;
      };
    }

    $scope.$watch("license_movements", function () {
      if (!$scope.license_movements) return;
      for (var i = 0; i < $scope.license_movements.length; i++) {
        var license_movement = $scope.license_movements[i];
        license_movement.marcado = typeof($scope.marcados[license_movement.id]) != "undefined";
      };
      updateCheckAll();
    });

    $scope.marcarLicense = function(license) {
      if (!license.marcado) {
        license.marcado = true;
        $scope.marcados[license.id] = license;
      } else {
        license.marcado = false;
        delete $scope.marcados[license.id];
      }
      updateCheckAll();
    }

    $scope.doCheckAll = function() {
      if (!$scope.checkAll) {
        $scope.marcarTodos();
      } else {
        $scope.desmarcarTodos();
      }
    }

    $scope.keys = function(obj) {
      return Object.keys(obj);
    }

    $scope.marcarTodos = function() {
      for (var i = 0; i < $scope.license_movements.length; i++) {
        $scope.license_movements[i].marcado = true;
        $scope.marcados[$scope.license_movements[i].id] = $scope.license_movements[i];
      };
    }

    $scope.desmarcarTodos = function() {
      for (var i = 0; i < $scope.license_movements.length; i++) {
        $scope.license_movements[i].marcado = false;
        delete $scope.marcados[$scope.license_movements[i].id];
      };
    }
  }]);