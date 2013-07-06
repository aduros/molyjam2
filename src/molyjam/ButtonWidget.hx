import Widget;

class ButtonWidget extends Widget
{
    public function new ()
    {
        super();
        this._segments = 2;
    }

    override public function onUpdate (dt :Float)
    {
        // How do two-image sprites? Is there an instanceof in haxe?
        var sprite = owner.get(Sprite);
        sprite.rotation._ = (_displayVal == 0) ? 0 : 180;
    }
}