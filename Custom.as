package {
	import flash.utils.ByteArray;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.DisplayObject;

	public class Custom {

		public function Custom() {
		}
		
		public static function sign(num:Number):int{
			if(num > 0) return +1;
			else if(num < 0) return -1;
			else return 0;
		}
		public static function random(seed:uint=1, sign:int=0):Number{
			if(sign < 0) return -(Math.random()*seed);
			else if(sign > 0) return +(Math.random()*seed);
			else return seed-Math.random()*(seed*2);
		}
		public static function parseBoolean(value:String):Boolean{
			if(value.toLowerCase() == "true"){
				return true;
			}
			return false;
		}
		
		public static function encodePNG(img:BitmapData):ByteArray {
			// Create output byte array
			var png:ByteArray = new ByteArray  ;
			// Write PNG signature
			png.writeUnsignedInt(0x89504e47);
			png.writeUnsignedInt(0x0D0A1A0A);
			// Build IHDR chunk
			var IHDR:ByteArray = new ByteArray  ;
			IHDR.writeInt(img.width);
			IHDR.writeInt(img.height);
			IHDR.writeUnsignedInt(0x08060000);
			// 32bit RGBA;
			IHDR.writeByte(0);
			writeChunk(png,0x49484452,IHDR);
			// Build IDAT chunk
			var IDAT:ByteArray = new ByteArray  ;
			for (var i:int = 0; i < img.height; i++) {
				// no filter
				IDAT.writeByte(0);
				var p:uint;
				var j:int;
				if (! img.transparent) {
					for (j = 0; j < img.width; j++) {
						p = img.getPixel(j,i);
						IDAT.writeUnsignedInt(uint(p & 0xFFFFFF << 8 | 0xFF));
					}
				}
				else {
					for (j = 0; j < img.width; j++) {
						p = img.getPixel32(j,i);
						IDAT.writeUnsignedInt(uint(p & 0xFFFFFF << 8 | p >>> 24));
					}
				}
			}
			IDAT.compress();
			writeChunk(png,0x49444154,IDAT);
			// Build IEND chunk
			writeChunk(png,0x49454E44,null);
			// return PNG
			return png;
		}

		private static function writeChunk(png:ByteArray,type:uint,data:ByteArray):void {
			
			var crcTable:Array;
			var crcTableComputed:Boolean = false;
			
			if (! crcTableComputed) {
				crcTableComputed = true;
				crcTable = [];
				var c:uint;
				for (var n:uint = 0; n < 256; n++) {
					c = n;
					for (var k:uint = 0; k < 8; k++) {
						if (c & 1) {
							c = uint(uint(0xedb88320) ^ uint(c >>> 1));
						}
						else {
							c = uint(c >>> 1);
						}
					}
					crcTable[n] = c;
				}
			}
			var len:uint = 0;
			if (data != null) {
				len = data.length;
			}
			png.writeUnsignedInt(len);
			var p:uint = png.position;
			png.writeUnsignedInt(type);
			if (data != null) {
				png.writeBytes(data);
			}
			var e:uint = png.position;
			png.position = p;
			c = 0xffffffff;
			for (var i:int = 0; i < e - p; i++) {
				c = uint(crcTable[c ^ png.readUnsignedByte() & uint(0xff)] ^ uint(c >>> 8));
			}
			c = uint(c ^ uint(0xffffffff));
			png.position = e;
			png.writeUnsignedInt(c);
		}
		
		public static function getBitmapData(initialData:ByteArray):DisplayObject{
			var finalData:ByteArray = new ByteArray();
			var byteCon:Loader = new Loader();
			var found:Boolean = false;
			var offset:int;
			var length:int;
			
			initialData.position = 0;
			//get offset and length
			while(!found){
				var pos:int = initialData.readUnsignedInt();
				if(pos == 0x41504943){
					offset = initialData.position + 20;
				}
				if(pos == 0){
					if (!found){
						length = initialData.position - 1 - offset;
						if(length > 5000){
							found = true;
						}
					}
				}
				initialData.position = initialData.position - 3;
			}
		
			finalData.writeBytes(initialData, offset, length);
			finalData.position = 0;
			byteCon.loadBytes(finalData);
			return byteCon.content;
		}
		
		public static function toWords(num:Number):String {
			var str:String = "";
			var numLimit:Number = 999999999999999;
			var len:int = 3;
			var heirachy:Array = ["","thousand","million","billion","trillion","quadrillion"];
			num = Number(num.toFixed(len));
			var deciPat:RegExp = /(?P<num>(\d+))/;
			var preciPat:RegExp = /\.(?P<num>(\d*))/;
			var deci:Object = deciPat.exec(num.toString());
			if(Number(deci.num) > numLimit) deci.num = numLimit.toString();
			var i:int = deci.num.length%len;
			if(i == 0) i = 3;
			for(i; i < len; i++){
				deci.num = "0"+deci.num;
			}
			var h:int = Math.floor((deci.num.length-1)/len);
			for(var j:int = -1; j < h; j++){
				//trace((deci.num as String).substr((j+1)*len,len));
				if(Number((deci.num as String).substr((j+1)*len,len)) != 0)
					str += ", " + toHundredWords(Number((deci.num as String).substr((j+1)*len,len))) + " " + heirachy[h-(j+1)];
			}
			if(str == "") str = "zero";
			str = RegExp(/((\w)+,* *)*\w+/).exec(str)[0];
			var preci:Object = preciPat.exec(num.toString());
			if(preci != null && preci.num != "") str += " point" + toPreciWords(preci.num);
			return str;
		}
		private static function toHundredWords(num:Number):String{
			var str:String = "";
			var hundreds:int,tens:int,units:int;
			if(num > 999) num = 999;
			hundreds = Math.floor(num / 100);
			num %=  100;
			tens = Math.floor(num / 10);
			units = (num%=10);
			if (hundreds > 0 && str.length > 0) {
				str +=  ", ";
			}
			if (hundreds > 0 && hundreds < 10) {
				str +=  toUnitWord(hundreds) + " hundred";
			}
			if ((tens > 0 || units > 0) && str.length > 0) {
				str +=  " and ";
			}
			if (tens == 1) {
				str +=  toTenWord(tens * 10 + units);
			}
			else if ((tens > 1 && tens < 10) || str.length == 0 || str.substr(str.length-5,5) == " and ") {
				str +=  toTenWord(tens * 10);
				if (units > 0 && str.length > 0 && str.substr(str.length-1,1) != " ") {
					str +=  " ";
				}
				if (units > 0 && units < 10) {
					str +=  toUnitWord(units);
				}
			}
			if(str.length == 0){
				str += toUnitWord(0);
			}
			return str;
		}
		private static function toUnitWord(num:int):String {
			switch (num) {
				case 0 :
					return "zero";
					break;
				case 1 :
					return "one";
					break;
				case 2 :
					return "two";
					break;
				case 3 :
					return "three";
					break;
				case 4 :
					return "four";
					break;
				case 5 :
					return "five";
					break;
				case 6 :
					return "six";
					break;
				case 7 :
					return "seven";
					break;
				case 8 :
					return "eight";
					break;
				case 9 :
					return "nine";
					break;
				default :
					return "";
					break;
			}
		}
		private static function toPrefix(num:int):String {
			switch (num) {
				case 2 :
					return "twen";
					break;
				case 3 :
					return "thir";
					break;
				case 5 :
					return "fif";
					break;
				case 8 :
					return "eigh";
					break;
				default :
					return toUnitWord(num);
					break;
			}
		}
		private static function toTenWord(num:int):String {
			switch (num) {
				case 10 :
					return "ten";
					break;
				case 11 :
					return "eleven";
					break;
				case 12 :
					return "twelve";
					break;
				case 13 :
				case 14 :
				case 15 :
				case 16 :
				case 17 :
				case 18 :
				case 19 :
					return toPrefix(num%10) + "teen";
					break;
				case 20 :
				case 30 :
				case 40 :
				case 50 :
				case 60 :
				case 70 :
				case 80 :
				case 90 :
					return toPrefix(num/10) + "ty";
				default :
					return "";
			}
		}
		private static function toPreciWords(num:String):String{
			 var str:String = "";
			 for(var i:int = 0; i < num.length; i++){
				 str += " " + toUnitWord(Number(num.substr(i,1)));
			 }
			 return str;
		}
		
	}

}