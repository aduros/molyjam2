package molyjam.phone;

import js.Browser;

import flambe.System;
import flambe.asset.AssetPack;
import flambe.display.*;
import flambe.scene.Director;
import flambe.scene.SlideTransition;
import flambe.util.Assert;
import flambe.util.Signal0;
import flambe.util.Signal2;
import flambe.util.Value;
import flambe.Entity;
import flambe.math.Point;

import molyjam.Channel;
import molyjam.Config;
import molyjam.GameData;

using flambe.util.Arrays;

/** All the client state goes here. */
class PhoneContext
{
    // The height of the bottom tray that holds the home button
    public static inline var TRAY_HEIGHT = 50;

    public static var APPS = [
        new AppData("Facebork", "TODO", [
            new Point(100, 100),
            new Point(200, 200),
            new Point(200, 100),
            new Point(100, 200),
            new Point(150, 150),
        ]),
        new AppData("Tweetr", "TODO", [
            new Point(100, 100),
            new Point(200, 200),
            new Point(200, 100),
            new Point(100, 200),
            new Point(150, 150),
        ]),
        new AppData("Facebork", "TODO", [
            new Point(100, 100),
            new Point(200, 200),
            new Point(200, 100),
            new Point(100, 200),
            new Point(150, 150),
        ]),
    ];

    public var pack (default, null) :AssetPack;
    public var font (default, null) :Font;

    // Scene management
    public var director (default, null) :Director;

    // App index to # of active hotspots
    public var hotspots :Array<Int>;
    public var hotspotAdded :Signal2<Int,Int>;

    public var homeButton :Signal0;

    // Because passing contexts around is for dorks
    public static var instance (default, null) :PhoneContext;

    private function new (pack :AssetPack, server :Channel)
    {
        this.pack = pack;
        font = new Font(pack, "tinyfont");
        _server = server;
        homeButton = new Signal0();

        director = new Director().setSize(System.stage.width, System.stage.height-TRAY_HEIGHT);

        var viewport = new Entity().add(director);
        System.root.addChild(viewport);

        var tray = new Entity()
            .add(new FillSprite(0x101010, System.stage.width, TRAY_HEIGHT)
                .setXY(0, System.stage.height-TRAY_HEIGHT));
        System.root.addChild(tray);

        var button = new FillSprite(0x000000, 40, 40).centerAnchor()
            .setXY(System.stage.width/2, TRAY_HEIGHT/2);
        button.pointerDown.connect(function (_) {
            homeButton.emit();
        });
        tray.addChild(new Entity().add(button));

        hotspotAdded = new Signal2();

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

    public function onClickHotspot (appIdx :Int)
    {
        var app = PhoneContext.APPS[appIdx];
        --hotspots[appIdx];
        hotspotAdded.emit(appIdx, -1);
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
