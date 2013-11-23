package {
	
	import flash.display.MovieClip;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.events.Event;
	import flash.display.NativeWindowType;
	import flash.filesystem.File;
	import flash.display.NativeWindow;
	import flash.display.NativeWindowInitOptions;
	import flash.display.NativeWindowSystemChrome;
	import flash.ui.ContextMenu;
	import flash.display.Screen;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.display.NativeMenu;
	import flash.filesystem.FileStream;
	import flash.filesystem.FileMode;
	import flash.events.MouseEvent;
	import fl.transitions.Tween;
	import com.greensock.easing.Strong;
	import flash.events.FocusEvent;
	import flash.desktop.NativeApplication;
	import flash.geom.Rectangle;
	
	public class Main extends MovieClip {
		
		private const VERSION:String = "2.45";
		private const MENU:XML = <menu>
			<menu name="Start at login" shortcut="" modify="false" separator="false" />
			<menu name="Always on Top" shortcut="" modify="false" separator="false" />
			<!--menu name="" shortcut="" modify="false" separator="true" /-->
			<menu name="Auto Hide" shortcut="" modify="false" separator="false" />
			<menu name="Mute" shortcut="" modify="false" separator="false" />
			<menu name="Clock Type" shortcut="" modify="false" separator="false">
				<menu name="Flip" shortcut="" modify="false" separator="false" />
				<menu name="Combination" shortcut="" modify="false" separator="false" />
			</menu>
			<menu name="Snap To" shortcut="" modify="false" separator="false">
				<menu name="Top" shortcut="" modify="false" separator="false" />
				<menu name="Right" shortcut="" modify="false" separator="false" />
				<menu name="Bottom" shortcut="" modify="false" separator="false" />
				<menu name="Left" shortcut="" modify="false" separator="false" />
				<menu name="None" shortcut="" modify="false" separator="false" />
			</menu>
			<menu name="" shortcut="" modify="false" separator="true" />
			<menu name="Exit" shortcut="" modify="false" separator="false" />
		</menu>
		private const OPT:XML = <options version="">
		<target event="COVENANT UNIVERSITY GRADUATION" year="2012" month="5" day="29" hour="5" minute="00" />
		<position x="0" y="0" orientation="Right" />
		<loginstart>true</loginstart>
		<ontop>true</ontop>
		<autohide>true</autohide>
		<audible>true</audible>
		<clocktype>Flip</clocktype>
		</options>;
		private const OPT_FILENAME:String = "options.xml";
		
		private var opt:XML, optFile:File, optURL:String, optLoader:URLLoader;
		private var cw:NativeWindow, cwInitOpt:NativeWindowInitOptions, clock:Clock;
		private var optMenu:NativeMenu, autohide:Boolean, audible:Boolean, type:String;
		private var target:Object, position:Object, tweenPostion:Tween, tweenAlpha:Tween, duration:Number = .3;
		
		// CONSTRUCTOR
		public function Main() {
			stage.nativeWindow.visible = false;
			optMenu = new CustomMenu();
			(optMenu as CustomMenu).setConfig(MENU);
			//(optMenu as CustomMenu).addEventListener("complete", menuListeners);
			cwInitOpt = new NativeWindowInitOptions();
			cwInitOpt.maximizable = false;
			cwInitOpt.minimizable = false;
			cwInitOpt.resizable = false;
			cwInitOpt.systemChrome = NativeWindowSystemChrome.NONE;
			cwInitOpt.transparent = true;
			cwInitOpt.type = NativeWindowType.LIGHTWEIGHT;
			cw = new NativeWindow(cwInitOpt);
			cw.x = 0; cw.y = 0;
			cw.alwaysInFront = true;
			cw.height = Screen.mainScreen.visibleBounds.height;
			cw.width = Screen.mainScreen.visibleBounds.width;
			cw.stage.stageHeight = cw.height;
			cw.stage.stageWidth = cw.width;
			cw.stage.align = StageAlign.TOP_LEFT;
			cw.stage.scaleMode = StageScaleMode.NO_SCALE;
			cw.activate();
			stage.nativeWindow.close();
			
			// pick the options file to load
			optFile = new File(File.applicationStorageDirectory.nativePath + File.separator + OPT_FILENAME);
			if(optFile.exists){
				// load the options XML
				optLoader = new URLLoader();
				optLoader.addEventListener(Event.COMPLETE, optLoaded);
				optLoader.load( new URLRequest(optFile.url) );
			}
			else{
				// create the options XML from the default
				opt = new XML(OPT);
				setClock();
			}
		}
		
		private function optLoaded(e:Event):void {
			opt = new XML(e.target.data);
			checkVersion();
			setClock();
		}
		private function checkVersion():void{
			if(!opt.@version || opt.@version != VERSION) opt = new XML(OPT);
			opt.@version = VERSION;
		}
		
		private function setClock(e:Event = null):void{
			// extract XML data
			type = opt.clocktype.toString();
			audible = Custom.parseBoolean(opt.audible.toString());
			autohide = Custom.parseBoolean(opt.autohide.toString());
			var targetEvent:String = opt.child("target").attribute("event");
			var targetDate:Date = new Date();
			targetDate.setTime(Date.UTC(int(opt.child("target").attribute("year")), int(opt.child("target").attribute("month")), int(opt.child("target").attribute("day")), int(opt.child("target").attribute("hour")), int(opt.child("target").attribute("minute"))));
			
			var clockX:Number = Number(opt.child("position").attribute("x"));
			var clockY:Number = Number(opt.child("position").attribute("y"));
			var clockO:String = opt.child("position").attribute("orientation");
			while(cw.stage.numChildren > 0) cw.stage.removeChildAt(0);
			clock = null;
			clock = createClock(type);
			clock.contextMenu = optMenu;
			cw.stage.addChild(clock);
			
			target = clock.target(targetEvent, targetDate);
			position = clock.position(clockX, clockY, clockO);
			
			clockListeners();
			menuListeners();
			cw.alwaysInFront = Custom.parseBoolean(opt.ontop.toString());
			NativeApplication.nativeApplication.startAtLogin = Custom.parseBoolean(opt.loginstart.toString());
		}
		private function createClock(_type:String):Clock{
			_type = type.substr(0,4).toLowerCase();
			if(_type == "flip") return new FlipClock();
			else if(_type == "comb") return new CombClock();
			else { this.type = "Flip"; return new FlipClock(); }
		}
		
		private function clockListeners(e:Event = null):void{
			clock.addEventListener("update", update);
			autohideListeners();
		}
		private function autohideListeners(e:Event = null):void{
			if(autohide){
				cw.addEventListener(Event.ACTIVATE, show);
				cw.addEventListener(Event.DEACTIVATE, hide);
				clock.addEventListener(FocusEvent.FOCUS_IN, show);
				//clock.addEventListener(FocusEvent.FOCUS_OUT, hide);
			}
			else{
				if(cw.hasEventListener(Event.DEACTIVATE)) cw.removeEventListener(Event.DEACTIVATE, hide);
				if(clock.hasEventListener(FocusEvent.FOCUS_OUT)) clock.removeEventListener(FocusEvent.FOCUS_OUT, hide);
			}
			show();
		}
		
		private function menuListeners(e:Event = null):void{
			optMenu.getItemByName("Start at login").addEventListener(Event.SELECT, startAtLoginHandler);
			optMenu.getItemByName("Always on Top").addEventListener(Event.SELECT, onTopHandler);
			optMenu.getItemByName("Auto Hide").addEventListener(Event.SELECT, autohideHandler);
			optMenu.getItemByName("Mute").addEventListener(Event.SELECT, muteHandler);
			optMenu.getItemByName("Clock Type").submenu.getItemByName("Flip").addEventListener(Event.SELECT, typeHandler);
			optMenu.getItemByName("Clock Type").submenu.getItemByName("Combination").addEventListener(Event.SELECT, typeHandler);
			optMenu.getItemByName("Snap To").submenu.getItemByName("Top").addEventListener(Event.SELECT, orientHandler);
			optMenu.getItemByName("Snap To").submenu.getItemByName("Right").addEventListener(Event.SELECT, orientHandler);
			optMenu.getItemByName("Snap To").submenu.getItemByName("Bottom").addEventListener(Event.SELECT, orientHandler);
			optMenu.getItemByName("Snap To").submenu.getItemByName("Left").addEventListener(Event.SELECT, orientHandler);
			optMenu.getItemByName("Snap To").submenu.getItemByName("None").addEventListener(Event.SELECT, orientHandler);
			optMenu.getItemByName("Exit").addEventListener(Event.SELECT, exitHandler);
			updateMenu();
		}
		
		private function update(e:Event = null):void{}
		
		private function dragBounds():Rectangle{
			var bounds:Rectangle = new Rectangle();
			if(position.orientation.toLowerCase() == "top" || position.orientation.toLowerCase() == "bottom"){
				bounds.x = 0 - clock.diff;
				//bounds.y = position.y;
				if(position.orientation.toLowerCase() == "top") bounds.y = -clock.diff;
				else if(position.orientation.toLowerCase() == "bottom") bounds.y = Screen.mainScreen.visibleBounds.height - clock.height + clock.diff;
				bounds.width = Screen.mainScreen.visibleBounds.width - (clock.width - clock.diff*2);
			}
			else if(position.orientation.toLowerCase() == "left" || position.orientation.toLowerCase() == "right"){
				//bounds.x = position.x;
				bounds.y = 0 - clock.diff;
				if(position.orientation.toLowerCase() == "left") bounds.x = -clock.diff;
				else if(position.orientation.toLowerCase() == "right") bounds.x = Screen.mainScreen.visibleBounds.width - clock.width + clock.diff;
				bounds.height = Screen.mainScreen.visibleBounds.height - (clock.height - clock.diff*2);
			}
			else{
				bounds.x = 0 - clock.diff;
				bounds.y = 0 - clock.diff;
				bounds.width = Screen.mainScreen.visibleBounds.width - (clock.width - clock.diff*2);
				bounds.height = Screen.mainScreen.visibleBounds.height - (clock.height - clock.diff*2);
			}
			return bounds;
		}
		private function startClockDrag(e:Event = null):void{
			var bounds:Rectangle = dragBounds();
			clock.addEventListener(MouseEvent.MOUSE_UP, stopClockDrag);
			clock.startDrag(false, bounds);
		}
		private function stopClockDrag(e:Event = null):void{
			clock.stopDrag();
			clock.removeEventListener(MouseEvent.MOUSE_UP, stopClockDrag);
		}
		
		private function updateMenu(e:Event = null):void{
			CustomMenu.selectOnlyFrom(optMenu.getItemByName("Snap To").submenu.getItemByName(position.orientation), optMenu.getItemByName("Snap To").submenu);
			CustomMenu.selectOnlyFrom(optMenu.getItemByName("Clock Type").submenu.getItemByName(type), optMenu.getItemByName("Clock Type").submenu);
			optMenu.getItemByName("Mute").checked = !audible;
			optMenu.getItemByName("Auto Hide").checked = autohide;
			optMenu.getItemByName("Always on Top").checked = cw.alwaysInFront;
			optMenu.getItemByName("Start at login").enabled = NativeApplication.supportsStartAtLogin;
			optMenu.getItemByName("Start at login").checked = NativeApplication.nativeApplication.startAtLogin;
		}
		
		private function show(e:Event = null):void{
			clock.audible = audible;
			if(tweenAlpha != null && tweenAlpha.isPlaying){
				tweenAlpha.stop();
			}
			tweenAlpha = new Tween(clock, "alpha", Strong.easeOut, clock.alpha, 1, duration, true);
			if(tweenPostion != null && tweenPostion.isPlaying){
				tweenPostion.stop();
			}
			if(position.orientation.toLowerCase() == "top") tweenPostion = new Tween(clock, "y", Strong.easeOut, clock.y, -clock.diff, duration, true);
			else if(position.orientation.toLowerCase() == "right") tweenPostion = new Tween(clock, "x", Strong.easeOut, clock.x, Screen.mainScreen.visibleBounds.width - clock.width + clock.diff, duration, true);
			else if(position.orientation.toLowerCase() == "bottom") tweenPostion = new Tween(clock, "y", Strong.easeOut, clock.y, Screen.mainScreen.visibleBounds.height - clock.height + clock.diff, duration, true);
			else if(position.orientation.toLowerCase() == "left") tweenPostion = new Tween(clock, "x", Strong.easeOut, clock.x,  -clock.diff, duration, true);
			
			clock.addEventListener(MouseEvent.MOUSE_DOWN, startClockDrag);
		}
		private function hide(e:Event = null):void{
			clock.audible = false;
			if(tweenAlpha != null && tweenAlpha.isPlaying){
				tweenAlpha.stop();
			}
			tweenAlpha = new Tween(clock, "alpha", Strong.easeOut, clock.alpha, 0.1, duration, true);
			if(tweenPostion != null && tweenPostion.isPlaying){
				tweenPostion.stop();
			}
			if(position.orientation.toLowerCase() == "top" || position.orientation.toLowerCase() == "bottom") tweenPostion = new Tween(clock, "y", Strong.easeOut, clock.y, position.y, duration, true);
			else if(position.orientation.toLowerCase() == "right" || position.orientation.toLowerCase() == "left") tweenPostion = new Tween(clock, "x", Strong.easeOut, clock.x, position.x, duration, true);
		}
		
		private function startAtLoginHandler(e:Event):void{
			NativeApplication.nativeApplication.startAtLogin = !e.target.checked;
			saveOpt();
			updateMenu();
		}
		private function onTopHandler(e:Event):void{
			cw.alwaysInFront = !e.target.checked;
			saveOpt();
			updateMenu();
		}
		private function autohideHandler(e:Event):void{
			autohide = !autohide;
			autohideListeners();
			saveOpt();
			updateMenu();
		}
		private function muteHandler(e:Event):void{
			audible = !audible;
			clock.audible = audible;
			saveOpt();
			updateMenu();
		}
		private function orientHandler(e:Event):void{
			var orientation:String
			if(e && e.target && e.target.name)  orientation = e.target.name;
			else orientation = "None";
			position = clock.position(clock.x, clock.y, orientation);
			show();
			saveOpt();
			updateMenu();
		}
		private function typeHandler(e:Event):void{
			if(e && e.target && e.target.name)  type = e.target.name;
			else type = "Flip";
			saveOpt();
			setClock();
			updateMenu();
		}
		private function exitHandler(e:Event):void{
			saveOpt();
			NativeApplication.nativeApplication.exit();
		}
		
		private function saveOpt(e:Event = null):Object{
			opt.@version = VERSION;
			opt.position.@x = clock.x;
			opt.position.@y = clock.y;
			opt.position.@orientation = position.orientation;
			opt.loginstart = NativeApplication.nativeApplication.startAtLogin.toString();
			opt.ontop = cw.alwaysInFront;
			opt.autohide = autohide;
			opt.audible = audible;
			opt.clocktype = type;
			try{
				var fileStream:FileStream = new FileStream();
				fileStream.open(optFile, FileMode.WRITE);
				fileStream.writeUTFBytes(opt.toXMLString());
				fileStream.close();
				return {saved:true, error:null};
			}
			catch(e:Error){
				return {saved:false, error:e};
			}
			return {saved:false, error:null};
		}
		
	}
	
}