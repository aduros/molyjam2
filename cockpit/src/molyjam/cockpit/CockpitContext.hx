package molyjam.cockpit;

import flambe.asset.AssetPack;

import molyjam.GameData;

/** All the client state goes here. */
class CockpitContext
{
    public var pack (default, null) :AssetPack;

    public var game (default, null) :GameData;

    public function new (pack :AssetPack)
    {
        this.pack = pack;

        // TODO(bruno): Pull this down from the server
        game = new GameData();
        game.addWidget(Altitude).value = 0.2;
        // Probably don't want duplicates eventually if they're keyed by type
        game.addWidget(Altitude).value = 0.9;
    }
}
