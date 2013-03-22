package
{		
	import com.greensock.TweenMax;
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.ImageLoader;
	import com.greensock.loading.LoaderMax;
	import com.greensock.loading.MP3Loader;
	import com.greensock.loading.VideoLoader;
	import com.greensock.loading.XMLLoader;
	import com.greensock.loading.display.ContentDisplay;
	
	import f4.Player;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import flash.system.Security;
	
	import fsharp.ui.PhoneUI;

	[SWF(width="900", height="500", backgroundColor="#ffffff", frameRate="30")]
	
	public class VideoPhone extends Sprite
	{
		private var xmlPath : String = "../asset/config.xml";
		private var configXml : XML;
		private var imagePath:String;
		private var imageList:Array;
		private var videoPath:String;
		private var audioPath:String;
		private var i:Number;
		private var phoneHolder:PhoneUI;
		private var currentPhoneFrame:Number = 0;
		private var currentPhoneMouseX:Number = -1;
		//keeps track of the VideoLoader that is currently playing
		private var _currentVideo:VideoLoader;
		
		private const imageWidth:Number = 823;
		private const imageHeight:Number = 427;
		private var video:Video;
		private var videoHolder:Sprite;
		private var angle:Number = 0;
		private var speed:Number = 5;

		
		var context1:LoaderContext = new LoaderContext();
		var req:URLRequest = new URLRequest("http://graph.facebook.com/" + "" + "/picture?type=large");

		
		public function VideoPhone()
		{
			Security.loadPolicyFile("http://graph.facebook.com/crossdomain.xml");
			Security.allowDomain("*");
			Security.allowInsecureDomain("*");
			
			context1.checkPolicyFile = true;
			
			LoaderMax.activate([XMLLoader, ImageLoader, MP3Loader, VideoLoader]);
			
			var loader:XMLLoader = new XMLLoader(xmlPath, {name:"configXML", onComplete:onXMLLoaded});
			loader.load();
		}
		
		private function onXMLLoaded(event:LoaderEvent):void {
			
			var queue:LoaderMax = new LoaderMax({name:"mainQueue", onProgress:progressHandler, onComplete:onAllLoaded, onError:errorHandler});
			
			configXml = LoaderMax.getContent("configXML");
			
			videoPath = configXml.video.@loc;
			audioPath = configXml.audio.@loc;
			trace(configXml.images.@loc);
			var totalImgNum:Number = Number(configXml.images.@total);
			for (i = 0; i < totalImgNum; i++) {
				//append the ImageLoader and several other loaders
				queue.append( new ImageLoader(String(configXml.images.@loc) + (Number(configXml.images.@start) + i) + configXml.images.@type, {name:"image"+i, container:this, x:0, y:0, width:imageWidth, height:imageHeight, scaleMode:"proportionalInside", centerRegistration:false, noCache:false}) );
				
			}
			imageList = new Array(totalImgNum-1);
			
			//start loading
			queue.load();
			
		}
		
		private function progressHandler(event:LoaderEvent):void {
			trace("progress: " + event.target.progress);
		}
		
		private function completeHandler(event:LoaderEvent):void {
			var image:ContentDisplay = LoaderMax.getContent("photo1");
			TweenMax.to(image, 1, {alpha:1, y:100});
			trace(event.target + " is complete!");
		}
		
		private function errorHandler(event:LoaderEvent):void {
			trace("error occured with " + event.target + ": " + event.text);
		}
		
		private function onXMLFailed(e:Event):void {
			trace("xml failed to load");
		}
		private function onAllLoaded(e:LoaderEvent):void {
			phoneHolder = new PhoneUI();
			addChild(phoneHolder);
			
			for (i = 0; i < imageList.length; i++) {
				imageList[i] = LoaderMax.getContent("image"+i);
				//TweenMax.to(imageList[i], 3, {alpha:.4});
			}
			
			phoneHolder.init(imageList);
			phoneHolder.showPhoneFrame(currentPhoneFrame);
			video = new Video();
			video.width = 626;
			video.height = 362;
			videoHolder = new Sprite;
			videoHolder.addChild(video);
			phoneHolder.addChild(videoHolder);
			
			var nc:NetConnection = new NetConnection();
			nc.connect(null);
			
			var ns:NetStream = new NetStream(nc);
			ns.client = {onMetaData:ns_onMetaData, onCuePoint:ns_onCuePoint};
			
			video.attachNetStream(ns);
			ns.play("http://content.bitsontherun.com/videos/XtyoLQuV-RyDNOtym.mp4");
			//videoHolder.transform.perspectiveProjection.fieldOfView=55;

			phoneHolder.initHitArea();
			
			phoneHolder.addEventListener(MouseEvent.MOUSE_DOWN, onPhoneOver);
			phoneHolder.addEventListener(MouseEvent.MOUSE_OUT, onPhoneOut);
			phoneHolder.addEventListener(MouseEvent.MOUSE_UP, onPhoneOut);
			return;
			/*
			var player = new Player();
			var skin = new videoSkin();
			skin.initialization(player, 300, 200, "http://content.bitsontherun.com/videos/XtyoLQuV-RyDNOtym.mp4","", true);
			phoneHolder.addChild(skin);
return;
			var movie:Video = player.Movie(300,200);
			player.Play("http://content.bitsontherun.com/videos/XtyoLQuV-RyDNOtym.mp4");
			
			return;
			//get the LoaderMax named "videoListLoaded" which was inside our XML
			var queue:LoaderMax = LoaderMax.getLoader("videoListLoader");
			
			//start loading the queue of VideoLoaders (they will load in sequence)
			queue.load();
			
			//show the first video
			showVideo(queue.getChildren()[0]);
			*/
		}
		
		private function showVideo(video:VideoLoader):void {
			
			phoneHolder.addEventListener(MouseEvent.MOUSE_DOWN, onPhoneOver);
			phoneHolder.addEventListener(MouseEvent.MOUSE_OUT, onPhoneOut);
			phoneHolder.addEventListener(MouseEvent.MOUSE_UP, onPhoneOut);
			
			//set the _currentLoader variable so that it refers to the new video.
			_currentVideo = video;
			
			//start playing the video from its beginning
			_currentVideo.gotoVideoTime(0, true);
			
			//when we addChild() the VideoLoader's content, it makes it rise to the top of the stacking order
			phoneHolder.addChild(_currentVideo.content);
			phoneHolder.initHitArea();
			//fade the VideoLoader's content alpha in. Remember, the "content" refers to the ContentDisplay Sprite that we see on the stage.
			TweenMax.to(_currentVideo.content, 0.8, {autoAlpha:1});
			
		}
		
		private function ns_onMetaData(item:Object):void {
			trace("metaData");
			// Resize video instance.
			//video.width = item.width;
			//video.height = item.height;
			// Center video instance on Stage.
			video.x = (stage.stageWidth - video.width) / 2;
			video.y = (stage.stageHeight - video.height) / 2;
			video.x = 100;
			video.y = 20;
		}
		
		private function ns_onCuePoint(item:Object):void {
			trace("cuePoint");
			trace(item.name + "\t" + item.time);
		}
		
		private function onPhoneOver(e:MouseEvent):void {
			trace("onPhoneOver");
			phoneHolder.addEventListener(MouseEvent.MOUSE_MOVE, onPhoneMove);			
		}
		private function onPhoneOut(e:MouseEvent):void {
			trace("onPhoneOut");
			phoneHolder.removeEventListener(MouseEvent.MOUSE_MOVE, onPhoneMove);
		}
		private function onPhoneMove(e:MouseEvent):void {
			trace("onPhoneMove");
			if (currentPhoneMouseX > 0) {
				if (mouseX > currentPhoneMouseX) {
					//rotate right
					currentPhoneFrame++;
					start3DRotate(-5);
				} else {
					//rotate left
					currentPhoneFrame--;
					start3DRotate(5);
				}
			} else {
				//Intial Move
				currentPhoneMouseX = mouseX;
				return;
			}
			currentPhoneMouseX = mouseX;
			if (currentPhoneFrame >= imageList.length) {
				currentPhoneFrame = 0;
			} else if (currentPhoneFrame < 0) {
				currentPhoneFrame = imageList.length - 1;
			}
			phoneHolder.showPhoneFrame(currentPhoneFrame);
		}
		private function start3DRotate(speed):void
		{
			angle<360? angle+=speed : angle = 0;
			videoHolder.rotationY = angle;
		}

	}
}