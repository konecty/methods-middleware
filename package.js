Package.describe({
  name: 'methods-middleware',
  summary: 'Add more power to Meteor.methods with methods-middleware',
  version: '1.3.0',
  git: 'https://github.com/Konecty/methods-middleware.git'
});

Package.onUse(function(api) {
  api.versionsFrom('1.2');
  api.use([
    'ecmascript',
    'nooitaf:colors@1.2.0'
  ]);
  api.addFiles('methods-middleware.js', 'server');
});

Package.onTest(function(api) {
  api.use([
    'tinytest',
    'methods-middleware',
    'nooitaf:colors@1.2.0'
  ]);
  api.addFiles('methods-middleware.test.js', 'server');
});
