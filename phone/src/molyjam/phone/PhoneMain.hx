package molyjam.phone;

import js.html.WebSocket;

import flambe.Entity;
import flambe.System;
import flambe.asset.AssetPack;
import flambe.asset.Manifest;
import flambe.display.FillSprite;
import flambe.display.ImageSprite;

class PhoneMain
{
    private static function main ()
    {
        // Wind up all platform-specific stuff
        System.init();

        // Load up the compiled pack in the assets directory named "bootstrap"
        var manifest = Manifest.build("bootstrap");
        var loader = System.loadAssetPack(manifest);
        loader.get(function (pack) {
            _socket = new WebSocket("ws://"+Config.SERVER_HOST+":"+Config.SERVER_PORT);
            _socket.onerror = function (_) {
                trace("Connection error!");
            };
            _socket.onopen = function (_) {
                PhoneContext.init(pack, new Channel(_socket));
            };
        });
    }

    // Keep a hard reference to the socket to prevent GC bugs in some browsers. Pretend this isn't
    // here :)
    private static var _socket :WebSocket;
}
