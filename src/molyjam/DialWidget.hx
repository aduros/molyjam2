import Widget;
import flambe.Sprite;
import flambe.ImageSprite;

class DialWidget extends Widget
{
    public function new (segments :Int, minRot :Float, maxRot :Float)
    {
        super();
        this._segments = segments;
        this._minRot = minRot;
        this._maxRot = maxRot;
    }

    override public function onUpdate (dt :Float)
    {
        var sprite = owner.get(Sprite);
        sprite.rotation._ = (_maxRot - _minRot) * _value + _minRot;
    }

    private var _minRot :Float;
    private var _maxRot :Float;
}