package {
	
	import flash.display.MovieClip;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.events.Event;
	
	public class CombClock extends Clock {
		
		// CONSTRUCTOR
		public function CombClock() {
			super();
		}
		
		// set the target date and start the countdown timer
		public override function target(event:String, date:Date):Object {
			targetEvent.text = event;
			
			_targetDate = date;
			
			initTimer();
			
			// display the target date above the clock
			t_date.text = _targetDate.toLocaleString().toUpperCase();
			
			// update the clock once here so it starts with the correct time
			hardUpdate();
			
			return {event:targetEvent.text, date:_targetDate};
		}
		
		protected override function hide(arg:String = "all"):void{
			switch(arg){
				case "top":
				case "right":
				case "bottom":
				case "left":
				this[arg].setVisible(false);
				break;
				case "none":
				top.visible = true;
				right.visible = true;
				bottom.visible = true;
				left.visible = true;
				break;
				case "all":
				default:
				top.visible = false;
				right.visible = false;
				bottom.visible = false;
				left.visible = false;
				break;
			}
		}
		protected override function show(arg:String = "all"):void{
			switch(arg){
				case "top":
				case "right":
				case "bottom":
				case "left":
				this[arg].setVisible(true);
				break;
				case "none":
				hide("all");
				break;
				case "all":
				default:
				hide("none");
				break;
			}
		}
		
		protected override function update(e:TimerEvent = null):void {
			var now:Date = new Date(); // get the current time
			if(audible)	_tickSound.play();	
			
			// find the difference (in ms) between the target and now
			var diff:Number = _targetDate.valueOf() - now.valueOf();
			if(diff <=0){
				// TIME'S UP!
				// do something cool here
				_clockTimer.stop();
				_clockTimer.removeEventListener(TimerEvent.TIMER, update);
				diff = 0;
				timeup();
			} 
			
			// convert to seconds
			diff = Math.round(diff/1000);
			
			// number of days
			var days:int = Math.floor(diff/ (24 * 60 * 60));
			diff -= days*(24 * 60 * 60 );
			
			// number of hours
			var hours:int = Math.floor(diff / (60 * 60))
			diff -= hours*60 * 60;
			
			// number of minutes
			var min:int = Math.floor(diff/ 60);
			diff -= min*60;
			
			// seconds are all that remain
			var sec:int = diff;
			
			// create an array of strings to hold the number for each value
			var diffArr:Array = new Array(String(days), String(hours), String(min), String(sec));
			var diffString:String = ""
			var len:int = 3; // the first value (days) has 3 wheels. All the rest have 2
			for each(var s:String in diffArr){
				// pad the string with a leading zero if needed
				while(s.length <len){
					s = "0"+s;
				}
				
				len = 2; // all the other values are 2 wheels in length
				diffString += s; // add the padded string to the diffString
			}
			
			// go through each character in the diffString and set the corresponding wheel
			for(var i:int = 0; i<diffString.length; i++){
				if(diffString.charAt(i) != this["wheel"+i].number || !this["wheel"+i].precise()){
					this["wheel"+i].rollTo(diffString.substr(i, 1));
				}
			}
			//trace("x:"+x+" y:"+y);
			dispatchEvent(new Event("update"));

		}
		
		private function hardUpdate():void{
			var now:Date = new Date(); // get the current time
			var diff:Number = _targetDate.valueOf() - now.valueOf();
			if(diff <=0){
				_clockTimer.stop();
				_clockTimer.removeEventListener(TimerEvent.TIMER, update);
				diff = 0;
				timeup();
			} 
			
			diff = Math.round(diff/1000);
			
			var days:int = Math.floor(diff/ (24 * 60 * 60));
			diff -= days*(24 * 60 * 60 );
			
			var hours:int = Math.floor(diff / (60 * 60))
			diff -= hours*60 * 60;
			
			var min:int = Math.floor(diff/ 60);
			diff -= min*60;
			
			var sec:int = diff;
			
			var diffArr:Array = new Array(String(days), String(hours), String(min), String(sec));
			var diffString:String = ""
			var len:int = 3; 
			for each(var s:String in diffArr){
				// pad the string with a leading zero if needed
				while(s.length <len){
					s = "0"+s;
				}
				
				len = 2;
				diffString += s;
			}
			
			for(var i:int = 0; i<diffString.length; i++){
				this["wheel"+i].reset();
				this["wheel"+i].number = diffString.substr(i, 1);
			}
		}
	
	}

}