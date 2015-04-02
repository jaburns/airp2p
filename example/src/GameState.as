package
{
    public class GameState
    {
        // Dictionary of Player objects indexed by IP.
        public var players :Object = {};

        // Keeps track of the time since the game session was started.
        public var time :Number = 0;


        public function update(inputsByIP:Object) :void
        {
            // Add new players to the game if we're seeing a new IP in the inputs collection.
            for (var ip:String in inputsByIP) {
                if (players[ip] === undefined) {
                    players[ip] = new Player;
                }
            }

            // Remove players from the game whose IP is now missing from the inputs collection.
            for (ip in players) {
                if (inputsByIP[ip] === undefined) {
                    delete players[ip];
                }
            }

            time += 1.0;

            for (ip in players) {
                players[ip].update(time, inputsByIP[ip]);
            }
        }
    }
}
