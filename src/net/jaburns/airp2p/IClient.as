package net.jaburns.airp2p
{
    public interface IClient
    {
        function readInputState() :Object;
        function renderGameState(state:Object) :void;
    }
}
