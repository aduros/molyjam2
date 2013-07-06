package molyjam.cockpit;

import js.html.WebSocket;

import flambe.asset.AssetPack;
import flambe.util.Assert;
import flambe.util.Value;

import molyjam.Channel;
import molyjam.Config;
import molyjam.GameData;

using flambe.util.Arrays;

/** All the client state goes here. */
class CockpitContext
{
    public var pack (default, null) :AssetPack;

    public var game (default, null) :Value<GameData>;

    // Because passing contexts around is for dorks
    public static var instance (default, null) :CockpitContext;

    private function new (pack :AssetPack, server :Channel)
    {
        this.pack = pack;
        _server = server;

        game = new Value<GameData>(null);

        _server.messaged.connect(onMessage);
        _server.closed.connect(function () {
            trace("Oh noes, you are disconnected!");
        });
        _server.send("cockpit_login");
    }

    public function sendToggle (data :WidgetData)
    {
        _server.send("toggle", game._.widgets.indexOf(data));
    }

    private function onMessage (event :String, data :Dynamic)
    {
        switch (event) {
        case "gamedata":
            trace("Got GameData from server");
            game._ = data;
        case "snapshot":
            game._.applySnapshot(cast data);
        }
    }

    public static function init (pack :AssetPack, server :Channel)
    {
        // Make sure it hasn't already been setup
        Assert.that(instance == null);
        instance = new CockpitContext(pack, server);
    }

    private var _server :Channel;
}
