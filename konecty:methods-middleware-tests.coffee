Meteor.registerLogs = true
Meteor.registerVerboseLogs = true

Meteor.registerBeforeMethod 'validate:arguments', (args...) ->
	if args.length isnt 2
		return new Error 'You must pass 2 arguments'

Meteor.registerMiddleware 'toNumber', (args...) ->
	this.arguments = args
	for arg, index in this.arguments
		this.arguments[index] = parseFloat arg
	return

Meteor.registerMethod 'sum', (a, b) ->
	return a + b

Meteor.registerMethod 'numbers:sum', 'toNumber', (a, b) ->
	return this.arguments[0] + this.arguments[1]


Tinytest.add 'Methods Middleware - sum numbers', (test) ->
	value = Meteor.call 'sum', 2, 3
	test.equal value, 5

Tinytest.add 'Methods Middleware - sum strings', (test) ->
	value = Meteor.call 'sum', '2', '3'
	test.equal value, '23'

Tinytest.add 'Methods Middleware - sum strings as numbers', (test) ->
	value = Meteor.call 'numbers:sum', '2', '3'
	test.equal value, 5

Tinytest.add 'Methods Middleware - wrong number of arguments', (test) ->
	value = Meteor.call 'numbers:sum', 2
	test.instanceOf value, Error

