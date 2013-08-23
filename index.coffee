configs = require './configs'
api = require 'simple-api'

v0 = new api
	prefix: ["api", "v0"]
	host: configs.host
	port: configs.port
	logLevel: 5

