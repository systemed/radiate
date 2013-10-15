class Area
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
		locations = location.respond_to?('geometries') ? 
			location.geometries.collect { |g| encoded(g.rings[0].points) } : 
			[encoded(location.rings[0].points)]
		{
			id: id,
			name: name,
			type: type,
			location: locations,
			geometry: 'polygon',
			value1: value1,
			value2: value2,
			source: source,
			source_ref: source_ref
		}
	end

	def api_request
		[200, Router::HEADERS_JSON, [struct.to_json] ]
	end
	
	def encoded(points)
		Polylines::Encoder.encode_points(points.collect {|p| [p.y,p.x]} )
	end
end
