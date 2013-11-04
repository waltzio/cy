crypto = require 'crypto'

KeysController =
	options: {}
	routes:
		getKey:
			method: "GET"
			path: ["[.*]identifier"]

	actions:
		getKey: (req, res, params) ->

			if !req.session.user? or !req.session.user
				@responses.notAuth res
			else
				Users = mongoose.model "Users"
				Keys = mongoose.model "Keys"

				Users.getByIdentifier req.session.user.identifier, (err, existingUser) =>
					if err or !existingUser.length
						@responses.notAuth res
					else
						user = existingUser[0]
						if user.logged_out_at > req.session.logged_in_at
							req.session = {}
							@responses.notAuth res
						else
							Keys.getUserKeyWithIdentifier user, params.identifier, (err, key) =>
								if err
									@responses.internalError res, "Error retrieving your key.  This probably isn't your fault"
								else if !key.length
									#Key doesn't exist, so let's create a new one
									console.log "Key doesn't exist.  Creating"
									@helpers.generateKey (err, key) =>
										if err
											@responses.internalError res, "Error generating key.  This probably isn't your fault."
										else 
											console.log "Key generated.  Persisting"
											Keys.createUserKeyWithIdentifier req.session.user, params.identifier, key, (err, keyObj) =>
												if err
													@responses.internalError res, "Your key didn't exist, so we tried to create a new one.  We got an error.  It probably wasn't your fault."
												else
													@responses.respond res, 
														key: keyObj

								else
									#Woot woot!  Key already exists!
									@responses.respond res, 
										key: key[0]

	helpers: 
		generateKey: (cb) ->
			crypto.randomBytes 256, (err, buff) ->
				cb? err, buff.toString 'hex'

module.exports = exports = KeysController