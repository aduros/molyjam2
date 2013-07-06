import flambe.Component;
import flambe.Sprite;

class Widget extends Component
{
    public function new ()
    {
        this._value = 0;
        this._segments = 0;
    }

    public function set (val :Float) :Bool
    {
        var i = (_segments == 0) ? 0 : (val / (1.0 / _segments));
        if ((_segments == 0) || (Math.floor(i) == i)) {
            _value = val;
            return true;
        }
        return false;
    }

    private var _value :Float;
    private var _segments :Int;
}