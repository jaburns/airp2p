package net.jaburns.airp2p
{
    import flash.events.DatagramSocketDataEvent;
    import flash.events.Event;
    import flash.events.TimerEvent;
    import flash.net.DatagramSocket;
    import flash.net.registerClassAlias;
    import flash.utils.ByteArray;
    import flash.utils.Timer;
    import flash.utils.describeType;

    import avmplus.getQualifiedClassName;

    public class NetGame
    {
        static private const SOCKET_PORT :int = 30322;


        static private var s_canInstantiate :Boolean = false;
        static private var s_instance :NetGame = null;


        private var _gameStateClass :Class;
        private var _gameState :Object;

        private var _log :Function;
        private var _client :IClient;
        private var _peers :PeerGroup;
        private var _socket :DatagramSocket;
        private var _hosting :Boolean = false;
        private var _tickLength :Number;
        private var _loopTimer :Timer;

        // Hash of input objects indexed by the IP address of the sender.  Used when hosting only.
        private var _freshInputs :Boolean;
        private var _inputs :Object;

        private var _latestState :Object = null;


        static public function registerTypes(...args) :void
        {
            // Instead of requiring the user to provide all types which are going to be serialized
            // we can do describeType(GameState) and recursively walk the types of the public
            // fields while calling registerClassAlias(typeName, getDefinitionByName(typeName)).
            // That, of course, is more complex than asking for a list of used types, but it would be nice.

            for each (var klass:Class in args) {
                registerClassAlias(getQualifiedClassName(klass), klass);
            }
        }

        static public function start(gameStateClass:Class, clientLogic:IClient, tickLength:Number, log:Function=null) :NetGame
        {
            if (s_instance !== null) {
                throw new Error ("NetGame.start has already been called");
            }

            s_canInstantiate = true;
            s_instance = new NetGame(gameStateClass, clientLogic, tickLength, log);
            s_canInstantiate = false;

            Platform.start();

            return s_instance;
        }

        static public function stop() :void
        {
            if (s_instance === null) return;
            s_instance.dispose();
            s_instance = null;

            Platform.stop();
        }


        public function NetGame(gameStateClass:Class, clientLogic:IClient, tickLength:Number, log:Function=null)
        {
            if (!s_canInstantiate) {
                throw new Error ("Should call NetGame.start instead of instantiating with new");
            }

            if (!checkForUpdateMethod(gameStateClass)) {
                throw new Error ("Class supplied as gameStateClass must have a public method update(Object):void");
            }

            if (log !== null) {
                _log = function(msg:String) :void {
                    log("[NetGame] "+msg);
                };
            } else {
                _log = function(msg:String) :void { };
            }

            _tickLength = tickLength;

            _gameStateClass = gameStateClass;
            _gameState = new _gameStateClass;
            _client = clientLogic;

            _socket = new DatagramSocket();
            _socket.addEventListener(DatagramSocketDataEvent.DATA, socket_receive);
            _socket.bind(SOCKET_PORT);
            _socket.receive();

            _peers = new PeerGroup(log);
            _peers.addEventListener(PeerGroupEvent.PEER_CONNECTED, peers_peerConnected);
            _peers.addEventListener(PeerGroupEvent.PEER_DISCONNECTED, peers_peerDisconnected);
            _peers.addEventListener(PeerGroupEvent.HOST_DETERMINED, peers_hostDetermined);
            _peers.addEventListener(PeerGroupEvent.HOST_DISCONNECTED, peers_hostDisconnected);
            _peers.connect();
        }

        public function dispose() :void
        {
            _socket.close();
            _socket.removeEventListener(DatagramSocketDataEvent.DATA, socket_receive);

            _peers.disconnect();
            _peers.removeEventListener(PeerGroupEvent.PEER_CONNECTED, peers_peerConnected);
            _peers.removeEventListener(PeerGroupEvent.PEER_DISCONNECTED, peers_peerDisconnected);
            _peers.removeEventListener(PeerGroupEvent.HOST_DETERMINED, peers_hostDetermined);
            _peers.removeEventListener(PeerGroupEvent.HOST_DISCONNECTED, peers_hostDisconnected);

            disposeTimer();
        }

        private function peers_hostDetermined(e:PeerGroupEvent) :void
        {
            _hosting = e.ip === _peers.localIP;
            _freshInputs = true;
            _inputs = {};

            _client.notifyConnected();

            _log("Host determined. Starting updates.");
            _loopTimer = new Timer(_tickLength);
            _loopTimer.addEventListener(TimerEvent.TIMER, loopTimer_tick);
            _loopTimer.start();
        }

        private function peers_hostDisconnected(e:PeerGroupEvent) :void
        {
            _log("Host disconnected. Stopping updates.");
            disposeTimer();
        }

        private function disposeTimer() :void
        {
            if (_loopTimer) {
                _loopTimer.stop();
                _loopTimer.removeEventListener(TimerEvent.TIMER, loopTimer_tick);
                _loopTimer = null;
            }
        }

        private function peers_peerConnected(e:PeerGroupEvent) :void
        {
        }

        private function peers_peerDisconnected(e:PeerGroupEvent) :void
        {
            if (_hosting) {
                delete _inputs[e.ip];
            }
        }

        private function loopTimer_tick(e:TimerEvent) :void
        {
            if (_hosting) {
                // Make sure that we've received an input packet from each player before updating.
                if (_freshInputs) {
                    _freshInputs = false;
                    for each (var ip:String in _peers.getIPs()) {
                        if (_inputs[ip] === undefined) {
                            _freshInputs = true;
                            break;
                        }
                    }
                }
                if (!_freshInputs) {
                    _gameState.update(_inputs);
                    for each (ip in _peers.getIPs()) {
                        if (ip === _peers.localIP) continue;
                        sendObject(ip, _gameState);
                    }
                }

                // Update the client system (read inputs, render state) on the host device.
                _inputs[_peers.localIP] = baClone(_client.readInput());
                _client.notifyGameState(baClone(_gameState));
            }
            else {
                sendObject(_peers.hostIP, _client.readInput());
            }
        }

        private function baClone(obj:Object) :Object
        {
            var ba:ByteArray = new ByteArray;
            ba.writeObject(obj);
            ba.position = 0;
            return ba.readObject();
        }

        private function socket_receive(e:DatagramSocketDataEvent) :void
        {
            if (!_loopTimer) return;

            if (_hosting) {
                _inputs[e.srcAddress] = e.data.readObject();
            } else {
                _gameState = e.data.readObject();
                _client.notifyGameState(_gameState);
            }
        }

        private function sendObject(ip:String, obj:Object) :void
        {
            var data:ByteArray = new ByteArray;
            data.writeObject(obj);
            _socket.send(data, 0, 0, ip, SOCKET_PORT);
        }


        static private function checkForUpdateMethod(klass:Class) :Boolean
        {
            var info:XML = describeType(klass);
            for each (var method:XML in info.factory.method) {
                if (method.@name == "update") {
                    if (method.@returnType != "void") return false;
                    for each (var child:XML in method.children()) {
                        if (child.name() == "parameter") {
                            if (child.@index != "1") return false;
                            if (child.@type != "Object") return false;
                        }
                    }
                    return true;
                }
            }
            return false;
        }
    }
}
