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

        var matches = new Map<String,Match>();
        wsServer.on("connect", function (socket) {
            trace("Client connected from " + socket.remoteAddress);

            var channel = new Channel(socket);
            channel.messaged.connect(function (event, data) {
                switch (event) {
                case "cockpit_login":
                    var name :String = cast data;
                    var match = new Match(name, channel);
                    if (matches.get(name) == null) {
                        matches.set(name, match);
                        channel.closed.connect(function () {
                            matches.remove(name);
                        });
                    } else {
                        trace("Tried to register with an already active game name: " + name);
                    }
                case "phone_login":
                    // Tell them the active matches
                    var summary = [];
                    for (match in matches) {
                        summary.push({
                            name: match.name,
                            population: match.population(),
                        });
                    }
                    channel.send("matches", summary);
                case "join":
                    var name :String = cast data;
                    var match = matches.get(name);
                    if (match != null) {
                        match.addPhone(channel);
                    } else {
                        trace("Tried to join an invalid game name: " + name);
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
}
