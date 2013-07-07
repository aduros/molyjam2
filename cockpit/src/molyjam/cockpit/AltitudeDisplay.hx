package molyjam.cockpit;

import flambe.Entity;
import flambe.display.ImageSprite;

class AltitudeDisplay extends WidgetDisplay
{
    public function new (data :WidgetData)
    {
        super(data);
    }

    override public function onAdded ()
    {
        var ctx = CockpitContext.instance;

        var background = new ImageSprite(ctx.pack.getTexture("altimeter"));
        owner.add(background);

        _bigHand = new ImageSprite(ctx.pack.getTexture("altimeter-bighand"));
        _smallHand = new ImageSprite(ctx.pack.getTexture("altimeter-smallhand"));

        var width = _bigHand.getNaturalWidth();
        owner.addChild(new Entity().add(_bigHand.setXY(width/2, width/2).centerAnchor()));
        owner.addChild(new Entity().add(_smallHand.setXY(width/2, width/2).centerAnchor()));
    }

    override public function onUpdate (dt :Float)
    {
        _smallHand.rotation._ = 360 * _data.value;
        _bigHand.rotation._ = 3600 * _data.value;
    }

    private var _bigHand :ImageSprite;
    private var _smallHand :ImageSprite;
}
