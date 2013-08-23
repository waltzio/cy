crypto = require 'crypto'

KeysController =
	options: {}
	routes:
		getKey:
			method: "GET"
			pieces: []

	actions:
		getKey: (req, res, params) ->
			@helpers.generateKey (err, key) ->
				if err
					console.log err
					res.statusCode = 500
					res.end JSON.stringify
						error: true
						message: "Error Generating Keys.  This probably isn't your fault."
				else
					res.end JSON.stringify
						key: key

	helpers: 
		generateKey: (cb) ->
			crypto.randomBytes 256, (err, buff) ->
				cb? err, buff.toString 'hex'


module.exports = exports = KeysController