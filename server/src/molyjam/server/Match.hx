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
        _widgetMap = new Map();

        addWidget(Altitude, 1.0);
        addWidget(TestToggle, Math.random());
        addWidget(TestToggle, Math.random());
        addWidget(TestToggle, Math.random());
        addWidget(TestToggle, Math.random());

        addWidget(Yaw, 0.5);
        addWidget(YawChange, 0.5);

        addWidget(Pitch, 0.5);
        addWidget(PitchChange, 0.5);

        addWidget(AirSpeed, 0.9);
        addWidget(Throttle, 0.5);
        addWidget(AirBrakes, 0.0);

        addWidget(EngineEnabled, 1.0);
        addWidget(EngineEnabled, 1.0);
        addWidget(EngineEnabled, 1.0);
        addWidget(EngineEnabled, 1.0);

        addWidget(Fire, 0.0);
        addWidget(Fire, 0.0);
        addWidget(Fire, 0.0);
        addWidget(Fire, 0.0);

        addWidget(FireExtinguisher, 0.0);
        addWidget(FireExtinguisher, 0.0);
        addWidget(FireExtinguisher, 0.0);
        addWidget(FireExtinguisher, 0.0);

        addWidget(Fuel, 1.0);
        addWidget(Fuel, 1.0);
        addWidget(Fuel, 1.0);
        addWidget(Fuel, 1.0);

        addWidget(FuelDump, 0.0);
        addWidget(FuelDump, 0.0);
        addWidget(FuelDump, 0.0);
        addWidget(FuelDump, 0.0);

        addWidget(Oil, 1.0);
        addWidget(Hydro, 1.0);
        addWidget(AutoPilot, 1.0);

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
        var all = _widgetMap.get(type);
        return (all == null) ? null : all[0];
    }

    private function addWidget (type :WidgetType, init :Float) :Void
    {
        var widget = _game.addWidget(type);
        widget.value = init;
        var data = _widgetMap.get(type);
        if (data == null) {
            data = new Array();
            _widgetMap.set(type, data);
        }
        data.push(widget);
    }

    private var _game :GameData;
    private var _cockpit :Channel;
    private var _phones :Array<Channel>;

    private var _elapsed :Float = 0;

    private var _widgetMap :Map<WidgetType, Array<WidgetData>>;

    // Collection of stateful server-only variables.
    private var _yawChange :Float = 0.5;
    private var _pitchChange :Float = 0.5;
}
