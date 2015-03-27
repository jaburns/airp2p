package net.jaburns.airp2p
{
    internal class UDPGroupBuilder implements IPeerGroupBuilder
    {
        private var _log :Function;

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

        public function connect(thisIP:String, ips:Vector.<String>, ready:Function):void
        {
            throw new Error("lol");
        }

        public function listen():void
        {
            throw new Error("lol");
        }
    }
}
