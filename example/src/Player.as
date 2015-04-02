package 
{
    public class Player
    {
        public var x :Number;
        public var y :Number;
        public var squished :Boolean;

        public function Player()
        {
            x = 500 + 200*Math.random();
            y = 100 + 600*Math.random();
        }

        public function update(input:InputState) :void
        {
            squished = input.tapping;
        }
    }
}
