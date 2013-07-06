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
        sprite.rotation._ = _yaw.value * 360;
        sprite.setXY(System.stage.width / 2, System.stage.height * _pitch.value);
    }

    private var _pitch :WidgetData;
    private var _yaw :WidgetData;
}