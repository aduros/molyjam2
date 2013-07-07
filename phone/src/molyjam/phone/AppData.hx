package molyjam.phone;

import flambe.math.Point;

class AppData
{
    public var name (default, null) :String;
    public var image (default, null) :String;
    public var hotspots (default, null) :Array<Point>;

    public function new (name :String, image :String, hotspots :Array<Point>)
    {
        this.name = name;
        this.image = image;
        this.hotspots = hotspots;
    }
}
