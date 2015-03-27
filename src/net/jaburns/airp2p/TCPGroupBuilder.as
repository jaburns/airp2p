package net.jaburns.airp2p
{
    import flash.events.Event;
    import flash.events.ProgressEvent;
    import flash.events.ServerSocketConnectEvent;
    import flash.net.ServerSocket;
    import flash.net.Socket;

    internal class TCPGroupBuilder implements IPeerGroupBuilder
    {
        static private const SOCKET_PORT :int = 7891;

        private var _log :Function;
        private var _serverSocket :ServerSocket;

        private var _sockets :Vector.<Socket> = new <Socket> [];
        private var _socketsExpected :int = -1;
        private var _connectReady :Function = null;

        private var _peerGroup :PeerGroup = null;

        public function TCPGroupBuilder(log:Function=null)
        {
            if (log !== null) {
                _log = function(msg:String) :void {
                    log("[com.jaburns.airp2p.MatchBuilder] "+msg);
                };
            } else {
                _log = function(msg:String) :void { };
            }
        }

        public function listen() :void
        {
            _serverSocket = new ServerSocket;
            _serverSocket.addEventListener(Event.CONNECT, insocket_connect);
            _serverSocket.bind(SOCKET_PORT);
            _serverSocket.listen();
        }

        public function connect(thisIP:String, ips:Vector.<String>, ready:Function) :void
        {
            if (_connectReady !== null) {
                throw new Error("Cannot call connect twice on PeerGroupBuilder");
            }

            _connectReady = ready;
            _socketsExpected = ips.length - 1;

            var ipsArray :Array = [];
            for each (var ip:String in ips) {
                ipsArray.push(ip);
            }
            ipsArray.sort();

            var thisIndex :int = ipsArray.indexOf(thisIP);

            // The last IP on the list is only listening and makes no outgoing connections.
            if (thisIndex === ipsArray.length - 1) {
                checkReady();
            }
            else {
                // The first IP on the list makes only outgoing connections. Don't need a ServerSocket.
                if (thisIndex === 0) {
                    _serverSocket.close();
                }

                for (var i:int = thisIndex + 1; i < ipsArray.length; ++i) {
                    var sock:Socket = new Socket();
                    sock.addEventListener(Event.CONNECT, outsocket_connect);
                    sock.connect(ipsArray[i], SOCKET_PORT);
                }
            }
        }

        private function outsocket_connect(e:Event) :void
        {
            _log("New outgoing connection");
            addConnectedSocket(e.target as Socket);
        }

        private function insocket_connect(e:ServerSocketConnectEvent) :void
        {
            _log("New incoming connection");
            addConnectedSocket(e.socket);
        }

        private function addConnectedSocket(sock:Socket) :void
        {
            sock.addEventListener(ProgressEvent.SOCKET_DATA, socketListener(sock));
            _sockets.push(sock);
            checkReady();
        }

        private function checkReady() :void
        {
            if (_socketsExpected < 0) return;

            if (_sockets.length === _socketsExpected) {
                _log("Connections with all peers have been established");
                _peerGroup = new PeerGroup;
                _peerGroup.bindBroadcaster(broadcast);
                _connectReady(_peerGroup);
            }
        }

        private function socketListener(sock:Socket) :Function
        {
            return function (e:ProgressEvent) :void {
                var msg:String = sock.readUTF();
                if (_peerGroup) _peerGroup.receive(msg);
            }
        }

        private function broadcast(msg:String) :void
        {
            for each (var sock:Socket in _sockets) {
                sock.writeUTF(msg);
                sock.flush();
            }
        }
    }
}
