package animateatlas;
import flixel.FlxSprite;
import flixel.util.FlxDestroyUtil;
import openfl.geom.Rectangle;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import openfl.Assets;
import haxe.Json;
import openfl.display.BitmapData;
import animateatlas.JSONData.AtlasData;
import animateatlas.JSONData.AnimationData;
import animateatlas.displayobject.SpriteAnimationLibrary;
import animateatlas.displayobject.SpriteMovieClip;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.graphics.frames.FlxFrame;
import sys.io.File;

using StringTools;

class AtlasFrameMaker extends FlxFramesCollection{
        public static function construct(key:String,?_excludeArray:Array<String> = null):FlxFramesCollection{

                var frameCollection:FlxFramesCollection;
                var frameArray:Array<Array<FlxFrame>> = [];
                var animationData:AnimationData = Json.parse(Paths.getTextFile(key + "/Animation.json"));
                var atlasData:AtlasData = Json.parse(Paths.getTextFile(key + "/spritemap.json").replace("\uFEFF", ""));//FIXED UTF8 w/ BOM error

				var graphic:FlxGraphic = Paths.getbmp(key+'/spritemap',false);
				var testsprite:FlxSprite = new FlxSprite(0, 0);
				testsprite.loadGraphic(graphic);
				testsprite.scrollFactor.set();

                var ss = new SpriteAnimationLibrary(animationData, atlasData, graphic.bitmap);
                var t = ss.createAnimation();
                if(_excludeArray == null){
                _excludeArray = t.getFrameLabels();
                }
                frameCollection = new FlxFramesCollection(graphic,FlxFrameCollectionType.IMAGE);

                for(x in t.getFrameLabels()){
                        frameArray.push(getFramesArray(t, x,_excludeArray));
                }

                for(x in frameArray){
                        for(y in x){
                     frameCollection.pushFrame(y);
                        }
                }
                return frameCollection;
        }

        @:noCompletion static function getFramesArray(t:SpriteMovieClip,animation:String,_excludeArray:Array<String>):Array<FlxFrame>
        {
                var sizeInfo:Rectangle = new Rectangle(0,0);
                t.currentLabel = animation;
                var bitMapArray:Array<BitmapData> = [];
                var daFramez:Array<FlxFrame> = [];
                var firstPass = true;
                var frameSize:FlxPoint = new FlxPoint(0,0);

                for (i in t.getFrame(animation)...t.numFrames){
                        t.currentFrame = i;
                        if (t.currentLabel == animation){
                                if (_excludeArray.contains(animation)){
                                        sizeInfo = t.getBounds(t);

                     var bitmapShit:BitmapData = new BitmapData(
                     Std.int(sizeInfo.width + Math.abs(sizeInfo.x)),Std.int(sizeInfo.height +Math.abs(sizeInfo.y)),true,0);

                     bitmapShit.draw(t,null,null,null,null,true);
                     bitMapArray.push(bitmapShit);

                     if (firstPass){
                     frameSize.set(bitmapShit.width,bitmapShit.height);
                     firstPass = false;
                                        }
                                }
                        }
                        else break;
                }

                for (i in 0...bitMapArray.length){
                 var b = FlxGraphic.fromBitmapData(bitMapArray[i]);
                 var theFrame = new FlxFrame(b);
                 theFrame.parent = b;
                 theFrame.name = animation + i;
                 theFrame.sourceSize.set(frameSize.x,frameSize.y);
                 theFrame.frame = new FlxRect(0, 0, bitMapArray[i].width, bitMapArray[i].height);
                 daFramez.push(theFrame);
                }
                return daFramez;
        }
}