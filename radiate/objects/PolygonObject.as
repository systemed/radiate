package radiate.objects {

	import flash.display.*;
	import flash.geom.*;
	import flash.filters.*;
	import radiate.*;
	import radiate.utils.GooglePolyline;

	public class PolygonObject extends DataObject {
		public var paths:Array;

		public function PolygonObject(_id:Number, _location:Array) {
			id=_id;
			paths=[];
			for (var i:uint=0; i<_location.length; i++) {
				paths.push(GooglePolyline.decode(_location[i]));
			}
		}
		
		override public function draw(heatmap:HeatMap, radius:Number, strength:Number):void {
			var polygon:Shape = new Shape();
			var m:Matrix = new Matrix();
			var colour:uint = strengthToColour(strength);		// this controls darkness of polygon
			polygon.filters=[ new GlowFilter(colour, 1, radius, radius, 16, 2),
							  new BlurFilter(radius, radius, 1) 
							];
			polygon.graphics.lineStyle(radius,colour);
			polygon.graphics.beginFill(colour,1);
			for (var a:uint=0; a<paths.length; a++) {
				var path:Array=paths[a];
				for (var i:uint=0; i<path.length; i++) {
					var p:Point=heatmap.project(path[i][0],path[i][1]);
					if (i==0) { polygon.graphics.moveTo(p.x,p.y); }
						 else { polygon.graphics.lineTo(p.x,p.y); }
				}
			}
			polygon.graphics.endFill();

			// Place shape
			heatmap.bitmap.draw(polygon,null,null,blendMode(strength)); //,t,null);		// add ,BlendMode.ERASE
		}
	}
}
