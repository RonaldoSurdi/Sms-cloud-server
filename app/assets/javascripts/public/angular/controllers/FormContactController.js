sendmy
  .controller("FormContactController", ["$scope", "$http", "filterFilter", "Formating", function($scope, $http, filterFilter, Formating) {
    $scope.working = false;
    $scope.selectedGroup;
    $scope.selectedGroups = [];
    $scope.groups = {};
    $scope.contactParams = {};
    $scope.contactGroupParams = {};

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

    $scope.groupIdsCatcher = function() {
      $scope.contactParams.group_ids = [];
      for (var i = 0; i < $scope.selectedGroups.length; i++) {
        $scope.contactParams.group_ids.push($scope.selectedGroups[i].id);
      };
    }

    $scope.$watch("selectedGroup", function() {
      if (!$scope.selectedGroup) return;
      $scope.selectedGroups.unshift($scope.selectedGroup);
      $scope.selectedGroup = "";
      $(".select2-choice .select2-chosen").text("");
    });

    $scope.initEdition = function(contact, contactGroups) {
      if (contact.id) {
        $scope.contactParams = {
          id: contact.id,
          nome: contact.nome,
          sexo: (contact.sexo === "masculino" ? 0 : 1),
          celular: Formating.phoneFormat(contact.celular),
          email: contact.email,
          empresa: contact.empresa,
          nascimento: Formating.dateBrFormat(contact.nascimento)
        };

        $scope.selectedGroups = contactGroups;
      }

      if (!$scope.contactParams.sexo) {
        $scope.contactParams.sexo = 0;
      }
    }

    $scope.filterAlreadyAdded = function(value) {
      var filter = filterFilter($scope.selectedGroups, {id: value.id});
      return filter && filter.length == 0;
    }

    $scope.removerGrupoDosSelecionados = function(index) {
      $scope.selectedGroups.splice(index, 1);
    }

    $scope.limparCampos = function() {
      $("#contact_nome").focus();
      $scope.contactParams = {sexo: $scope.contactParams.sexo};
    }

    $scope.patternSubmit = function($event, httpRequestFunction) {
      $event.preventDefault();

      $("#contact_celular").trigger("change");
      $("#contact_nascimento").trigger("change");

      $scope.groupIdsCatcher();

      $("button[type=submit]").attr("disabled", "disabled");
      $scope.working = true;
      $scope.mensagem = {};
      $scope.fieldsErrors = {};

      httpRequestFunction();
    }

    $scope.cadastrarContato = function($event) {
      $scope.patternSubmit($event, function() {
        $http.post(Routes.contacts_path(), {contact: $scope.contactParams})
        .success(function(data) {
          $scope.mensagem.texto = "Contato adicionado com sucesso!";
          successHandle();
          $scope.limparCampos();
        })
        .error(function(data) {
          errorHandle(data);
          $scope.mensagem.texto = "Não foi possível adicionar o contato!";
        });
      });
    }

    $scope.cadastrarGrupoDeContatos = function($event) {
      $event.preventDefault();

      $scope.workingGroups = true;

      $http.post(Routes.contact_groups_path(), {contact_group: $scope.contactGroupParams})
      .success(function(data) {
        $scope.groups.push({id: data.id, descricao: data.descricao});
        $scope.selectedGroups.unshift(data);
        $scope.workingGroups = false;
      })
      .error(function(data) {
        $scope.workingGroups = false;
      });

      $("#new_contact_modal, #edit_contact_modal").modal("hide");
      $scope.contactGroupParams = {};
    }
  }]);