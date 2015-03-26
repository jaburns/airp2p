package net.jaburns.airp2p
{
    import flash.utils.getDefinitionByName;

    internal class LANAddress
    {
        static public function find() :String
        {
            return findLocalIP(shouldUseNativeNetworkInfo
                ? getIPsNative()
                : getIPsAIR());
        }

        static private function get shouldUseNativeNetworkInfo() :Boolean
        {
            return !getDefinitionByName("flash.net.NetworkInfo").isSupported;
        }

        static private function getIPsNative() :Vector.<String>
        {
            return getIPsFromInterfaceList(
                getDefinitionByName("com.adobe.nativeExtensions.Networkinfo.NetworkInfo")['networkInfo']['findInterfaces']()
            );
        }

        static private function getIPsAIR() :Vector.<String>
        {
            return getIPsFromInterfaceList(
                getDefinitionByName("flash.net.NetworkInfo")['networkInfo']['findInterfaces']()
            );
        }

        static private function getIPsFromInterfaceList(interfaces:*) :Vector.<String>
        {
            var ret :Vector.<String> = new <String> [];

            for each (var i:Object in interfaces) {
                for each (var a:Object in i.addresses) {
                    ret.push(a.address);
                }
            }

            return ret;
        }

        static private function findLocalIP(ips:Vector.<String>) :String
        {
            var classB :String = null;
            var classC :String = null;

            // Check for standard class B and C subnet IPs in the interface stack.
            for each (var ip:String in ips) {
                if (ip.indexOf("192.168.") === 0) {
                    classC = ip;
                }
                else if (ip.indexOf("172.") === 0) {
                    var secondByte:int = parseInt(ip.substr(4,ip.substr(4).indexOf('.')));
                    if (secondByte >= 16 && secondByte <= 31) {
                        classB = ip;
                    }
                }
            }

            if (classC) return classC;
            return classB;
        }
    }
}
