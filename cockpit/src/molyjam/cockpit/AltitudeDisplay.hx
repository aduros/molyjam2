package molyjam.cockpit;

import flambe.display.FillSprite;

class AltitudeDisplay extends WidgetDisplay
{
    public function new (data :WidgetData)
    {
        super(data);
    }

    override public function onUpdate (dt :Float)
    {
        var sprite = owner.get(FillSprite);
        sprite.color = (_data.getSegment(2) == 0) ? 0xff0000 : 0x00ff00;
    }
}
