package molyjam.cockpit;

import js.Browser;

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
            Browser.window.location.reload();
        });
        _server.send("cockpit_login");
    }

    public function toggleWidget (data :WidgetData)
    {
        var idx = game._.widgets.indexOf(data);
        _server.send("set", {
            idx: idx,
            value: (data.value == 0) ? 1 : 0,
        });
    }

    public function incrementWidget (data :WidgetData, states :Int)
    {
        var idx = game._.widgets.indexOf(data);
        var currentState = data.getSegment(states);
        var newState = (currentState+1) % states;
        _server.send("set", {
            idx: idx,
            value: newState/states,
        });
    }

    public function updateYawChange (newChange :Float)
    {
        _server.send("updateYawChange", newChange);
    }

    public function updatePitchChange (newChange :Float)
    {
        _server.send("updatePitchChange", newChange);
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
