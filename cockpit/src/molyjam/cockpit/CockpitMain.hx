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
                CockpitContext.init(pack, new Channel(_socket));
                var ctx = CockpitContext.instance;

                // Wait for the GameData to come in from the server
                ctx.game.changed.connect(function (game,_) {
                    start();
                });
            };
        });
    }

    private static function start ()
    {
        var ctx = CockpitContext.instance;

        var screen = new Entity();
        System.root.addChild(screen);

        var sky = new FillSprite(0xb9deec, System.stage.width, System.stage.height);
        screen.addChild(new Entity().add(sky));
        var earth = new FillSprite(0x684e3c, System.stage.width * 2, System.stage.height * 2).setAnchor(System.stage.width / 2, 0);

        var pdata :WidgetData = null;
        var ydata :WidgetData = null;
        var y = 0;
        for (widget in ctx.game._.widgets) {
            var display = createDisplay(widget);
            var s = display.get(Sprite);
            s.setXY(0, y);
            screen.addChild(display);
            y += 60;

            trace("widget: " + widget);
            
            switch(widget.type) {
                case Pitch:
                    pdata = widget;
                    break;
                case Yaw:
                    ydata = widget;
                    break;
                default:
            }
        }
        trace("pdata: " + pdata + "ydata: " + ydata);
        screen.addChild(new Entity().add(earth).add(new BackgroundDisplay(pdata, ydata)));
    }

    private static function createDisplay (data :WidgetData) :Entity
    {
        switch (data.type) {
        case Altitude:
            return new Entity()
                .add(new FillSprite(0xff0000, 50, 50))
                .add(new AltitudeDisplay(data));
        default:
            return new Entity()
                .add(new FillSprite(0xff0000, 50, 50))
                .add(new AltitudeDisplay(data));
        }
    }

    // Keep a hard reference to the socket to prevent GC bugs in some browsers. Pretend this isn't
    // here :)
    private static var _socket :WebSocket;
}
