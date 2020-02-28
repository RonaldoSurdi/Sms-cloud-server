ronaldosurdi
  .controller("ContactController", ["$scope", "$http", "$window", "Formating", function($scope, $http, $window, Formating) {

    var MAX_ITEMS_IN_LIMITED_STRING_ARRAY = 10;

    $scope.working = true;
    $scope.workingModal = false;
    $scope.contacts = {};
    $scope.selectedContact = {};
    $scope.selectedContactGroups = {};
    $scope.mensagem = {};
    $scope.filteredContacts = {};
    $scope.filteredContactsCount = 0;

    $scope.$watch("filterGroup", function() {
      if ($scope.filterGroup == "") {
        $scope.filterGroup = undefined;
      }
    });

    $scope.$watch("filteredContacts", function() {
      var count = 0

      Object.keys($scope.filteredContacts)
      .forEach(function(index) {
        if ($scope.filteredContacts[index] !== undefined) {
          count += $scope.filteredContacts[index].length;
        }
      });

      $scope.filteredContactsCount = count;
    }, true);

    var inicializarContatos = function() {
      $http.get(Routes.contacts_path({format: "json"}))
      .success(function(data) {
        $scope.contacts = data;
        acoesPadroesNoGetHTTP();
      })
      .error(function(data) {
        acoesPadroesNoGetHTTP();
      });
    }

    var acoesPadroesNoGetHTTP = function() {
      $scope.working = false;
      $("select.select2").select2("enable");
    }

    $scope.formatarTelefone = function(telefoneSoNumeros) {
      return Formating.phoneFormat(telefoneSoNumeros);
    }

    $scope.formatarData = function(dataFormatoIngles) {
      return Formating.dateBrFormat(dataFormatoIngles);
    }

    $scope.formatarTitulo = function(titulo) {
      return Formating.titleFormat(titulo);
    }

    $scope.abrirModalContatos = function(contatoId) {
      $scope.selectedContact = {};

      $("#index_contacts_modal").modal("show");
      $scope.workingModal = true;

      $http.get(Routes.contact_path(contatoId))
        .success(function(data) {
          $scope.selectedContact = data[0];
          $scope.selectedContactGroups = data[1];
          $scope.spliceStringArray($scope.selectedContactGroups, "etc...");
          $scope.workingModal = false;
        })
        .error(function() {
          $scope.workingModal = false;
      });
    }

    $scope.excluirContato = function(contatoId) {
      if (!$window.confirm("Você tem certeza que deseja excluir esse registro?"))
        return;

      $scope.working = true;

      $http({
        method: "DELETE",
        url: Routes.contact_path(contatoId),
      })
      .success(function(data) {
        $scope.mensagem.texto = data;
        $scope.mensagem.label = "label-success";
        $scope.working = false;
        $scope.mostrarMensagem();
        $scope.removerDaListaDeContatos(contatoId);
      })
      .error(function(data) {
        $scope.mensagem.texto = "Não foi possível excluir o registro!";
        $scope.mensagem.label = "label-danger";
        $scope.working = false;
        $scope.mostrarMensagem();
      });

      $("#index_contacts_modal").modal("hide");
    }

    $scope.mostrarMensagem = function() {
      $scope.canShowMesssage = true;

      $window.setTimeout(function() {
        $scope.canShowMesssage = false;
        $scope.$apply();
      }, 5000);
    }

    $scope.removerDaListaDeContatos = function(contatoId) {
      Object.keys($scope.contacts)
      .forEach(function(index) {
        $scope.contacts[index] = $scope.contacts[index].filter(function(contact) {
          return contact.id !== contatoId;
        });
      });
    }

    $scope.spliceStringArray = function(stringArray, lastStringOnArray) {
      if ($scope.selectedContactGroups.length > MAX_ITEMS_IN_LIMITED_STRING_ARRAY) {
        $scope.selectedContactGroups.splice(MAX_ITEMS_IN_LIMITED_STRING_ARRAY - 1);

        if (lastStringOnArray)
          $scope.selectedContactGroups.push(lastStringOnArray);
      }
    }

    inicializarContatos();
  }]);