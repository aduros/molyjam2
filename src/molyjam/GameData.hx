package molyjam;

/** Streamed to clients. */
class GameData
{
    public var widgets (default, null) :Array<WidgetData>;

    public function new ()
    {
        widgets = [];
    }

    public function addWidget (type :WidgetType) :WidgetData
    {
        var widget = new WidgetData(type);
        widgets.push(widget);
        return widget;
    }
}
