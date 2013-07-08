package molyjam.phone;

import flambe.*;
import flambe.animation.Ease;
import flambe.display.*;

class HomeScene
{
    public static function create () :Entity
    {
        var ctx = PhoneContext.instance;

        var scene = new Entity().add(new Sprite());
        scene.addChild(new Entity()
            .add(new FillSprite(0x000000, System.stage.width, System.stage.height)));

        var buttons = [];

        var buttonSize = 57;
        var padX = 30;
        var padY = 50;
        var offsetX = System.stage.width/2 - (3*(buttonSize+padX)-padX)/2;
        var offsetY = 10;
        for (ii in 0...PhoneContext.APPS.length) {
            var app = PhoneContext.APPS[ii];
            var x = ii % 3;
            var y = Std.int(ii / 3);

            var button = new Entity().add(new Sprite()
                .setXY(offsetX + x * (buttonSize+padX) + buttonSize/2,
                       offsetY + y * (buttonSize+padY) + buttonSize/2));
            buttons.push(button);
            scene.addChild(button);

            var icon = new FillSprite(0x009900, buttonSize, buttonSize);
            icon.setAnchor(icon.getNaturalWidth()/2, 0);
            icon.pointerDown.connect(function (_) {
                trace("Pushed button " + (3*y+x));
                ctx.director.pushScene(AppScene.create(ii), new LaunchTransition(0.3, Ease.quadOut));
            });
            button.addChild(new Entity().add(icon));

            var label = new TextSprite(ctx.font, app.name);
            label.setAnchor(label.getNaturalWidth()/2, 0);
            label.setXY(0, buttonSize + 5);
            button.addChild(new Entity().add(label));

            var badge = new TextSprite(ctx.font);
            badge.align = Right;
            badge.setXY(buttonSize/2, 0);
            ctx.hotspotAdded.connect(function (appIdx, delta) {
                if (appIdx == ii) {
                    var active = ctx.hotspots[appIdx];
                    badge.text = (active > 0) ? "(" + active + ")" : "";
                }
            });
            button.addChild(new Entity().add(badge));
        }

        ctx.hotspots = [];
        for (app in PhoneContext.APPS) ctx.hotspots.push(0);
        System.root.add(new PhoneUpdater()); // Hackity hack

        return scene;
    }
}

private class PhoneUpdater extends Component
{
    public function new () {}

    override public function onUpdate (dt :Float)
    {
        var ctx = PhoneContext.instance;

        _elapsed += dt;
        while (_elapsed > 1) {
            _elapsed -= 0.5*Math.random() + 0.5;

            var appIdx = Std.int(Math.random()*PhoneContext.APPS.length);
            if (ctx.hotspots[appIdx] < PhoneContext.APPS[appIdx].hotspots.length) {
                ++ctx.hotspots[appIdx];
                ctx.hotspotAdded.emit(appIdx, 1);
                trace("Plink");
            }
        }
    }

    private var _elapsed = 0.0;
}
