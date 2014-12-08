Meteor.registerLogs = true
Meteor.registerVerboseLogs = true

# Before methods
Meteor.registerBeforeMethod 'validate:arguments', (args...) ->
	if args.length isnt 2
		return new Error 'You must pass 2 arguments'
	return


# After methods
Meteor.registerAfterMethod 'transform:zeroInNull', (params) ->
	console.log params
	if params.result is 0
		return null
	return


# Middlewares
Meteor.registerMiddleware 'toNumber', (args...) ->
	this.arguments = args
	for arg, index in this.arguments
		this.arguments[index] = parseFloat arg
	return


# Methods
Meteor.registerMethod 'sum', (a, b) ->
	return a + b

Meteor.registerMethod 'numbers:sum', 'toNumber', (a, b) ->
	return this.arguments[0] + this.arguments[1]


# Tests
Tinytest.add 'Methods Middleware - simple call - sum numbers', (test) ->
	value = Meteor.call 'sum', 2, 3
	test.equal value, 5

Tinytest.add 'Methods Middleware - simple call - sum strings', (test) ->
	value = Meteor.call 'sum', '2', '3'
	test.equal value, '23'

Tinytest.add 'Methods Middleware - middleware - sum strings as numbers', (test) ->
	value = Meteor.call 'numbers:sum', '2', '3'
	test.equal value, 5

Tinytest.add 'Methods Middleware - before method - wrong number of arguments', (test) ->
	value = Meteor.call 'numbers:sum', 2
	test.instanceOf value, Error

Tinytest.add 'Methods Middleware - after method - zero result must be null', (test) ->
	value = Meteor.call 'numbers:sum', 0, 0
	test.isNull value
