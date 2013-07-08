package molyjam.cockpit;

import flambe.display.*;

class ButtonDisplay extends WidgetDisplay
{
    public function new (data :WidgetData, clickable :Bool)
    {
        super(data);
        _clickable = clickable;
    }

    override public function onAdded ()
    {
        if (_clickable) {
            var sprite = owner.get(Sprite);
            sprite.pointerDown.connect(function (event) {
                CockpitContext.instance.toggleWidget(_data);
            });
        }
    }

    override public function onUpdate (dt :Float)
    {
        var ctx = CockpitContext.instance;
        var sprite = owner.get(ImageSprite);
        sprite.texture = ctx.pack.getTexture((_data.getSegment(2) == 1) ? "switch-on" : "switch-off");
    }

    private var _clickable :Bool;
}
