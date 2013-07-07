package molyjam.cockpit;

import js.html.WebSocket;

import flambe.Entity;
import flambe.System;
import flambe.asset.AssetPack;
import flambe.asset.Manifest;
import flambe.display.*;
import flambe.script.*;

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

        _crashHolder = new Entity();
        screen.addChild(_crashHolder);

        var left = new ImageSprite(ctx.pack.getTexture("cockpit-half"));
        screen.addChild(new Entity().add(left));
        var right = new ImageSprite(left.texture).setScaleXY(-1, 1).setXY(2*left.texture.width, 0);
        screen.addChild(new Entity().add(right));

        var pdata :WidgetData = null;
        var ydata :WidgetData = null;
        var pchange :WidgetData = null;
        var ychange :WidgetData = null;
        var x = 192;
        var y = 432;
        var ii = 0;
        for (widget in ctx.game._.widgets) {
            var display = createDisplay(widget);
            var s = display.get(Sprite);
            s.setXY(x, y);
            screen.addChild(display);
            x += 96;

            ++ii;
            if (ii == 7) {
                x = 48;
                y = 576;
            }

            switch(widget.type) {
                case Pitch:
                    pdata = widget;
                case Yaw:
                    ydata = widget;
                case PitchChange:
                    pchange = widget;
                case YawChange:
                    ychange = widget;
                default:
            }
        }

        var wheel = new ImageSprite(ctx.pack.getTexture("wheel"));
        wheel.setAnchor(wheel.getNaturalWidth() / 2, wheel.getNaturalHeight() / 2);
        wheel.setXY(System.stage.width / 2, System.stage.height);
        screen.addChild(new Entity().add(wheel).add(new SteeringDisplay(pchange, ychange)));

        // Reverse-order these so we can add earth last.
        var earth = new FillSprite(0x684e3c, System.stage.width * 2, System.stage.height * 2);
        earth.setAnchor(earth.getNaturalWidth()/2, 0);
        screen.addChild(new Entity().add(earth).add(new BackgroundDisplay(pdata, ydata)), false);

        var sky = new FillSprite(0xb9deec, System.stage.width, System.stage.height);
        screen.addChild(new Entity().add(sky), false);

        ctx.gameover.connect(showGameOver);
    }

    private static function showGameOver (score :Float)
    {
        var ctx = CockpitContext.instance;
        var left = new ImageSprite(null);
        var right :ImageSprite = cast new ImageSprite(null).setScaleXY(-1, 1).setXY(System.stage.width, 0);
        _crashHolder.addChild(new Entity().add(left));
        _crashHolder.addChild(new Entity().add(right));

        var frame = 0;
        var nextFrame = function () {
            ++frame;
            left.texture = right.texture = ctx.pack.getTexture("cockpit-crash/frame"+frame);
        };
        nextFrame();

        var script = new Script();
        script.run(new Repeat(new Sequence([
            new CallFunction(nextFrame),
            new Delay(0.2),
        ]), 6));
        _crashHolder.add(script);
    }

    private static function createDisplay (data :WidgetData) :Entity
    {
        switch (data.type) {
        case TestToggle:
            return new Entity()
                .add(new FillSprite(0xff0000, 50, 50))
                .add(new TestDisplay(data));
        case Altitude:
            return new Entity()
                .add(new FillSprite(0xff0000, 50, 50))
                .add(new AltitudeDisplay(data));
        // case Fuel:
        //     return new Entity()
        //         .add(new ImageSprite(null))
        //         .add(new KnobDisplay(data, 4));
        default:
            return new Entity()
                .add(new FillSprite(0xff0000, 50, 50))
                .add(new AltitudeDisplay(data));
        }
    }

    private static var _crashHolder :Entity; // yeehaw

    // Keep a hard reference to the socket to prevent GC bugs in some browsers. Pretend this isn't
    // here :)
    private static var _socket :WebSocket;
}
