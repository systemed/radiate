class Accommodation
	include DataMapper::Resource

	property :id,			Serial
	property :name,			String, :length => 80
	property :location,		PostGISGeometry, :index => true, :lazy => true
	property :category,		Enum[ :group, :hostel, :self_catering, :caravan, :camping, :caravan_camping, :hotel, :b_and_b ]
	property :source,		String

	# :group			- Group Accommodation, Campus, Activity Accommodation
	# :hostel			- Hostel, Bunkhouse
	# :self_catering	- Self Catering
	# :caravan			- Touring Park, Holiday & Touring Park
	# :camping			- Camping Park
	# :caravan_camping	- Touring & Camping Park, Holiday, Touring & Camping Park, Holiday Centre
	# :hotel			- Hotel, Inn, Budget Hotel, Country House Hotel, Restaurant with Rooms, Small Hotel, Metro Hotel
	# :b_and_b			- Guest House, Guest Accommodation, Bed & Breakfast, Farmhouse

end
