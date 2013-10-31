var connect = require('connect');

module.exports = function initSession(opts) {

    var cookieParser = connect.cookieParser();
    var cookieSession = connect.cookieSession(opts);

    return function (req, res) {
        req.originalUrl = req.url;
        return cookieParser(req, res, function () {
            cookieSession(req, res, function() {});
        });
    }
};