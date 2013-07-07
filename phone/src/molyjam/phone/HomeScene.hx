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

        var buttonSize = 57;
        var padX = 30;
        var padY = 50;
        var offsetX = System.stage.width/2 - (3*(buttonSize+padX)-padX)/2;
        var offsetY = 10;
        for (y in 0...3) {
            for (x in 0...3) {
                var button = new Entity().add(new Sprite()
                    .setXY(offsetX + x * (buttonSize+padX) + buttonSize/2,
                           offsetY + y * (buttonSize+padY) + buttonSize/2));
                scene.addChild(button);

                var icon = new FillSprite(0x009900, buttonSize, buttonSize);
                icon.setAnchor(icon.getNaturalWidth()/2, 0);
                icon.pointerDown.connect(function (_) {
                    trace("Pushed button " + (3*y+x));
                    ctx.director.pushScene(AppScene.create(), new LaunchTransition(0.5, Ease.quadOut));
                    // button.setXY(
                    //     Math.random()*(System.stage.width-button.getNaturalWidth()),
                    //     Math.random()*(System.stage.height-button.getNaturalHeight()));
                    // ctx.poke();
                });
                button.addChild(new Entity().add(icon));

                var label = new TextSprite(ctx.font, "App " + (3*y+x));
                label.setAnchor(label.getNaturalWidth()/2, 0);
                label.setXY(0, buttonSize + 5);
                button.addChild(new Entity().add(label));
            }
        }

        ctx.hotspots = new Map();
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
            _elapsed -= 1;

            var hotspot = Std.int(Math.random()*100);
            if (!ctx.hotspots.exists(hotspot)) {
                ctx.hotspots.set(hotspot, true);
                ctx.hotspotAdded.emit(hotspot);
                trace("Plink");
            }
        }
    }

    private var _elapsed = 0.0;
}
