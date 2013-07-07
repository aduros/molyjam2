package molyjam.phone;

import flambe.animation.Ease;
import flambe.display.Sprite;
import flambe.scene.*;
import flambe.Entity;

class LaunchTransition extends TweenTransition
{
    public function new (duration :Float, ?ease :EaseFunction)
    {
        super(duration, ease);
    }

    override public function init (director :Director, from :Entity, to :Entity)
    {
        super.init(director, from, to);
        _to.get(Sprite).setXY(_director.width/2, _director.height/2).setScale(0);
    }

    override public function update (dt :Float) :Bool
    {
        var done = super.update(dt);
        var scale = interp(0, 1);
        var sprite = _to.get(Sprite);
        sprite.setScale(scale).setXY(
            _director.width*(1-scale)/2,
            _director.height*(1-scale)/2);
        return done;
    }

    override public function complete ()
    {
        _to.get(Sprite).setXY(0, 0).setScale(1);
    }
}
