utils = Npm.require 'util'

Middlewares = {}
BeforeMethods = {}
AfterMethods = {}

# Meteor.registerLogs = true
# Meteor.registerVerboseLogs = true

formatJsonWithPrefixAndColor = (value, prefix, color) ->
	value = JSON.stringify value, null, '  '
	value.replace /(.*\n)|(.+)/g, (value) ->
		return (prefix + value)[color]


removeInternalProperties = (value) ->
	value = utils._extend {}, value
	delete value.__methodName__
	return value


logBeforeExecution = (methodName, scope, args) ->
	if Meteor.registerLogs isnt true
		return

	console.log "#{methodName}".cyan

	if Meteor.registerVerboseLogs isnt true
		return

	if scope?
		console.log '   > SCOPE'.grey
		console.log formatJsonWithPrefixAndColor removeInternalProperties(scope), '   | ', 'grey'
	if args?
		console.log '   > ARGUMENTS'.grey
		console.log formatJsonWithPrefixAndColor args, '   | ', 'grey'

logAfterExecution = (methodName, scope, args, result) ->
	if Meteor.registerLogs isnt true
		return

	console.log "#{methodName} [done]".cyan

	if Meteor.registerVerboseLogs isnt true
		return

	if scope?
		console.log '   > SCOPE'.grey
		console.log formatJsonWithPrefixAndColor removeInternalProperties(scope), '   | ', 'grey'
	if args?
		console.log '   > ARGUMENTS'.grey
		console.log formatJsonWithPrefixAndColor args, '   | ', 'grey'
	if result?
		console.log '   > RESULT'.grey
		console.log formatJsonWithPrefixAndColor processResult(result), '   | ', 'grey'

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
			logBeforeExecution "<- #{name} - #{beforeMethodName}", scope, arguments
			result = beforeMethod.apply scope, arguments
			logAfterExecution "<- #{name} - #{beforeMethodName}", scope, arguments, result
			if result?
				return processResult result

		for middlewareName, middleware of middlewares
			logBeforeExecution "<> #{name} - #{middlewareName}", scope, arguments
			result = middleware.apply scope, arguments
			logAfterExecution "<> #{name} - #{middlewareName}", scope, arguments, result
			if result?
				return processResult result

		logBeforeExecution "   #{name}", scope, arguments
		result = mainMethod.apply scope, arguments
		result = processResult result
		logAfterExecution "   #{name}", scope, arguments, result

		for afterMethodName, afterMethod of AfterMethods
			afterMethodParams =
				result: result
				arguments: arguments

			logBeforeExecution "-> #{name} - #{afterMethodName}", scope, afterMethodParams
			afterMethodResult = afterMethod.call scope, afterMethodParams
			logAfterExecution "-> #{name} - #{afterMethodName}", scope, afterMethodParams

			result = afterMethodParams.result

			if afterMethodResult?
				return result

		return result

	Meteor.methods meteorMethods