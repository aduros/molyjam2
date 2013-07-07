package molyjam.phone;

import flambe.Entity;
import flambe.System;
import flambe.display.*;

class PlayingScene
{
    public static function create () :Entity
    {
        var ctx = PhoneContext.instance;

        var scene = new Entity();
        scene.addChild(new Entity()
            .add(new FillSprite(0x000000, System.stage.width, System.stage.height)));

        scene.addChild(new Entity()
            .add(new TextSprite(ctx.font, "Playing!")));

        var button = new FillSprite(0x009900, 50, 50).setXY(100, 100);
        button.pointerDown.connect(function (_) {
            button.setXY(
                Math.random()*(System.stage.width-button.getNaturalWidth()),
                Math.random()*(System.stage.height-button.getNaturalHeight()));
            ctx.poke();
        });
        scene.addChild(new Entity().add(button));

        return scene;
    }
}
