package molyjam;

class WidgetData
{
    public var type (default, null) :WidgetType;

    // The value between [0, 1]
    public var value :Float = 0;

    public function new (type :WidgetType)
    {
        this.type = type;
    }

    // Useful for display/gameplay purposes?
    public function getSegment (count :Int) :Int
    {
        return Math.round(value * count);
    }
}
