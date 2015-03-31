package net.jaburns.airp2p
{
    public interface IHost
    {
        function step(inputs:Object) :void;
        function getState() :Object;
        function setState(state:Object) :void;
    }
}
