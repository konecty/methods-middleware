import util from 'util';

const Middlewares = {};
const BeforeMethods = {};
const AfterMethods = {};

// Meteor.registerLogs = true
// Meteor.registerDoneLogs = true
// Meteor.registerVerboseLogs = true

const formatJsonWithPrefixAndColor = function (value, prefix, color) {
  value = JSON.stringify(value, null, '  ');
  return value.replace(/(.*\n)|(.+)/g, value => (prefix + value)[color]);
};


const removeInternalProperties = function (value) {
  value = util._extend({}, value);
  delete value.__methodName__;
  return value;
};


const logBeforeExecution = function (methodName, scope, args) {
  if (Meteor.registerLogs !== true) {
    return;
  }

  console.log(`${methodName}`.cyan);

  if (Meteor.registerVerboseLogs !== true) {
    return;
  }

  if (scope) {
    console.log('   > SCOPE'.grey);
    console.log(formatJsonWithPrefixAndColor(removeInternalProperties(scope), '   | ', 'grey'));
  }
  if (args) {
    console.log('   > ARGUMENTS'.grey);
    return console.log(formatJsonWithPrefixAndColor(args, '   | ', 'grey'));
  }
};

const logAfterExecution = function (methodName, scope, args, result) {
  if (Meteor.registerDoneLogs !== true) {
    return;
  }

  console.log(`${methodName} [done]`.cyan);

  if (Meteor.registerVerboseLogs !== true) {
    return;
  }

  if (scope) {
    console.log('   > SCOPE'.grey);
    console.log(formatJsonWithPrefixAndColor(removeInternalProperties(scope), '   | ', 'grey'));
  }
  if (args) {
    console.log('   > ARGUMENTS'.grey);
    console.log(formatJsonWithPrefixAndColor(args, '   | ', 'grey'));
  }
  if (result) {
    console.log('   > RESULT'.grey);
    if (result instanceof Error) {
      return console.log('   |'.grey, result.toString().red);
    } else {
      return console.log(formatJsonWithPrefixAndColor(processResult(result), '   | ', 'grey'));
    }
  }
};

var processResult = function (result) {
  if (isObject(result) && typeof result.fetch === "function") {
    return result.fetch();
  }

  return result;
};


Meteor.registerAfterMethod = function (name, method) {
  if (AfterMethods[name]) {
    console.error(`[konecty:methods-middleware] Duplicated after method: ${name}`.red);
  }

  return AfterMethods[name] = method;
};


Meteor.registerBeforeMethod = function (name, method) {
  if (BeforeMethods[name]) {
    console.error(`[konecty:methods-middleware] Duplicated before method: ${name}`.red);
  }

  return BeforeMethods[name] = method;
};


Meteor.registerMiddleware = function (name, method) {
  if (Middlewares[name]) {
    console.error(`[konecty:methods-middleware] Duplicated middleware: ${name}`.red);
  }

  return Middlewares[name] = method;
};


Meteor.registerMethod = function (name, ...rest) {
  const adjustedLength = Math.max(rest.length, 1);
  const middlewareNames = rest.slice(0, adjustedLength - 1);
  const mainMethod = rest[adjustedLength - 1];
  const middlewares = {};

  for (let middlewareName of middlewareNames) {
    const middleware = Middlewares[middlewareName];
    if ((middleware == null)) {
      console.error(`[konecty:methods-middleware] Middleware not registered: ${middlewareName}`.red);
    } else {
      middlewares[middlewareName] = middleware;
    }
  }

  const meteorMethods = {};
  meteorMethods[name] = function (...args1) {
    let result;
    const adjustedLength1 = Math.max(args1.length, 1);
    const args = args1.slice(0, adjustedLength1 - 1);
    const lastArgument = args1[adjustedLength1 - 1];
    const scope = this;
    scope.__methodName__ = name;

    if ((this.connection === null) && isObject(lastArgument) && isObject(lastArgument.__scope__)) {
      for (let key in lastArgument.__scope__) {
        const value = lastArgument.__scope__[key];
        if ((scope[key] == null)) {
          scope[key] = value;
        }
      }
    }

    const processAfterMethods = function (result, args) {
      for (let afterMethodName in AfterMethods) {
        const afterMethod = AfterMethods[afterMethodName];
        const afterMethodParams = {
          result,
          arguments: args
        };

        logBeforeExecution(`-> ${name} - ${afterMethodName}`, scope, afterMethodParams);
        const afterMethodResult = afterMethod.call(scope, afterMethodParams);
        logAfterExecution(`-> ${name} - ${afterMethodName}`, scope, afterMethodParams);

        ({
          result
        } = afterMethodParams);

        if (afterMethodResult !== undefined) {
          return afterMethodResult;
        }

        return result;
      }
    };

    for (let beforeMethodName in BeforeMethods) {
      const beforeMethod = BeforeMethods[beforeMethodName];
      logBeforeExecution(`<- ${name} - ${beforeMethodName}`, scope, arguments);
      result = beforeMethod.apply(scope, arguments);
      logAfterExecution(`<- ${name} - ${beforeMethodName}`, scope, arguments, result);
      if (result !== undefined) {
        result = processAfterMethods(result, arguments);
        return processResult(result);
      }
    }

    for (let middlewareName in middlewares) {
      const middleware = middlewares[middlewareName];
      logBeforeExecution(`<> ${name} - ${middlewareName}`, scope, arguments);
      result = middleware.apply(scope, arguments);
      logAfterExecution(`<> ${name} - ${middlewareName}`, scope, arguments, result);
      if (result !== undefined) {
        result = processAfterMethods(result, arguments);
        return processResult(result);
      }
    }

    logBeforeExecution(`   ${name}`, scope, arguments);
    result = mainMethod.apply(scope, arguments);
    result = processResult(result);
    logAfterExecution(`   ${name}`, scope, arguments, result);

    result = processAfterMethods(result, arguments);
    return result;
  };

  return Meteor.methods(meteorMethods);
};

function isObject(obj) {
  const type = typeof obj;
  return type === 'function' || (type === 'object' && !!obj);
}
