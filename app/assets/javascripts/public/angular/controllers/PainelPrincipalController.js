sendmy
  .controller("PainelPrincipalController", ["$scope", "$http", "$window", function($scope, $http, $window) {

  var REFRESH_INTERVAL = 10;
  var EXTRA_TIME_DURATION = 2;
  var MAX_PERCENT = 100;

  $scope.mensagem = {};
  $scope.mensagem.titulo = "Escrever Mensagem";
  $scope.mensagem.desabilitarCampos;
  $scope.mensagem.numero;
  $scope.mensagem.texto;

  $scope.dash = {};
  $scope.dash.transacao;
  $scope.dash.porcentagem = 0;

  $scope.dash.progressBar = new ProgressBar.Circle("#progressbar-circle", {
    color: "#DDD",
    trailColor: "#8B2166",
    strokeWidth: 20,
    trailWidth: 20,
    duration: (REFRESH_INTERVAL + EXTRA_TIME_DURATION) * 1000,
    text: {
      value: ($scope.dash.transacao ? String($scope.dash.enviando) : '0')
    },
    step: function(state, bar) {
      var value = bar.value() || 0;
      bar.setText(((value <= 0 ? 0 : value) * 100).toFixed(0) + "%");
    }
  });

  var alert = function(mensagem) {
    $window.bootbox.alert({
      title: "<strong>Notificação</strong>",
      message: "<big>" + mensagem + "</big>"
    });
  }

  var acoesPadroesPostHTTP = function(data) {
    $scope.mensagem = {};
    $scope.mensagem.titulo = "Escrever Mensagem";
    alert(data);
  }

  $scope.init = function () {
    $scope.dash.contador = REFRESH_INTERVAL;

    clearInterval($window.intervalDash);

    if ($scope.dash.transacao)
      $scope.dash.progressBar.animate($scope.calcularPorcentagem() / MAX_PERCENT);
    else
      $scope.buscarTransacao();

    $window.intervalDash = setInterval(function() {
      $scope.dash.contador -= 1;

      if ($scope.dash.contador <= 0) {
        if ($scope.dash.porcentagem === MAX_PERCENT || !$scope.dash.transacao) {
          $scope.dash.transacao = undefined;
          $scope.buscarTransacao();
        } else
          $scope.atualizarTransacao();

        $scope.dash.contador = REFRESH_INTERVAL;
      }
    }, 1000);
  }

  $scope.enviarMensagem = function() {
    if ($scope.saldo < 1 || !$scope.mensagem.texto || !$scope.mensagem.numero || $scope.mensagem.numero.length < 10) {
      alert("Para enviar a mensagem é preciso de um número, da mensagem e de saldo!");
      return;
    } else {
      $window.bootbox.confirm("<big>Você tem certeza que deseja enviar?</big>", function(confirm) {
        if (!confirm) return;

        var params = {
          message: $scope.mensagem.texto,
          cellphones: [$scope.mensagem.numero],
          agendamento: "false"
        };

        $scope.mensagem.titulo = "Enviando...";
        $scope.mensagem.desabilitarCampos = true;

        $http.post(Routes.envios_path({format: "json"}), {message: params})
        .success(function(data) {
          acoesPadroesPostHTTP(data);
          $scope.descontarSaldo(1);
        })
        .error(function(data) {
          acoesPadroesPostHTTP(data);
        });
      });
    }
  }

  $scope.atualizarTransacao = function() {
    $http.get(Routes.relatorio_path($scope.dash.transacao.grupo, {format: 'json'}))
    .success(function(data) {
      $scope.dash.transacao = data;

      if (($scope.dash.transacao.quantidade_sucesso + $scope.dash.transacao.quantidade_erro) === $scope.dash.transacao.quantidade_total) {
        $scope.dash.progressBar.animate(1, {duration: EXTRA_TIME_DURATION * 1000});

        setTimeout(function() {
          $scope.dash.transacao = undefined;
          $scope.dash.progressBar.animate(0, {duration: 0});
          $scope.$apply();
        }, (EXTRA_TIME_DURATION + 0.5) * 1000);
      } else
        $scope.dash.progressBar.animate($scope.calcularPorcentagem() / MAX_PERCENT);
    });
  }

  $scope.buscarTransacao = function() {
    $http.get(Routes.painel_index_path({format: 'json'}))
    .success(function(data) {
      $scope.dash.transacao = data[0];
      $scope.dash.mensagem = data[1];

      if ($scope.dash.transacao)
        $scope.dash.progressBar.animate($scope.calcularPorcentagem() / MAX_PERCENT);
    });
  }

  $scope.calcularPorcentagem = function() {
    var porcentagem = parseInt((MAX_PERCENT * $scope.dash.transacao.quantidade_enviado) / $scope.dash.transacao.quantidade_total);
    $scope.dash.porcentagem = porcentagem > 0 ? porcentagem : 0;
    return $scope.dash.porcentagem;
  }

  $scope.descontarSaldo = function(desconto) {
    $scope.saldo -= desconto;
  }
}]);
