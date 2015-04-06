package net.jaburns.airp2p
{
    public interface IClient
    {
        function notifyConnected() :void;
        function readInput() :Object;
        function notifyGameState(state:Object) :void;
    }
}
