package molyjam.server;

import flambe.util.Assert;
import flambe.math.FMath.*;

/** A single hosted game. */
class Match
{
    public var name (default, null) :String;

    public function new (name :String, cockpit :Channel)
    {
        this.name = name;

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
        _cockpit.closed.connect(function () {
            // Boot all the phones if the cockpit disconnects
            for (phone in _phones) {
                phone.close();
            }
        });
        _cockpit.send("gamedata", _game);

        _phones = [];
    }

    public function addPhone (channel :Channel)
    {
        _phones.push(channel);
        channel.closed.connect(function () {
            _phones.remove(channel);
        });
        channel.messaged.connect(onPhoneMessage);
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

        // Lift is a function of air speed, drag, and thrust.
        // Air speed is a function of drag and thrust.
        // Drag is a function of all the weird crap.
        // Thrust is a function of throttle.
        // Throttle affects fuel consumption.

        var altitude = get(Altitude);
        altitude.value += dt*lift;

        // var yawChange = (wellness-0.5) * 0.01 + (get(YawChange).value-0.5);
        // get(Yaw).value += dt*yawChange;
        var yawChange = get(YawChange);
        if (yawChange.value != _yawChange) {
            if (Math.abs(yawChange.value - _yawChange) < 0.0001) {
                _yawChange = yawChange.value;
            } else {
                _yawChange = (yawChange.value - _yawChange) / 4 + _yawChange;
            }
        }
        get(Yaw).value += dt * (_yawChange - 0.5);

        var pitchChange = get(PitchChange);
        if (pitchChange.value != _pitchChange) {
            if (Math.abs(pitchChange.value - _pitchChange) < 0.0001) {
                pitchChange.value = _pitchChange;
            } else {
                _pitchChange = (pitchChange.value - _pitchChange) / 4 + _pitchChange;
            }
        }
        var pitchChangeWithLift = 4*lift + (_pitchChange-0.5);
        get(Pitch).value += dt * pitchChangeWithLift;

        // Update the client
        _cockpit.send("snapshot", _game.createSnapshot());
    }

    public function population () :Int
    {
        return 1 + _phones.length;
    }

    private function onCockpitMessage (event :String, data :Dynamic)
    {
        trace("Got event from cockpit: " + event + ", " + data);
        switch (event) {
        case "toggle":
            var widgetIdx = cast data;
            var widget = _game.widgets[widgetIdx];
            widget.value = (widget.value == 0) ? 1 : 0;
        case "updateYawChange":
            get(YawChange).value = cast data;
        case "updatePitchChange":
            get(PitchChange).value = cast data;
        }
    }

    private function onPhoneMessage (event :String, data :Dynamic)
    {
        trace("Got event from phone: " + event + ", " + data);
        switch (event) {
        case "poke":
            // Not what we want, but illustrative for now
            get(Pitch).value = Math.random();
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
    private var _phones :Array<Channel>;

    private var _elapsed :Float = 0;

    // Collection of stateful server-only variables.
    private var _yawChange :Float = 0.5;
    private var _pitchChange :Float = 0.5;
}
