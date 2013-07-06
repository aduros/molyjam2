package molyjam.cockpit;

import flambe.asset.AssetPack;

/** All the game state goes here. */
class CockpitContext
{
    public var pack (default, null) :AssetPack;

    public function new (pack :AssetPack)
    {
        this.pack = pack;
    }
}
