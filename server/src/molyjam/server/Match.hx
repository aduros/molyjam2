package molyjam.server;

/** A single hosted _game. */
class Match
{
    public function new (cockpit :Channel)
    {
        _game = new GameData();
        _game.addWidget(Altitude).value = 0.7;
        _game.addWidget(Altitude).value = 0.1;
        _game.addWidget(Altitude).value = 0.9;
        _game.addWidget(Altitude).value = 0.9;

        _cockpit = cockpit;
        _cockpit.messaged.connect(onCockpitMessage);
        _cockpit.send("gamedata", _game);
    }

    public function update (dt :Float)
    {
        // for (widget in _game.widgets) {
        //     widget.value = Math.random();
        // }

        // Update the client
        _cockpit.send("snapshot", _game.createSnapshot());
    }

    private function onCockpitMessage (event :String, data :Dynamic)
    {
        switch (event) {
        case "toggle":
            var widgetIdx = cast data;
            var widget = _game.widgets[widgetIdx];
            widget.value = (widget.value == 0) ? 1 : 0;
        }
    }

    private var _game :GameData;
    private var _cockpit :Channel;
}
