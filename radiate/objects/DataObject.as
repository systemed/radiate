package radiate.objects {

	import radiate.Map;
	import radiate.HeatMap;
	import radiate.console;
	import radiate.utils.GooglePolyline;
	import flash.display.BlendMode;

	public class DataObject {
		public var attributes:Object;
		public var weight:Number;		// e.g. a village cluster with 5 B&Bs would =5
		public var id:Number;

		public function draw(heatmap:HeatMap, radius:Number, strength:Number):void {
		}

		public function within(minlon:Number,minlat:Number,maxlon:Number,maxlat:Number):Boolean {
			return true;
		}

		// Convert from a JSON-derived object into a DataObject
		public static function fromObject(obj:Object, map:Map):DataObject {
			switch (obj.geometry) {
				case 'polygon':		return new PolygonObject(obj.id, obj.location);
				case 'polyline':	return new PolylineObject(obj.id, GooglePolyline.decode(obj.location), map);
				default:			return new PointObject(obj.id, obj.location[0], obj.location[1]);
			}
			return null;
		}

		protected function strengthToColour(strength:Number):uint {
			var byte:uint=Math.abs(strength)*200;
			return (  (byte*256+byte)*256+byte )*256+byte;
		}

		protected function blendMode(strength:Number):String {
			return (strength>0) ? BlendMode.ADD : BlendMode.SUBTRACT;
		}

	}
}
