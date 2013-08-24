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

keysSchema.static "getUserKeyByIdentifier", (userid, ident, cb) ->
	this.find 
		user:
			id: userid
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



Keys = mongoose.model 'Keys', keysSchema

module.exports = exports = Keys
