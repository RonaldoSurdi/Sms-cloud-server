ronaldosurdi
  .controller("RelatorioController", ["$scope", "$http", "$interval", "$rootScope", function($scope, $http, $interval, $rootScope) {

  var REFRESH_INTERVAL = 30;

  var inicializar = function() {
    window.intervalRelatorios = setInterval(function() {
      $scope.contador -= 1;
      $scope.$apply();

      if ($scope.contador <= 0) {
        clearInterval(window.intervalRelatorios);
        Turbolinks.visit(window.location.href);
      }
    }, 1000);
  }

  $scope.init = function (argument) {
    $scope.contador = REFRESH_INTERVAL;
    clearInterval(window.intervalRelatorios);
    inicializar();
  }
}]);