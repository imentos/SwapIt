Parse.Cloud.define("addQuestion", function(request, response) {
    Parse.Cloud.httpRequest({
        method: 'POST',
        headers: {
            'Content-Type': 'application/json;charset=utf-8'
        },
        body: {
            query: 'CREATE (n:Question {objectId: {objectId}, text: {text}, timestamp: TIMESTAMP()}) RETURN n',
            params: {
                text: request.params.text,
                objectId: request.params.objectId
            }
        },
        url: 'http://changeIt:IChjQEbKm7G89oZ0iZwF@changeit.sb05.stations.graphenedb.com:24789/db/data/cypher',
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
 
Parse.Cloud.define("getQuestionsCountOfItem", function(request, response) {
    Parse.Cloud.httpRequest({
        method: 'POST',
        headers: {
            'Content-Type': 'application/json;charset=utf-8'
        },
        body: {
            query: 'MATCH (n:Item{objectId:{itemId}})<-[r:LINK]-() RETURN COUNT(r)',
            params: {
                itemId: request.params.itemId
            }
        },
        url: 'http://changeIt:IChjQEbKm7G89oZ0iZwF@changeit.sb05.stations.graphenedb.com:24789/db/data/cypher',
        followRedirects: true,
        success: function(httpResponse) {
            var json_result = JSON.parse(httpResponse.text)
            var aResults = []
            json_result.data.forEach(function(o) {
                aResults.push(o[0])
            })
            response.success(JSON.stringify(aResults));
        },
        error: function(httpResponse) {
            response.error('Request failed with response code ' + httpResponse.status);
        }
    });
});


Parse.Cloud.define("getQuestionedItemsByUser", function(request, response) {
    Parse.Cloud.httpRequest({
        method: 'POST',
        headers: {
            'Content-Type': 'application/json;charset=utf-8'
        },
        body: {
            query: 'MATCH (u:User)-[a:ASK]->(q:Question)-[r:LINK]->(i:Item{objectId:{itemId}}) RETURN q, u ORDER BY q.timestamp',
            params: {
                userId: request.params.userId,
                itemId: request.params.itemId
            }
 
        },
        url: 'http://changeIt:IChjQEbKm7G89oZ0iZwF@changeit.sb05.stations.graphenedb.com:24789/db/data/cypher',
        followRedirects: true,
        success: function(httpResponse) {
            var json_result = JSON.parse(httpResponse.text)
            var aResults = []
            json_result.data.forEach(function(o) {
                aResults.push({"question": o[0].data, "user": o[1].data})
            })
            response.success(JSON.stringify(aResults));
        },
        error: function(httpResponse) {
            response.error('Request failed with response code ' + httpResponse.status);
        }
    });
});
 
Parse.Cloud.define("askItemQuestionByUser", function(request, response) {
    Parse.Cloud.httpRequest({
        method: 'POST',
        headers: {
            'Content-Type': 'application/json;charset=utf-8'
        },
        body: {
            query: 'MATCH (u:User{objectId:{userId}}), (q:Question{objectId:{questionId}}), (i:Item{objectId:{itemId}}) CREATE UNIQUE (u)-[r:ASK]->(q)-[r1:LINK]->(i) RETURN r',
            params: {
                userId: request.params.userId,
                itemId: request.params.itemId,
                questionId: request.params.questionId,
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