ronaldosurdi
  .controller("HomeMessagesController", ["$scope", "$http", "$window", "$filter", function($scope, $http, $window, $filter) {
  var ENUM_PERIODOS = {
    seisMeses: 0,
    trintaDias: 1
  };

  var MESES_NO_ANO = 12;
  var MESES = [null, "Janeiro", "Fevereiro", "Março", "Abril", "Maio", "Junho", "Julho", "Agosto", "Setembro", "Outubro", "Novembro", "Dezembro"];

  $scope.periodos = [
    { texto: "Últimos 6 meses", valor: ENUM_PERIODOS.seisMeses },
    { texto: "Últimos 30 dias", valor: ENUM_PERIODOS.trintaDias }
  ];

  $scope.periodoSelecionado = $scope.periodos[0].valor;
  $scope.carregandoMensagens = false;
  $scope.contagemMensagens;
  $scope.contagemMensagensSucesso;
  $scope.contagemMensagensErro;

  var cores = { verde: "#49BF67", vermelho: "#B94A48", cinza: "#D3D7D9" };
  var plot;

  $scope.init = function(contagemMensagens) {
    $scope.contagemMensagens = contagemMensagens;
    $scope.atualizarGraficoMensagens();
  };

  $scope.atualizarGraficoMensagens = function() {
    $scope.contagemMensagensSucesso = undefined;
    $scope.contagemMensagensErro = undefined;
    $scope.atualizarContagens();

    var plot = $.plot($("#mensagens-chart"), [
      {
        data: $scope.contagemMensagensSucesso,
        label: "Sucesso"
      }, {
        data: $scope.contagemMensagensErro,
        label: "Com Erro"
      }
    ], {
      series: {
        lines: {
          show: true,
          lineWidth: 3
        },
        points: { show: true },
      },
      legend: { backgroundColor: "rgba(245,245,245,0.5)" },
      grid: {
        hoverable: true,
        borderWidth: 0,
        tickColor: cores.cinza
      },
      tooltip: {
        show: true,
        content: "<span style='font-weight: bold'>%s:</span> %y.0 SMS's"
      },
      xaxis: { mode: "categories" },
      yaxis: { min: 0 },
      colors: [cores.verde, cores.vermelho]
    });
  };

  $scope.atualizarContagens = function() {
    var ultimasDatas = [];
    var contagem = {};

    if ($scope.periodoSelecionado == ENUM_PERIODOS.seisMeses) {
      ultimasDatas = $scope.filtrarUltimosMeses(6);
      contagem = $scope.contagemSMSParaOsMeses(ultimasDatas, $scope.contagemMensagens);
    } else {
      ultimasDatas = $scope.filtrarUltimosDias(30);
      contagem = $scope.contagemSMSParaOsDias(ultimasDatas, $scope.contagemMensagens);
    }

    $scope.contagemMensagensSucesso = ultimasDatas.map(function(item, indice) {
      return [item, contagem.sucessos[indice]];
    });

    $scope.contagemMensagensErro = ultimasDatas.map(function(item, indice) {
      return [item, contagem.erros[indice]];
    });
  };

  $scope.buscarContagemDeMensagens = function() {
    $scope.carregandoMensagens = true;

    $http.get(Routes.administrator_root_path({periodo: $scope.periodoSelecionado, format: 'json'}))
    .success(function(data) {
      $scope.contagemMensagens = data;
      $scope.atualizarGraficoMensagens();
      $scope.carregandoMensagens = false;
    })
    .error(function() {
      $scope.carregandoMensagens = false;
      $scope.contagemMensagens = {};
      $window.alert("Não foi possível carregar os dados de mensagens enviadas, por favor tente mais tarde...");
    });
  };

  $scope.filtrarUltimosMeses = function(quantidadeMeses) {
    var mesAtual = parseInt(moment().format("MM"));
    var mesAntigo = mesAtual - quantidadeMeses;
    var mesesAnoAnterior = [];

    if (mesAntigo < 1) {
      mesAntigo = MESES_NO_ANO + mesAntigo + 1;

      mesesAnoAnterior = MESES.filter(function(mes, indice) {
        return ((indice >= mesAntigo) && (indice <= MESES_NO_ANO));
      });
    }

    var mesesAnoAtual = MESES.filter(function(mes, indice) {
      if (mesAntigo > mesAtual) {
        return (indice <= mesAtual) && (indice > 0);
      } else
        return (indice <= mesAtual) && (indice > mesAntigo);
    });

    return mesesAnoAnterior.concat(mesesAnoAtual);
  };

  $scope.filtrarUltimosDias = function(quantidadeDias) {
    var hoje = moment().hours(0).minutes(0).seconds(0).milliseconds(0);
    var trintaDiasAtras = moment().hours(0).minutes(0).seconds(0).milliseconds(0).subtract(quantidadeDias - 1, 'days');
    var datasArray = [];

    for (var m = trintaDiasAtras; !m.isAfter(hoje); m.add('days', 1)) {
      datasArray.push(m.format("DD"));
    };

    return datasArray;
  };

  $scope.contagemSMSParaOsMeses = function(meses, contagemMensagens) {
    var contagem = {sucessos: [], erros: []};

    meses.forEach(function(item, indice) {
      var mes = contagemMensagens[0] ? parseInt(contagemMensagens[0].group_name.split("/")[0]) : undefined

      if (mes && (item == MESES[mes])) {
        contagem.sucessos.push((contagemMensagens[0].total - contagemMensagens[0].total_erro) || 0);
        contagem.erros.push(contagemMensagens[0].total_erro || 0);

        contagemMensagens.splice(0, 1);
      } else {
        contagem.sucessos.push(0);
        contagem.erros.push(0);
      }
    });

    return contagem;
  };

  $scope.contagemSMSParaOsDias = function(dias, contagemMensagens) {
    var contagem = {sucessos: [], erros: []};

    for (var i = 0; i < dias.length; i++) {
      var dia = contagemMensagens[0] ? parseInt(contagemMensagens[0].group_name.split("/")[0]) : undefined

      if (dia && (parseInt(dias[i]) === dia)) {
        contagem.sucessos.push((contagemMensagens[0].total - contagemMensagens[0].total_erro) || 0);
        contagem.erros.push(contagemMensagens[0].total_erro || 0);

        contagemMensagens.splice(0, 1);
      } else {
        contagem.sucessos.push(0);
        contagem.erros.push(0);
      }
    };

    return contagem;
  };
}]);