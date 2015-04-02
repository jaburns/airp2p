package net.jaburns.airp2p
{
    public interface IClient
    {
        function readInput() :Object;
        function notifyGameState(state:Object) :void;
    }
}
