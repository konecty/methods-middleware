utils = Npm.require 'util'

Middlewares = {}
BeforeMethods = {}
AfterMethods = {}


formatJsonWithPrefixAndColor = (value, prefix, color) ->
	value = JSON.stringify value, null, '  '
	value.replace /(.*\n)|(.+)/g, (value) ->
		return (prefix + value)[color]


removeInternalProperties = (value) ->
	value = utils._extend {}, value
	delete value.__methodName__
	return value


logBeforeExecution = (methodName, scope, args) ->
	console.log "#{methodName} [will call]".cyan
	if scope?
		console.log '  > SCOPE'.cyan
		console.log formatJsonWithPrefixAndColor removeInternalProperties(scope), '  | ', 'cyan'
	if args?
		console.log '  > ARGUMENTS'.cyan
		console.log formatJsonWithPrefixAndColor args, '  | ', 'cyan'

logAfterExecution = (methodName, scope, args, result) ->
	console.log "#{methodName} [called]".magenta
	if scope?
		console.log '  > SCOPE'.magenta
		console.log formatJsonWithPrefixAndColor removeInternalProperties(scope), '  | ', 'magenta'
	if args?
		console.log '  > ARGUMENTS'.magenta
		console.log formatJsonWithPrefixAndColor args, '  | ', 'magenta'
	if result?
		console.log '  > RESULT'.magenta
		console.log formatJsonWithPrefixAndColor args, '  | ', 'magenta'

processResult = (result) ->
	if _.isObject(result) and _.isFunction(result.fetch)
		return result.fetch()

	return result


Meteor.registerAfterMethod = (name, method) ->
	if AfterMethods[name]?
		console.error "[konecty:methods-middleware] Duplicated after method: #{name}".red

	AfterMethods[name] = method


Meteor.registerBeforeMethod = (name, method) ->
	if BeforeMethods[name]?
		console.error "[konecty:methods-middleware] Duplicated before method: #{name}".red

	BeforeMethods[name] = method


Meteor.registerMiddleware = (name, method) ->
	if Middlewares[name]?
		console.error "[konecty:methods-middleware] Duplicated middleware: #{name}".red

	Middlewares[name] = method


Meteor.registerMethod = (name, middlewareNames..., mainMethod) ->
	middlewares = {}

	for middlewareName in middlewareNames
		middleware = Middlewares[middlewareName]
		if not middleware?
			console.error "[konecty:methods-middleware] Middleware not registered: #{middlewareName}".red
		else
			middlewares[middlewareName] = middleware

	meteorMethods = {}
	meteorMethods[name] = ->
		scope =
			__methodName__: name

		for beforeMethodName, beforeMethod of BeforeMethods
			logBeforeExecution beforeMethodName, scope, arguments
			result = beforeMethod.apply scope, arguments
			logAfterExecution beforeMethodName, scope, arguments, result
			if result?
				return processResult result

		for middlewareName, middleware of middlewares
			logBeforeExecution middlewareName, scope, arguments
			result = middleware.apply scope, arguments
			logAfterExecution middlewareName, scope, arguments, result
			if result?
				return processResult result

		logBeforeExecution name, scope, arguments
		result = mainMethod.apply scope, arguments
		logAfterExecution name, scope, arguments, result

		for afterMethodName, afterMethod of AfterMethods
			afterMethodParams =
				result: result
				arguments: arguments

			logBeforeExecution afterMethodName, scope, afterMethodParams
			afterMethodResult = afterMethod.call scope, afterMethodParams
			logAfterExecution afterMethodName, scope, afterMethodParams

			result = afterMethodParams.result

			if afterMethodResult?
				return processResult result

		return processResult result

	Meteor.methods meteorMethods