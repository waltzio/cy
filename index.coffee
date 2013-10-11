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
				host: null
				port: configs.port
				before: prepareAPIRequest
				fallback: apiFallback
				logLevel: 5

			#Load Controllers
			v0.Controller "keys", require "#{__dirname}/api/v0/controllers/keys.coffee"


			#Mock simple-api model format
			require "#{__dirname}/api/v0/models/keys.coffee"
			require "#{__dirname}/api/v0/models/users.coffee"

			console.log "#{configs.name} is now running at #{configs.host}:#{configs.port}"
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
	#req.$session.user = 12345 #Fake the user for offline testing
	
	urlParts = url.parse req.url, true

	if urlParts.pathname == "/login"
		fs.readFile './views/loginTest.html', 'utf8', (err, data) ->
			if err
				v0.responses.internalError res
			else
				v0.responses.respond res, data.replace "{{host}}", configs.host
	else if urlParts.pathname == "/clefCallback"
		handleClefCallback req, res
	else if urlParts.pathname == "/clefLogout"
		handleClefLogout req, res
	else if urlParts.pathname == "/logout"
		handleBrowserLogout req, res
	else if urlParts.pathname == "/check"
		handleAuthenticationCheck req, res
	else
		v0.responses.notAvailable res

handleClefLogout = (req, res) ->
	urlParts = url.parse req.url, true 
	form = 
 		app_id: configs.clef.app_id
 		app_secret: configs.clef.app_secret
 		logout_token: req.body.logout_token

 	request.post 
 		url: 'https://clef.io/api/v1/logout'
 		form: form
 	, (err, resp, body) ->
 		clefResponse = JSON.parse body
 		if err or not clefResponse.access_token?
 			console.log "Error getting CLEF access token", err, clefResponse
 			v0.responses.notAuth res
 		else
 			req.$session.clefAccessToken = JSON.parse(body)['access_token']

	 		request.get "https://clef.io/api/v1/info?access_token=#{req.$session.clefAccessToken}", (err, resp, body) ->
	 			userInfo = JSON.parse body

	 			if err or !userInfo.success? or !userInfo.success
	 				console.log "Error getting clef user info", err
	 				v0.responses.notAuth res
	 			else	
	 				for sess in session.sessions
	 					if sess.user.identifier == userInfo.info.id
	 						sess.user = false
	 						v0.response.respond res

handleBrowserLogout = (req, res) ->
	if req.$session
		req.$session.user = false

	v0.responses.respond res


handleAuthenticationCheck = (req, res) ->
	if req.$session? and req.$session.user
		v0.responses.respond res,
			user: true
	else
		v0.responses.respond res,
			user: false


handleClefCallback = (req, res) ->
	urlParts = url.parse req.url, true
	code = urlParts.query.code
	form = 
 		app_id: configs.clef.app_id
 		app_secret: configs.clef.app_secret
 		code: code

 	console.log form

 	request.post 
 		url: 'https://clef.io/api/v1/authorize'
 		form: form
 	, (err, resp, body) ->
 		clefResponse = JSON.parse body
 		if err or not clefResponse.access_token?
 			console.log "Error getting CLEF access token", err, clefResponse
 			v0.responses.notAuth res
 		else
 			req.$session.clefAccessToken = JSON.parse(body)['access_token']

	 		request.get "https://clef.io/api/v1/info?access_token=#{req.$session.clefAccessToken}", (err, resp, body) ->
	 			userInfo = JSON.parse body

	 			if err or !userInfo.success? or !userInfo.success
	 				console.log "Error getting clef user info", err
	 				v0.responses.notAuth res
	 			else
	 				Users = mongoose.model "Users"
	 				
	 				Users.getByIdentifier userInfo.info.id, (err, existingUser) ->
	 					if err
	 						v0.responses.internalError res, "Error finding your user.  This probably isn't your fault.  Try again."
	 					else if !existingUser.length
	 						#User doesn't exist.  Let's create one!
	 						Users.createWithIdentifier userInfo.info.id, (err, newUser) ->
	 							if err
	 								v0.responses.internalError res, "Error creating user.  This probably isn't your fault.  Try again."
	 							else
	 								#New user created!  Woohoo!
	 								req.$session.user = newUser
	 								v0.responses.respond res
	 					else
	 						#user already exists.  Let's use that.
	 						req.$session.user = existingUser[0]
	 						v0.responses.respond res, "<script type='text/javascript'>addEventListener('message', function(e) { e.source.postMessage({auth: true}, e.origin); });</script>"



kickoff()


