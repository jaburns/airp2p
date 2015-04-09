package net.jaburns.airp2p
{
    internal interface IGameRunner
    {
        function start(gameStateClass:Class, clientLogic:IClient, tickRate:TickRate, log:Function=null) :void;
        function stop() :void;
    }
}
