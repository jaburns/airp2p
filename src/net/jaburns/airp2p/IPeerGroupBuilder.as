package net.jaburns.airp2p
{
    public interface IPeerGroupBuilder
    {
        function listen() :void;
        function connect(thisIP:String, ips:Vector.<String>, ready:Function) :void;
    }
}
