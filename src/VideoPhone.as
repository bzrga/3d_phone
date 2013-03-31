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
	import com.greensock.plugins.TweenPlugin;
	import com.greensock.plugins.VolumePlugin;
	
	import f4.Player;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.NetStatusEvent;
	import flash.geom.Matrix;
	import flash.geom.PerspectiveProjection;
	import flash.geom.Point;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import flash.system.Security;
	import flash.text.TextField;
	import flash.ui.Mouse;
	import flash.utils.*;
	
	import fsharp.ui.AudioControl;
	import fsharp.ui.PhoneUI;
	import fsharp.ui.TestSlider;

	[SWF(width="800", height="700", backgroundColor="#ffffff", frameRate="30")]
	
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
		
		private var totalImgNum:Number;
		private var videoWidth:Number;
		private var videoHeight:Number;
		
		private var videoX:Number;
		private var videoY:Number;
		
		private var video:Video;
		private var videoHolder:Sprite;
		private var angle:Number = 0;
		private var speed:Number = 5;
		private var mainHolder:Sprite;
		
		private var sliderX:TestSlider;
		private var sliderY:TestSlider;
		private var sliderZ:TestSlider;
		private var sliderFV:TestSlider;
		private var sliderScale:TestSlider;
		private var sliderFrame:TestSlider;
		private var sliderPX:TestSlider;
		private var sliderPY:TestSlider;
		
		private var sliderScaleX:TestSlider;
		private var sliderScaleY:TestSlider;
		
		private var phoneFrameLabel:TextField;
		
		private var audioFrontLoader:MP3Loader;
		private var audioBackLoader:MP3Loader;
		private var currentSC:SoundChannel;
		private var currentPan:Number = 0;
		
		private var playAudioBack:Boolean = false;
		private var ns:NetStream;
		private var videoBuffering:Boolean = true;
		private var _rotationHint:Sprite;
		private var _audioControl:AudioControl;
		
		var context1:LoaderContext = new LoaderContext();
		var req:URLRequest = new URLRequest("http://graph.facebook.com/" + "" + "/picture?type=large");

		
		public function VideoPhone()
		{
			//Security.loadPolicyFile("http://graph.facebook.com/crossdomain.xml");
			Security.allowDomain("*");
			Security.allowInsecureDomain("*");
			
			context1.checkPolicyFile = true;
			
			LoaderMax.activate([XMLLoader, ImageLoader, MP3Loader, VideoLoader]);
			TweenPlugin.activate([VolumePlugin]);
			
			var loader:XMLLoader = new XMLLoader(xmlPath, {name:"configXML", onComplete:onXMLLoaded});
			loader.load();
		}

		private function onXMLLoaded(event:LoaderEvent):void {
			var queue:LoaderMax = new LoaderMax({name:"mainQueue", onProgress:progressHandler, onComplete:onAllLoaded, onError:errorHandler});
			
			audioFrontLoader = LoaderMax.getLoader("audioFront");
			audioBackLoader = LoaderMax.getLoader("audioBack");
			configXml = LoaderMax.getContent("configXML");
			
			videoPath = configXml.video.@loc;
			audioPath = configXml.audio.@loc;
			videoX = configXml..videoloader.@videoX;
			videoY = configXml..videoloader.@videoY;
			videoWidth = configXml..videoloader.@width;
			videoHeight = configXml..videoloader.@height;

			totalImgNum = Number(configXml.images.@total);
			for (i = 0; i < totalImgNum; i++) {
				//append the ImageLoader and several other loaders
				queue.append( new ImageLoader(String(configXml.images.@loc) + (Number(configXml.images.@start) + i) + configXml.images.@type, {name:"image"+i, container:this, centerRegistration:false, alpha:0, noCache:false}) );
				
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
			mainHolder = new Sprite;
			addChild(mainHolder);
			
			
			phoneHolder = new PhoneUI();
			mainHolder.addChild(phoneHolder);

			videoHolder = new Sprite;
			mainHolder.addChild(videoHolder);

			for (i = 0; i < imageList.length; i++) {
				imageList[i] = LoaderMax.getContent("image"+i);
			}
			
			phoneHolder.init(imageList);
			phoneHolder.showPhoneFrame(currentPhoneFrame);
			video = new Video();
			video.width = videoWidth;
			video.height = videoHeight;
			
			
			
			videoHolder.addChild(video);
			
			
			/***********************************/
			var Type:Class = getDefinitionByName("container") as Class;
			var myBox:MovieClip = new Type();
			
			myBox.x = videoHolder.x = videoX;
			myBox.y = videoHolder.y = videoY;
			
			
			addChild(myBox);
			
			phoneFrameLabel = createCustomTextField(300, 520, 200, 20);
			
			phoneFrameLabel.text = "Current phone frame index " + currentPhoneFrame;
			
			myBox.addEventListener(MouseEvent.CLICK, startRotate);
			
			
			sliderX = new TestSlider;
			sliderX.init("Video Rotation X", 0 , 1080);
			sliderX.x = 20;
			sliderX.y = 520;
			
			sliderY = new TestSlider;
			sliderY.init("Video Rotation Y", 0 , 1080);
			sliderY.x = (40 + 100)*1;
			sliderY.y = 520;

			sliderZ = new TestSlider;
			sliderZ.init("Video Rotation Z", 0 , 1080);
			sliderZ.x = (40 + 100)*2;
			sliderZ.y = 520;

			
			sliderFV = new TestSlider;
			sliderFV.init("fieldOfView", 1, 179);
			sliderFV.x = (40 + 100)*3;
			sliderFV.y = 520;
			sliderFV.updateSliderValue(55);
			
			sliderScale = new TestSlider;
			sliderScale.init("Scale", 1, 1.2, .01);
			sliderScale.x = (40 + 100)*4;
			sliderScale.y = 520;
			sliderScale.updateSliderValue(1);
			
			sliderFrame = new TestSlider;
			sliderFrame.init("Frame #", 0, imageList.length);
			sliderFrame.x = (40 + 100)*5-20;
			sliderFrame.y = 520;
			sliderFrame.updateSliderValue(54);
			
			sliderScaleX = new TestSlider;
			sliderScaleX.init("Scale x", 1, 1.2, .01);
			sliderScaleX.x = (40 + 100)*2;
			sliderScaleX.y = 620;
			sliderScaleX.updateSliderValue(1);
			
			sliderScaleY = new TestSlider;
			sliderScaleY.init("Scale y", 1, 1.2, .01);
			sliderScaleY.x = (40 + 100)*3;
			sliderScaleY.y = 620;
			sliderScaleY.updateSliderValue(1);
			
			sliderPX = new TestSlider;
			sliderPX.init("Frame X", 0, 200);
			sliderPX.x = (40 + 100)*4;
			sliderPX.y = 620;
			sliderPX.updateSliderValue(100);
			
			sliderPY = new TestSlider;
			sliderPY.init("Frame y", 0, 200);
			sliderPY.x = (40 + 100)*5-20;
			sliderPY.y = 620;
			sliderPY.updateSliderValue(100);
			
			
			addChild(sliderScale);
			addChild(sliderScaleX);
			addChild(sliderScaleY);
			
			addChild(sliderZ);

		
			addChild(sliderX);
			
			addChild(sliderY);
			
			
			addChild(sliderPX);
			
			addChild(sliderPY);
			
			addChild(sliderFV);
			
			addChild(sliderFrame);
			/***********************************/
			
			sliderX.addEventListener(TestSlider.UPDATE_VIDEO_3D, updateVideoPerspective);
			sliderY.addEventListener(TestSlider.UPDATE_VIDEO_3D, updateVideoPerspective);
			sliderZ.addEventListener(TestSlider.UPDATE_VIDEO_3D, updateVideoPerspective);
			sliderFV.addEventListener(TestSlider.UPDATE_VIDEO_3D, updateVideoPerspective);
			sliderScale.addEventListener(TestSlider.UPDATE_VIDEO_3D, updateVideoPerspective);			
			sliderFrame.addEventListener(TestSlider.UPDATE_VIDEO_3D, updatePhoneFrameTest);	
			sliderPX.addEventListener(TestSlider.UPDATE_VIDEO_3D, updateVideoPerspective);	
			sliderPY.addEventListener(TestSlider.UPDATE_VIDEO_3D, updateVideoPerspective);
			sliderScaleX.addEventListener(TestSlider.UPDATE_VIDEO_3D, updateVideoPerspective);
			sliderScaleY.addEventListener(TestSlider.UPDATE_VIDEO_3D, updateVideoPerspective);
			var nc:NetConnection = new NetConnection();
			nc.connect(null);
			
			ns = new NetStream(nc);
			ns.client = {onMetaData:ns_onMetaData, onCuePoint:ns_onCuePoint};
			
			ns.addEventListener(NetStatusEvent.NET_STATUS,netStatusHandler);
			
			
			video.attachNetStream(ns);
			ns.play("http://content.bitsontherun.com/videos/XtyoLQuV-RyDNOtym.mp4");			
			
			phoneHolder.initHitArea();
		
			mainHolder.addEventListener(MouseEvent.MOUSE_OVER, showHint);
			mainHolder.addEventListener(MouseEvent.MOUSE_DOWN, onPhoneOver);
			mainHolder.addEventListener(MouseEvent.MOUSE_OUT, onPhoneOut);
			mainHolder.addEventListener(MouseEvent.MOUSE_UP, onPhoneOut);
			
			var symbolClass:Class;
			
			symbolClass=getDefinitionByName("rotationHint") as Class;
			_rotationHint=new symbolClass();
			addChild(_rotationHint);
			_rotationHint.visible = false;

			_audioControl = new AudioControl;
			addChild(_audioControl);
			_audioControl.y = 600;
			_audioControl.x = 60;
			_audioControl.addEventListener(MouseEvent.CLICK, onAudioClick);
		}
		private function onAudioClick(e:MouseEvent) : void {
			var _soundTransform = new SoundTransform();

			if (_audioControl.mute) {
				
				_soundTransform.volume = 0;	
			} else {
				_soundTransform.volume = .5;	
			}
			currentSC.soundTransform = _soundTransform;
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
				//ns.resume();
			} else {
				e.target.addEventListener(MouseEvent.MOUSE_MOVE, moveMouseRotation);
				ns.pause();
			}
			rotateFlag = !rotateFlag;
		}
		
		private function moveMouseRotation(e:MouseEvent) : void {
			videoHolder.rotationX= stage.mouseY;
			videoHolder.rotationY= stage.mouseX;
				sliderX.updateSliderValue(videoHolder.rotationX);
				sliderY.updateSliderValue(videoHolder.rotationY);
		}		
		
		private function updatePhoneFrameTest(e:Event=null) : void {
			currentPhoneFrame = sliderFrame.value;
			phoneHolder.showPhoneFrame(currentPhoneFrame);
			phoneFrameLabel.text = "Current phone frame index " + currentPhoneFrame;
			updateVideoPerspective();
		}
		private function updateVideoPerspective(e:Event=null) : void {
			var rotationObj = {};
			
			var audioFrontLeftFrame = 53;
			var audioFrontRightFrame = 17;

			var audioBackRightFrame = 35;
			
			var audioPopLeftFrame = 24;
			var audioPopRightFrame = 45;
			
			var rotationData:XML;
			if (configXml..rotation.(@id == currentPhoneFrame).length()) {
				rotationData = configXml..rotation.(@id == currentPhoneFrame)[0];
			}
			
			if (e == null && rotationData) {
			//if (currentPhoneFrame == 4 && e == null) {
				rotationObj.rotationX = 360;
				rotationObj.rotationY = 565;
				rotationObj.rotationZ = 360;
				rotationObj.scale = 1.05;
				rotationObj.fv = 1;	

				rotationObj.rotationX = rotationData.@x;
				rotationObj.rotationY = rotationData.@y;
				rotationObj.rotationZ = rotationData.@z;
				rotationObj.scale = rotationData.@scale;
				rotationObj.fv = rotationData.@fv;	
				
				if (rotationData.@px) {
					rotationObj.px = videoX + Number(rotationData.@px);
					rotationObj.py = videoY + Number(rotationData.@py);
					trace("rotationObj.@px=" + rotationData.@px);
					trace("rotationObj.px=" + rotationObj.px);
					
					sliderPX.updateSliderValue(100 + Number(rotationData.@px));
					sliderPY.updateSliderValue(100 + Number(rotationData.@py));
				}
				if (rotationData.@scaleX) {
					rotationObj.scaleX = rotationData.@scaleX;
					rotationObj.scaleY = rotationData.@scaleY;
				} else {
					rotationObj.scaleX = rotationData.@scale;
					rotationObj.scaleY = rotationData.@scale;
				}
				sliderX.updateSliderValue(rotationObj.rotationX);
				sliderY.updateSliderValue(rotationObj.rotationY);
				sliderZ.updateSliderValue(rotationObj.rotationZ);
				sliderScale.updateSliderValue(rotationObj.scale);
				sliderFV.updateSliderValue(rotationObj.fv);
			} else {
				
				rotationObj.rotationX = 0;
				rotationObj.rotationY = 0;
				rotationObj.rotationZ = 0;
				rotationObj.scale = 1;
				rotationObj.fv = 55;
				
				rotationObj.scaleX = 1;
				rotationObj.scaleY = 1;
				
				rotationObj.px = videoX;
				rotationObj.py = videoY;
				
				rotationObj.rotationX = sliderX.value;
				rotationObj.rotationY = sliderY.value;
				rotationObj.rotationZ = sliderZ.value;
				rotationObj.scale = sliderScale.value;
				rotationObj.fv = sliderFV.value;
				
				rotationObj.scaleX = sliderScaleX.value;
				rotationObj.scaleY = sliderScaleY.value;
				
				rotationObj.px = videoX + sliderPX.value-100;
				rotationObj.py = videoY + sliderPY.value-100;
			}
			
			var tweenTime = .2;
			var pp:PerspectiveProjection=new PerspectiveProjection();
			TweenMax.killTweensOf(videoHolder);
			//adjust video position
			if (((currentPhoneFrame >= audioFrontRightFrame && currentPhoneFrame <= audioPopLeftFrame) || (currentPhoneFrame >= audioPopRightFrame && currentPhoneFrame <= audioFrontLeftFrame))) {
				if (videoHolder.scaleX != .4 && phoneHolder.imagesHolder.scaleX == 1) {
					videoHolder.alpha = 0;
				}
				videoHolder.rotationX = videoHolder.rotationY  = videoHolder.rotationZ = 0;
				videoHolder.transform.perspectiveProjection=pp;
				//reveal 20%
				TweenMax.to(videoHolder, tweenTime, {y:videoY-230, alpha:1, scaleX:.4,scaleY:.4});
				TweenMax.to(phoneHolder.imagesHolder, tweenTime, {y:0, scaleX:1,scaleY:1});
				
			} else if (currentPhoneFrame > audioPopLeftFrame && currentPhoneFrame < audioPopRightFrame) {
				videoHolder.alpha = 1;
				videoHolder.rotationX = videoHolder.rotationY  = videoHolder.rotationZ = 0;
				videoHolder.transform.perspectiveProjection=pp;
				
				//video reveal 100%, phone shrinks
				TweenMax.to(videoHolder, tweenTime, {y:videoY-130, scaleX:1,scaleY:1});
				//TweenMax.to(videoHolder, tweenTime, {y:videoY-130});
				TweenMax.to(phoneHolder.imagesHolder, tweenTime, {y:140, scaleX:.5,scaleY:.5});
				
			} else {
				//TweenMax.to(videoHolder, tweenTime, {y:videoY, scaleX:1,scaleY:1});
				videoHolder.alpha = 1;
				TweenMax.to(videoHolder, 0, {y:videoY});
				TweenMax.to(phoneHolder.imagesHolder, tweenTime, {y:0, scaleX:1,scaleY:1});
				
				videoHolder.rotationX = rotationObj.rotationX;
				videoHolder.rotationY = rotationObj.rotationY;
				videoHolder.rotationZ = rotationObj.rotationZ;
				//videoHolder.scaleX =videoHolder.scaleY=rotationObj.value;
				
				videoHolder.scaleX = rotationData.@scale;
				videoHolder.scaleY = rotationData.@scale;
				if (rotationObj.px) {
					videoHolder.x = rotationObj.px;
					videoHolder.y = rotationObj.py;
					//videoHolder.scaleX = rotationObj.scaleX;
					//videoHolder.scaleY=rotationObj.scaleY;
					
					trace("videoHolder.px=" + rotationObj.px);
				} else {
					videoHolder.x = videoX;
					videoHolder.y = videoY;
				}
				pp.fieldOfView=rotationObj.fv;
				videoHolder.transform.perspectiveProjection=pp;
			}
			
			
			//adjust audio chanel
			if (currentPhoneFrame <= audioFrontRightFrame) {
				currentPan = 1 * ((currentPhoneFrame)/audioFrontRightFrame);
				//increase right sound
				if (playAudioBack) {
					playAudioBack = false;
					if (!videoBuffering) playAudio(true);
				}
			} else if (currentPhoneFrame >= audioFrontLeftFrame) {
				currentPan = -1 * ((totalImgNum -currentPhoneFrame)/(totalImgNum-audioFrontLeftFrame))
				//increase left sound
				if (playAudioBack) {
					playAudioBack = false;
					if (!videoBuffering) playAudio(true);
				}
			} else {
				//play alt back sound
				if (currentPhoneFrame < audioBackRightFrame) {
					//right pan
					currentPan = 1 * (1-(currentPhoneFrame-audioFrontRightFrame)/(35-audioFrontRightFrame));
				} else {
					//left pan
					currentPan = -1 * ((currentPhoneFrame)/(audioFrontLeftFrame));
				}
				if (!playAudioBack) {
					playAudioBack = true;
					if (!videoBuffering) playAudio(true);
				}
			}
			
			updatePanning();
			


		}
		
		private function updatePanning():void {
			if (currentSC) {
				if (currentPan == 1) currentPan = .95;
				if (currentPan == -1) currentPan = -.95;
				trace("current pan = " + currentPan);
				var _soundTransform = new SoundTransform();
				_soundTransform.pan = currentPan;
				currentSC.soundTransform = _soundTransform;
			}
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
			video.x = -video.width/2;
			video.y = -video.height/2;
		}
		
		private function ns_onCuePoint(item:Object):void {
			trace("cuePoint");
			trace(item.name + "\t" + item.time);
		}
		
		private function netStatusHandler(event:NetStatusEvent):void {
			switch (event.info.code) {
				case "NetStream.Buffer.Empty":
					//Pause audio
					playAudio(false);
					videoBuffering = true;
					break;
				case "NetStream.Buffer.Full":
					//Play audio
					playAudio();
					videoBuffering = false;
					break;
			}
		}
		
		private function playAudio(_play:Boolean = true):void {
			var soundTime:Number = Math.max(audioFrontLoader.soundTime, audioBackLoader.soundTime);
			trace("soundTime="+soundTime);
			trace("_play="+_play);
			
			if (_play) {
				if (playAudioBack) {
					audioFrontLoader.pauseSound();
					audioBackLoader.gotoSoundTime(soundTime, true);
					currentSC = audioBackLoader.channel;
				} else {
					audioFrontLoader.gotoSoundTime(soundTime, true);
					audioBackLoader.pauseSound();
					currentSC = audioFrontLoader.channel;
				}
			} else {
				//audioFrontLoader.pauseSound();
				//audioBackLoader.pauseSound();
			}
			
			updatePanning();
		}
				
		private function onPhoneOver(e:MouseEvent):void {
			trace("onPhoneOver");
			//_rotationHint.x = mouseX;
			//_rotationHint.y = mouseY;
			addEventListener(Event.ENTER_FRAME, updateHint);	
			phoneHolder.addEventListener(MouseEvent.MOUSE_MOVE, onPhoneMove);			
		}
		
		private function updateHint(e:Event):void {
			trace("onPhoneOver");
			_rotationHint.x = mouseX;
			_rotationHint.y = mouseY;
		}
		
		
		private function showHint(e:MouseEvent):void {
			trace("onPhoneOver");
			_rotationHint.x = mouseX;
			_rotationHint.y = mouseY;
			_rotationHint.visible = true;
			Mouse.cursor="hand";
		}
		
		
		private function onPhoneOut(e:MouseEvent):void {
			trace("onPhoneOut");
			_rotationHint.visible = false;
			Mouse.cursor="auto";
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