package molyjam.cockpit;

import flambe.Component;
import flambe.display.*;
import flambe.System;

class SteeringDisplay extends Component
{
    public function new (pitchChange :WidgetData, yawChange :WidgetData)
    {
        _pitchChange = pitchChange;
        _yawChange = yawChange;
    }

    override public function onAdded ()
    {
        var sprite = owner.get(Sprite);
        System.keyboard.down.connect(function (event) {
            switch(event.key) {
                case Down:
                    _downHeld = true;
                case Up:
                    _upHeld = true;
                case Left:
                    _leftHeld = true;
                case Right:
                    _rightHeld = true;
                default:
            }
        });
        System.keyboard.up.connect(function (event) {
            switch(event.key) {
                case Down:
                    _downHeld = false;
                case Up:
                    _upHeld = false;
                case Left:
                    _leftHeld = false;
                case Right:
                    _rightHeld = false;
                default:
            }
        });
    }

    override public function onUpdate (dt :Float)
    {
        var sprite = owner.get(Sprite);
        sprite.rotation._ = _yawChange.value * 180.0 - 90.0;
        // Locked between 1.1 and 0.9
        sprite.setScale((_pitchChange.value - 0.5) * 0.2 + 1.0);

        var pitchChangeDiff = 0.05;
        var newPitchChange = _pitchChange.value;
        if (_downHeld && !_upHeld) {
            newPitchChange += pitchChangeDiff;
        } else if (_upHeld && !_downHeld) {
            newPitchChange -= pitchChangeDiff;
        }
        if (newPitchChange != _pitchChange.value) {
            CockpitContext.instance.updatePitchChange(newPitchChange);
        }

        var yawChangeDiff = 0.05;
        var newYawChange = _yawChange.value;
        if (_leftHeld && !_rightHeld) {
            newYawChange -= yawChangeDiff;
        } else if (_rightHeld && !_leftHeld) {
            newYawChange += yawChangeDiff;
        }
        if (newYawChange != _yawChange.value) {
            CockpitContext.instance.updateYawChange(newYawChange);
        }
    }

    private var _pitchChange :WidgetData;
    private var _yawChange :WidgetData;
    private var _downHeld :Bool;
    private var _upHeld :Bool;
    private var _leftHeld :Bool;
    private var _rightHeld :Bool;
}