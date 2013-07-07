package molyjam.cockpit;

import flambe.display.FillSprite;
import flambe.display.Sprite;

class TestDisplay extends WidgetDisplay
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
        var sprite = owner.get(FillSprite);
        sprite.color = (_data.value == 0) ? 0xff0000 : 0x00ff00;
    }
}
