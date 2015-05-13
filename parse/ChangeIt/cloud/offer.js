
Parse.Cloud.define("exchangeItem", function(request, response) {
    Parse.Cloud.httpRequest({
        method: 'POST',
        headers: {
            'Content-Type': 'application/json;charset=utf-8'
        },
        body: {
            query: 'MATCH (s:Item{objectId:{srcItemId}}), (d:Item{objectId:{distItemId}}) CREATE UNIQUE (s)-[r:EXCHANGE]->(d) RETURN r',
            params: {
                srcItemId: request.params.srcItemId,
                distItemId: request.params.distItemId
            }

        },
        url: 'http://changeIt:IChjQEbKm7G89oZ0iZwF@changeit.sb05.stations.graphenedb.com:24789/db/data/cypher',
        followRedirects: true,
        success: function(httpResponse) {
            response.success(httpResponse.text);
        },
        error: function(httpResponse) {
            response.error('Request failed with response code ' + httpResponse.status);
        }
    });
});

Parse.Cloud.define("getItemsWithOffersByUser", function(request, response) {
    Parse.Cloud.httpRequest({
        method: 'POST',
        headers: {
            'Content-Type': 'application/json;charset=utf-8'
        },
        body: {
            query: 'MATCH (u:User{objectId:{userId}})--(s:Item) OPTIONAL MATCH s<-[r:EXCHANGE]-(d:Item) RETURN s,d',
            params: {
                userId: request.params.userId
            }
        },
        url: 'http://changeIt:IChjQEbKm7G89oZ0iZwF@changeit.sb05.stations.graphenedb.com:24789/db/data/cypher',
        followRedirects: true,
        success: function(httpResponse) {
            var json_result = JSON.parse(httpResponse.text)
            var aResults = []
            var oOffers = {}
            json_result.data.forEach(function(o) { 
                // TODO: for future use, this is an aggregation version
/*
                var id = o[1].data.objectId
                if (!oOffers.hasOwnProperty(id)) {
                    oOffers[id] = []  
                    oOffers[id].push(o[0] ? o[0].data : null)  
                    aResults.push({"src": oOffers[id], "dst": o[1].data})
                } else {
                    oOffers[id].push({"src": o[0] ? o[0].data : null, "dst": o[1].data})
                }
                
*/
                aResults.push({"src": o[0].data, "dst": o[1] ? o[1].data : null})
            })
            response.success(JSON.stringify(aResults));
        },
        error: function(httpResponse) {
            response.error('Request failed with response code ' + httpResponse.status);
        }
    });
});

Parse.Cloud.define("getSentOffersByUser", function(request, response) {
    Parse.Cloud.httpRequest({
        method: 'POST',
        headers: {
            'Content-Type': 'application/json;charset=utf-8'
        },
        body: {
            query: 'MATCH (u:User{objectId:{userId}})--(s:Item)-[r:EXCHANGE]->(d:Item) RETURN s, d',
            params: {
                userId: request.params.userId
            }
        },
        url: 'http://changeIt:IChjQEbKm7G89oZ0iZwF@changeit.sb05.stations.graphenedb.com:24789/db/data/cypher',
        followRedirects: true,
        success: function(httpResponse) {
            var json_result = JSON.parse(httpResponse.text)
            var aResults = []
            json_result.data.forEach(function(o) {
                aResults.push({"src": o[0].data, "dst": o[1].data})
            })
            response.success(JSON.stringify(aResults));
        },
        error: function(httpResponse) {
            response.error('Request failed with response code ' + httpResponse.status);
        }
    });
});

Parse.Cloud.define("getReceivedOffersByUser", function(request, response) {
    Parse.Cloud.httpRequest({
        method: 'POST',
        headers: {
            'Content-Type': 'application/json;charset=utf-8'
        },
        body: {
            query: 'MATCH (u:User{objectId:{userId}})--(d:Item)<-[r:EXCHANGE]-(s:Item) RETURN s, d',
            params: {
                userId: request.params.userId
            }
        },
        url: 'http://changeIt:IChjQEbKm7G89oZ0iZwF@changeit.sb05.stations.graphenedb.com:24789/db/data/cypher',
        followRedirects: true,
        success: function(httpResponse) {
            var json_result = JSON.parse(httpResponse.text)
            var aResults = []
            json_result.data.forEach(function(o) {
                aResults.push({"src": o[0].data, "dst": o[1].data})
            })
            response.success(JSON.stringify(aResults));
        },
        error: function(httpResponse) {
            response.error('Request failed with response code ' + httpResponse.status);
        }
    });
});
