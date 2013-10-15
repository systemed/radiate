package radiate.utils {

	public class GooglePolyline {
		
		// from https://github.com/jieter/Leaflet.encoded/blob/master/Polyline.encoded.js
		// see also https://gist.github.com/ajturner/733488
		// and http://blog.duncanhall.net/2010/02/as3-encoded-polyline-algorithm-for-google-maps/
		
		public static function decode(encoded:String):Array {
			var len:Number = encoded.length;
			var index:uint = 0;
			var latlngs:Array = [];
			var lat:Number = 0;
			var lng:Number = 0;

			while (index < len) {
				var b:uint;
				var shift:uint = 0;
				var result:uint = 0;
				do {
					b = encoded.charCodeAt(index++) - 63;
					result |= (b & 0x1f) << shift;
					shift += 5;
				} while (b >= 0x20);
				var dlat:Number = ((result & 1) ? ~(result >> 1) : (result >> 1));
				lat += dlat;

				shift = 0;
				result = 0;
				do {
					b = encoded.charCodeAt(index++) - 63;
					result |= (b & 0x1f) << shift;
					shift += 5;
				} while (b >= 0x20);
				var dlng:Number = ((result & 1) ? ~(result >> 1) : (result >> 1));
				lng += dlng;

				latlngs.push([lat * 1e-5, lng * 1e-5]);
			}
			return latlngs;
		}
	}
}
