configs = require './configs'
mongoose = require 'mongoose'
api = require 'simple-api'

kickoffTries = 0

kickoff = () ->
	kickoffTries++

	mongoose.connect configs.mongoURL, (err) ->
		if not err
			v0 = new api
				prefix: ["api", "v0"]
				host: configs.host
				port: configs.port
				logLevel: 5

			v0.Controller "keys", require "#{__dirname}/api/v0/controllers/keys.coffee"

			console.log "#{configs.name} now running at #{configs.host}:#{configs.port}"
		else if err & kickoffTries < 5
			console.log "Mongoose didn't work.  That's a bummer.  Let's try it again in half a second"
			setTimeout () ->
				kickoff()
			, 500
		else if err
			console.log "Mongo server seems to really be down.  We tried 5 times.  Tough luck."

			
kickoff()


