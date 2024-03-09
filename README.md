# Methods Middleware

**fork of Konecty Methods Middleware**

Add more power to Meteor.methods with methods-middleware

--

With this package you can register methods that will be registered as native Meteor methods, is the same as use Meteor.methods to create methods but using this package you can do more like:

- Register regular methods;
- Register **middlewares** and **only reference** them when register methods to be executed before this method;
- Add methods to be executed **before** and **after all** your methods registered with **registerMethod**;

## Installation
```sell
meteor add sbborders:methods-middleware
```

## Execution Pipeline
- Execute all before methods
- Execute middlewares registered for called method
- Execute called method
- Execute all after methods

**If MIDLEWARES or BEFORE METHODS returns something different from UNDEFINED the execution stops and return this value!**

## Regular Methods
Register a method named **sum**
```javascript
Meteor.registerMethod('sum', function(a, b) {
  return a + b;
});
```

Call registered method **sum** as normal methods
```javascript
Meteor.call('sum', 2, 3);
```

## Methods with Middlewares
Register a new middleware to convert arguments to number and pass to method via context
```javascript
Meteor.registerMiddleware('toNumber', function() {
  var args = Array.prototype.slice.apply(arguments);

  args.forEach(function(arg, index) {
    args[index] = parseFloat(arg);
  });

  this.arguments = args;
  return
});
```
Register a method named **sum** using the middleware **toNumber** and get values from context
```javascript
Meteor.registerMethod('sum', 'toNumber', function(a, b) {
  return this.arguments[0] + this.arguments[1];
});
```

Call registered method **sum** passing strings that will be converted by middleware
```javascript
Meteor.call('sum', '2', '3');
```

# Before and After Methods
You can register methods to be executed before and after **all** methods registered with **registerMethod**.
In the above example we are tracking execution time and logging to console.

This method will be executed before every method call and will put in context the date and time from the begining of the execution
```javascript
Meteor.registerBeforeMethod('startTimer', function() {
  this.startedAt = new Date();
  return
});
```

This method will be executed after every method call and will get the date time saved in context to calculate the execution time and log to console
```javascript
Meteor.registerAfterMethod('endTimer', function(a, b) {
  var now = new Date();
  console.log('Time: ' + (now.getTime() - this.startedAt.getTime()));
  return
});
```
