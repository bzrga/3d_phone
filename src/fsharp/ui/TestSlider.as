package fsharp.ui
{
	import fl.controls.Label;
	import fl.controls.Slider;
	import fl.events.SliderEvent;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	
	public class TestSlider extends Sprite
	{
		public var min:Number;
		public var max:Number;
		public var value:Number;
		public var sliderHoder:Slider;
		public var sliderLabel:TextField;
		public var desc:String;
		public static var UPDATE_VIDEO_3D:String = "UPDATE_VIDEO_3D";
		public function TestSlider()
		{
			super();
		}
		
		public function init(desc:String, min:Number, max:Number):void {
			this.min = min;
			this.max = max;
			this.desc = desc;
			
			sliderLabel = createCustomTextField(0, 50, 200, 20);
			//label2.text = "Drag to select some of this text.";
			 
			sliderLabel.text = desc; 
			
			sliderHoder = new Slider(); 
			sliderHoder.width = 100; 
			sliderHoder.snapInterval = 1; 
			sliderHoder.tickInterval = 1; 
			sliderHoder.maximum = max; 
			sliderHoder.value = min; 
			sliderHoder.move(0, 30); 
			
			addChild(sliderLabel); 
			addChild(sliderHoder); 
			
			sliderHoder.addEventListener(SliderEvent.CHANGE, changeHandler); 

		}
		
public function updateSliderValue(value:Number) :void {
	trace("updateSliderValue Y= " + value);
	this.value = value;
	sliderHoder.value = value;
	sliderLabel.text = this.desc + " " + value; 
}
		private function changeHandler(event:SliderEvent):void { 
			trace("changeHandler=" + event.value);
			sliderLabel.text = this.desc + " " + event.value; 
			value = event.value; 
			dispatchEvent(new Event(UPDATE_VIDEO_3D));
			//aLoader.alpha = event.value * .01; 
		}
		
		private function createCustomTextField(x:Number, y:Number, width:Number, height:Number):TextField {
			var result:TextField = new TextField();
			result.x = x; result.y = y;
			result.width = width; result.height = height;
			addChild(result);
			return result;
		}
	}
}