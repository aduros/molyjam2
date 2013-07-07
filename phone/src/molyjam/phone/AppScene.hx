package molyjam.phone;

import flambe.animation.Ease;
import flambe.Entity;
import flambe.System;
import flambe.display.*;

class AppScene
{
    public static function create ()
    {
        var ctx = PhoneContext.instance;

        var scene = new Entity()
            .add(new FillSprite(Std.int(Math.random()*0xffffff), System.stage.width, System.stage.height));

        scene.get(Sprite).pointerDown.connect(function (_) {
            ctx.director.popScene(new CloseTransition(0.3, Ease.quadOut));
        });
        return scene;
    }
}
