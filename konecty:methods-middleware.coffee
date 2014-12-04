Middlewares = {}
BeforeMethods = {}
AfterMethods = {}


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


Meteor.registerMethod = (name, middlewares..., method) ->
	m = {}
	scope = {}
	m[name] = ->
		for middleware in middlewares
			fn = Middlewares[middleware]
			result = fn.apply scope, arguments
			if result?
				if _.isObject(result) and _.isFunction(result.fetch)
					return result.fetch()
				return result

		result = method.apply scope, arguments
		if _.isObject(result) and _.isFunction(result.fetch)
			return result.fetch()
		return result

	Meteor.methods m