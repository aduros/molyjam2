package molyjam;

import flambe.math.FMath;

class WidgetData
{
    public var type (default, null) :WidgetType;

    // The value between [0, 1]
    public var value (default, set) :Float = 0;

    public function new (type :WidgetType)
    {
        this.type = type;
    }

    // Useful for display/gameplay purposes?
    public function getSegment (count :Int) :Int
    {
        return FMath.clamp(Math.round(value * count), 0, count - 1);
    }

    private function set_value (value :Float) :Float
    {
        return this.value = FMath.clamp(value, 0, 1);
    }
}
