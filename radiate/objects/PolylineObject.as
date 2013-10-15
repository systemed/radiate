package radiate.objects {

	import flash.display.*;
	import flash.geom.*;
	import flash.filters.*;
	import radiate.*;

	public class PolylineObject extends DataObject {
		public var path:Array;
		private var offsetx:Array=[];
		private var offsety:Array=[];
		private var latp:Array=[];
		private var df:Array=[];
		private static var CHUNK_SIZE:uint=10000;

		public function PolylineObject(_id:Number, _coords:Array, _map:Map) {
			id=_id; path=_coords.slice();
			for (var i:uint=0; i<path.length; i++) latp[i]=_map.lat2latp(path[i][0]);
		}

		override public function draw(heatmap:HeatMap, radius:Number, strength:Number):void {
			var colour:uint = strengthToColour(strength);			// these control darkness of line
			var linecolour:uint = strengthToColour(strength);		//  |
			var r:Number=radius;

			for (var start:uint=0; start<path.length; start+=CHUNK_SIZE) {
				var end:uint=Math.min(start+CHUNK_SIZE-1,path.length);
				var polyline:Shape = new Shape();
				for (var i:uint=start; i<end; i++) {
					var p:Point=heatmap.project(path[i][0],path[i][1]);
					if (heatmap.onScreen(p,r)) {
						polyline.graphics.beginFill(colour,1);
						polyline.graphics.drawCircle(p.x,p.y,r);
						polyline.graphics.endFill();
					}
				}

				for (i=start; i<end-1; i++) {
					var x1:Number=path[i  ][1]; var y1:Number=latp[i  ];
					var x2:Number=path[i+1][1]; var y2:Number=latp[i+1];
					var dx:Number = x2 - x1; 
					var dy:Number = y2 - y1; 
					var perp_x:Number =  dy 
					var perp_y:Number = -dx; 
					var len:Number = Math.sqrt( perp_x * perp_x + perp_y * perp_y ); 
					perp_x /= len; perp_x *= r;
					perp_y /= len; perp_y *= r;

					var p1:Point=heatmap.project_latp(y1,x1);
					var p2:Point=heatmap.project_latp(y2,x2);
					if (heatmap.lineOnScreen(p1,p2,r)) {
						polyline.graphics.beginFill(colour,1);
						polyline.graphics.moveTo(p1.x+perp_x,p1.y+perp_y);
						polyline.graphics.lineTo(p2.x+perp_x,p2.y+perp_y);
						polyline.graphics.lineTo(p2.x-perp_x,p2.y-perp_y);
						polyline.graphics.lineTo(p1.x-perp_x,p1.y-perp_y);
						polyline.graphics.lineTo(p1.x+perp_x,p1.y+perp_y);
						polyline.graphics.endFill();
					}
				}

				polyline.filters=[ new GlowFilter(colour, 1, r, r, 16, 2),
								  new BlurFilter(r, r, 1) ];

				heatmap.bitmap.draw(polyline,null,null,blendMode(strength));
			}
		}

		/** Compute determinant. */
		private function det(a:Number,b:Number,c:Number,d:Number):Number { return a*d-b*c; }

	}

}
