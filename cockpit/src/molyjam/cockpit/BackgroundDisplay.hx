package molyjam.cockpit;

import flambe.Component;
import flambe.display.*;
import flambe.System;

class BackgroundDisplay extends Component
{
    public function new (pitch :WidgetData, yaw :WidgetData)
    {
        _pitch = pitch;
        _yaw = yaw;
    }

    override public function onUpdate (dt :Float)
    {
        var sprite = owner.get(Sprite);

        var maxRoll = 90;
        sprite.rotation._ = (_yaw.value-0.5) * maxRoll;

        var maxOffset = 200;
        sprite.setXY(System.stage.width/2, System.stage.height/2 + maxOffset*(2*_pitch.value-1));
    }

    private var _pitch :WidgetData;
    private var _yaw :WidgetData;
}
