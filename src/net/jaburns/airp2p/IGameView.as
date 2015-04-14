package net.jaburns.airp2p
{
    public interface IGameView
    {
        function notifyConnected(connected:Boolean) :void;
        function readInput() :Object;
        function update(model:Object) :void;
    }
}
