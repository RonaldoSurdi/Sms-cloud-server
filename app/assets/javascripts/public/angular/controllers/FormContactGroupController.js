ronaldosurdi
  .controller("FormContactGroupController", ["$scope", "$http", "filterFilter", "Formating", function($scope, $http, filterFilter, Formating) {
    $scope.working = true;
    $scope.contacts;
    $scope.selectedContact;
    $scope.selectedContacts = [];
    $scope.groups = {};
    $scope.groupParams = {};

    var inicializarContatos = function() {
      $("select.select2").select2("disable");

      $http.get(Routes.get_contacts_contact_groups_path({format: "json"}))
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

    var errorHandle = function(data) {
      $scope.mensagem.tipoAlert = "alert-danger";
      $scope.fieldsErrors = data;
      requestHandle();
    }

    var successHandle = function() {
      $scope.mensagem.tipoAlert = "alert-success";
      requestHandle();
    }

    var requestHandle = function() {
      $("button[type=submit]").removeAttr("disabled");
      $scope.working = false;
      $scope.submited = true;
    }

    $scope.contactIdsCatcher = function() {
      $scope.groupParams.contact_ids = [];
      for (var i = 0; i < $scope.selectedContacts.length; i++) {
        $scope.groupParams.contact_ids.push($scope.selectedContacts[i].id);
      };
    }

    $scope.$watch("selectedContact", function() {
      if (!$scope.selectedContact) return;
      $scope.selectedContacts.unshift($scope.selectedContact);
      $scope.selectedContact = "";
      $(".select2-choice .select2-chosen").text("");
    });

    $scope.initEdition = function(contact_group, contacts) {
      if (contact_group.id) {
        $scope.groupParams = {
          id: contact_group.id,
          descricao: contact_group.descricao,
          observacao: contact_group.observacao
        };

        $scope.selectedContacts = contacts;
      }
    }

    $scope.filterAlreadyAdded = function(value) {
      var filter = filterFilter($scope.selectedContacts, {id: value.id});
      return filter && filter.length == 0;
    }

    $scope.removerContatoDosSelecionados = function(index) {
      $scope.selectedContacts.splice(index, 1);
    }

    $scope.limparCampos = function() {
      $("#contact_group_descricao").focus();
      $scope.groupParams = null;
    }

    $scope.cadastrarGrupo = function($event) {
      $event.preventDefault();

      $scope.contactIdsCatcher();

      $("button[type=submit]").attr("disabled", "disabled");
      $scope.working = true;
      $scope.mensagem = {};
      $scope.fieldsErrors = {};

      $http.post(Routes.contact_groups_path(), {contact_group: $scope.groupParams})
      .success(function(data) {
        $scope.mensagem.texto = "Grupo criado com sucesso!";
        successHandle();
        $scope.limparCampos();
      })
      .error(function(data) {
        errorHandle(data);
        $scope.mensagem.texto = "Não foi possível criar o grupo!";
      });
    }

    inicializarContatos();
  }]);