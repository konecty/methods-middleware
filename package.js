Package.describe({
  name: 'konecty:methods-middleware',
  summary: 'Add more power to Meteor.methods with methods-middleware',
  version: '1.2.4',
  git: 'https://github.com/Konecty/methods-middleware.git'
});

Package.onUse(function(api) {
  api.versionsFrom('1.2');
  api.use('coffeescript');
  api.use('underscore');
  api.use('nooitaf:colors@1.1.2_1');
  api.addFiles('konecty:methods-middleware.coffee', 'server');
});

Package.onTest(function(api) {
  api.use('tinytest');
  api.use('konecty:methods-middleware');
  api.use('coffeescript');
  api.use('nooitaf:colors@1.1.2_1');
  api.addFiles('konecty:methods-middleware.test.coffee', 'server');
});
