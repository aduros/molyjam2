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

        var game = new GameData();
        // Don't have duplicates eventually
        game.addWidget(Altitude).value = 0.7;
        game.addWidget(Altitude).value = 0.1;
        game.addWidget(Altitude).value = 0.9;
        game.addWidget(Altitude).value = 0.9;

        var channels = [];
        wsServer.on("connect", function (socket) {
            trace("Client connected from " + socket.remoteAddress);

            var channel = new Channel(socket);
            channels.push(channel);

            channel.messaged.connect(function (event, data) {
                switch (event) {
                case "cockpit_login":
                    trace("Got a login message from the client");
                    channel.send("gamedata", game);
                case "phone_login":
                    trace("Soon");
                };
            });
        });
    }
}
