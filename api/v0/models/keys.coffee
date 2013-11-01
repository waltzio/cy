keysSchema = mongoose.Schema
	user:
		type: mongoose.Schema.ObjectId
		ref: "User"
	identifier: String
	key: String
	created_at:
		type: Date
		default: Date.now
	updated_at:
		type: Date
		default: Date.now

keysSchema.static "getUserKeyWithIdentifier", (user, ident, cb) ->
	this.find 
		user: user.id
		identifier: ident
	, (err, doc) ->
			if err
				console.log "Error getting user key by identifier"
				cb?(err)
				return true
			else
				cb?(null, doc)
				return false

	return true

keysSchema.static "createUserKeyWithIdentifier", (user, ident, key, cb) ->
	newKey = new Keys
		user: user
		identifier: ident
		key: key

	newKey.save cb



Keys = mongoose.model 'Keys', keysSchema

module.exports = exports = Keys
