package molyjam;

/** Streamed to clients. */
class GameData
{
    public var name (default, null) :String;
    public var widgets (default, null) :Array<WidgetData>;

    public function new (name :String)
    {
        this.name = name;
        widgets = [];
    }

    public function addWidget (type :WidgetType) :WidgetData
    {
        var widget = new WidgetData(type);
        widgets.push(widget);
        return widget;
    }

    public function createSnapshot () :Array<Float>
    {
        var snapshot = [];
        for (widget in widgets) {
            snapshot.push(widget.value);
        }
        return snapshot;
    }

    public function applySnapshot (snapshot :Array<Float>)
    {
        for (ii in 0...snapshot.length) {
            widgets[ii].value = snapshot[ii];
        }
    }
}
