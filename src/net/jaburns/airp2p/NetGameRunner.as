package net.jaburns.airp2p
{
    import flash.events.DatagramSocketDataEvent;
    import flash.events.TimerEvent;
    import flash.net.DatagramSocket;
    import flash.utils.ByteArray;
    import flash.utils.describeType;
    import flash.utils.getQualifiedClassName;
    import flash.utils.getTimer;

    internal class NetGameRunner implements IGameRunner
    {
        static private const SOCKET_PORT :int = 30322;


        private var _gameStateClass :Class;
        private var _gameState :Object;

        private var _log :Function;
        private var _client :IClient;
        private var _peers :PeerGroup;
        private var _socket :DatagramSocket;
        private var _hosting :Boolean = false;
        private var _timer :TickTimer;

        private var _clientConnected :Boolean = false;
        private var _ticksWithoutReceiveState :int = 0;
        private var _lastReceiveTime :int = 0;

        // Hash of input objects indexed by the IP address of the sender.  Used when hosting only.
        private var _freshInputs :Boolean;
        private var _inputs :Object;

        private var _latestState :Object = null;


        public function start(gameStateClass:Class, clientLogic:IClient, tickLength:Number, log:Function=null) :void
        {
            if (!Util.checkForUpdateMethod(gameStateClass)) {
                throw new Error ("Class supplied as gameStateClass must have a public method update(Object):void");
            }

            if (log !== null) {
                _log = function(msg:String) :void {
                    log("[NetGameRunner] "+msg);
                };
            } else {
                _log = function(msg:String) :void { };
            }

            _timer = new TickTimer(tickLength);
            _timer.addEventListener(TimerEvent.TIMER, loopTimer_tick);

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

        public function stop() :void
        {
            _socket.close();
            _socket.removeEventListener(DatagramSocketDataEvent.DATA, socket_receive);

            _peers.disconnect();
            _peers.removeEventListener(PeerGroupEvent.PEER_CONNECTED, peers_peerConnected);
            _peers.removeEventListener(PeerGroupEvent.PEER_DISCONNECTED, peers_peerDisconnected);
            _peers.removeEventListener(PeerGroupEvent.HOST_DETERMINED, peers_hostDetermined);
            _peers.removeEventListener(PeerGroupEvent.HOST_DISCONNECTED, peers_hostDisconnected);

            _timer.stop();
            _timer.removeEventListener(TimerEvent.TIMER, loopTimer_tick);
        }

        private function notifyClientConnected(connected:Boolean) :void
        {
            if (_clientConnected !== connected) {
                _client.notifyConnected(connected);
                _clientConnected = connected;
            }
        }

        private function peers_hostDetermined(e:PeerGroupEvent) :void
        {
            _hosting = e.ip === _peers.localIP;
            _freshInputs = true;
            _inputs = {};

            _log("Host determined. Starting updates.");
            _timer.start();
        }

        private function peers_hostDisconnected(e:PeerGroupEvent) :void
        {
            _log("Host disconnected. Stopping updates.");
            _timer.stop();
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
                _inputs[_peers.localIP] = Util.deepClone(_client.readInput());

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

                    notifyClientConnected(true);
                    _client.notifyGameState(Util.deepClone(_gameState));
                }
            }
            else {
                sendObject(_peers.hostIP, _client.readInput());

                if (++_ticksWithoutReceiveState >= 3) {
                    notifyClientConnected(false);
                }
            }
        }

        private function socket_receive(e:DatagramSocketDataEvent) :void
        {
            if (!_timer.running) return;

            if (_hosting) {
                _inputs[e.srcAddress] = e.data.readObject();
            } else {
                var newReceiveTime :int = getTimer();
                var orphanPacket :Boolean = newReceiveTime - _lastReceiveTime > _timer.interval * 2;
                _lastReceiveTime = getTimer();

                if (!orphanPacket) {
                    _ticksWithoutReceiveState = 0;
                    notifyClientConnected(true);

                    _gameState = e.data.readObject();
                    _client.notifyGameState(_gameState);
                }
            }
        }

        private function sendObject(ip:String, obj:Object) :void
        {
            var data:ByteArray = new ByteArray;
            data.writeObject(obj);
            _socket.send(data, 0, 0, ip, SOCKET_PORT);
        }
    }
}
