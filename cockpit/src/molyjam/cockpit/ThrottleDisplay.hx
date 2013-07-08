package molyjam.cockpit;

import flambe.Component;
import flambe.display.*;
import flambe.System;

class ThrottleDisplay extends Component
{
    public function new (throttle :WidgetData)
    {
        _throttle = throttle;
    }

    override public function onAdded ()
    {
        var sprite = owner.get(Sprite);
        System.keyboard.down.connect(function (event) {
            switch(event.key) {
                case M:
                    _mHeld = true;
                case N:
                    _nHeld = true;
                default:
            }
        });
        System.keyboard.up.connect(function (event) {
            switch(event.key) {
                case M:
                    _mHeld = false;
                case N:
                    _nHeld = false;
                default:
            }
        });
    }

    override public function onUpdate (dt :Float)
    {
        var sprite = owner.get(Sprite);
        // Locked between 1.1 and 0.9
        sprite.setScale((_throttle.value - 0.5) * 0.2 + 1.0);

        var throttleDiff = 0.05;
        var newThrottle = _throttle.value;
        if (_mHeld && !_nHeld) {
            newThrottle += throttleDiff;
        } else if (_nHeld && !_mHeld) {
            newThrottle -= throttleDiff;
        }
        if (newThrottle != _throttle.value) {
            CockpitContext.instance.updateThrottle(newThrottle);
        }
    }

    private var _throttle :WidgetData;
    private var _mHeld :Bool;
    private var _nHeld :Bool;
}
