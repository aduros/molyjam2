package molyjam.cockpit;

import js.html.WebSocket;

import flambe.Entity;
import flambe.System;
import flambe.asset.AssetPack;
import flambe.asset.Manifest;
import flambe.display.*;

class CockpitMain
{
    private static function main ()
    {
        // Wind up all platform-specific stuff
        System.init();

        // Load up the compiled pack in the assets directory named "bootstrap"
        var manifest = Manifest.build("bootstrap");
        var loader = System.loadAssetPack(manifest);
        loader.get(function (pack) {
            _socket = new WebSocket("ws://"+Config.SERVER_HOST+":"+Config.SERVER_PORT);
            _socket.onerror = function (_) {
                trace("Connection error!");
            };
            _socket.onopen = function (_) {
                trace("Game connected!");
                var ctx = new CockpitContext(pack, new Channel(_socket));

                // Wait for the GameData to come in from the server
                ctx.game.changed.connect(function (game,_) {
                    start(ctx);
                });
            };
        });
    }

    private static function start (ctx :CockpitContext)
    {
        var screen = new Entity();
        System.root.addChild(screen);

        var background = new ImageSprite(ctx.pack.getTexture("horizon"));
        screen.addChild(new Entity().add(background).add(new BackgroundDisplay()));

        var y = 0;
        for (widget in ctx.game._.widgets) {
            var display = createDisplay(widget);
            display.get(Sprite).setXY(0, y);
            screen.addChild(display);
            y += 60;
        }
    }

    private static function createDisplay (data :WidgetData) :Entity
    {
        switch (data.type) {
        case Altitude:
            return new Entity()
                .add(new FillSprite(0xff0000, 50, 50))
                .add(new AltitudeDisplay(data));
        }
    }

    // Keep a hard reference to the socket to prevent GC bugs in some browsers. Pretend this isn't
    // here :)
    private static var _socket :WebSocket;
}
