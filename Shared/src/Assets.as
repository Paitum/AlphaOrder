package {

import flash.display.Bitmap;
import flash.display.Loader;
import flash.events.IOErrorEvent;
import flash.net.URLLoader;
import flash.net.URLRequest;

import starling.events.Event;
import starling.textures.Texture;

import starling.utils.AssetManager;

/**
 * Assets singleton
 */
public class Assets {

    static public var assets:AssetManager;

//    public static function loadXML(assetName:String, path:String):void {
//        var urlRequest:URLRequest = new URLRequest(path);
//        var loader:URLLoader = new URLLoader(urlRequest);
//        loader.addEventListener(Event.COMPLETE, function(event:Event):void {
//            var xml:XML = XML(loader.data);
//            assets.addXml(assetName, xml);
//        });
//        loader.addEventListener(IOErrorEvent.IO_ERROR, function(event:Event):void {
//            trace("Failed to load xml [" + path + "] asset[" + assetName + "]");
//        });
//    }
//
//    public static function loadTexture(assetName:String, path:String):void {
//        var urlRequest:URLRequest = new URLRequest(path);
//        var loader:Loader = new Loader();
//        loader.load(urlRequest);
//        loader.addEventListener(Event.COMPLETE, function(event:Event):void {
//            var bitmap:Bitmap = loader.content as Bitmap;
//            assets.addTexture(assetName, Texture.fromBitmap(bitmap));
//        });
//        loader.addEventListener(IOErrorEvent.IO_ERROR, function(event:Event):void {
//            trace("Failed to load image [" + path + "] asset[" + assetName + "]");
//        });
//    }


//
//    [Embed(source="../media/multi-resolutions/assets1x.png")]
//    public static const assets1xPNG:Class;
//    [Embed(source="../media/multi-resolutions/assets1x.xml", mimeType="application/octet-stream")]
//    public static const assets1xXML:Class;
//
//    [Embed(source="../media/multi-resolutions/assets5x.png")]
//    public static const assets5xPNG:Class;
//    [Embed(source="../media/multi-resolutions/assets5x.xml", mimeType="application/octet-stream")]
//    public static const assets5xXML:Class;
}
}
