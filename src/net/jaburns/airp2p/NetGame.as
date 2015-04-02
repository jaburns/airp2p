package net.jaburns.airp2p
{
    import flash.events.DatagramSocketDataEvent;
    import flash.events.TimerEvent;
    import flash.net.DatagramSocket;
    import flash.net.registerClassAlias;
    import flash.utils.ByteArray;
    import flash.utils.Timer;
    import flash.utils.describeType;

    import avmplus.getQualifiedClassName;

    public class NetGame
    {
        static private const SOCKET_PORT :int = 7892;


        static private var s_canInstantiate :Boolean = false;
        static private var s_instance :NetGame = null;


        private var _gameStateClass :Class;
        private var _gameState :Object;

        private var _client :IClient;
        private var _peers :PeerGroup;
        private var _socket :DatagramSocket;
        private var _hosting :Boolean = false;
        private var _loopTimer :Timer;

        // Hash of input objects indexed by the IP address of the sender.  Used when hosting only.
        private var _inputs :Object = {};

        private var _latestState :Object = null;


        static public function registerTypes(...args) :void
        {
            for each (var klass:Class in args) {
                registerClassAlias(getQualifiedClassName(klass), klass);
            }
        }

        static public function start(gameStateClass:Class, clientLogic:IClient, logFn:Function=null) :NetGame
        {
            if (s_instance !== null) {
                throw new Error ("NetGame.start has already been called");
            }

            s_canInstantiate = true;
            s_instance = new NetGame(gameStateClass, clientLogic, logFn);
            s_canInstantiate = false;

            return s_instance;
        }

        static public function get instanace() :NetGame
        {
            if (!s_instance === null) {
                throw new Error ("Must call NetGame.start before getting instance");
            }
            return s_instance;
        }


        public function NetGame(gameStateClass:Class, clientLogic:IClient, logFn:Function=null)
        {
            if (!s_canInstantiate) {
                throw new Error ("Should call NetGame.start instead of instantiating with new");
            }

            if (!checkForUpdateMethod(gameStateClass)) {
                throw new Error ("Class supplied as gameStateClass must have a public method update(Object):void");
            }

            _gameStateClass = gameStateClass;
            _gameState = new _gameStateClass;
            _client = clientLogic;

            _socket = new DatagramSocket();
            _socket.addEventListener(DatagramSocketDataEvent.DATA, socket_receive);
            _socket.bind(SOCKET_PORT);
            _socket.receive();

            _peers = new PeerGroup(logFn);
            _peers.addEventListener(PeerGroupEvent.HOST_DETERMINED, peers_hostDetermined);
            _peers.connect();
        }

        private function peers_hostDetermined(e:PeerGroupEvent) :void
        {
            _hosting = e.ip === _peers.localIP;

            _loopTimer = new Timer(40);
            _loopTimer.addEventListener(TimerEvent.TIMER, loopTimer_tick);
            _loopTimer.start();
        }

        private function loopTimer_tick(e:TimerEvent) :void
        {
            if (_hosting) {
                _gameState.update(_inputs);

                for each (var ip:String in _peers.getIPs()) {
                    if (ip === _peers.localIP) continue;
                    sendObject(ip, _gameState);
                }

                _inputs[_peers.localIP] = _client.readInputs();
                _client.setState(_gameState);
            }
            else {
                sendObject(_peers.hostIP, _client.readInputs());
            }
        }

        private function socket_receive(e:DatagramSocketDataEvent) :void
        {
            if (_hosting) {
                _inputs[e.srcAddress] = e.data.readObject();
            } else {
                _client.setState(e.data.readObject());
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
