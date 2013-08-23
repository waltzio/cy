configs = require './configs'
api = require 'simple-api'

v0 = new api
	prefix: ["api", "v0"]
	host: configs.host
	port: configs.port
	logLevel: 5

v0.Controller "keys", require "#{__dirname}/api/v0/controllers/keys.coffee"

console.log "#{configs.name} now running at #{configs.host}:#{configs.port}"

