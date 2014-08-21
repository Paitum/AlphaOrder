package {

import flash.system.Capabilities;
import starling.errors.AbstractClassError;

public class Constants {
    public function Constants() { throw new AbstractClassError(); }

    public static const DEFAULT_FONT:String = "Souses";

    private static const DEVICE_TYPE_IPHONE:String = "iphone";
    private static const DEVICE_TYPE_IPAD:String = "ipad";
    private static const DEVICE_TYPE_IPOD:String = "ipod";

    private static var deviceInfo_cache:Object = null;

    public static function getDeviceInfo():Object {
        if(deviceInfo_cache) {
            return deviceInfo_cache;
        }

        var os:String = Capabilities.os.toLowerCase();

//        os = "iPhone6,1".toLowerCase();

        var device:Object = {};
        device.type = "UNKNOWN";

        var match:Array = os.match(/(iphone|ipad|ipod)(\d+),(\d+)/i);

        if(match) {
            device.type = match[1];
            device.major = int(match[2]);
            device.minor = int(match[3]);

            var major:int = device.major;
            var minor:int = device.minor;

            if(DEVICE_TYPE_IPHONE == device.type) {
                device.model = "iPhone";

                if(major == 1 && minor == 1) device.model += " 1";
                else if(major == 1 && minor == 2) device.model += " 3G";
                else if(major == 2) device.model += " 3GS";
                else if(major == 3) device.model += " 4";
                else if(major == 4) device.model += " 4S";
                else if(major == 5 && minor <= 2) device.model += " 5";
                else if(major == 5 && minor > 2) device.model += " 5C";
                else if(major == 6) device.model += " 5S";

                if(major <= 2) {
                    device.longEdge = 480;
                    device.shortEdge = 320;
                    device.ppi = 163;
                    device.scale = 1;
                } else if(major <= 4) {
                    device.longEdge = 960;
                    device.shortEdge = 640;
                    device.ppi = 326;
                    device.scale = 2;
                } else {
                    device.longEdge = 1136;
                    device.shortEdge = 640;
                    device.ppi = 326;
                    device.scale = 2;
                }
            } else if(DEVICE_TYPE_IPAD == device.type) {
                device.model = "iPad";

                if(major == 1) device.model += " 1";
                else if(major == 2 && minor <= 4) device.model += " 2";
                else if(major == 2 && minor > 4) device.model += " Mini 1";
                else if(major == 3 && minor <= 3) device.model += " 3";
                else if(major == 3 && minor > 3) device.model += " 4";
                else if(major == 4 && minor <= 3) device.model += " Air";
                else if(major == 4 && minor > 3) device.model += " Mini 2";

                if(major <= 2) { // iPad 1, 2, and Mini 1
                    device.longEdge = 1024;
                    device.shortEdge = 768;
                    device.ppi = 132;
                    device.scale = 1;
                } else { // iPad 3, 4, and Mini 2
                    device.longEdge = 2048;
                    device.shortEdge = 1536;
                    device.ppi = 264;
                    device.scale = 2;
                }
            } else if(DEVICE_TYPE_IPOD == device.type) {
                device.model = "iPod";

                if(major == 1) device.model += " Touch 1";
                else if(major == 2) device.model += " Touch 2";
                else if(major == 3) device.model += " Touch 3";
                else if(major == 4) device.model += " Touch 4";
                else if(major == 5) device.model += " Touch 5";

                if(major <= 2) {
                    device.longEdge = 480;
                    device.shortEdge = 320;
                    device.ppi = 163;
                    device.scale = 1;
                } else if(major <= 4) {
                    device.longEdge = 960;
                    device.shortEdge = 640;
                    device.ppi = 326;
                    device.scale = 2;
                } else {
                    device.longEdge = 1136;
                    device.shortEdge = 640;
                    device.ppi = 326;
                    device.scale = 2;
                }
            }
        }

        if(device.type == "UNKNOWN") {
            device.model = "UNKNOWN";
            device.major = -1;
            device.minor = -1;
            device.longEdge = 640;
            device.shortEdge = 480;
            device.ppi = 160;
            device.scale = 1;
        }

        if(os.match(/windows/)) {
            device.model = "Windows";
            device.isDesktop = true;
        } else {
            device.isDesktop = false;
        }

        trace("Constants.getDeviceInfo: [" + os + "] [" + device.model + "/(" + device.longEdge + "x" + device.shortEdge + ":" + device.ppi + ":" + device.scale + "x)]");

        deviceInfo_cache = device;
        return deviceInfo_cache;
    }
}
}
