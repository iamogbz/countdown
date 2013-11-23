package {

	import flash.display.MovieClip;
	import fl.transitions.Tween;
	import fl.motion.easing.Linear;
	import fl.transitions.TweenEvent;
	import flash.events.Event;
	
	public class Wheel extends MovieClip {
		private var _number:String = "0";
		
		// CONSTRUCTOR
		public function Wheel() {
			//reset();
		}
		
		public function rollTo(num:String):void {
			_number = num;
			//prev.text = next.text;
			next.text = num;
			
			//tween next in
			new Tween(next, "y", Linear.easeNone, next.y, -25.2, .2, true);
			//tween notches
			new Tween(notch, "y", Linear.easeNone, notch.y, 39.8, .2, true);
			//tween prev out;
			new Tween(prev, "y", Linear.easeNone, prev.y, 14.6, .2, true).addEventListener(TweenEvent.MOTION_FINISH, rollComplete);
		}
		
		public function get number():String {
			//return _number;
			return prev.text;
		}
		public function set number(value:String):void {
			_number = value;
			prev.text = _number;
		}
		
		private function rollComplete(e:Event = null):void {
			prev.text = _number;
			
			// reset positions;
			reset();
		}
		
		public function reset():void {
			next.y = -65;
			notch.y = 0;
			prev.y = -25.2;
		}
		
		public function precise():Boolean{
			return (next.y == -65 && notch.y == 0 && prev.y == -25.2);
		}
	
	}

}