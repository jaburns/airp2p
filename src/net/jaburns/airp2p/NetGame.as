package net.jaburns.airp2p
{
    import flash.events.DatagramSocketDataEvent;
    import flash.net.DatagramSocket;
    import flash.utils.ByteArray;

    public class NetGame
    {
        static private const SOCKET_PORT :int = 7892;


        static private var s_canInstantiate :Boolean = false;
        static private var s_instance :NetGame = null;


        private var _host :IHost;
        private var _client :IClient;
        private var _peers :PeerGroup;
        private var _socket :DatagramSocket;
        private var _hosting :Boolean = false;


        static public function start(hostLogic:IHost, clientLogic:IClient, logFn:Function) :NetGame
        {
            if (s_instance !== null) {
                throw new Error ("NetGame.start has already been called");
            }

            s_canInstantiate = true;
            s_instance = new NetGame(hostLogic, clientLogic, logFn);
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


        public function NetGame(hostLogic:IHost, clientLogic:IClient, logFn:Function)
        {
            if (!s_canInstantiate) {
                throw new Error ("Should call NetGame.start instead of instantiating with new");
            }

            _host = hostLogic;
            _client = clientLogic;

            _socket = new DatagramSocket();
            _socket.addEventListener(DatagramSocketDataEvent.DATA, socket_receive);
            _socket.bind(SOCKET_PORT);
            _socket.receive();

            _peers = new PeerGroup(logFn);
            _peers.addEventListener(PeerGroupEvent.PEER_CONNECTED, peers_connected);
            _peers.addEventListener(PeerGroupEvent.PEER_DISCONNECTED, peers_disconnected);
            _peers.addEventListener(PeerGroupEvent.HOST_DETERMINED, peers_hostDetermined);
            _peers.connect();
        }

        private function peers_hostDetermined(e:PeerGroupEvent) :void
        {
            _hosting = e.ip === _peers.localIP;
        }

        private function peers_connected(e:PeerGroupEvent) :void
        {
        }

        private function peers_disconnected(e:PeerGroupEvent) :void
        {
        }

        private function socket_receive(e:DatagramSocketDataEvent) :void
        {
        }

        private function sendData() :void
        {
            var data:ByteArray = null;
            var ip:String = "127.0.0.1";
            _socket.send(data, 0, 0, ip, SOCKET_PORT);
        }
    }
}
