package molyjam.cockpit;

import flambe.Component;

// Maybe too flimsy to warrant a base class, but oh well
class WidgetDisplay extends Component
{
    public function new (data :WidgetData)
    {
        _data = data;
    }

    private var _data :WidgetData;
}
