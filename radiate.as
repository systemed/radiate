package {

	import radiate.*;
	import flash.display.*;
	import flash.events.*;
	import flash.external.ExternalInterface;

	[Frame(factoryClass="radiate")]
	public class radiate extends Sprite {

		public var theMap:Map;

		function radiate():void {
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			this.loaderInfo.addEventListener(Event.COMPLETE, startApp);
		}
		
		private function startApp(event:Event):void {
			// Get parameters
			var params:Object={}; var k:String;
			for (k in this.loaderInfo.parameters) params[k]=this.loaderInfo.parameters[k];
			// do something with params

			// Initialise map
			theMap = new Map();
            theMap.updateSize(stage.stageWidth, stage.stageHeight);
			addChild(theMap);
			theMap.init(params['lat'], params['lon'], params['zoom']);

			// Zoom buttons
			var z1:Sprite=new Sprite();
			z1.graphics.beginFill(0x0000FF); z1.graphics.drawRoundRect(0,0,20,20,5); z1.graphics.endFill();
			z1.graphics.lineStyle(2,0xFFFFFF);
			z1.graphics.moveTo(5,10); z1.graphics.lineTo(15,10);
			z1.graphics.moveTo(10,5); z1.graphics.lineTo(10,15);
			z1.x=5; z1.y=5; z1.buttonMode=true;
			z1.addEventListener(MouseEvent.CLICK, zoomInHandler, false, 1);
			addChild(z1);

			var z2:Sprite=new Sprite();
			z2.graphics.beginFill(0x0000FF); z2.graphics.drawRoundRect(0,0,20,20,5); z2.graphics.endFill();
			z2.graphics.lineStyle(2,0xFFFFFF);
			z2.graphics.moveTo(5,10); z2.graphics.lineTo(15,10);
			z2.x=5; z2.y=30; z2.buttonMode=true;
			z2.addEventListener(MouseEvent.CLICK, zoomOutHandler, false, 1);
			addChild(z2);

			// Listeners
			stage.addEventListener(MouseEvent.MOUSE_UP, theMap.mouseUpHandler);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, theMap.mouseMoveHandler);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, theMap.mouseDownHandler);

			// TileSet
			theMap.tileset.init({ url: "http://otile1.mqcdn.com/tiles/1.0.0/map/$z/$x/$y.jpg" },true);

			// JavaScript integration
			// ExternalInterface.addCallback('jumpTo', onJumpTo);
			ExternalInterface.addCallback("testInterface", testInterface);
		}

		private function zoomInHandler(e:MouseEvent):void  { e.stopPropagation(); theMap.zoomIn(); }
		private function zoomOutHandler(e:MouseEvent):void { e.stopPropagation(); theMap.zoomOut(); }

		public function testInterface():void {
			console.log("Interface running");
		}
	}
}
