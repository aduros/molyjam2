package molyjam.cockpit;

import flambe.Component;
import flambe.display.*;

class BackgroundDisplay extends Component
{
    public function new () { }

    override public function onUpdate (dt :Float)
    {        
        var sprite = owner.get(Sprite);
        sprite.rotation._ = 0;
    }
}