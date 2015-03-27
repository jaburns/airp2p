package net.jaburns.airp2p
{
    import flash.events.DatagramSocketDataEvent;
    import flash.net.DatagramSocket;
    import flash.utils.ByteArray;

    internal class UDPGroupBuilder implements IPeerGroupBuilder
    {
        static private const SOCKET_PORT :int = 7892;

        private var _log :Function;
        private var _socket :DatagramSocket;
        private var _peerGroup :PeerGroup;
        private var _outgoingIPs :Vector.<String> = null;

        public function UDPGroupBuilder(log:Function)
        {
            if (log !== null) {
                _log = function(msg:String) :void {
                    log("[com.jaburns.airp2p.UDPGroupBuilder] "+msg);
                };
            } else {
                _log = function(msg:String) :void { };
            }
        }

        public function listen():void
        {
            _socket = new DatagramSocket();
            _socket.addEventListener(DatagramSocketDataEvent.DATA, dataReceived);
            _socket.bind(SOCKET_PORT);
            _socket.receive();
        }

        public function connect(thisIP:String, ips:Vector.<String>, ready:Function):void
        {
            _outgoingIPs = ips.slice();
            _outgoingIPs.splice(_outgoingIPs.indexOf(thisIP), 1);

            _peerGroup = new PeerGroup;
            _peerGroup.bindBroadcaster(broadcast);
            ready(_peerGroup);
        }

        private function broadcast(msg:String) :void
        {
            var data :ByteArray = new ByteArray;
            data.writeUTF(msg);

            for each (var ip:String in _outgoingIPs) {
                _socket.send(data, 0, 0, ip, SOCKET_PORT);
            }
        }

        private function dataReceived(e:DatagramSocketDataEvent) :void
        {
            _peerGroup.receive(e.data.readUTF());
        }
    }
}
