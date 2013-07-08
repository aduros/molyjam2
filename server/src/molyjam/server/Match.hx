package molyjam.server;

import flambe.util.Assert;
import flambe.math.FMath.*;

/** A single hosted game. */
class Match
{
    public var id (default, null) :Int;

    public function new (id :Int, cockpit :Channel)
    {
        this.id = id;

        _game = new GameData(generateName());

        _widgetMap = new Map();

        _toiletFlushTimestamps = new Array();
        _toiletFlushTimestamps.push(0.0);
        _toiletFlushTimestamps.push(0.0);
        _toiletFlushTimestamps.push(0.0);
        _toiletFlushTimestamps.push(0.0);

        addWidget(Altitude, 1.0);
        // addWidget(TestToggle, Math.random());
        // addWidget(TestToggle, Math.random());
        // addWidget(TestToggle, Math.random());
        // addWidget(TestToggle, Math.random());

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

        //addWidget(Fire, 0.0);
        //addWidget(Fire, 0.0);
        //addWidget(Fire, 0.0);
        //addWidget(Fire, 0.0);

        //addWidget(FireExtinguisher, 0.0);
        //addWidget(FireExtinguisher, 0.0);
        //addWidget(FireExtinguisher, 0.0);
        //addWidget(FireExtinguisher, 0.0);

        addWidget(Fuel, 1.0);
        addWidget(Fuel, 1.0);
        addWidget(Fuel, 1.0);
        addWidget(Fuel, 1.0);

        addWidget(FuelDump, 0.0);
        addWidget(FuelDump, 0.0);
        addWidget(FuelDump, 0.0);
        addWidget(FuelDump, 0.0);

        //addWidget(Oil, 1.0);
        //addWidget(OilDesired, 1.0);
        //addWidget(Hydro, 1.0);
        //addWidget(HydroDesired, 1.0);
        addWidget(Flaps, 1.0);
        addWidget(FlapsDesired, 1.0);

        //addWidget(AutoPilot, 1.0);
        //addWidget(CallFlightAttendant, 1.0);
        addWidget(ToiletFault, 0.0);

        addWidget(ToiletFlush, 0.0);
        addWidget(ToiletFlush, 0.0);
        addWidget(ToiletFlush, 0.0);
        addWidget(ToiletFlush, 0.0);

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

    public function broadcast (event :String, data :Dynamic)
    {
        for (phone in _phones) {
            phone.send(event, data);
        }
        _cockpit.send(event, data);
    }

    public function sendGameOver ()
    {
        broadcast("gameover", {
            score: 0,
        });
    }

    public function update (dt :Float) :Bool
    {
        var toiletFlushBuffer = 5.0;
        var toiletFaultBuffer = 30.0;
        var toiletFaultLength = 5.0;
        var maxThrustFuelDrainRate = 0.001;
        var maxFlapsDrag = 1.0;
        var toiletFaultDrag = 5.0;
        var airBrakesDrag = 1.0;
        var maxPitch = 45.0;
        var airSpeedConstant = 0.05;
        var weight = 0.05;
        var baseLift = 0.05;
        var baseDrag = 0.2;
        var pitchDrag = 0.2;
        var minAirSpeed = 0.2;
        var fallingPitchChange = -2.0;

        _elapsed += dt;

        var toiletFlushList = _widgetMap.get(ToiletFlush);
        var allToiletsFlushing :Bool = true;
        for (i in 0...toiletFlushList.length) {
            if (_elapsed - _toiletFlushTimestamps[i] > toiletFlushBuffer) {
                if (toiletFlushList[i].getSegment(2) == 1) {
                    _toiletFlushTimestamps[i] = _elapsed;
                } else {
                    allToiletsFlushing = false;
                }
            }
        }
        if (allToiletsFlushing && (_elapsed - _toiletFaultTimestamp) > toiletFaultBuffer) {
            _toiletFaultTimestamp = _elapsed;
            get(ToiletFault).value = 1;
        }


        var dumpList = _widgetMap.get(FuelDump);
        var fuelList = _widgetMap.get(Fuel);
        var hasFuel :Bool = false;
        for (i in 0...dumpList.length) {
            if (dumpList[i].getSegment(2) == 1) {
                fuelList[i].value -= maxThrustFuelDrainRate * 10;
            }
        }

        var thrust :Float = 0;
        var throttle = get(Throttle).value;
        var enginesEnabled = _widgetMap.get(EngineEnabled);
        for (i in 0...enginesEnabled.length) {
            if (fuelList[i].value > 0) {
                thrust += enginesEnabled[i].getSegment(2) * throttle;
                fuelList[i].value -= enginesEnabled[i].getSegment(2) * maxThrustFuelDrainRate * throttle;
                if (fuelList[i].value == 0) {
                    enginesEnabled[i].value = 0;
                }
            }
        }

        var drag :Float = baseDrag;
        var flaps = get(Flaps).value;
        var flapsDesired = get(FlapsDesired).value;
        if (flaps != flapsDesired) {
            drag += Math.abs(flaps - flapsDesired) * maxFlapsDrag;
        }
        if (get(AirBrakes).getSegment(2) == 1) {
            drag += airBrakesDrag;
        }        
        if (get(ToiletFault).getSegment(2) == 1) {
            drag += toiletFaultDrag;
            if (_elapsed - _toiletFaultTimestamp > toiletFaultLength) {
                get(ToiletFault).value = 0;
            }
        }

        var pitchVal = get(Pitch).value - 0.5;
        if (pitchVal > 0) {
            drag += pitchDrag * pitchVal;
        }
        get(AirSpeed).value += (thrust - drag) * airSpeedConstant;

        var airSpeed = get(AirSpeed).value;
        var lift = airSpeed * pitchVal;
        if (airSpeed < minAirSpeed) {
            lift -= (minAirSpeed - get(AirSpeed).value);
        }
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
        var pitchChangeWithLift = (airSpeed < minAirSpeed) ? (fallingPitchChange * (minAirSpeed - airSpeed)) + (_pitchChange-0.5) : (_pitchChange-0.5);
        get(Pitch).value += dt * pitchChangeWithLift;


        // Update the client
        _cockpit.send("snapshot", _game.createSnapshot());
        return altitude.value <= 0;
    }

    public function toSummary () :Dynamic
    {
        return {
            name: _game.name,
            id: id,
            population: 1 + _phones.length,
        };
    }

    private function onCockpitMessage (event :String, data :Dynamic)
    {
        trace("Got event from cockpit: " + event + ", " + data);
        switch (event) {
        case "set":
            var widgetIdx :Int = data.idx;
            var widget = _game.widgets[widgetIdx];
            widget.value = data.value;
        case "updateYawChange":
            get(YawChange).value = cast data;
        case "updatePitchChange":
            get(PitchChange).value = cast data;
        case "updateThrottle":
            get(Throttle).value = cast data;
        }
    }

    private function onPhoneMessage (event :String, data :Dynamic)
    {
        trace("Got event from phone: " + event + ", " + data);
        switch (event) {
        case "poke":
            var widget = _game.widgets[Std.int(Math.random() * _game.widgets.length)];

            switch(widget.type) {
                case Altitude|Pitch|Yaw|AirSpeed|Fuel|Direction|Fire|ToiletFault:
                case PitchChange|YawChange|Throttle:
                    widget.value = Math.random();
                default:
                    widget.value = clamp(Math.round(Math.random() * 2), 0, 1);
            }
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

    private static function generateName ()
    {
        function digit () return Std.int(Math.random()*10);
        return "Flight " + digit() + digit() + digit();
    }

    private var _game :GameData;
    private var _cockpit :Channel;
    private var _phones :Array<Channel>;

    private var _elapsed :Float = 0;

    private var _widgetMap :Map<WidgetType, Array<WidgetData>>;

    // Collection of stateful server-only variables.
    private var _yawChange :Float = 0.5;
    private var _pitchChange :Float = 0.5;

    private var _toiletFaultTimestamp :Float = 0;
    private var _toiletFlushTimestamps :Array<Float>;
}
