package {
	
	import flash.display.MovieClip;
	import flash.events.TimerEvent;
	import flash.media.Sound;
	import flash.utils.Timer;
	import flash.events.Event;
	import flash.display.Screen;
	import flash.filters.DropShadowFilter;
	
	public dynamic class Clock extends MovieClip {
		protected var _clockTimer:Timer;
		protected var _targetDate:Date;
		protected var _tickSound:Sound = new TickSound();
		public var diff:int = 25, audible:Boolean = true;
		
		// CONSTRUCTOR
		public function Clock() {
			//Apply Shadow
			this.filters = [new DropShadowFilter(0,0,0,1,10,10)];
			this.addEventListener(Event.REMOVED_FROM_STAGE, denitTimer);
		}
		
		protected function initTimer(e:Event = null):void{
			_clockTimer = new Timer(1000) // tick every second (1000 milliseconds)
			_clockTimer.addEventListener(TimerEvent.TIMER, update);
			_clockTimer.start();
		}
		protected function denitTimer(e:Event = null):void{
			_clockTimer.stop();
			if(_clockTimer.hasEventListener(TimerEvent.TIMER)) _clockTimer.removeEventListener(TimerEvent.TIMER, update);
			_clockTimer = null;
		}
		
		// set the target date and start the countdown timer
		public function target(event:String, date:Date):Object {return null;}
		
		public function position(x:Number, y:Number, orientation:String):Object{
			hide();
			if(orientation.toLowerCase() == "top"){
				this.x = x;
				this.y = -height+diff;
			}
			else if(orientation.toLowerCase() == "right"){
				this.x = Screen.mainScreen.visibleBounds.width-diff;
				this.y = y;
			}
			else if(orientation.toLowerCase() == "bottom"){
				this.x = x;
				this.y = Screen.mainScreen.visibleBounds.height-diff;
			}
			else if(orientation.toLowerCase() == "left"){
				this.x = -width+diff;
				this.y = y;
			}
			else{
				orientation = "None"
				this.x = x;
				this.y = y;
			}
			normalize(orientation.toLowerCase());
			show(orientation.toLowerCase());
			update();
			return {x:this.x, y:this.y, orientation:orientation};
		}
		public function normalize(orientation:String):void{
			if(orientation == "top" || orientation == "bottom"){
				if(this.x < 0) this.x = 0;
				else if(this.x > Screen.mainScreen.visibleBounds.width-this.width) this.x = Screen.mainScreen.visibleBounds.width-this.width;
			}
			else if(orientation == "left" || orientation == "right"){
				if(this.y < 0) this.y = 0;
				else if(this.y > Screen.mainScreen.visibleBounds.height-this.height) this.y = Screen.mainScreen.visibleBounds.height-this.height;
			}
			else{
				if(this.x < 0) this.x = 0;
				else if(this.x > Screen.mainScreen.visibleBounds.width-this.width) this.x = Screen.mainScreen.visibleBounds.width-this.width;
				if(this.y < 0) this.y = 0;
				else if(this.y > Screen.mainScreen.visibleBounds.height-this.height) this.y = Screen.mainScreen.visibleBounds.height-this.height;
			}
		}
		
		protected function hide(arg:String = "all"):void {}
		protected function show(arg:String = "all"):void {}
		
		protected function update(e:TimerEvent = null):void {}
		
		protected function timeup():void {}
	
	}

}