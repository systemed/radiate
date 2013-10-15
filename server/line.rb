class Line
	include DataMapper::Resource

	property :id,			Serial
	property :name,			String, :length => 80
	property :location,		PostGISGeometry, :index => true, :lazy => true
	property :type,			LTree, :index => true
	property :value1,		Float
	property :value2,		Float
	property :source,		String, :length => 80
	property :source_ref,	String, :length => 80

	def struct
		linestring = location.respond_to?('geometries') ? location.geometries[0].points : location.points
 		{
			id: id,
			name: name,
			type: type,
			location: Polylines::Encoder.encode_points(linestring.collect {|p| [p.y,p.x]} ),
			geometry: 'polyline',
			value1: value1,
			value2: value2,
			source: source,
			source_ref: source_ref
		}
	end

	def api_request
		[200, Router::HEADERS_JSON, [struct.to_json] ]
	end
end
