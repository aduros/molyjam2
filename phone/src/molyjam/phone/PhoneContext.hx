package molyjam.phone;

import js.Browser;

import flambe.System;
import flambe.asset.AssetPack;
import flambe.display.*;
import flambe.scene.Director;
import flambe.scene.SlideTransition;
import flambe.scene.FadeTransition;
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
    public static inline var TRAY_HEIGHT = 60;

    public static var APPS = [
        new AppData("Facebork", "facebook", [
            new Point(64, 87),
            new Point(226, 91),
            new Point(409, 84),
            new Point(114, 879),
            new Point(336, 879),
            new Point(529, 879),
            new Point(228, 568),
            new Point(387, 490),
        ]),
        new AppData("Tweetr", "twitter", [
            new Point(592, 81),
            new Point(312, 84),
            new Point(558, 910),
            new Point(84, 910),
            new Point(240, 910),
            new Point(399, 910),
        ]),
        new AppData("Google", "google", [
            new Point(583, 384),
            new Point(444, 628),
            new Point(271, 741),
            new Point(394, 741),
            new Point(570, 921),
        ]),
        new AppData("Instagram", "instagram", [
            new Point(205, 778),
            new Point(340, 778),
            new Point(475, 778),
            new Point(91, 778),
            new Point(264, 909),
            new Point(381, 909),
            new Point(580, 909),
            new Point(211, 546),
        ]),
        new AppData("Music", "music", [
            new Point(58, 87),
            new Point(592, 87),
            new Point(318, 816),
            new Point(97, 816),
            new Point(540, 816),
            new Point(345, 912),
            new Point(585, 262),
            new Point(318, 262),
            new Point(57, 262),
        ]),
        new AppData("Letterpress", "letterpress", [
            new Point(595, 49),
            new Point(49, 49),
            new Point(321, 637),
            new Point(568, 771),
            new Point(61, 636),
        ]),
        new AppData("Messages", "text", [
            new Point(30, 922),
            new Point(573, 922),
            new Point(106, 922),
            new Point(565, 85),
            new Point(99, 85),
        ]),
        new AppData("Phone", "dialpad", [
            new Point(111, 730),
            new Point(329, 760),
            new Point(535, 760),
            new Point(534, 201),
            new Point(97, 350),
            new Point(99, 470),
            new Point(331, 602),
        ]),
        new AppData("Yelp", "yelp", [
            new Point(63, 85),
            new Point(573, 81),
            new Point(64, 910),
            new Point(189, 910),
            new Point(328, 910),
            new Point(444, 910),
            new Point(574, 910),
            new Point(409, 471),
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
        font = new Font(pack, "segoe28-white");
        _server = server;
        homeButton = new Signal0();

        director = new Director().setSize(System.stage.width, System.stage.height-TRAY_HEIGHT);

        var viewport = new Entity().add(director);
        System.root.addChild(viewport);

        var tray = new Entity()
            .add(new FillSprite(0x101010, System.stage.width, TRAY_HEIGHT)
                .setXY(0, System.stage.height-TRAY_HEIGHT));
        System.root.addChild(tray);

        var button = new FillSprite(0xf0f0f0, 50, 50).centerAnchor()
            .setXY(System.stage.width/2, TRAY_HEIGHT/2);
        tray.addChild(new Entity().add(button));

        var button = new FillSprite(0x000000, 48, 48).centerAnchor()
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
        case "gameover":
            var score :Float = cast data;
            var overlay = new Entity().add(new FillSprite(0xf0f0f0, System.stage.width,
                System.stage.height));
            overlay.addChild(new Entity().add(new ImageSprite(pack.getTexture("win"))));
            overlay.get(Sprite).alpha.animate(0, 1, 2);
            System.root.addChild(overlay);
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
