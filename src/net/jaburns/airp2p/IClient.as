package net.jaburns.airp2p
{
    public interface IClient
    {
        function notifyConnected(connected:Boolean) :void;
        function readInput() :Object;
        function notifyGameState(state:Object) :void;
    }
}
