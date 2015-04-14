package model
{
    import net.jaburns.airp2p.Interpolate;

    public class GameState
    {
        static public const interpolationPaths :Vector.<Vector.<String>> = Interpolate.genPaths(
            "players.*.x",
            "players.*.y"
        );

        public var players :Object = {};
        public var time :Number = 0;
    }
}
