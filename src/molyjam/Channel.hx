package molyjam;

import haxe.Serializer;
import haxe.Unserializer;

import flambe.util.Signal0;
import flambe.util.Signal2;

class Channel
{
    /** Emitted when a message is received. */
    public var messaged (default, null) :Signal2<String,Dynamic>;

    public var closed (default, null) :Signal0;

    public function new (socket :Dynamic)
    {
        _socket = socket;
        messaged = new Signal2();
        closed = new Signal0();

#if nodejs
        _socket.on("message", function (event) {
            if (event.type == "utf8") {
                onMessage(event.utf8Data);
            }
        });
        _socket.on("close", function () {
            closed.emit();
        });

#else
        _socket.onmessage = function (event) {
            onMessage(event.data);
        };
        _socket.onclose = function () {
            closed.emit();
        };
#end
    }

    public function send (event :String, data :Dynamic = null)
    {
        var raw = Serializer.run({
            event: event,
            data: data,
        });
        _socket.send(raw);
    }

    public function close ()
    {
        _socket.close();
    }

    private function onMessage (raw :String)
    {
        var message = Unserializer.run(raw);
        messaged.emit(message.event, message.data);
    }

    private var _socket :Dynamic;
}
