ronaldosurdi
  .controller("ContactGroupController", ["$scope", "$http", "$window", function($scope, $http, $window) {
    $scope.working = true;
    $scope.groups = {};
    $scope.selectedGroup = {};
    $scope.mensagem = {};

    $http.get(Routes.contact_groups_path({format: "json"}))
      .success(function(data) {
        $scope.groups = data;
        $scope.working = false;
      })
      .error(function(data) {
        $scope.working = false;
      });

    $scope.openModalShowGroupContacts = function(grupoId, $event) {
      if ($($event.target).is($("a")))
        return;

      $("#index_contact_groups_modal").modal("show");

      for (var i = 0; i < $scope.groups.length; i++) {
        if ($scope.groups[i].id == grupoId) {
          $scope.selectedGroup = $scope.groups[i];
        }
      };
    }

    $scope.excluirGrupo = function(grupoId) {
      if (!$window.confirm("Você tem certeza que deseja excluir esse registro?"))
        return;

      $scope.working = true;

      $http({
        method: "DELETE",
        url: Routes.contact_group_path(grupoId),
      })
      .success(function(data) {
        $scope.mensagem.texto = data;
        $scope.mensagem.label = "label-success";
        $scope.working = false;
        $scope.removerDaListaDeGrupos(grupoId);
        $scope.mostrarMensagem();
      })
      .error(function() {
        $scope.mensagem.texto = "Não foi possível excluir o registro!";
        $scope.mensagem.label = "label-danger";
        $scope.loader = false;
        $scope.mostrarMensagem();
      });

      $("#index_contact_groups_modal").modal("hide");
    }

    $scope.mostrarMensagem = function() {
      $scope.canShowMesssage = true;

      $window.setTimeout(function() {
        $scope.canShowMesssage = false;
        $scope.$apply();
      }, 5000);
    }

    $scope.removerDaListaDeGrupos = function(grupoId) {
      $scope.groups = $scope.groups.filter(function(grupo) {
        return grupo.id !== grupoId;
      });
    }
  }]);