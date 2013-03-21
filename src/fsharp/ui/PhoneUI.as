// ActionScript file
package fsharp.ui {
	import flash.display.Sprite;
	import flash.events.*;
	
	public class PhoneUI extends Sprite {
		private var imageList:Array;
		private var i:Number;
		
		public function PhoneUI()
		{
			super();
		}
		
		public function init($imageList:Array):void {
			imageList = $imageList;
			
			for (i = 0; i < imageList.length; i++) {
				addChild(imageList[i]);
				
			}
			
			var square:Sprite = new Sprite();
			addChild(square);
			square.graphics.beginFill(0x0000FF,.3);
			square.graphics.drawRect(0,0,200,400);
			square.graphics.endFill();
			
			buttonMode = useHandCursor = true;
		}
		
		public function showPhoneFrame(frameNum:Number):void {
			for (i = 0; i < imageList.length; i++) {
				imageList[i].visible = false;
			}

			imageList[frameNum].visible = true;
		}
	}
}