Parse.Cloud.define("addQuestion", function(request, response) {
    Parse.Cloud.httpRequest({
        method: 'POST',
        headers: {
            'Content-Type': 'application/json;charset=utf-8'
        },
        body: {
            query: 'CREATE (n:Question {objectId: {objectId}, text: {text}, owner: {owner}, timestamp: TIMESTAMP()}) RETURN n',
            params: {
                text: request.params.text,
                objectId: request.params.objectId,
                owner: request.params.owner
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

Parse.Cloud.define("addReplyToQuestion", function(request, response) {
    Parse.Cloud.httpRequest({
        method: 'POST',
        headers: {
            'Content-Type': 'application/json;charset=utf-8'
        },
        body: {
            query: 'MATCH (q:Question{objectId:{questionId}}) CREATE (n:Reply {objectId: {objectId}, owner: {userId}, text: {text}, timestamp: TIMESTAMP()})-[r:REPLY]->q RETURN n',
            params: {
                text: request.params.text,
                objectId: request.params.objectId,
                questionId: request.params.questionId,
                userId: request.params.userId
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

Parse.Cloud.define("getRepliesOfQuestion", function(request, response) {
    Parse.Cloud.httpRequest({
        method: 'POST',
        headers: {
            'Content-Type': 'application/json;charset=utf-8'
        },
        body: {
            query: 'MATCH (q:Question{objectId:{questionId}})<-[reply:REPLY]->(r:Reply) RETURN r ORDER BY r.timestamp',
            params: {
                questionId: request.params.questionId
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

Parse.Cloud.define("getAskedQuestions", function(request, response) {
    Parse.Cloud.httpRequest({
        method: 'POST',
        headers: {
            'Content-Type': 'application/json;charset=utf-8'
        },
        body: {
            query: 'MATCH (u:User{objectId:{userId}})-[a:ASK]->(q:Question)-[r:LINK]->(i:Item)<-[o:OFFER]-(u1:User) RETURN q, i, u1 ORDER BY q.timestamp DESC',
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
                aResults.push({"question": o[0].data, "item": o[1].data, "user": o[2].data})
            })
            response.success(JSON.stringify(aResults));
        },
        error: function(httpResponse) {
            response.error('Request failed with response code ' + httpResponse.status);
        }
    });
});

Parse.Cloud.define("getAskedQuestionByItem", function(request, response) {
    Parse.Cloud.httpRequest({
        method: 'POST',
        headers: {
            'Content-Type': 'application/json;charset=utf-8'
        },
        body: {
            query: 'MATCH (u:User{objectId:{userId}})-[a:ASK]->(q:Question)-[r:LINK]->(i:Item{objectId:{itemId}}) RETURN q, u ORDER BY q.timestamp DESC',
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

Parse.Cloud.define("setQuestionRead", function(request, response) {
    Parse.Cloud.httpRequest({
        method: 'POST',
        headers: {
            'Content-Type': 'application/json;charset=utf-8'
        },
        body: {
            query: 'MATCH (q:Question{objectId:{objectId}})-[r:LINK]->() SET r.read = true RETURN q',
            params: {
                objectId: request.params.objectId
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

Parse.Cloud.define("setQuestionUnread", function(request, response) {
    Parse.Cloud.httpRequest({
        method: 'POST',
        headers: {
            'Content-Type': 'application/json;charset=utf-8'
        },
        body: {
            query: 'MATCH (q:Question{objectId:{objectId}})-[r:LINK]->() SET r.read = false RETURN q',
            params: {
                objectId: request.params.objectId
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

Parse.Cloud.define("getUnreadReceivedQuestionsCountOfItem", function(request, response) {
    Parse.Cloud.httpRequest({
        method: 'POST',
        headers: {
            'Content-Type': 'application/json;charset=utf-8'
        },
        body: {
            query: 'MATCH (n:Item{objectId:{itemId}})<-[r:LINK]-(q:Question)<-[a:ASK]-(u:User) WHERE r.read = false AND ((u)-[:OFFER]->(:Item)-[:EXCHANGE]->(n))  RETURN COUNT(r)',
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

Parse.Cloud.define("getUnreadQuestionsCount", function(request, response) {
    Parse.Cloud.httpRequest({
        method: 'POST',
        headers: {
            'Content-Type': 'application/json;charset=utf-8'
        },
        body: {
            query: 'MATCH (n:Item)<-[r:LINK]-(q:Question)<-[a:ASK]-(u:User) WHERE r.read = false AND NOT ((u)-[:OFFER]->(:Item)-[:EXCHANGE]->(n))  RETURN COUNT(r)',
            params: {
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

Parse.Cloud.define("getUnreadQuestionsCountOfItem", function(request, response) {
    Parse.Cloud.httpRequest({
        method: 'POST',
        headers: {
            'Content-Type': 'application/json;charset=utf-8'
        },
        body: {
            query: 'MATCH (n:Item{objectId:{itemId}})<-[r:LINK]-(q:Question)<-[a:ASK]-(u:User) WHERE r.read = false AND NOT ((u)-[:OFFER]->(:Item)-[:EXCHANGE]->(n))  RETURN COUNT(r)',
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

Parse.Cloud.define("getQuestionsCountOfItem", function(request, response) {
    Parse.Cloud.httpRequest({
        method: 'POST',
        headers: {
            'Content-Type': 'application/json;charset=utf-8'
        },
        body: {
            query: 'MATCH (n:Item{objectId:{itemId}})<-[r:LINK]-(q:Question)<-[a:ASK]-(u:User) WHERE NOT ((u)-[:OFFER]->(:Item)-[:EXCHANGE]->(n)) RETURN COUNT(r)',
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

Parse.Cloud.define("getQuestionedItems", function(request, response) {
    Parse.Cloud.httpRequest({
        method: 'POST',
        headers: {
            'Content-Type': 'application/json;charset=utf-8'
        },
        body: {
            query: 'MATCH (u:User)-[a:ASK]->(q:Question)-[r:LINK]->(i:Item{objectId:{itemId}}) WHERE NOT ((u)-[:OFFER]->(:Item)-[:EXCHANGE]->(i)) RETURN q, u, r ORDER BY q.timestamp DESC',
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
                aResults.push({"question": o[0].data, "user": o[1].data, "link": o[2].data})
            })
            response.success(JSON.stringify(aResults));
        },
        error: function(httpResponse) {
            response.error('Request failed with response code ' + httpResponse.status);
        }
    });
});

Parse.Cloud.define("deleteUnusedQuestions", function(request, response) {
    Parse.Cloud.httpRequest({
        method: 'POST',
        headers: {
            'Content-Type': 'application/json;charset=utf-8'
        },
        body: {
            query: 'MATCH (reply:Reply)-[r]-(q:Question)-[a:ASK]-() WHERE NOT (q)-[:LINK]->() DELETE a,q,r,reply'
        },
        url: 'http://changeIt:IChjQEbKm7G89oZ0iZwF@changeit.sb05.stations.graphenedb.com:24789/db/data/cypher',
        followRedirects: true,
        success: function(httpResponse) {
            response.success("success");
        },
        error: function(httpResponse) {
            response.error('Request failed with response code ' + httpResponse.status);
        }
    });
});

Parse.Cloud.define("deleteQuestion", function(request, response) {
    Parse.Cloud.httpRequest({
        method: 'POST',
        headers: {
            'Content-Type': 'application/json;charset=utf-8'
        },
        body: {
            query: 'MATCH (q:Question{objectId:{questionId}}) OPTIONAL MATCH (q)-[r]-() DELETE q, r',
            params: {
                questionId: request.params.questionId
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
 
Parse.Cloud.define("askItemQuestionByUser", function(request, response) {
    Parse.Cloud.httpRequest({
        method: 'POST',
        headers: {
            'Content-Type': 'application/json;charset=utf-8'
        },
        body: {
            query: 'MATCH (u:User{objectId:{userId}}), (q:Question{objectId:{questionId}}), (i:Item{objectId:{itemId}}) CREATE UNIQUE (u)-[r:ASK]->(q)-[r1:LINK{read:false}]->(i) RETURN r',
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