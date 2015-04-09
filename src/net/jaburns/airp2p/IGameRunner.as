package net.jaburns.airp2p
{
    internal interface IGameRunner
    {
        function start(gameStateClass:Class, clientLogic:IClient, tickLength:Number, log:Function=null) :void;
        function stop() :void;
    }
}
