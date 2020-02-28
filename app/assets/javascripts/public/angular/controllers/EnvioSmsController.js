ronaldosurdi
  .controller("EnvioSmsController", ["$scope", "$http", "$window", "Formating", "filterFilter", function($scope, $http, $window, Formating, filterFilter) {
    $scope.mensagem;
    $scope.contatos = [];
    $scope.contatosListados = [];
    $scope.contatosAdicionados = [];
    $scope.carregandoModal = true;
    $scope.filtroTexto;
    $scope.filtroGrupo;
    $scope.filtroSexo;
    $scope.filtroAniversarioMes;
    $scope.filtroAniversarioDia;
    $scope.numeroAvulso;

    $scope.$watch("filtroGrupo", function() {
      if ($scope.filtroGrupo === "") {
        $scope.filtroGrupo = undefined;
        $("select.select2").select2("data", {id: "", text: ""});
      }
    });

    $scope.$watch("filtroAniversarioMes", function() {
      if ($scope.filtroAniversarioMes === "") {
        $scope.filtroAniversarioMes = undefined;
        $scope.filtroAniversarioDia = undefined;
      }
    });

    var inicializar = function() {
      $http.get(Routes.all_contacts_path({format: "json"}))
        .success(function(data) {
          $scope.contatos = data;
          for (var i = 0; i < $scope.contatos.length; i++) {
            if ($scope.contatos[i].nascimento) {
              var separacaoData = $scope.contatos[i].nascimento.split('-');

              $scope.contatos[i].mesAniversario = separacaoData[1];
              $scope.contatos[i].diaAniversario = separacaoData[2];
              $scope.contatos[i].nascimento = null;
            }
          };

          $scope.carregandoModal = false;
        })
        .error(function() {
          $scope.carregandoModal = false;
      });
    }

    $scope.formatarTelefone = function(telefone) {
      return Formating.phoneFormat(telefone);
    }

    $scope.alternarSelecaoTodos = function(contatos) {
      for (var i = 0; i < contatos.length; i++) {
        if ($scope.marcarTodos)
          contatos[i].selecionado = true;
        else
          contatos[i].selecionado = false;
      };
    }

    $scope.adicionarContatos = function() {
      var possuiSelecionados = false;
      $scope.marcarTodos = false;

      for (var i = 0; i < $scope.contatosListados.length; i++) {
        if ($scope.contatosListados[i].selecionado) {
          $scope.contatosListados[i].selecionado = false;
          $scope.contatosAdicionados.unshift($scope.contatosListados[i]);
          possuiSelecionados = true;
        }
      };

      if (!possuiSelecionados) {
        $window.alert("Você precisa selecionar ao menos um contato para adicionar à listagem!");
      }
    }

    $scope.adicionarNumeroAvulso = function() {
      if ($scope.numeroAvulso && ($scope.numeroAvulso.length === 10 || $scope.numeroAvulso.length === 11)) {
        $scope.contatosAdicionados.unshift({celular: $scope.numeroAvulso});
        $scope.numeroAvulso = "";
      }
    }

    $scope.removerDosAdicionados = function(index) {
      $scope.contatosAdicionados.splice(index, 1);
    }

    $scope.filtroJaAdicionados = function(value) {
      var filtro = filterFilter($scope.contatosAdicionados, {id: value.id});
      return filtro && filtro.length == 0;
    }

    $scope.removerTodosAdicionados = function() {
      if ($window.confirm("Você tem certeza que deseja limpar a lista de contatos/números selecionados?")) {
        $scope.contatosAdicionados = [];
      }
    }

    $scope.verificarSaldo = function($event) {
      if (!$scope.agendarEnvio && $scope.contatosAdicionados.length > $scope.saldo) {
        $event.preventDefault();
        $window.alert("Você não possui saldo o suficiente para enviar suas mensagens.");
      }
    }

    $scope.limparFiltros = function() {
      $scope.filtroTexto = "";
      $scope.filtroGrupo = "";
      $scope.filtroSexo = "";
      $scope.filtroAniversarioMes = "";
      $scope.filtroAniversarioDia = "";

      $("#filtro_aniversario_dia").attr("disabled", "disabled");
      $("#selecionar_contatos_envio_modal input:first").focus();
    }

    inicializar();
  }]);