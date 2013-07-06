package molyjam.cockpit;

import js.html.WebSocket;

import flambe.asset.AssetPack;
import flambe.util.Value;

import molyjam.Channel;
import molyjam.Config;
import molyjam.GameData;

/** All the client state goes here. */
class CockpitContext
{
    public var pack (default, null) :AssetPack;

    public var game (default, null) :Value<GameData>;

    public function new (pack :AssetPack, channel :Channel)
    {
        this.pack = pack;
        _channel = channel;

        game = new Value<GameData>(null);

        _channel.messaged.connect(onMessage);
        _channel.closed.connect(function () {
            trace("Oh noes, you are disconnected!");
        });
        _channel.send("cockpit_login");
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

    private var _channel :Channel;
}
