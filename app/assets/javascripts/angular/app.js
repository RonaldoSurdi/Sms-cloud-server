(function() {
  window.sendmy = angular.module("sendmy", ["ngRoute", "bgf.paginateAnything", "sendmy.services", "sendmy.filters", "ui.utils.masks"])

  .directive("ngEnter", function() {
    return function(scope, element, attrs) {
      element.bind("keydown keypress", function(event) {
        if(event.which === 13) {
          scope.$apply(function(){
            scope.$eval(attrs.ngEnter, {"event": event});
          });

          event.preventDefault();
        }
      });
    }
  })

})();


$(document).on('page:change', function(){
  clearInterval(window.intervalDash);
  clearInterval(window.intervalRelatorios);
  clearInterval(window.intervalAdminDashboard);

  angular.bootstrap(document.body, ['sendmy']);
});