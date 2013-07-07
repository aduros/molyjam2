package molyjam.phone;

import flambe.Disposer;
import flambe.Entity;
import flambe.System;
import flambe.animation.Ease;
import flambe.display.*;

class AppScene
{
    public static function create ()
    {
        var ctx = PhoneContext.instance;

        var scene = new Entity()
            .add(new FillSprite(Std.int(Math.random()*0xffffff),
                System.stage.width,
                System.stage.height-PhoneContext.TRAY_HEIGHT));

        var disposer = new Disposer();
        disposer.connect0(ctx.homeButton, function () {
            ctx.director.popScene(new CloseTransition(0.3, Ease.quadOut));
        });
        scene.add(disposer);

        return scene;
    }
}
