package molyjam.cockpit;

import flambe.display.*;

class ButtonDisplay extends WidgetDisplay
{
    public function new (data :WidgetData)
    {
        super(data);
    }

    override public function onAdded ()
    {
        var sprite = owner.get(Sprite);
        sprite.pointerDown.connect(function (event) {
            CockpitContext.instance.toggleWidget(_data);
        });
    }

    override public function onUpdate (dt :Float)
    {
        var ctx = CockpitContext.instance;
        var sprite = owner.get(ImageSprite);
        sprite.texture = ctx.pack.getTexture((_data.getSegment(2) == 1) ? "switch-on" : "switch-off");
    }
}
