package net.jaburns.airp2p
{
    public interface IHost
    {
        function stepGame(inputs:Object) :void;
        function getState() :Object;
        function forceState(state:Object) :void;
    }
}
