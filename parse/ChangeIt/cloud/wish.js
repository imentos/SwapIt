Parse.Cloud.define("linkMyWish", function(request, response) {
    Parse.Cloud.httpRequest({
        method: 'POST',
        headers: {
            'Content-Type': 'application/json;charset=utf-8'
        },
        body: {
            query: 'MATCH (u:User{objectId:{userId}}), (w:Wish{objectId:{objectId}}) CREATE UNIQUE (u)-[r:WISH]->(w) RETURN r',
            params: {
                userId: request.params.userId,
                objectId: request.params.objectId
            }

        },
        url: 'https://brttr:tvOzwHwOJ5Eackn0nMyz@db-ji81rfgudyhg0oollisv.graphenedb.com:24780/db/data/cypher',
        followRedirects: true,
        success: function(httpResponse) {
            response.success(httpResponse.text);
        },
        error: function(httpResponse) {
            response.error('Request failed with response code ' + httpResponse.status);
        }
    });
});

Parse.Cloud.define("getWishesOfUser", function(request, response) {
    Parse.Cloud.httpRequest({
        method: 'POST',
        headers: {
            'Content-Type': 'application/json;charset=utf-8'
        },
        body: {
            query: 'MATCH (u:User{objectId:{userId}})-[r:WISH]->(w:Wish) RETURN w ORDER BY w.timestamp DESC',
            params: {
                userId: request.params.userId
            }
        },
        url: 'https://brttr:tvOzwHwOJ5Eackn0nMyz@db-ji81rfgudyhg0oollisv.graphenedb.com:24780/db/data/cypher',
        followRedirects: true,
        success: function(httpResponse) {
            var json_result = JSON.parse(httpResponse.text)
            var aResults = []
            json_result.data.forEach(function(o) {
                aResults.push(o[0].data)
            })
            response.success(JSON.stringify(aResults));
        },
        error: function(httpResponse) {
            response.error('Request failed with response code ' + httpResponse.status);
        }
    });
});

Parse.Cloud.define("getWishes", function(request, response) {
    Parse.Cloud.httpRequest({
        method: 'POST',
        headers: {
            'Content-Type': 'application/json;charset=utf-8'
        },
        body: {
            query: 'MATCH (n:Wish) RETURN n ORDER BY n.timestamp DESC'
        },
        url: 'https://brttr:tvOzwHwOJ5Eackn0nMyz@db-ji81rfgudyhg0oollisv.graphenedb.com:24780/db/data/cypher',
        followRedirects: true,
        success: function(httpResponse) {
            var json_result = JSON.parse(httpResponse.text)
            var aResults = []
            json_result.data.forEach(function(o) {
                aResults.push(o[0].data)
            })
            response.success(JSON.stringify(aResults));
        },
        error: function(httpResponse) {
            response.error('Request failed with response code ' + httpResponse.status);
        }
    });
});

Parse.Cloud.define("deleteWishOfUser", function(request, response) {
    Parse.Cloud.httpRequest({
        method: 'POST',
        headers: {
            'Content-Type': 'application/json;charset=utf-8'
        },
        body: {
            query: 'MATCH (n:Wish{objectId:{objectId}})<-[r:WISH]-(u:User{objectId:{userId}}) DELETE n,r',
            params: {
                objectId: request.params.objectId,
                userId: request.params.userId
            }
        },
        url: 'https://brttr:tvOzwHwOJ5Eackn0nMyz@db-ji81rfgudyhg0oollisv.graphenedb.com:24780/db/data/cypher',
        followRedirects: true,
        success: function(httpResponse) {
            response.success(httpResponse.status);
        },
        error: function(httpResponse) {
            response.error('Request failed with response code ' + httpResponse.status);
        }
    });
});

Parse.Cloud.define("deleteWishesOfUser", function(request, response) {
    Parse.Cloud.httpRequest({
        method: 'POST',
        headers: {
            'Content-Type': 'application/json;charset=utf-8'
        },
        body: {
            query: 'MATCH (n:Wish)<-[r:WISH]-(u:User{objectId:{userId}}) WHERE n.objectId IN {objectIds} DELETE n,r',
            params: {
                objectIds: request.params.objectIds,
                userId: request.params.userId
            }
        },
        url: 'https://brttr:tvOzwHwOJ5Eackn0nMyz@db-ji81rfgudyhg0oollisv.graphenedb.com:24780/db/data/cypher',
        followRedirects: true,
        success: function(httpResponse) {
            response.success(httpResponse.status);
        },
        error: function(httpResponse) {
            response.error('Request failed with response code ' + httpResponse.status);
        }
    });
});

Parse.Cloud.define("deleteAllWishesOfUser", function(request, response) {
    Parse.Cloud.httpRequest({
        method: 'POST',
        headers: {
            'Content-Type': 'application/json;charset=utf-8'
        },
        body: {
            query: 'MATCH (n:Wish)<-[r:WISH]-(u:User{objectId:{userId}}) DELETE n,r',
            params: {
                userId: request.params.userId
            }
        },
        url: 'https://brttr:tvOzwHwOJ5Eackn0nMyz@db-ji81rfgudyhg0oollisv.graphenedb.com:24780/db/data/cypher',
        followRedirects: true,
        success: function(httpResponse) {
            response.success(httpResponse.status);
        },
        error: function(httpResponse) {
            response.error('Request failed with response code ' + httpResponse.status);
        }
    });
});

Parse.Cloud.define("addWish", function(request, response) {
    var tokens = request.params.name.split(" ");
    var sSearchRegex = "(?i)" + tokens.join("|")
    Parse.Cloud.httpRequest({
        method: 'POST',
        headers: {
            'Content-Type': 'application/json;charset=utf-8'
        },
        body: {
            query: 'CREATE (n:Wish {name: {name}, objectId: {objectId}, searchRegex: {searchRegex}, timestamp: TIMESTAMP()}) RETURN n',
            params: {
                name: request.params.name,
                objectId: request.params.objectId,
                searchRegex: sSearchRegex
            }
        },
        url: 'https://brttr:tvOzwHwOJ5Eackn0nMyz@db-ji81rfgudyhg0oollisv.graphenedb.com:24780/db/data/cypher',
        followRedirects: true,
        success: function(httpResponse) {
            response.success(httpResponse.text);
        },
        error: function(httpResponse) {
            response.error('Request failed with response code ' + httpResponse.status);
        }
    });
});
