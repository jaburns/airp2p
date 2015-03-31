package net.jaburns.airp2p
{
    public interface IClient
    {
        function readInputs() :Object;
        function renderState(state:Object) :void;
    }
}
