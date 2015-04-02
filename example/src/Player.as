package
{
    public class Player
    {
        public var x :Number;
        public var y :Number;
        public var squished :Boolean;

        public function Player()
        {
            x = 100 + 500*Math.random();
            y = 300 + 300*Math.random();
        }

        public function update(input:InputState) :void
        {
            squished = input.tapping;
        }
    }
}
