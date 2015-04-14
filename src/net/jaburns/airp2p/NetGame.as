package net.jaburns.airp2p
{
    import flash.net.registerClassAlias;
    import flash.utils.describeType;
    import flash.utils.getQualifiedClassName;
    import flash.utils.getTimer;

    public class NetGame
    {
        static private var s_runner :IGameRunner = null;

        static public function registerModelTypes(...args) :void
        {
            for each (var klass:Class in args) {
                registerClassAlias(getQualifiedClassName(klass), klass);
            }
        }

        static public function start(
            online:Boolean,
            modelClass:Class,
            controllerClass:Class,
            viewInstance:IGameView,
            tickRate:TickRate,
            log:Function=null
        ) :void
        {
            if (s_runner !== null) {
                throw new Error ("NetGame has already been started");
            }

            if (online) {
                s_runner = new NetGameRunner;
                Platform.start();
            } else {
                s_runner = new OfflineGameRunner;
            }

            s_runner.start(modelClass, controllerClass, viewInstance, tickRate, log);
        }

        static public function stop() :void
        {
            if (s_runner === null) return;
            s_runner.stop();
            s_runner = null;

            Platform.stop();
        }
    }
}
