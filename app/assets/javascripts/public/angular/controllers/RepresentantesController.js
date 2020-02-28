ronaldosurdi
  .controller("RepresentantesController", ["$scope", "$http", "$window", "Formating", function($scope, $http, $window, Formating) {
  $scope.estados = [];
  $scope.estadoSelecionado = {};
  $scope.representantes = [];
  $scope.carregando = false;
  $scope.estados = [
    { "id": 0 },
    { "id": 1 },
    { "id": 2 },
    { "id": 3, "uf": "AC", "nome": 'Acre' },
    { "id": 4, "uf": "AM", "nome": 'Amazonas' },
    { "id": 5, "uf": "RR", "nome": 'Roraima' },
    { "id": 6, "uf": "AP", "nome": 'Amapá' },
    { "id": 7, "uf": "MA", "nome": 'Maranhão' },
    { "id": 8, "uf": "RO", "nome": 'Rondônia' },
    { "id": 9, "uf": "MT", "nome": 'Mato Grosso' },
    { "id": 10, "uf": "MS", "nome": 'Mato Grosso do Sul' },
    { "id": 11, "uf": "GO", "nome": 'Goiás' },
    { "id": 12, "uf": "PR", "nome": 'Paraná' },
    { "id": 13, "uf": "SP", "nome": 'São Paulo' },
    { "id": 14, "uf": "RJ", "nome": 'Rio de Janeiro' },
    { "id": 15, "uf": "ES", "nome": 'Espírito Santo' },
    { "id": 16, "uf": "MG", "nome": 'Minas Gerais' },
    { "id": 17, "uf": "SC", "nome": 'Santa Catarina' },
    { "id": 18, "uf": "RS", "nome": 'Rio Grande do Sul' },
    { "id": 19, "uf": "TO", "nome": 'Tocantins' },
    { "id": 20, "uf": "BA", "nome": 'Bahia' },
    { "id": 21, "uf": "SG", "nome": 'Sergipe' },
    { "id": 22, "uf": "AL", "nome": 'Alagoas' },
    { "id": 23, "uf": "PI", "nome": 'Piauí' },
    { "id": 24, "uf": "CE", "nome": 'Ceará' },
    { "id": 25, "uf": "RN", "nome": 'Rio Grande do Norte' },
    { "id": 26, "uf": "PB", "nome": 'Paraíba' },
    { "id": 27, "uf": "PE", "nome": 'Pernambuco' },
    { "id": 28, "uf": "PA", "nome": 'Pará' }
  ];

  var alternarClasses = function(estadoId) {
    if ($(".estado.ativo").length > 0) {
      $(".estado.ativo").attr("class",
        $(".estado.ativo").attr("class").replace(" ativo", "")
      );
    }

    if (estadoId) {
      var strEstado = "estado".concat(estadoId);
      $(".estado." + strEstado).attr("class", "estado ativo " + strEstado);
    }
  }

  $scope.alternarEstado = function(estadoId) {
    if (estadoId === $scope.estadoSelecionado.id) return;

    $scope.estadoSelecionado = $scope.estados[estadoId];
    $scope.carregando = true;
    alternarClasses($scope.estadoSelecionado.id);

    $http.get(Routes.por_estado_public_representatives_path({"uf": $scope.estadoSelecionado.uf, "format": "json"}))
    .success(function(data) {
      $scope.carregando = false;
      $scope.representantes = data;
    })
    .error(function() {
      $scope.carregando = false;
      $window.alert("Não foi possível realizar a busca, tente novamente mais tarde.");
    });
  }

  $scope.formatarTelefone = function(telefone) {
    return Formating.phoneFormat(telefone);
  }
}]);