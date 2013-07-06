package molyjam.cockpit;

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
            var ctx = new CockpitContext(pack);
            start(ctx);
        });
    }

    private static function start (ctx :CockpitContext)
    {
        var screen = new Entity();
        System.root.addChild(screen);

        var background = new FillSprite(0x202020, System.stage.width, System.stage.height);
        screen.addChild(new Entity().add(background));

        var widget = new SimpleWidget();
        widget.set(0.2);

        var button = new Entity()
            .add(new FillSprite(0xff0000, 50, 50))
            .add(new SimpleWidget());
        screen.addChild(button);
    }
}
