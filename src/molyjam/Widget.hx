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
        // TODO: Round this instead of floor, then lock to [0..1].
        var i = (_segments == 0) ? 0 : (val / (1.0 / _segments));
        if ((_segments == 0) || (Math.floor(i) == i)) {
            _value = val;
            _displayValue = val;
            return true;
        }
        return false;
    }


    public function setDisplayValue (val :Float) :Void
    {
        _displayValue = val;
    }

    private var _displayValue :Float;
    private var _value :Float;
    private var _segments :Int;
}