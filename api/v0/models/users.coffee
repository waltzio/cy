usersSchema = mongoose.Schema
	identifier: String
	created_at:
		type: Date
		default: Date.now
	updated_at:
		type: Date
		default: Date.now

usersSchema.static "getByIdentifier", (ident, cb) ->
	this.find 
		identifier: ident
	, (err, doc) ->
			if err
				console.log "Error getting user by identifier"
				cb?(err)
				return true
			else
				cb?(null, doc)
				return false

	return true


Users = mongoose.model 'Users', usersSchema

module.exports = exports = Users
