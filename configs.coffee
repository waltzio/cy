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
			app_id: '2cb640916f76717e3b29ce3a02cac3d5'
			app_secret: 'a478a7ba6466973a731e0cf666ce5479'
		configs.secret_key = "secret key"


	when "production"
		configs.cache = true
		configs.mongoURL = process.env.MONGOLAB_URI
		configs.url = "http://cydoemus.vault.tk"
		configs.port = process.env.PORT || "80"
		configs.host = process.env.HOST || "cydoemus.vault.tk"
		configs.url = process.env.URL || "https://cydoemus.vault.tk"
		configs.clef =
			app_id: process.env.CLEF_APP_ID
			app_secret: process.env.CLEF_APP_SECRET
		configs.secret_key = process.env.SECRET_KEY

module.exports = exports = configs
