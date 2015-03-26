package net.jaburns.airp2p
{
    import flash.events.Event;
    import flash.events.ProgressEvent;
    import flash.events.ServerSocketConnectEvent;
    import flash.net.ServerSocket;
    import flash.net.Socket;

    internal class MatchBuilder
    {
        static private const SOCKET_PORT :int = 7891;

        private var _log :Function;
        private var _serverSocket :ServerSocket;

        private var _sockets :Vector.<Socket> = new <Socket> [];

        public function MatchBuilder(log:Function=null)
        {
            if (log !== null) {
                _log = function(msg:String) :void {
                    log("[com.jaburns.airp2p.MatchBuilder] "+msg);
                };
            } else {
                _log = function(msg:String) :void { };
            }
        }

        public function initServerSocket() :void
        {
            _serverSocket = new ServerSocket;
            _serverSocket.addEventListener(Event.CONNECT, socket_connect);
            _serverSocket.bind(SOCKET_PORT);
            _serverSocket.listen();
        }

        private function socket_connect(e:ServerSocketConnectEvent) :void
        {
            _log("New incoming connection");

            var sock:Socket = e.socket;
            sock.addEventListener(ProgressEvent.SOCKET_DATA, socketListener(sock));
            _sockets.push(sock);
        }

        private function socketListener(sock:Socket) :Function
        {
            return function (e:ProgressEvent) :void {
                _log("Data received on socket...");
                _log(sock.readUTF());
            }
        }

        private function broadcast(msg:String) :void
        {
            _log("Writing "+msg);
            for each (var sock:Socket in _sockets) {
                sock.writeUTF(msg);
                sock.flush();
            }
        }

        public function connect(thisIP:String, ips:Vector.<String>) :Function
        {
            var ipsArray :Array = [];
            for each (var ip:String in ips) {
                ipsArray.push(ip);
            }
            ipsArray.sort();

            var thisIndex :int = ipsArray.indexOf(thisIP);

            if (thisIndex === 0) {
                _serverSocket.close();
            }

            for (var i:int = thisIndex + 1; i < ipsArray.length; ++i) {
                _log("Making outgoing connection to "+ipsArray[i]);
                var sock:Socket = new Socket(ipsArray[i], SOCKET_PORT);
                sock.addEventListener(ProgressEvent.SOCKET_DATA, socketListener(sock));
                _sockets.push(sock);
            }
            // TODO use callback or even to not return Match until all the sockets have connected.

            return broadcast;
        }
    }
}
