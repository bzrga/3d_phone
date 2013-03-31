// ActionScript file
package fsharp.ui {
	import com.greensock.TweenMax;
	
	import flash.display.Sprite;
	import flash.events.*;
	
	public class PhoneUI extends Sprite {
		private var imageList:Array;
		private var i:Number;
		public var imageWidth:Number = 800;
		public var imageHeight:Number = 500;
		public var fixedY : Number;
		public var imagesHolder : Sprite;
		public function PhoneUI()
		{
			super();
		}
		
		public function init($imageList:Array):void {
			imageList = $imageList;
			imagesHolder = new Sprite;
			for (i = 0; i < imageList.length; i++) {
				imagesHolder.addChild(imageList[i]);
				imageList[i].x = -imageList[i].width/2;
				imageList[i].y = -imageList[i].height/2;
			}
			imageWidth = imageList[0].width;
			imageHeight = imageList[0].height;
			addChild(imagesHolder);
			x = Math.abs(imageList[0].x);
			y = Math.abs(imageList[0].y);
			fixedY = y;
			buttonMode = true;
		}
		
		public function initHitArea():void {
			var square:Sprite = new Sprite();
			addChild(square);
			square.graphics.beginFill(0x0000FF, 0.3);
			square.graphics.drawRect(0,0,640, 350+200);
			square.graphics.endFill();
			square.x = -square.width/2;
			square.y = -square.height/2-20;
		}
		
		public function showPhoneFrame(frameNum:Number):void {
			for (i = 0; i < imageList.length; i++) {
				imageList[i].visible = false;
				imageList[i].alpha = 1;
			}
			imageList[frameNum].alpha = 1;
			imageList[frameNum].visible = true;
		}
	}
}