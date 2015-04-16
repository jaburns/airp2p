package net.jaburns.airp2p
{
    internal interface IGameRunner
    {
        function start(
            modelClass :Class,
            controller :IGameController,
            view :IGameView,
            tickRate :TickRate,
            log :Function=null
        ):void;

        function stop() :void;
    }
}
