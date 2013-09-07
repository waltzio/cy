crypto = require 'crypto'

KeysController =
	options: {}
	routes:
		getKey:
			method: "GET"
			path: ["*identifier"]

	actions:
		getKey: (req, res, params) ->
			console.log "Attempting to get key"

			#This whole afterAuth thing is just temporary, because we're not doing real auth yet.
			#Eventually this code flow will be more logical..  For now, this function is just here
			#So that I don't have to define it twice (once after user creation, once after existing session auth)
			afterAuth = (user) =>
				Keys = mongoose.model "Keys"

				Keys.getUserKeyWithIdentifier user, params.identifier, (err, key) =>
					if err
						@responses.internalError res, "Error retrieving your key.  This probably isn't your fault"
					else if !key.length
						#Key doesn't exist, so let's create a new one
						console.log "Key doesn't exist.  Creating"
						@helpers.generateKey (err, key) ->
							if err
								@responses.internalError res, "Error generating key.  This probably isn't your fault."
							else 
								console.log "Key generated.  Persisting"
								Keys.createUserKeyWithIdentifier user, params.identifier, key, (err, keyObj) ->
									if err
										@responses.internalError res, "Your key didn't exist, so we tried to create a new one.  We got an error.  It probably wasn't your fault."
									else
										@responses.respond res, keyObj

					else
						#Woot woot!  Key already exists!
						res.end JSON.stringify
							key: key[0]

			if not req.$session.user? or req.$session.user == false
				#The user doesn't already exist.  Since we're not ready for auth yet, let's just create a faux user
				console.log "User is not auth'd.  Try a faux user"
				Users = mongoose.model "Users"


				Users.getByIdentifier 1337, (err, existingUser) ->
					if err
						@responses.internalError res, "Error getting existing faux user.  This probably isn't your fault."
					else if existingUser.length
						console.log "Faux user already exists.  Auth the session and move on"

						req.$session.user = existingUser[0]

						afterAuth existingUser[0]
					else
						console.log "Faux user doesn't exit.  Create one"

						Users.createWithIdentifier 1337, (err, newUser) ->
							#I should really make this error handler a function..  This is not very DRY
							if err
								@responses.internalError res, "Error Creating User.  This probably isn't your fault."
							else
								console.log "User created.  Auth the session and move on"

								req.$session.user = newUser

								afterAuth newUser
			else
				console.log "User already auth'd.  Move on"
				afterAuth req.$session.user

	helpers: 
		generateKey: (cb) ->
			crypto.randomBytes 256, (err, buff) ->
				cb? err, buff.toString 'hex'

module.exports = exports = KeysController