Package.describe({
  name: 'konecty:methods-middleware',
  summary: ' /* Fill me in! */ ',
  version: '1.0.0',
  git: ' /* Fill me in! */ '
});

Package.onUse(function(api) {
  api.versionsFrom('1.0');
  api.use('coffeescript');
  api.use('nooitaf:colors');
  api.addFiles('konecty:methods-middleware.coffee', ['server']);
});

Package.onTest(function(api) {
  api.use('tinytest');
  api.use('konecty:methods-middleware');
  api.addFiles('konecty:methods-middleware-tests.js');
});
