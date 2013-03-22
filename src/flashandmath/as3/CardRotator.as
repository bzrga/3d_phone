/* ***********************************************************************
ActionScript 3 Flash CS4 Tutorial by Barbara Kaskosz

http://www.flashandmath.com/

Last modified: April 4, 2010
************************************************************************ */


package flashandmath.as3 {
	
	import flash.display.DisplayObject;
	
	import flash.display.Sprite;
	
	import flash.events.Event;
	
	import flash.geom.Vector3D;
	
	import flash.geom.Matrix3D;
	
    public  class CardRotator extends Sprite {
		  
		  private var objFront:DisplayObject;
		    
		  private var objBack:DisplayObject;
		  
		  private var contFront:Sprite;
		  
		  private var contBack:Sprite;
		   
		  private var card:Sprite;
		  
		  private var normalEnd:Sprite;
		      
		  private var cardWidth:Number;
		  
		  private var cardHeight:Number;
		  
		  private var dir:String;
		  
		  private var reg:String;
		  
		  private var _rotX:Number;
		  
		  private var _rotY:Number;
		  
		  private var _rotZ:Number;
		  
		  /*
		  The constructor of the class defined below takes four parameters, the last two optional. The first two parameters
          are the DisplayObjects that provide the front and the back of the instance 
          of CardRotator created by the constructor - a 'card'. 

          The third parameter is a String, 'vertical' or 'horizontal' (default 'vertical'). Based
          on the value of this parameter the back side of the card is initially rotated about the y-axis
          or about the x-axis by 180 degrees. That will give the correct orientation of the back
          after vertical or, respectively, horizontal rotation. The last parameter is a String, 'center' or 'corner'
          (default 'corner'). The parameter contains the information about the registration points
          of the DisplayObjects passed to the contructor: 'corner' if the registration points are in the upper
          left corner, and 'center' if the registration points are in the center. 

          Both DisplayObjects passed to the constructor should have the same width and height.
		  */
		   
		    
	   public function CardRotator(obf:DisplayObject,obb:DisplayObject,d:String="vertical",r:String="corner"){
		   
		   objFront=obf;
		    
		   objBack=obb;
		   
		   dir=d;
		   
		   reg=r;
		    
		   this.addEventListener(Event.ADDED_TO_STAGE,isOnStage);
		    
	}
	
	private function isOnStage(e:Event):void {
		
		this.removeEventListener(Event.ADDED_TO_STAGE,isOnStage);
		
		buildCard();
	
	}
	
	private function buildCard():void {
		
		   cardWidth=objFront.width;
		   
		   cardHeight=objFront.height;
		   
		   card=new Sprite();
		   
		   this.addChild(card);
		   
		   card.x=0;
		   
		   card.y=0;
		   
		   card.z=0;
		    
		   normalEnd=new Sprite();
		   
		   card.addChild(normalEnd);
		   
		   contFront=new Sprite();
		   
		   contBack=new Sprite();
		   
		   card.addChild(contBack);
		   
		   card.addChild(contFront);
		   
		   contFront.addChild(objFront);
		   
		   contBack.addChild(objBack);
		   
		   if(reg=="corner"){
		   
		   objBack.x=-cardWidth/2;
		   
		   objBack.y=-cardHeight/2;
		   
		   objFront.x=-cardWidth/2;
		   
		   objFront.y=-cardHeight/2;
		   
		   }
		   
		   if(dir=="vertical"){
		   
		   contBack.rotationY=180;
		   
		   } else {
			   
			   contBack.rotationX=180;
		   }
		   
		   normalEnd.x=0;
		   
		   normalEnd.y=0;
		   
		   normalEnd.z=-100;
		
		  _rotX=0;
		  
		  _rotY=0;
		  
		  _rotZ=0;
		
	}
	
	private function sortFaces():void {
		
		var dotProd:Number;
		
		var thisGlobalPos:Vector3D=new Vector3D();
		
		var toObserver:Vector3D=new Vector3D();
		
		var normalGlobalEnd:Vector3D=new Vector3D();
		
		var normalGlobalVec:Vector3D=new Vector3D();
		
		var observerPos:Vector3D=new Vector3D();
		
		observerPos.x=root.transform.perspectiveProjection.projectionCenter.x;
		
		observerPos.y=root.transform.perspectiveProjection.projectionCenter.y;
		
		observerPos.z=-root.transform.perspectiveProjection.focalLength;
		
		thisGlobalPos=contBack.transform.getRelativeMatrix3D(root).position.clone();
		
		normalGlobalEnd=normalEnd.transform.getRelativeMatrix3D(root).position.clone();
		
		normalGlobalVec=normalGlobalEnd.subtract(thisGlobalPos);
		
		toObserver=observerPos.subtract(thisGlobalPos);
		
		dotProd=normalGlobalVec.x*toObserver.x+normalGlobalVec.y*toObserver.y+normalGlobalVec.z*toObserver.z;
		
		if(dotProd>=0){
			
			card.addChild(contFront);
		}
		
		else
		
		{
			card.addChild(contBack);
			
		}
		
		
	}
	
	/*
	The class has three public pseudo-properties: rotX, rotY, rotZ that give the rotations of an instance
	about the x-, y-, and z- axis, respectively.
	*/
	
	public function set rotX(b:Number) {
		
		_rotX=b;
		
		_rotX=_rotX%360;
		
		card.rotationX=_rotX;
	
		sortFaces();
		
	}
	
	public function set rotY(b:Number) {
		
		_rotY=b;
		
		_rotY=_rotY%360;
		
		card.rotationY=_rotY;
		
		sortFaces();
		
	}
	
	public function set rotZ(b:Number) {
		
		_rotZ=b;
		
		_rotZ=_rotZ%360;
		
		card.rotationZ=_rotZ;
	
		sortFaces();
		
	}
	
	public function get rotX():Number {
		
		return _rotX;
		
	}
	
	public function get rotY():Number {
		
		return _rotY;
		
	}
	
	public function get rotZ():Number {
		
		return _rotZ;
		
	}
	
	
	

   }

}