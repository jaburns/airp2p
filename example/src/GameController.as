package
{
    import model.GameState;
    import model.PlayerState;

    import net.jaburns.airp2p.IGameController;
    import model.InputState;

    public class GameController implements IGameController
    {
        public function update(modelObj:Object, inputsByIP:Object):void
        {
            var state :GameState = modelObj as GameState;

            // Add new players to the game if we're seeing a new IP in the inputs collection.
            for (var ip:String in inputsByIP) {
                if (state.players[ip] === undefined) {
                    state.players[ip] = createPlayer();
                }
            }

            // Remove players from the game whose IP is now missing from the inputs collection.
            for (ip in state.players) {
                if (inputsByIP[ip] === undefined) {
                    delete state.players[ip];
                }
            }

            state.time += 1.0;

            for (ip in state.players) {
                updatePlayer(state, state.players[ip], inputsByIP[ip]);
            }
        }

        static private function createPlayer() :PlayerState
        {
            var player :PlayerState = new PlayerState;
            player.x = 100 + 500*Math.random();
            player.y = 300 + 300*Math.random();
            player.timeOffset = 100*Math.random();
            return player;
        }

        static private function updatePlayer(state:GameState, player:PlayerState, input:InputState) :void
        {
            player.x += 2*Math.sin(player.timeOffset + state.time / 20);
            player.y += 2*Math.cos(player.timeOffset + state.time / 20);
            player.squished = input.tapping;
        }
    }
}
