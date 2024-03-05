/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
Meteor.registerLogs = true;
Meteor.registerDoneLogs = true;
Meteor.registerVerboseLogs = true;

// Before methods
Meteor.registerBeforeMethod('validate:arguments', function (...args) {
  if (args.length !== 2) {
    return new Error('You must pass 2 arguments');
  }
});


// After methods
Meteor.registerAfterMethod('transform:zeroInNull', function (params) {
  console.log(params);
  if (params.result === 0) {
    return null;
  }
});


// Middlewares
Meteor.registerMiddleware('toNumber', function (...args) {
  this.arguments = args;
  for (let index = 0; index < this.arguments.length; index++) {
    const arg = this.arguments[index];
    this.arguments[index] = parseFloat(arg);
  }
});


// Methods
Meteor.registerMethod('sum', (a, b) => a + b);

Meteor.registerMethod('numbers:sum', 'toNumber', function (a, b) {
  return this.arguments[0] + this.arguments[1];
});


// Tests
Tinytest.add('Methods Middleware - simple call - sum numbers', function (test) {
  const value = Meteor.call('sum', 2, 3);
  return test.equal(value, 5);
});

Tinytest.add('Methods Middleware - simple call - sum strings', function (test) {
  const value = Meteor.call('sum', '2', '3');
  return test.equal(value, '23');
});

Tinytest.add('Methods Middleware - middleware - sum strings as numbers', function (test) {
  const value = Meteor.call('numbers:sum', '2', '3');
  return test.equal(value, 5);
});

Tinytest.add('Methods Middleware - before method - wrong number of arguments', function (test) {
  const value = Meteor.call('numbers:sum', 2);
  return test.instanceOf(value, Error);
});

Tinytest.add('Methods Middleware - after method - zero result must be null', function (test) {
  const value = Meteor.call('numbers:sum', 0, 0);
  return test.isNull(value);
});
