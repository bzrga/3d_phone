package
{	
	import br.com.stimuli.loading.BulkLoader;
	import br.com.stimuli.loading.BulkProgressEvent;
	
	import com.greensock.TweenMax;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import flash.system.Security;
	
	import fsharp.ui.PhoneUI;

	[SWF(width="600", height="600", backgroundColor="#ffffff", frameRate="30")]
	
	public class VideoPhone extends Sprite
	{
		private var loader : BulkLoader;
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
		
		var context1:LoaderContext = new LoaderContext();
		var req:URLRequest = new URLRequest("http://graph.facebook.com/" + "" + "/picture?type=large");

		
		public function VideoPhone()
		{
			Security.loadPolicyFile("http://graph.facebook.com/crossdomain.xml");
			Security.allowDomain("*");
			Security.allowInsecureDomain("*");
			
			context1.checkPolicyFile = true;
			
			loader = new BulkLoader("main-site");
			loader.add(xmlPath, {id:"configXML"});
			loader.get(xmlPath).addEventListener(BulkLoader.ERROR, onXMLFailed);
			loader.get(xmlPath).addEventListener(BulkLoader.COMPLETE, onXMLLoaded);
				
			loader.start();
		}
		private function onXMLFailed(e:Event):void {
			trace("xml failed to load");
		}
		private function onXMLLoaded(e:Event):void {
			configXml = loader.getContent("configXML",true);
			
			videoPath = configXml.video.@loc;
			audioPath = configXml.audio.@loc;
			var imageXmlList:XMLList = configXml..image;
			imageList = new Array(imageXmlList.length());
			trace(configXml.images.@loc);
			for (i = 0; i < imageXmlList.length(); i++) {
				trace("i=" + imageXmlList.children()[i]);
				loader.add(String(configXml.images.@loc) + String(imageXmlList.children()[i]), {id:"image"+i});
			}
			
			loader.addEventListener(BulkProgressEvent.COMPLETE, onAllLoaded);
			loader.start();
		}
		private function onAllLoaded(e:Event):void {
			phoneHolder = new PhoneUI();
			addChild(phoneHolder);
			
			for (i = 0; i < imageList.length; i++) {
				imageList[i] = loader.getContent("image"+i,true);
				//TweenMax.to(imageList[i], 3, {alpha:.4});
			}
			
			phoneHolder.init(imageList);
			phoneHolder.showPhoneFrame(currentPhoneFrame);
			
			phoneHolder.addEventListener(MouseEvent.MOUSE_DOWN, onPhoneOver);
			phoneHolder.addEventListener(MouseEvent.MOUSE_OUT, onPhoneOut);
			phoneHolder.addEventListener(MouseEvent.MOUSE_UP, onPhoneOut);
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
				} else {
					//rotate left
					currentPhoneFrame--;
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
	}
}