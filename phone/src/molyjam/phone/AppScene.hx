package molyjam.phone;

import flambe.Disposer;
import flambe.Entity;
import flambe.System;
import flambe.animation.Ease;
import flambe.display.*;

using flambe.util.Arrays;

class AppScene
{
    public static function create (appIdx :Int)
    {
        var ctx = PhoneContext.instance;
        var app = PhoneContext.APPS[appIdx];

        var scene = new Entity()
            .add(new FillSprite(Std.int(Math.random()*0xffffff),
                System.stage.width,
                System.stage.height-PhoneContext.TRAY_HEIGHT));

        var activeHotspots = [];
        for (p in app.hotspots) {
            activeHotspots.push(false);
        }

        var addHotspot = function () {
            if (activeHotspots.indexOf(false) < 0) {
                return; // Just in case to prevent an infinite loop below
            }

            var idx;
            do {
                idx = Std.int(app.hotspots.length*Math.random());
            } while (activeHotspots[idx]);
            activeHotspots[idx] = true;

            var button = new FillSprite(0xff0000, 50, 50).centerAnchor();
            var p = app.hotspots[idx];
            button.setXY(p.x, p.y);
            button.pointerDown.connect(function (_) {
                trace("click");
                activeHotspots[idx] = false;
                ctx.onClickHotspot(appIdx);
                button.owner.dispose();
            });
            scene.addChild(new Entity().add(button));
        };

        // Add all the existing hotspots
        for (ii in 0...ctx.hotspots[appIdx]) {
            addHotspot();
        }

        var disposer = new Disposer();
        disposer.connect0(ctx.homeButton, function () {
            ctx.director.popScene(new CloseTransition(0.3, Ease.quadOut));
        });
        disposer.connect2(ctx.hotspotAdded, function (idx, delta) {
            if (idx == appIdx && delta > 0) {
                // Add new hotspots as they come in
                addHotspot();
            }
        });
        scene.add(disposer);

        return scene;
    }
}
