package molyjam.phone;

import flambe.animation.Ease;
import flambe.display.Sprite;
import flambe.scene.*;
import flambe.Entity;

class CloseTransition extends TweenTransition
{
    public function new (duration :Float, ?ease :EaseFunction)
    {
        super(duration, ease);
    }

    override public function init (director :Director, from :Entity, to :Entity)
    {
        super.init(director, from, to);
        _to.addChild(_from); // HACK?
        _from.get(Sprite).setXY(0, 0).setScale(1);
    }

    override public function update (dt :Float) :Bool
    {
        var done = super.update(dt);
        var scale = interp(1, 0);
        var sprite = _from.get(Sprite);
        sprite.setScale(scale).setXY(
            _director.width*(1-scale)/2,
            _director.height*(1-scale)/2);
        return done;
    }

    override public function complete ()
    {
        _from.get(Sprite).setScale(0);
    }
}
