package molyjam.server;

import js.Node;

import molyjam.Config;

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

        trace("Running on "+host+":"+Config.SERVER_PORT);
    }
}
