package molyjam.server;

import js.Node;

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

        var matches = [];
        wsServer.on("connect", function (socket) {
            trace("Client connected from " + socket.remoteAddress);

            var channel = new Channel(socket);
            channel.messaged.connect(function (event, data) {
                switch (event) {
                case "cockpit_login":
                    var match = new Match(channel);
                    matches.push(match);
                case "phone_login":
                    trace("Soon");
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
