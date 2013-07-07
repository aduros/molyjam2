package molyjam.phone;

import js.Browser;

import flambe.System;
import flambe.asset.AssetPack;
import flambe.display.Font;
import flambe.scene.Director;
import flambe.scene.SlideTransition;
import flambe.util.Assert;
import flambe.util.Value;

import molyjam.Channel;
import molyjam.Config;
import molyjam.GameData;

using flambe.util.Arrays;

/** All the client state goes here. */
class PhoneContext
{
    public var pack (default, null) :AssetPack;
    public var font (default, null) :Font;

    // Scene management
    public var director (default, null) :Director;

    public var hotspots :Map<Int,Bool>;

    // Because passing contexts around is for dorks
    public static var instance (default, null) :PhoneContext;

    private function new (pack :AssetPack, server :Channel)
    {
        this.pack = pack;
        font = new Font(pack, "tinyfont");
        _server = server;

        director = new Director();
        System.root.add(director);

        _server.messaged.connect(onMessage);
        _server.closed.connect(function () {
            trace("Oh noes, you are disconnected!");
            Browser.window.location.reload();
        });
        _server.send("phone_login");
    }

    public function join (id :Int)
    {
        _server.send("join", id);
        director.unwindToScene(HomeScene.create(), new SlideTransition(0.3));
    }

    public function poke ()
    {
        _server.send("poke");
    }

    private function onMessage (event :String, data :Dynamic)
    {
        trace("Got message " + event);
        switch (event) {
        case "matches":
            var matches :Array<Dynamic> = cast data;
            director.unwindToScene(MatchesScene.create(matches));
        }
    }

    public static function init (pack :AssetPack, server :Channel)
    {
        // Make sure it hasn't already been setup
        Assert.that(instance == null);
        instance = new PhoneContext(pack, server);
    }

    private var _server :Channel;
}
