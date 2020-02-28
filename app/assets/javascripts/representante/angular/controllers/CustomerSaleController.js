ronaldosurdi
  .controller("CustomerSaleController", ["$scope", "$http", "$window", "Ordering", function($scope, $http, $window, Ordering) {
    COLOURS = ["blue", "orange", "red", "purple"];

    $scope.procurarLicencas = function() {

      if ($scope.selectedCustomer !== undefined && $scope.selectedCustomer !== null && $scope.selectedCustomer !== "") {
        $scope.mostrar = false;
        $scope.working = true;
        $http.get(Routes.verify_customer_representative_customer_path($scope.selectedCustomer, {format: "json"}))
          .success(function(data) {
            $scope.licenseMovements = data;

            $scope.number = 0;
            $scope.licenseMovements.forEach(function(licenseMovement) {
              licenseMovement.background = sequencialBackground();
            });

            $scope.working = false;
            $scope.mostrar = true;
          })
          .error(function() {
            $scope.working = false;
            $scope.mostrar = false;
          });
      } else {
        if ($scope.licenseMovements !== undefined) {
          $scope.licenseMovements = {};
        }
      }
    }

    $scope.abrirModal = function(index) {
      $("#sale_modal").modal("show");

      $scope.selectedLicense = $scope.licenseMovements[index];

      $window.setTimeout(function() {
        $window.App.prototype.applyMasks();
        var $input = $("input[type=text]");

        $input.on("focus", function() {
          this.selectionStart = this.selectionEnd = this.value.length;
        });

        $input.focusout();
        $input.focus();
      }, 500);
    }

    var sequencialBackground = function() {
      number_of_this_time = $scope.number;

      if ($scope.number < (COLOURS.length - 1)) {
        $scope.number++;
      } else {
        $scope.number = 0;
      }

      return COLOURS[number_of_this_time] + "-background";
    }
  }]);