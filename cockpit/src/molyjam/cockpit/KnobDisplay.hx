package molyjam.cockpit;

import flambe.display.*;

class KnobDisplay extends WidgetDisplay
{
    public function new (data :WidgetData, states :Int)
    {
        super(data);
        _states = states;
    }

    override public function onAdded ()
    {
        var sprite = owner.get(Sprite);
        sprite.pointerDown.connect(function (event) {
            CockpitContext.instance.incrementWidget(_data, _states);
        });
        onUpdate(0); // Hack
    }

    override public function onUpdate (dt :Float)
    {
        var ctx = CockpitContext.instance;
        var state = _data.getSegment(_states);

        var sprite = owner.get(ImageSprite);
        sprite.texture = ctx.pack.getTexture("knob/" + state);
    }

    private var _states :Int;
}
