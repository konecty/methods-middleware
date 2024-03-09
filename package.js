Package.describe({
  name: 'sbborders:methods-middleware',
  summary: 'Add more power to Meteor.methods with methods-middleware',
  version: '2.0.0',
  git: 'https://github.com/sbborders/methods-middleware.git'
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
    'sbborders:methods-middleware',
    'nooitaf:colors@1.2.0'
  ]);
  api.addFiles('methods-middleware.test.js', 'server');
});
