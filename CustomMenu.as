package 
{
	import flash.display.NativeMenu;
	import flash.filesystem.File;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.events.Event;
	import flash.display.NativeMenuItem;
	
	public class CustomMenu extends NativeMenu{
		
		private var config:XML, configUrl:String;
		private var configFile:File, configLoader:URLLoader
		
		public function CustomMenu():void{
		}
		
		public function setConfig(data:Object):void{
			config = new XML(data);
			removeAllItems();
			createMenu(this, config.children());
		}
		
		public function loadConfig(configUrl:String):void{
			this.configUrl = configUrl
			configFile = new File(configUrl);
			if(configFile.exists && !configFile.isDirectory){
				configLoader = new URLLoader(new URLRequest(configFile.url));
				configLoader.addEventListener(Event.COMPLETE, configLoaded);
			}
			else{
				dispatchEvent(new Event("not existing"));
			}
		}
		
		private function configLoaded(e:Event):void{
			setConfig(e.target.data);
			dispatchEvent(new Event("loaded"));
		}
		
		
		
		private function createMenu(menu:NativeMenu, xmlList:XMLList):void{
			var complexContent:Boolean = false;
			for(var i:int = 0; i < xmlList.length(); i++){
				//trace(xmlList[i].@name, xmlList[i].@shortcut, Boolean(Number(xmlList[i].@separator)));
				var menuItem:NativeMenuItem = createMenuItem(xmlList[i].@name, xmlList[i].@shortcut, Custom.parseBoolean(xmlList[i].@separator));
				if(Custom.parseBoolean(xmlList[i].@modify)){
					menuItem.keyEquivalentModifiers = [];
				}
				menuItem.name = xmlList[i].@name;
				menu.addItem(menuItem);
				if((complexContent = xmlList[i].hasComplexContent())){
					var subMenu:NativeMenu = new NativeMenu();
					menuItem.submenu = subMenu;
					createMenu(menuItem.submenu, xmlList[i].children());
				}
			}
			if(!complexContent) this.dispatchEvent(new Event(Event.COMPLETE));
		}
		
		private function createMenuItem(name:String, shortcut:String, isSeparator:Boolean):NativeMenuItem{
			var menuItem:NativeMenuItem = new NativeMenuItem(name, isSeparator);
			menuItem.keyEquivalent = shortcut;
			return menuItem;
		}
		
		public static function selectOnlyFrom(item:NativeMenuItem, menu:NativeMenu):void{//:Boolean{
			//if(menu.containsItem(item)){
				for(var i:int = 0; i < menu.numItems; i++){
					if(item == menu.getItemAt(i)){
						menu.getItemAt(i).checked = true;
					}
					else{
						menu.getItemAt(i).checked = false;
					}
				}
			//}
			//return menu.containsItem(item);
		}
		
	}
	
}