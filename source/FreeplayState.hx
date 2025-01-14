package;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.utils.Assets;
import openfl.utils.Assets as OpenFlAssets;
import Options;
import AttachedFlxText;
import sys.FileSystem;

using StringTools;

class FreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];

	var selector:FlxText;
	var curSelected:Int = 0;
	var curDifficulty:Int = 1;

	var scoreText:FlxText;
	var diffText:FlxText;
	var lerpScore:Int = 0;
	var intendedScore:Int = 0;
	var context:Bool = false;

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];
	public var dirs = [];
	public var vinyl:FlxSprite;
	public var contextBoard:FlxSprite;
	public var speakers:FlxSprite;
	public var contexttxt:AttachedFlxText;
	override function create()
	{
		
		var initSonglist = CoolUtil.coolTextFile(Paths.txt('freeplaySonglist'));

		for (i in 0...initSonglist.length)
		{
			var data = initSonglist[i].split(" ");
			var icon = data.splice(0,1)[0];
			songs.push(new SongMetadata(data.join(" "), 1, icon));
			dirs.push("assets");
		}

		for (u in TitleState.directories){
			var bobsongs = CoolUtil.coolTextFile3('mods/' + u + '/data/freeplaySonglist.txt');
			
			for (i in 0...bobsongs.length)
			{
				var data = bobsongs[i].split(" ");
				var icon = data.splice(0,1)[0];
				songs.push(new SongMetadata(data.join(" "), 1, icon));
				dirs.push('mods/'+u);
			}
			TitleState.curDir = "assets";
		}
		
		

			if (FlxG.sound.music != null)
			{
				if (!FlxG.sound.music.playing)
					FlxG.sound.playMusic(Paths.music('freakyMenu'));
			}


		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		var isDebug:Bool = false;

		#if debug
		isDebug = true;
		#end

		// LOAD MUSIC

		// LOAD CHARACTERS

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuBGBlue'));
		add(bg);

		
		
		
		
		add(CoolUtil.addSprite( -67.5, -84.6, "freeplaymenu/bg", 0));
		add(speakers = CoolUtil.addAnimPrefix(515, 188, "freeplaymenu/speakers", "speakers", 0, false));
		vinyl = CoolUtil.addAnimIndices(664,223, "freeplaymenu/vinyl", "vinyl", Character.numArr(0, 19), 0, false);
		vinyl.animation.addByIndices('button', 'vinyl', Character.numArr(20, 29), '', 24, false);
		add(vinyl);
		var light = CoolUtil.addSprite(567, -189, "freeplaymenu/light", 0);
		light.blend = 'add';
		contextBoard = CoolUtil.addSprite(696,-373, "freeplaymenu/contextBoard", 0);
		add(light);
		contexttxt = new AttachedFlxText(30.15, 223.25, 498.85, "No Context.", 30);
		contexttxt.font = "Woodrow W00 Reg";
		contexttxt.antialiasing = true;
		contexttxt.color = 0xff663333;
		contexttxt.xAdd = 30;
		contexttxt.yAdd = 223;
		contexttxt.sprTracker = contextBoard;
		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		
		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].songName.split("-").join(" "), true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpSongs.add(songText);
			TitleState.curDir = dirs[i];
			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;

			// using a FlxGroup is too much fuss!
			iconArray.push(icon);
			add(icon);

			// songText.x += 40;
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			// songText.screenCenter(X);
		}
		TitleState.curDir = "assets";
		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		// scoreText.autoSize = false;
		scoreText.setFormat(Paths.font("Woodrow W00 Reg.ttf"), 32, FlxColor.WHITE, RIGHT);
		// scoreText.alignment = RIGHT;

		add(contextBoard);
		add(contexttxt);
		var scoreBG:FlxSprite = new FlxSprite(scoreText.x - 6, 0).makeGraphic(Std.int(FlxG.width * 0.35), 66, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		add(diffText);

		add(scoreText);

		changeSelection();
		changeDiff();

		// FlxG.sound.playMusic(Paths.music('title'), 0);
		// FlxG.sound.music.fadeIn(2, 0, 0.8);
		selector = new FlxText();

		selector.size = 40;
		selector.text = ">";
		// add(selector);

		var swag:Alphabet = new Alphabet(1, 0, "swag");

		// JUST DOIN THIS SHIT FOR TESTING!!!
		/*
			var md:String = Markdown.markdownToHtml(Assets.getText('CHANGELOG.md'));

			var texFel:TextField = new TextField();
			texFel.width = FlxG.width;
			texFel.height = FlxG.height;
			// texFel.
			texFel.htmlText = md;

			FlxG.stage.addChild(texFel);

			// scoreText.textField.htmlText = md;

			trace(md);
		 */

		add(CoolUtil.addSprite(0, 649, "freeplaymenu/controls", 0));
		super.create();
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter));
	}

	public function addWeek(songs:Array<String>, weekNum:Int, ?songCharacters:Array<String>)
	{
		if (songCharacters == null)
			songCharacters = ['bf'];

		var num:Int = 0;
		for (song in songs)
		{
			addSong(song, weekNum, songCharacters[num]);

			if (songCharacters.length != 1)
				num++;
		}
	}
	override public function beatHit():Void 
	{
		super.beatHit();
		
				speakers.animation.play('speakers',true);
		
		if(vinyl.animation.curAnim.name == 'vinyl') vinyl.animation.play('vinyl',true);
	}
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}
		if (FlxG.sound.music != null){
			Conductor.songPosition = FlxG.sound.music.time;
		}
		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.4));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;

		scoreText.text = "PERSONAL BEST:" + lerpScore;

		var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var accepted = controls.ACCEPT;

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}
		if (FlxG.keys.justPressed.SHIFT)
		{
			context = !context;
				vinyl.animation.play('button');
			new FlxTimer().start(4/24, function(e:FlxTimer){
			FlxTween.tween(contextBoard, {y: context?-98.55:-373.5}, 1, {ease:FlxEase.backInOut});
			
			new FlxTimer().start(10/24, function(e:FlxTimer){
				
				vinyl.animation.play('vinyl',false,false,10);
			});
			});
		}

		if (controls.LEFT_P)
			changeDiff(-1);
		if (controls.RIGHT_P)
			changeDiff(1);

		if (controls.BACK)
		{
			FlxG.switchState(new MainMenuState());
		}

		if (accepted)
		{
			var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), curDifficulty);

			trace(poop);

			
			if (FlxG.keys.pressed.CONTROL){
				FlxG.switchState(new StageDebug("discord"));
			}else{
				
				PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());
				PlayState.isStoryMode = false;
				PlayState.storyDifficulty = curDifficulty;

				PlayState.storyWeek = songs[curSelected].week;
				trace('CUR WEEK' + PlayState.storyWeek);
				if (FlxG.keys.pressed.SHIFT){
					FlxG.switchState(new ChartingState());
				}else{
					LoadingState.loadAndSwitchState(new PlayState());
				}
			}
		}
	}

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = 2;
		if (curDifficulty > 2)
			curDifficulty = 0;
			
		var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), curDifficulty);
		if (!OpenFlAssets.exists(TitleState.curDir+'/data/'+songs[curSelected].songName.toLowerCase()+'/'+poop+'.json')){
			curDifficulty = 1;
		}
		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		#end
		
		switch (curDifficulty)
		{
			case 0:
				diffText.text = "EASY";
			case 1:
				diffText.text = 'NORMAL';
			case 2:
				diffText.text = "HARD";
		}
	}

	function changeSelection(change:Int = 0)
	{
		#if !switch
		//NGio.logEvent('Fresh');
		#end

		// NGio.logEvent('Fresh');
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		// selector.y = (70 * curSelected) + 30;

		TitleState.curDir = dirs[curSelected];
		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		// lerpScore = 0;
		#end
		contexttxt.text = Paths.getTextFile(TitleState.curDir + "/data/" + songs[curSelected].songName.toLowerCase() + "/context.txt", true);
		changeDiff(0);
		if(OptionUtils.options.freeplayPreview){
			#if PRELOAD_ALL
				FlxG.sound.playMusic(Paths.inst(songs[curSelected].songName.toLowerCase()), 0);
				var bpm = Song.loadFromJson(songs[curSelected].songName.toLowerCase(), songs[curSelected].songName.toLowerCase()).bpm;
				Conductor.changeBPM(bpm);
			#end
		}

		var bullShit:Int = 0;

		for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.6;
		}

		iconArray[curSelected].alpha = 1;

		for (item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";

	public function new(song:String, week:Int, songCharacter:String)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
	}
}
