package molyjam.server;

import flambe.util.Assert;

/** A single hosted game. */
class Match
{
    public function new (cockpit :Channel)
    {
        _game = new GameData();
        _game.addWidget(Altitude).value = 1.0;
        _game.addWidget(TestToggle);
        _game.addWidget(TestToggle);
        _game.addWidget(TestToggle);
        _game.addWidget(TestToggle);
        _game.addWidget(Pitch).value = 0.1;
        _game.addWidget(Yaw).value = 0.9;
        _game.addWidget(AirSpeed).value = 0.9;

        _cockpit = cockpit;
        _cockpit.messaged.connect(onCockpitMessage);
        _cockpit.send("gamedata", _game);
    }

    public function update (dt :Float)
    {
        // for (widget in _game.widgets) {
        // }

        var altitude = get(Altitude);
        altitude.value = Math.max(0, altitude.value-0.005);

        // Update the client
        _cockpit.send("snapshot", _game.createSnapshot());
    }

    private function onCockpitMessage (event :String, data :Dynamic)
    {
        trace("Got event from cockpit: " + event + ", " + data);
        switch (event) {
        case "toggle":
            var widgetIdx = cast data;
            var widget = _game.widgets[widgetIdx];
            widget.value = (widget.value == 0) ? 1 : 0;
        }
    }

    private function get (type :WidgetType) :WidgetData
    {
        for (widget in _game.widgets) {
            if (widget.type == type) {
                return widget;
            }
        }
        Assert.fail();
        return null;
    }

    private var _game :GameData;
    private var _cockpit :Channel;
}
