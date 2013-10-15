Radiate
=======

Radiate is a flexible heatmap engine in ActionScript 3. It supports points, polygons and polylines. Each can be applied with varying radius and strength.

Geometries are requested from a server using a simple API. Radius and strength is set via a method which can be called via JavaScript from the embedding page.

You can see a deployment of this project at www.growingroutes.org.uk.

Compiling
---------

`mxmlc radiate.as -output=/path/to/radiate.swf`

(as usual, add  `-verbose-stacktraces` for debug information)

JavaScript interface
--------------------

Call refreshLayers from JavaScript

`mapswf.refreshLayers(obj);`

with an object containing settings for each layer:

`{ name1: { radius: 5, strength: 50, enabled: true },
   name2: { radius: 1, strength: 100, enabled: false } }`

Database API
------------

Radiate expects to call an API located at `/api`: you can change API_URL in HeatMap.as to alter this. The API should provide two calls:

`/bbox`

Call with `bbox`, a JSON array of [bottom,left,top,right] latitudes and longitudes; and `layers`, a JSON array of layer names requested.

Returns a hash of areas, lines, routes, and accommodations (points) found in that bbox. Accommodations are returned as id, name, category, and a lat/lon pair: all others are returned as id, name, type only.

TODO: rationalise accommodation into generic 'point' type.

`/multiple`

Call with `requests`, a hash of lines, routes, and areas for which the geometry is desired.

Returns geometries for each object.

See `server/` for excerpts from a Ruby implementation of this API.

Um, Flash?
-----------

At the time of initially developing this code, native browser support for filters was less than ideal. The situation is continually improving and I'd anticipate that, in time, this will be ported to become an SVG overlay to Leaflet.

Licence and credits
-------------------

WTFPL.

Heatmap code by Richard Fairhurst, @richardf, richard@systemeD.net. Slippy map code adapted from Potlatch 2 (also WTFPL).
