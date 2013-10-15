package radiate {

	import radiate.objects.*;
	
	public class Layer {
		public var name:String;
		public var strength:Number;
		public var radius:Number;
		public var objects:Object={};
		public var enabled:Boolean=true;

		public function Layer(_name:String):void {
			name=_name;
		}
		
		public function add(d:DataObject):void {
			if (!objects[d.id]) { objects[d.id]=d; }
		}
		
		public function has(id:uint):Boolean {
			return Boolean(objects[id]);
		}

		// Draw all items in this layer
		public function draw(minlon:Number,minlat:Number,maxlon:Number,maxlat:Number,heatmap:HeatMap):void {
			if (!enabled) return;
			var coordRadius:Number=heatmap.map.metres2coord(radius);
			for each (var obj:DataObject in objects) {
				if (obj.within(minlon,minlat,maxlon,maxlat)) {
					obj.draw(heatmap,coordRadius,strength);
				}
			}
		}
		
		public function drawObject(id:uint,heatmap:HeatMap):void {
			var coordRadius:Number=heatmap.map.metres2coord(radius);
			objects[id].draw(heatmap,coordRadius);
		}
	}
}
