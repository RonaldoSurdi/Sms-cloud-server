ronaldosurdi
  .controller("PlanMovementController", ["$scope", "$http", "Ordering", "filterFilter", function($scope, $http, Ordering, filterFilter) {
    $scope.movimentacaoPlanos = [];
    $scope.filters = {};
    $scope.marcados = {};

    $scope.pesquisar = function() {
      $scope.filtersPaginate = angular.copy($scope.filters);
    }

    $scope.limparFiltros = function() {
      $scope.filters = {order: "plano_descricao asc"}
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
      if (!$scope.plan_movements) return;

      $scope.checkAll = true;
      for (var i = 0; $scope.checkAll && i < $scope.plan_movements.length; i++) {
        var plan_movement = $scope.plan_movements[i];
        $scope.checkAll = $scope.checkAll && plan_movement.marcado;
      };
    }

    $scope.$watch("plan_movements", function () {
      if (!$scope.plan_movements) return;
      for (var i = 0; i < $scope.plan_movements.length; i++) {
        var plan_movement = $scope.plan_movements[i];
        plan_movement.marcado = typeof($scope.marcados[plan_movement.id]) != "undefined";
      };
      updateCheckAll();
    });

    $scope.marcarPlan = function(plan) {
      if (!plan.marcado) {
        plan.marcado = true;
        $scope.marcados[plan.id] = plan;
      } else {
        plan.marcado = false;
        delete $scope.marcados[plan.id];
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
      for (var i = 0; i < $scope.plan_movements.length; i++) {
        $scope.plan_movements[i].marcado = true;
        $scope.marcados[$scope.plan_movements[i].id] = $scope.plan_movements[i];
      };
    }

    $scope.desmarcarTodos = function() {
      for (var i = 0; i < $scope.plan_movements.length; i++) {
        $scope.plan_movements[i].marcado = false;
        delete $scope.marcados[$scope.plan_movements[i].id];
      };
    }
  }]);