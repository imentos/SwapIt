Parse.Cloud.define("getItemsByUser", function(request, response) {
    Parse.Cloud.httpRequest({
        method: 'POST',
        headers: {
            'Content-Type': 'application/json;charset=utf-8'
        },
        body: {
            query: 'MATCH (u:User{objectId:{userId}})-[o:OFFER]->(s:Item) RETURN s ORDER BY s.timestamp DESC',
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
                aResults.push(o[0].data)
            })
            response.success(JSON.stringify(aResults));
        },
        error: function(httpResponse) {
            response.error('Request failed with response code ' + httpResponse.status);
        }
    });
});


Parse.Cloud.define("getBestItemsExceptMe", function(request, response) {
    Parse.Cloud.httpRequest({
        method: 'POST',
        headers: {
            'Content-Type': 'application/json;charset=utf-8'
        },
        body: {
            query: 'MATCH (o:Item),(u:User)--(w:Wish) WHERE o.title=~{search} AND o.title=~w.searchRegex AND u.objectId={userId} RETURN o ORDER BY o.timestamp DESC LIMIT {limit}',
            params: {
                search: "(?i)" + request.params.search,
                userId: request.params.userId,
                limit: request.params.limit
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

Parse.Cloud.define("getAllItemsExceptMe", function(request, response) {
    Parse.Cloud.httpRequest({
        method: 'POST',
        headers: {
            'Content-Type': 'application/json;charset=utf-8'
        },
        body: {
            query: 'MATCH (o:Item)<-[r:OFFER]-(u:User) WHERE o.title=~{search} AND NOT u.objectId={userId} RETURN o ORDER BY o.timestamp DESC LIMIT {limit}',
            params: {
                search: "(?i).*" + request.params.search + ".*",
                userId: request.params.userId,
                limit: request.params.limit
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


Parse.Cloud.define("getAllItemsByList", function(request, response) {
    Parse.Cloud.httpRequest({
        method: 'POST',
        headers: {
            'Content-Type': 'application/json;charset=utf-8'
        },
        body: {
            query: 'MATCH (o:Item)<-[r:OFFER]-(u:User) WHERE o.title=~{search} AND o.objectId IN {ids} AND NOT u.objectId={userId} RETURN o ORDER BY o.timestamp DESC LIMIT {limit}',
            params: {
                ids: request.params.ids,
                search: "(?i).*" + request.params.search + ".*",
                userId: request.params.userId,
                limit: request.params.limit
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

Parse.Cloud.define("deleteItem", function(request, response) {
    Parse.Cloud.httpRequest({
        method: 'POST',
        headers: {
            'Content-Type': 'application/json;charset=utf-8'
        },
        body: {
            query: 'MATCH (n:Item{objectId:{itemId}}) OPTIONAL MATCH (n)-[r]-() DELETE n,r',
            params: {
                itemId: request.params.itemId
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

Parse.Cloud.define("addItem", function(request, response) {
    Parse.Cloud.httpRequest({
        method: 'POST',
        headers: {
            'Content-Type': 'application/json;charset=utf-8'
        },
        body: {
            query: 'CREATE (n:Item {objectId: {objectId}, title: {title}, description: {description}, photo: {photo}, communication: {communication}, timestamp: TIMESTAMP()}) RETURN n',
            params: {
                objectId: request.params.objectId,
                title: request.params.title,
                description: request.params.description,
                photo: request.params.photo,
                communication: request.params.communication
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

Parse.Cloud.define("updateItem", function(request, response) {
    Parse.Cloud.httpRequest({
        method: 'POST',
        headers: {
            'Content-Type': 'application/json;charset=utf-8'
        },
        body: {
            query: 'MATCH (n:Item{objectId:{itemId}}) SET n.title={title}, n.description={description}, n.photo={photo}, n.communication={communication}, n.timestamp=TIMESTAMP() RETURN n',
            params: {
                itemId: request.params.itemId,
                title: request.params.title,
                description: request.params.description,
                photo: request.params.photo,
                communication: request.params.communication
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

Parse.Cloud.define("getItem", function(request, response) {
    Parse.Cloud.httpRequest({
        method: 'POST',
        headers: {
            'Content-Type': 'application/json;charset=utf-8'
        },
        body: {
            query: 'MATCH (n:Item{objectId:{itemId}}) RETURN n',
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
                aResults.push(o[0].data)
            })
            response.success(JSON.stringify(aResults));
        },
        error: function(httpResponse) {
            response.error('Request failed with response code ' + httpResponse.status);
        }
    });
});

Parse.Cloud.define("getItemExceptMe", function(request, response) {
    Parse.Cloud.httpRequest({
        method: 'POST',
        headers: {
            'Content-Type': 'application/json;charset=utf-8'
        },
        body: {
            query: 'MATCH (n:Item{objectId:{itemId}})<-[r:OFFER]-(u:User) WHERE NOT u.objectId={userId} RETURN n',
            params: {
                itemId: request.params.itemId,
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

Parse.Cloud.define("getItems", function(request, response) {
    Parse.Cloud.httpRequest({
        method: 'POST',
        headers: {
            'Content-Type': 'application/json;charset=utf-8'
        },
        body: {
            query: 'MATCH (n:Item) RETURN n ORDER BY n.timestamp DESC'
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

Parse.Cloud.define("getBookmarkedItems", function(request, response) {
    Parse.Cloud.httpRequest({
        method: 'POST',
        headers: {
            'Content-Type': 'application/json;charset=utf-8'
        },
        body: {
            query: 'MATCH (n:Item)<-[r:BOOKMARK]-(u:User{objectId:{userId}}) RETURN n ORDER BY n.timestamp DESC',
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
                aResults.push(o[0].data)
            })
            response.success(JSON.stringify(aResults));
        },
        error: function(httpResponse) {
            response.error('Request failed with response code ' + httpResponse.status);
        }
    });
});

Parse.Cloud.define("bookmarkItem", function(request, response) {
    Parse.Cloud.httpRequest({
        method: 'POST',
        headers: {
            'Content-Type': 'application/json;charset=utf-8'
        },
        body: {
            query: 'MATCH (u:User{objectId:{userId}}), (w:Item{objectId:{itemId}}) CREATE UNIQUE (u)-[r:BOOKMARK]->(w) RETURN r',
            params: {
                userId: request.params.userId,
                itemId: request.params.itemId
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

Parse.Cloud.define("unbookmarkItem", function(request, response) {
    Parse.Cloud.httpRequest({
        method: 'POST',
        headers: {
            'Content-Type': 'application/json;charset=utf-8'
        },
        body: {
            query: 'MATCH (u:User{objectId:{userId}})-[r:BOOKMARK]->(w:Item{objectId:{itemId}}) DELETE r',
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
                aResults.push(o[0].data)
            })
            response.success(JSON.stringify(aResults));
        },
        error: function(httpResponse) {
            response.error('Request failed with response code ' + httpResponse.status);
        }
    });
});

Parse.Cloud.define("isItemBookmarked", function(request, response) {
    Parse.Cloud.httpRequest({
        method: 'POST',
        headers: {
            'Content-Type': 'application/json;charset=utf-8'
        },
        body: {
            query: 'MATCH (u:User{objectId:{userId}})-[r:BOOKMARK]->(w:Item{objectId:{itemId}}) RETURN w',
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
                aResults.push(o[0].data)
            })
            response.success(JSON.stringify(aResults));
        },
        error: function(httpResponse) {
            response.error('Request failed with response code ' + httpResponse.status);
        }
    });
});

Parse.Cloud.define("linkMyItem", function(request, response) {
    Parse.Cloud.httpRequest({
        method: 'POST',
        headers: {
            'Content-Type': 'application/json;charset=utf-8'
        },
        body: {
            query: 'MATCH (u:User{objectId:{userId}}), (w:Item{objectId:{itemId}}) CREATE UNIQUE (u)-[r:OFFER]->(w) RETURN r',
            params: {
                userId: request.params.userId,
                itemId: request.params.itemId
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

Parse.Cloud.define("getUserOfItem", function(request, response) {
    Parse.Cloud.httpRequest({
        method: 'POST',
        headers: {
            'Content-Type': 'application/json;charset=utf-8'
        },
        body: {
            query: 'MATCH (o:Item{objectId:{itemId}})<-[r:OFFER]-(u:User) RETURN u',
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
                aResults.push(o[0].data)
            })
            response.success(JSON.stringify(aResults));
        },
        error: function(httpResponse) {
            response.error('Request failed with response code ' + httpResponse.status);
        }
    });
});

Parse.Cloud.define("getItemsOfUser", function(request, response) {
    Parse.Cloud.httpRequest({
        method: 'POST',
        headers: {
            'Content-Type': 'application/json;charset=utf-8'
        },
        body: {
            query: 'MATCH (u:User{objectId:{userId}})-[r:OFFER]->(o:Item) RETURN o ORDER BY o.timestamp DESC',
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
                aResults.push(o[0].data)
            })
            response.success(JSON.stringify(aResults));
        },
        error: function(httpResponse) {
            response.error('Request failed with response code ' + httpResponse.status);
        }
    });
});
