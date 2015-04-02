package net.jaburns.airp2p
{
    import flash.utils.ByteArray;
    import flash.utils.getQualifiedClassName;

    public class Interpolate
    {
        static public function genPaths(...paths) :Vector.<Vector.<String>>
        {
            var ret :Vector.<Vector.<String>> = new <Vector.<String>> [];

            for each (var path:String in paths) {
                ret.push(Vector.<String>(path.split(".")));
            }

            return ret;
        }

        static public function preserveType(t:Number, a:Object, b:Object, fieldPaths:Vector.<Vector.<String>>) :Object
        {
            if (t < 0) t = 0;

            var ba:ByteArray = new ByteArray;
            ba.writeObject(b);
            ba.position = 0;
            var ret:Object = ba.readObject();

            for each (var path:Vector.<String> in fieldPaths) {
                _preserveType(t, a, b, ret, path.slice());
            }

            return ret;
        }

        static private function _preserveType(t:Number, a:Object, b:Object, ret:Object, path:Vector.<String>) :void
        {
            if (a === null || b === null) return;

            while (path.length > 1) {
                var pathItem:String = path.shift();

                if (pathItem === "*") {
                    var typeName:String = getQualifiedClassName(a);

                    if (typeName.substr(0, 19) == "__AS3__.vec::Vector" ||  typeName === "Array" ||  typeName === "Object") {
                        for (var k:* in a) {
                            _preserveType(t, a[k], b[k], ret[k], path);
                        }
                        return;
                    }
                }

                a = a[pathItem];
                b = b[pathItem];
                ret = ret[pathItem];
            }

            ret[path[0]] = interpolateNumber(t, a[path[0]], b[path[0]]);
        }

        static private function interpolateNumber(t:Number, a:Number, b:Number) :Number
        {
            return a + (b-a)*t;
        }
    }
}
