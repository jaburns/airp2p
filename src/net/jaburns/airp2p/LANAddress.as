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
            // Local network IP address ranges
            //    Class A    10.  0.0.0 -  10.255.255.255
            //    Class B   172. 16.0.0 - 172. 31.255.255
            //    Class C   192.168.0.0 - 192.168.255.255

            for each (var ip:String in ips) {
                if (ip.indexOf("192.168") === 0) return ip;
            }
            return null;
        }
    }
}
