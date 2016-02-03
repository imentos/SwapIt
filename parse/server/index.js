var express = require('express');
var ParseServer = require('parse-server').ParseServer;

var app = express();
var api = new ParseServer({
    databaseURI: 'mongodb://brttr:brttr@ds055485.mongolab.com:55485/brttr',
    cloud: './cloud/main.js',
    appId: 'myAppId',
    // clientKey: 'myClientKey',
    masterKey: 'myMasterKey',
    // restAPIKey: 'myRESTAPIKey',
    facebookAppIds: ['839127896135278']
});

// Serve the Parse API at /parse URL prefix
app.use('/parse', api);

var port = 1337;
app.listen(port, function() {
    console.log('parse-server-example running on port ' + port + '.');
});
