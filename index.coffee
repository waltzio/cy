global.configs = require './configs'
global.mongoose = require 'mongoose'
session = require './lib/node-session'
api = require 'simple-api'
fs = require 'fs'
url = require 'url'
request = require 'request'

v0 = null
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
				fallback: apiFallback
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

apiFallback = (req, res) ->
	req.$session = session.start res, req
	urlParts = url.parse req.url, true

	if urlParts.pathname == "/login"
		fs.readFile './views/loginTest.html', 'utf8', (err, data) ->
			if err
				v0.responses.internalError res
			else
				v0.responses.respond res, data
	else if urlParts.pathname == "/clefCallback"
		handleClefCallback req, res
	else
		v0.responses.notAvailable res

handleClefCallback = (req, res) ->
	urlParts = url.parse req.url, true
	code = urlParts.query.code
	url = 'https://clef.io/api/v1/authorize';
	form = 
 		app_id: configs.clef.app_id
 		app_secret: configs.clef.app_secret
 		code: code

 	request.post 
 		url: url
 		form: form
 	, (err, resp, body) ->
 		clefResponse = JSON.parse body
 		if err or not clefResponse.access_token?
 			console.log "Error getting CLEF access token", err
 			v0.responses.notAuth res
 		else
 			req.$session.clefAccessToken = JSON.parse(body)['access_token']

	 		request.get "https://clef.io/api/v1/info?access_token=#{req.$session.clefAccessToken}", (err, resp, body) ->
	 			userInfo = JSON.parse body

	 			if err or !userInfo.success? or !userInfo.success
	 				console.log "Error getting clef user info", err
	 				v0.responses.notAuth res
	 			else
	 				v0.responses.respond res, body


kickoff()


