package net.jaburns.airp2p
{
    import flash.net.registerClassAlias;
    import flash.utils.describeType;
    import flash.utils.getQualifiedClassName;
    import flash.utils.getTimer;

    public class NetGame
    {
        static private var s_runner :IGameRunner = null;

        static public function registerTypes(...args) :void
        {
            // Instead of requiring the user to provide all types which are going to be serialized
            // we can do describeType(GameState) and recursively walk the types of the public
            // fields while calling registerClassAlias(typeName, getDefinitionByName(typeName)).
            // That, of course, is more complex than asking for a list of used types, but it would be nice.

            for each (var klass:Class in args) {
                registerClassAlias(getQualifiedClassName(klass), klass);
            }
        }

        static public function start(gameStateClass:Class, clientLogic:IClient, tickLength:Number, log:Function=null) :void
        {
            if (s_runner !== null) {
                throw new Error ("NetGame has already been started");
            }

            s_runner = new NetGameRunner;
            s_runner.start(gameStateClass, clientLogic, tickLength, log);

            Platform.start();
        }

        static public function startOffline(gameStateClass:Class, clientLogic:IClient, tickLength:Number, log:Function=null) :void
        {
            if (s_runner !== null) {
                throw new Error ("NetGame has already been started");
            }

            s_runner = new OfflineGameRunner;
            s_runner.start(gameStateClass, clientLogic, tickLength, log);
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
