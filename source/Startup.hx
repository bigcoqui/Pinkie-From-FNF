package;

import animateatlas.AtlasFrameMaker;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.text.FlxText;
import openfl.display.BitmapData;
import sys.FileSystem;
import flixel.FlxG;
import haxe.ds.Map;
import openfl.utils.Assets;

using StringTools;

class Startup extends MusicBeatState
{
	public var atlist = [
	'characters/discord_assets',
	'characters/discord_end'
	];
    public static var atlasFrames:Map<String, FlxFramesCollection> = new Map<String, FlxFramesCollection>();
	public static var indx = 0;
	public static var screen = 0;
	public static var loaded = false;
    var musicDone:Bool = false;
    var atlasDone:Bool = false;

    var loadingText:FlxText;

	override function create()
	{
		if (!loaded){
			screen = FlxG.random.int(0, 7);
		}
		    loaded = true;
        FlxG.mouse.visible = false;
        var loadingBG = new FlxSprite(0.0).loadGraphic(Paths.image('loadingscreen'+screen));
        loadingBG.antialiasing = true;
        add(loadingBG);
        loadingBG.scale.set(1280/loadingBG.width,1280/loadingBG.width);
        loadingBG.screenCenter();

        loadingText = new FlxText(5, FlxG.height - 30, 0, "Preloading Assets...", 24);
        loadingText.setFormat("assets/fonts/vcr.ttf", 24, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        add(loadingText);

        preloadAtlas();
			  indx ++;
	
        super.create();
    }

    override function update(elapsed) 
    {
			if (indx>=atlist.length)
				loadingText.text = "Done!";

       if (atlasDone)
        {
			if (indx>=atlist.length){
				FlxG.switchState(new TitleState());
			}else{
				FlxG.switchState(new Startup());
			}
        }
        super.update(elapsed);
    }

    function preloadMusic():Void{
        var music = [];
        var list = Assets.list();

        var daSongPath = list.filter(text -> text.contains('assets/songs'));

        for (i in daSongPath)
            {
                music.push(i);
            }

        for (i in music)
            {
                FlxG.sound.cache(Paths.inst(i));
                trace("cached " + i);
            }
        musicDone = true;
    }

    function preloadAtlas():Void{
			var boobers:FlxFramesCollection = AtlasFrameMaker.construct('assets/shared/images/' + atlist[indx]);

    atlasFrames.set(atlist[indx], boobers);
		trace(atlist[indx]);
		var testsprite:FlxSprite = new FlxSprite(1280, 1280);
		testsprite.frames = atlasFrames.get(atlist[indx]);
		add(testsprite);
    atlasDone = true;
  }
}