package net.jaburns.airp2p
{
    internal interface IGameRunner
    {
        function start(
            modelClass:Class,
            controllerClass:Class,
            viewInstance:IGameView,
            tickRate:TickRate,
            log:Function=null
        ):void;

        function stop() :void;
    }
}
