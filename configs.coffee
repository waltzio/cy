# If no env, set to local
if not process.env?.application_env
	process.env.application_env = "local"

configs = {
	name: "Cy"
}


switch process.env.application_env
	when "local"
		configs.mongoURL = "mongodb://localhost/cy"
		configs.host = "localhost"
		configs.port = "3333"
		configs.url = "http://localhost:3333"
		configs.cache = false
		configs.clef =
			app_id: '775da2c4142900d03bf3fca4cb13f93e'
			app_secret: '7d577bf2fdb7b9d92283def6fd3e11fb'

	when "production"
		configs.cache = true
		configs.mongoURL = process.env.MONGOLAB_URI
		configs.url = "http://cydoemus.vault.tk"
		configs.port = process.env.PORT || "80"
		configs.host = "cydoemus.vault.tk"
		configs.url = "https://cydoemus.vault.tk"
		configs.clef =
			app_id: process.env.CLEF_APP_ID
			app_secret: process.env.CLEF_APP_SECRET

module.exports = exports = configs
