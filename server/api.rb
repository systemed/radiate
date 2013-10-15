class API
	def self.bbox_request(params)
		# returns all POIs, and a list of areas/routes intersecting that bbox
		s,w,n,e= JSON.parse(params['bbox'])
		layers = JSON.parse(params['layers'])

		bbox   = GeoRuby::SimpleFeatures::LineString.from_coordinates( [ [w,s], [e,s], [e,n], [w,n], [w,s] ], 4326 )
		areas  = Area.all( :location.bbox_overlaps => bbox, :type => layers )
		routes = Route.all( :location.bbox_overlaps => bbox, :type => layers )
		lines  = Line.all( :location.bbox_overlaps => bbox, :type => layers )
		accomm = Accommodation.all( :location.bbox_overlaps => bbox )

		[200, Router::HEADERS_JSON, [ {
			:areas => areas.collect { |obj| {
				:id => obj.id,
				:name => obj.name,
				:type => obj.type
			} },
			:lines => lines.collect { |obj| {
				:id => obj.id,
				:name => obj.name,
				:type => obj.type
			} },
			:routes => routes.collect { |obj| {
				:id => obj.id,
				:name => obj.name,
				:type => obj.type
			} },
			:accommodations => accomm.collect { |obj| {
				:id => obj.id,
				:name => obj.name,
				:location => [obj.location.lat, obj.location.lon],
				:category => obj.category
			} }
		}.to_json] ]
	end

	def self.multiple(params)
		requests=JSON.parse(params['requests'])
		response={
			:lines  => requests['line' ].collect { |id|  Line.get(id.to_i).struct },
			:routes => requests['route'].collect { |id| Route.get(id.to_i).struct },
			:areas  => requests['area' ].collect { |id|  Area.get(id.to_i).struct }
		}
		[200, Router::HEADERS_JSON, [response.to_json] ]
	end

	def self.capabilities
		route_types = Route.find_by_sql(["SELECT DISTINCT type FROM routes"], :properties=>:type).collect { |obj| obj.type }.sort
		area_types  = Area.find_by_sql(["SELECT DISTINCT type FROM areas"], :properties=>:type).collect { |obj| obj.type }.sort
		line_types  = Area.find_by_sql(["SELECT DISTINCT type FROM lines"], :properties=>:type).collect { |obj| obj.type }.sort
		accomm_types= Accommodation.find_by_sql(["SELECT DISTINCT category FROM accommodations"], :properties=>:category).collect { |obj| obj.category }.sort
		
		[200, Router::HEADERS_JSON, [ [
			{ :name => 'route', :types => route_types, :geometry => 'polyline' },
			{ :name => 'area', :types => area_types, :geometry => 'polygon' },
			{ :name => 'line', :types => line_types, :geometry => 'polyline' },
			{ :name => 'accommodation', :types => accomm_types, :geometry => 'point' }
		].to_json ] ]
	end
end
