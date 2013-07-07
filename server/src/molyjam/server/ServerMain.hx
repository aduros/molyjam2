package molyjam.server;

import js.Node;

using Lambda;

class ServerMain
{
    private static function main ()
    {
        var connect = Node.require("connect");
        var websocket = Node.require("websocket");

        // Start a static HTTP server
        var host = "0.0.0.0";
        var staticServer = connect()
            .listen(Config.SERVER_PORT, host);

        // Start a websocket server
        var wsServer = Type.createInstance(websocket.server, [{
            httpServer: staticServer,
            autoAcceptConnections: true, // lolsecurity
        }]);
        trace("Listening on "+host+":"+Config.SERVER_PORT);

        var matches = new Map<Int,Match>();
        wsServer.on("connect", function (socket) {
            trace("Client connected from " + socket.remoteAddress);

            var channel = new Channel(socket);
            channel.messaged.connect(function (event, data) {
                switch (event) {
                case "cockpit_login":
                    var match = new Match(_matchId++, channel);
                    matches.set(match.id, match);
                    channel.closed.connect(function () {
                        matches.remove(match.id);
                    });
                case "phone_login":
                    // Tell them the active matches
                    var summary = [];
                    for (match in matches) {
                        summary.push(match.toSummary());
                    }
                    channel.send("matches", summary);
                case "join":
                    var id :Int = cast data;
                    var match = matches.get(id);
                    if (match != null) {
                        match.addPhone(channel);
                    } else {
                        trace("Tried to join an invalid game id: " + id);
                    }

                };
            });
        });

        var lastUpdate = Date.now().getTime();
        Node.setInterval(function () {
            var now = Date.now().getTime();
            var dt = now - lastUpdate;
            lastUpdate = now;

            for (match in matches) {
                match.update(dt/1000);
            }
        }, 100);
    }

    private static var _matchId :Int = 0;
}
