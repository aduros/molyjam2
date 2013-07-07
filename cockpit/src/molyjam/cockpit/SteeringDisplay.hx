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
                case Up:
                case Left:
                case Right:
                default:
            }
        });
    }

    override public function onUpdate (dt :Float)
    {        
        var sprite = owner.get(Sprite);
        sprite.rotation._ = _yawChange.value * 180.0 - 90.0;
        // Locked between 1.25 and 0.75
        sprite.setScale((_pitchChange.value - 0.5) * 0.5 + 0.5);
    }

    private var _pitchChange :WidgetData;
    private var _yawChange :WidgetData;
}