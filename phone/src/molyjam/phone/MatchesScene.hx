package molyjam.phone;

import flambe.Entity;
import flambe.System;
import flambe.display.*;

class MatchesScene
{
    public static function create (matches :Array<Dynamic>)
    {
        var ctx = PhoneContext.instance;

        var scene = new Entity();
        scene.addChild(new Entity()
            .add(new FillSprite(0x000000, System.stage.width, System.stage.height)));

        scene.addChild(new Entity()
            .add(new TextSprite(ctx.font, "Departures")));

        var y = 40;
        var pad = 10;
        var buttonHeight = 50;
        var buttonBorder = 2;

        for (match in matches) {
            var background = new FillSprite(0x202020, System.stage.width-2*pad, buttonHeight);
            background.setXY(pad, y);
            background.pointerDown.connect(function (_) {
                ctx.join(match.name);
            }).once();

            var button = new Entity().add(background);
            button.addChild(new Entity()
                .add(new FillSprite(0x000000,
                    background.getNaturalWidth() - 2*buttonBorder,
                    background.getNaturalHeight() - 2*buttonBorder)
                    .setXY(buttonBorder, buttonBorder)));

            var label = new TextSprite(ctx.font,
                "Flight " + match.name + ", " + match.population + " aboard");
            label.setXY(pad, buttonHeight/2 - label.font.size/2);
            button.addChild(new Entity().add(label));

            scene.addChild(button);

            y += buttonHeight + pad;
        }

        return scene;
    }
}
