package radiate.objects {

	import flash.display.*;
	import flash.geom.*;
	import radiate.*;

	public class PointObject extends DataObject {
		public var lat:Number;
		public var lon:Number;

		public function PointObject(_id:Number, _lat:Number,_lon:Number) {
			id=_id; lat=_lat; lon=_lon;
		}
		
		override public function draw(heatmap:HeatMap, radius:Number, strength:Number):void {
			var p:Point=heatmap.project(lat,lon);
			var colour:uint = strengthToColour(strength);

			// Create circle
			// (could this maybe be a static class, so it doesn't have to be constructed every time?)
			var circle:Shape = new Shape();
			var m:Matrix = new Matrix();
			var shapeRadius:Number = 1;
			m.createGradientBox(shapeRadius*2,shapeRadius*2, 0, -shapeRadius,-shapeRadius);
			circle.graphics.beginGradientFill(GradientType.RADIAL,[colour,colour],[1,0],[0,255],m);
			circle.graphics.drawCircle(0,0,shapeRadius);
			circle.graphics.endFill();

			// Place circle
			var t:Matrix = new Matrix(); t.createBox(radius,radius,0,p.x,p.y);	// scaleX,scaleY,rotation,transformX,transformY
			heatmap.bitmap.draw(circle,t,null,blendMode(strength));		// add ,BlendMode.ERASE

		}
	}

}
