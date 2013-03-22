// ActionScript file
package fsharp.ui {
	import flash.display.Sprite;
	import flash.events.*;
	
	public class PhoneUI extends Sprite {
		private var imageList:Array;
		private var i:Number;
		private const imageWidth:Number = 823;
		private const imageHeight:Number = 427;
		
		public function PhoneUI()
		{
			super();
		}
		
		public function init($imageList:Array):void {
			imageList = $imageList;
			
			for (i = 0; i < imageList.length; i++) {
				addChild(imageList[i]);
				
			}
			
			buttonMode = useHandCursor = true;
		}
		
		public function initHitArea():void {
			var square:Sprite = new Sprite();
			addChild(square);
			square.graphics.beginFill(0x0000FF,.2);
			square.graphics.drawRect(0,0,imageWidth,imageHeight);
			square.graphics.endFill();
		}
		
		public function showPhoneFrame(frameNum:Number):void {
			for (i = 0; i < imageList.length; i++) {
				imageList[i].visible = false;
			}

			imageList[frameNum].visible = true;
		}
	}
}