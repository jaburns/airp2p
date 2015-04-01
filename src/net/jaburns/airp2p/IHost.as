package net.jaburns.airp2p
{
    public interface IHost
    {
        function step(inputs:Object) :void;
        function getState() :Object;

        // Currently unused, host migration will use this to set host state from a client.
        function setState(state:Object) :void;
    }
}
