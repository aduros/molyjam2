package molyjam.cockpit;

import flambe.display.FillSprite;

class SimpleWidget extends Widget
{
    public function new ()
    {
        super();
        _segments = 2;
        _value = 0.7;
    }

    override public function onUpdate (dt :Float)
    {
        trace(_value);
        var sprite = owner.get(FillSprite);
        sprite.color = (_value > 0.5) ? 0xff0000 : 0x00ff00;
    }
}
