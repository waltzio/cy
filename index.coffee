global.configs = require './configs'
global.mongoose = require 'mongoose'
session = require './lib/node-session'
api = require 'simple-api'

kickoffTries = 0

kickoff = () ->
	kickoffTries++

	mongoose.connect configs.mongoURL, (err) ->
		if not err
			#Create API Server
			v0 = new api
				prefix: ["api", "v0"]
				host: configs.host
				port: configs.port
				before: prepareAPIRequest
				logLevel: 5

			#Load Controllers
			v0.Controller "keys", require "#{__dirname}/api/v0/controllers/keys.coffee"


			#Mock simple-api model format
			require "#{__dirname}/api/v0/models/keys.coffee"
			require "#{__dirname}/api/v0/models/users.coffee"

			console.log "#{configs.name} now running at #{configs.host}:#{configs.port}"
		else if err & kickoffTries < 5
			console.log "Mongoose didn't work.  That's a bummer.  Let's try it again in half a second"
			setTimeout () ->
				kickoff()
			, 500
		else if err
			console.log "Mongo server seems to really be down.  We tried 5 times.  Tough luck."

prepareAPIRequest = (req, res, controller) ->
	req.$session = session.start res, req


kickoff()


