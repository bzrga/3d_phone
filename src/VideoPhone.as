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
	import flash.geom.PerspectiveProjection;
	import flash.geom.Point;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import flash.system.Security;
	import flash.text.TextField;
	import flash.utils.*;
	
	import fsharp.ui.PhoneUI;
	import fsharp.ui.TestSlider;

	[SWF(width="800", height="500", backgroundColor="#ffffff", frameRate="30")]
	
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
		
		private const imageWidth:Number = 800;
		private const imageHeight:Number = 500;
		private var videoWidth:Number;
		private var videoHeight:Number;
		
		private var videoX:Number;
		private var videoY:Number;
		
		private var video:Video;
		private var videoHolder:Sprite;
		private var angle:Number = 0;
		private var speed:Number = 5;
		
		private var sliderX:TestSlider;
		private var sliderY:TestSlider;
		private var sliderZ:TestSlider;
		private var sliderFV:TestSlider;
		private var sliderScale:TestSlider;
		private var sliderWidth:TestSlider;
		
		private var rotationXLabel:TextField;
		private var rotationYLabel:TextField;
		private var phoneFrameLabel:TextField;
		
		private var ns:NetStream;
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
			videoX = configXml..videoloader.@videoX;
			videoY = configXml..videoloader.@videoY;
			videoWidth = configXml..videoloader.@width;
			videoHeight = configXml..videoloader.@height;

			var totalImgNum:Number = Number(configXml.images.@total);
			for (i = 0; i < totalImgNum; i++) {
				//append the ImageLoader and several other loaders
				queue.append( new ImageLoader(String(configXml.images.@loc) + (Number(configXml.images.@start) + i) + configXml.images.@type, {name:"image"+i, container:this, x:0, y:0, width:imageWidth, height:imageHeight, scaleMode:"proportionalInside", centerRegistration:false, alpha:0, noCache:false}) );
				
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
			video.width = videoWidth;
			video.height = videoHeight;
			videoHolder = new Sprite;
			
			videoHolder.addChild(video);
			
			var Type:Class = getDefinitionByName("container") as Class;
			var myBox:MovieClip = new Type();
			
			myBox.x = videoHolder.x = videoX;
			myBox.y = videoHolder.y = videoY;
			//phoneHolder.addChild(videoHolder);
			addChild(videoHolder);
			
			addChild(myBox);
			
			//rotationXLabel = createCustomTextField(0, 420, 200, 20);
			//rotationYLabel = createCustomTextField(150, 420, 200, 20);
			
			phoneFrameLabel = createCustomTextField(300, 420, 200, 20);
			
			phoneFrameLabel.text = "Current phone frame index " + currentPhoneFrame;
			
			myBox.addEventListener(MouseEvent.CLICK, startRotate);
			
			
			sliderX = new TestSlider;
			sliderX.init("Video Rotation X", 0 , 1080);
			sliderX.x = 20;
			sliderX.y = 420;
			
			sliderY = new TestSlider;
			sliderY.init("Video Rotation Y", 0 , 1080);
			sliderY.x = (40 + 100)*1;
			sliderY.y = 420;

			sliderZ = new TestSlider;
			sliderZ.init("Video Rotation Z", 0 , 1080);
			sliderZ.x = (40 + 100)*2;
			sliderZ.y = 420;

			
			sliderFV = new TestSlider;
			sliderFV.init("fieldOfView", 1, 179);
			sliderFV.x = (40 + 100)*3;
			sliderFV.y = 420;
			sliderFV.updateSliderValue(55);
			
			sliderScale = new TestSlider;
			sliderScale.init("Scale", 1, 1.2, .01);
			sliderScale.x = (40 + 100)*4;
			sliderScale.y = 420;
			sliderScale.updateSliderValue(1);
			addChild(sliderScale);
			
			addChild(sliderZ);

		
			addChild(sliderX);
			
			addChild(sliderY);
			/**/
			
			addChild(sliderFV);
			
			/*
			sliderWidth = new TestSlider;
			sliderWidth.init("Width", 600 , 1000);
			sliderWidth.x = (20 + 100)*5;
			sliderWidth.y = 420;
			addChild(sliderWidth);
			sliderWidth.addEventListener(TestSlider.UPDATE_VIDEO_3D, updateVideoPerspective);
			*/
			sliderX.addEventListener(TestSlider.UPDATE_VIDEO_3D, updateVideoPerspective);
			sliderY.addEventListener(TestSlider.UPDATE_VIDEO_3D, updateVideoPerspective);
			sliderZ.addEventListener(TestSlider.UPDATE_VIDEO_3D, updateVideoPerspective);
			sliderFV.addEventListener(TestSlider.UPDATE_VIDEO_3D, updateVideoPerspective);
			sliderScale.addEventListener(TestSlider.UPDATE_VIDEO_3D, updateVideoPerspective);
			
			//root.transform.perspectiveProjection.projectionCenter = new Point(175, 175); 
			
			
			var nc:NetConnection = new NetConnection();
			nc.connect(null);
			
			ns = new NetStream(nc);
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
		
		private function createCustomTextField(x:Number, y:Number, width:Number, height:Number):TextField {
			var result:TextField = new TextField();
			result.x = x; result.y = y;
			result.width = width; result.height = height;
			addChild(result);
			return result;
		}
		private var rotateFlag = false;
		private function startRotate(e:MouseEvent) : void {
			trace("startRotate=" + rotateFlag);
			if (rotateFlag) {
				e.target.removeEventListener(MouseEvent.MOUSE_MOVE, moveMouseRotation);
				e.target.removeEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelRotation);
				ns.pause();
			} else {
				e.target.addEventListener(MouseEvent.MOUSE_MOVE, moveMouseRotation);
				e.target.addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelRotation);
				ns.pause();
			}
			rotateFlag = !rotateFlag;
		}
		private function moveMouseRotation(e:MouseEvent) : void {
			videoHolder.rotationX= stage.mouseY;
			videoHolder.rotationY= stage.mouseX;
			/*rotationXLabel.text = "rotationX " + videoHolder.rotationX; 
				rotationYLabel.text ="rotationY " + videoHolder.rotationY;
			*/	
				sliderX.updateSliderValue(videoHolder.rotationX);
				sliderY.updateSliderValue(videoHolder.rotationY);
		}
		
		private function mouseWheelRotation(e:MouseEvent) {
			//videoHolder.rotationY= stage.mouseX;
		}
		
		
		private function updateVideoPerspective(e:Event=null) : void {
			var rotationObj = {};
			
			if (currentPhoneFrame == 4 && e == null) {
				rotationObj.rotationX = 360;
				rotationObj.rotationY = 565;
				rotationObj.rotationZ = 360;
				rotationObj.scale = 1.05;
				rotationObj.fv = 1;	
				
				sliderX.updateSliderValue(rotationObj.rotationX);
				sliderY.updateSliderValue(rotationObj.rotationY);
				sliderZ.updateSliderValue(rotationObj.rotationZ);
				sliderScale.updateSliderValue(rotationObj.scale);
				sliderFV.updateSliderValue(rotationObj.fv);
			} else {
				rotationObj.rotationX = sliderX.value;
				rotationObj.rotationY = sliderY.value;
				rotationObj.rotationZ = sliderZ.value;
				rotationObj.scale = sliderScale.value;
				rotationObj.fv = sliderFV.value;
			}
			
			videoHolder.rotationX = rotationObj.rotationX;
			videoHolder.rotationY = rotationObj.rotationY;
			videoHolder.rotationZ = rotationObj.rotationZ;
			videoHolder.scaleX =videoHolder.scaleY=sliderScale.value;
			//videoHolder.width = sliderWidth.value;
			var pp:PerspectiveProjection=new PerspectiveProjection();
			pp.fieldOfView=rotationObj.fv;
			//pp.projectionCenter=new Point(0,0);
			videoHolder.transform.perspectiveProjection=pp;

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
			//video.x = (stage.stageWidth - video.width) / 2;
			//video.y = (stage.stageHeight - video.height) / 2;
			video.x = -video.width/2;
			video.y = -video.height/2;
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
			phoneFrameLabel.text = "Current phone frame index " + currentPhoneFrame;
			updateVideoPerspective();

		}
		private function start3DRotate(speed):void
		{
			return;
			angle<360? angle+=speed : angle = 0;
			if (angle < 0) angle = 180+angle;
			if (angle > 180) angle-=180;
			videoHolder.rotationY = angle;
			sliderY.updateSliderValue(angle);
		}

	}
}