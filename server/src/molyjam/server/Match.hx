package molyjam.server;

import flambe.util.Assert;

/** A single hosted game. */
class Match
{
    public function new (cockpit :Channel)
    {
        _game = new GameData();
        _game.addWidget(Altitude).value = 1.0;
        _game.addWidget(TestToggle).value = Math.random();
        _game.addWidget(TestToggle).value = Math.random();
        _game.addWidget(TestToggle).value = Math.random();
        _game.addWidget(TestToggle).value = Math.random();

        _game.addWidget(Yaw).value = 0.5;
        _game.addWidget(YawChange).value = 0.5;

        _game.addWidget(Pitch).value = 0.5;
        _game.addWidget(PitchChange).value = 0.5;

        _game.addWidget(AirSpeed).value = 0.9;

        _cockpit = cockpit;
        _cockpit.messaged.connect(onCockpitMessage);
        _cockpit.send("gamedata", _game);
    }

    public function update (dt :Float)
    {
        _elapsed += dt;

        var wellness = 0.0;
        for (widget in _game.widgets) {
            if (widget.type == TestToggle && widget.value > 0) {
                ++wellness;
                widget.value -= Math.random()*dt;
            }
        }
        wellness /= 4; // normalize to [0,1]

        var lift = -0.05 + 0.08*wellness;

        var altitude = get(Altitude);
        altitude.value += dt*lift;

        // var yawChange = (wellness-0.5) * 0.01 + (get(YawChange).value-0.5);
        // get(Yaw).value += dt*yawChange;
        get(Yaw).value = 0.5*Math.sin(_elapsed/10) + 0.5;

        var pitchChange = 4*lift + (get(PitchChange).value-0.5);
        get(Pitch).value += dt*pitchChange;

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

    private var _elapsed :Float = 0;
}
