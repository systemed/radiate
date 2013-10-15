package radiate {

	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.external.ExternalInterface;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import flash.net.*;
	import flash.text.Font;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	
	public class Map extends Sprite {

		/** master map scale - how many Flash pixels in 1 degree longitude (for Landsat, 5120) */
		public const MASTERSCALE:Number=5825.4222222222; 
												
		/** don't zoom out past this */
		public const MINSCALE:uint=6; 
		/** don't zoom in past this */
		public const MAXSCALE:uint=23; 

		// Heatmap
		private var heatmap:HeatMap;

		/** map scale */
		public var scale:uint=12;
		/** current scaling factor for lon/latp */
		public var scalefactor:Number=MASTERSCALE;

		public var edge_l:Number;						// current bounding box
		public var edge_r:Number;						//  |
		public var edge_t:Number;						//  |
		public var edge_b:Number;						//  |
		public var centre_lat:Number;					// centre lat/lon
		public var centre_lon:Number;					//  |

		/** urllon-xradius/masterscale; */ 
		public var baselon:Number;
		/** lat2lat2p(urllat)+yradius/masterscale; */
		public var basey:Number; 
		/** width (Flash pixels) */
		public var mapwidth:uint; 
		/** height (Flash pixels) */
		public var mapheight:uint; 

		/** Is the map being panned */
		public var dragstate:uint=NOT_DRAGGING;			// dragging map (panning)
		/** Can the map be panned */
		private var _draggable:Boolean=true;			//  |
		private var lastxmouse:Number;					//  |
		private var lastymouse:Number;					//  |
		private var downX:Number;						//  |
		private var downY:Number;						//  |
		private var downTime:Number;					//  |
		public const NOT_DRAGGING:uint=0;				//  |
		public const NOT_MOVED:uint=1;					//  |
		public const DRAGGING:uint=2;					//  |
		public const SWALLOW_MOUSEUP:uint=3;			//  |
		/** How far the map can be dragged without actually triggering a pan. */
		public const TOLERANCE:uint=7;					//  |

		/** reference to backdrop sprite */
		public var backdrop:Object; 
		/** background tile object */
		public var tileset:TileSet; 
		/** show all objects, even if unstyled? */
		public var showall:Boolean=true; 
		
		// ------------------------------------------------------------------------------------------
		/** Map constructor function */
		public function Map() {
			// Remove any existing sprites
			while (numChildren) { removeChildAt(0); }

			// 900913 background
			tileset=new TileSet(this);
			addChild(tileset);

			// Heatmap
			heatmap = new HeatMap(this);
			addChild(heatmap);

			addEventListener(Event.ENTER_FRAME, everyFrame);
			scrollRect=new Rectangle(0,0,800,600);
		}

		// ------------------------------------------------------------------------------------------
		/** Initialise map at a given lat/lon */
		public function init(startlat:Number, startlon:Number, startscale:uint=0):void {
			if (startscale>0) {
				scale=startscale;
				this.dispatchEvent(new MapEvent(MapEvent.SCALE, {scale:scale}));
			}
			scalefactor=MASTERSCALE/Math.pow(2,13-scale);
			baselon    =startlon          -(mapwidth /2)/scalefactor;
			basey      =lat2latp(startlat)+(mapheight/2)/scalefactor;
			updateCoords(0,0);
			this.dispatchEvent(new Event(MapEvent.INITIALISED));
			updateLayers();
		}

		// ------------------------------------------------------------------------------------------
		/** Recalculate co-ordinates from new Flash origin */

		private function updateCoords(tx:Number,ty:Number):void {
			setScrollRectXY(tx,ty);
			edge_t=coord2lat(-ty          );
			edge_b=coord2lat(-ty+mapheight);
			edge_l=coord2lon(-tx          );
			edge_r=coord2lon(-tx+mapwidth );
			setCentre();
			tileset.update();
		}
		
		/** Move the map to centre on a given latitude/longitude. */
		private function updateCoordsFromLatLon(lat:Number,lon:Number):void {
			var cy:Number=-(lat2coord(lat)-mapheight/2);
			var cx:Number=-(lon2coord(lon)-mapwidth/2);
			updateCoords(cx,cy);
		}
		
		private function setScrollRectXY(tx:Number,ty:Number):void {
			var w:Number=scrollRect.width;
			var h:Number=scrollRect.height;
			scrollRect=new Rectangle(-tx,-ty,w,h);
		}
		private function setScrollRectSize(width:Number,height:Number):void {
			var sx:Number=scrollRect.x ? scrollRect.x : 0;
			var sy:Number=scrollRect.y ? scrollRect.y : 0;
			scrollRect=new Rectangle(sx,sy,width,height);
		}
		
		public function getX():Number { return -scrollRect.x; }
		public function getY():Number { return -scrollRect.y; }
		
		private function setCentre():void {
			centre_lat=coord2lat(-getY()+mapheight/2);
			centre_lon=coord2lon(-getX()+mapwidth/2);
			this.dispatchEvent(new MapEvent(MapEvent.MOVE, {lat:centre_lat, lon:centre_lon, scale:scale, minlon:edge_l, maxlon:edge_r, minlat:edge_b, maxlat:edge_t}));
		}
		
		/** Sets the offset between the background imagery and the map. */
		public function nudgeBackground(x:Number,y:Number):void {
			this.dispatchEvent(new MapEvent(MapEvent.NUDGE_BACKGROUND, { x: x, y: y }));
		}

		private function moveMap(dx:Number,dy:Number):void {
			trace("moveMap");
			updateCoords(getX()+dx,getY()+dy);
			updateLayers();
		}
		
		/** Recentre map at given lat/lon */
		public function moveMapFromLatLon(lat:Number,lon:Number):void {
			updateCoordsFromLatLon(lat,lon);
			updateLayers();
		}
		
		/** Recentre map at given lat/lon, if that point is currently outside the visible area. */
		public function scrollIfNeeded(lat:Number,lon:Number): void{
			if (lat> edge_t || lat < edge_b || lon < edge_l || lon > edge_r) {
				moveMapFromLatLon(lat, lon);
			}
		}

		// Co-ordinate conversion functions

		public function latp2coord(a:Number):Number	{ return -(a-basey)*scalefactor; }
		public function coord2latp(a:Number):Number	{ return a/-scalefactor+basey; }
		public function lon2coord(a:Number):Number	{ return (a-baselon)*scalefactor; }
		public function coord2lon(a:Number):Number	{ return a/scalefactor+baselon; }

		public function latp2lat(a:Number):Number	{ return 180/Math.PI * (2 * Math.atan(Math.exp(a*Math.PI/180)) - Math.PI/2); }
		public function lat2latp(a:Number):Number	{ return 180/Math.PI * Math.log(Math.tan(Math.PI/4+a*(Math.PI/180)/2)); }

		public function lat2coord(a:Number):Number	{ return -(lat2latp(a)-basey)*scalefactor; }
		public function coord2lat(a:Number):Number	{ return latp2lat(a/-scalefactor+basey); }

		public function metres2coord(a:Number):Number {
			var latfactor:Number=Math.cos(centre_lat/(180/Math.PI));	// 111200m in a degree at the equator
			return scalefactor/(111200*latfactor)*a;					// 111200m*cos(lat in radians) elsewhere
		}

		// ------------------------------------------------------------------------------------------
		/** Resize map size based on current stage and height */

		public function updateSize(w:uint, h:uint):void {
			mapwidth = w; centre_lon=coord2lon(-getX()+w/2);
			mapheight= h; centre_lat=coord2lat(-getY()+h/2);
			setScrollRectSize(w,h);
			updateCoords(getX(),getY());

			this.dispatchEvent(new MapEvent(MapEvent.RESIZE, {width:w, height:h}));
			
			if ( backdrop != null ) {
				backdrop.width=mapwidth;
				backdrop.height=mapheight;
			}
			if ( mask != null ) {
				mask.width=mapwidth;
				mask.height=mapheight;
			}
		}

		// Update heatmap etc.

		public function updateLayers():void {
			// download bbox at edge_l,edge_r,edge_t,edge_b
			heatmap.redraw();
			heatmap.requestData();
		}
		
		public function zoomIn():void {
			if (scale!=MAXSCALE) changeScale(scale+1);
		}

		public function zoomOut():void {
			if (scale!=MINSCALE) changeScale(scale-1);
		}

		private function changeScale(newscale:uint):void {
			scale=newscale;
			this.dispatchEvent(new MapEvent(MapEvent.SCALE, {scale:scale}));
			scalefactor=MASTERSCALE/Math.pow(2,13-scale);
			updateCoordsFromLatLon((edge_t+edge_b)/2,(edge_l+edge_r)/2);	// recentre
			tileset.changeScale(scale);
			updateLayers();
		}

		// ==========================================================================================
		// Events
		
		// ------------------------------------------------------------------------------------------
		// Mouse events
		
		/** Should map be allowed to pan? */
		public function set draggable(draggable:Boolean):void {
			_draggable=draggable;
			dragstate=NOT_DRAGGING;
		}

		/** Prepare for being dragged by recording start time and location of mouse. */
		public function mouseDownHandler(event:MouseEvent):void {
			if (!_draggable) { return; }
			if (dragstate==DRAGGING) { moveMap(x,y); dragstate=SWALLOW_MOUSEUP; }	// cancel drag if mouse-up occurred outside the window (thanks, Safari)
			else { dragstate=NOT_MOVED; }
			lastxmouse=stage.mouseX; downX=stage.mouseX;
			lastymouse=stage.mouseY; downY=stage.mouseY;
			downTime=new Date().getTime();
		}

		/** Respond to mouse up by possibly moving map. */
		public function mouseUpHandler(event:MouseEvent=null):void {
			if (dragstate==DRAGGING) { moveMap(x,y); }
			dragstate=NOT_DRAGGING;
		}
		
		/** Respond to mouse movement, dragging the map if tolerance threshold met. */
		public function mouseMoveHandler(event:MouseEvent):void {
			if (!_draggable) { return; }
			if (dragstate==NOT_DRAGGING) { 
				this.dispatchEvent(new MapEvent(MapEvent.MOUSE_MOVE, { x: coord2lon(mouseX), y: coord2lat(mouseY) }));
				return; 
			}
			
			if (dragstate==NOT_MOVED) {
				if (new Date().getTime()-downTime<300) {
					if (Math.abs(downX-stage.mouseX)<=TOLERANCE   && Math.abs(downY-stage.mouseY)<=TOLERANCE  ) return;
				} else {
					if (Math.abs(downX-stage.mouseX)<=TOLERANCE/2 && Math.abs(downY-stage.mouseY)<=TOLERANCE/2) return;
				}
				dragstate=DRAGGING;
			}
			
			setScrollRectXY(getX()+stage.mouseX-lastxmouse,getY()+stage.mouseY-lastymouse);
			lastxmouse=stage.mouseX; lastymouse=stage.mouseY;
			setCentre();
		}
		
		// ------------------------------------------------------------------------------------------
		// Do every frame

		private function everyFrame(event:Event):void {
			if (tileset) { tileset.serviceQueue(); }
			if (stage.focus && !stage.contains(stage.focus)) { stage.focus=stage; }
		}

		// ------------------------------------------------------------------------------------------
		// Miscellaneous events
		
		/** Respond to cursor movements and zoom in/out.*/
		public function keyUpHandler(event:KeyboardEvent):void {
			if (event.target is TextField) return;				// not meant for us
			switch (event.keyCode) {
				case Keyboard.PAGE_UP:		zoomIn(); break;					// Page Up - zoom in
				case Keyboard.PAGE_DOWN:	zoomOut(); break;					// Page Down - zoom out
				case Keyboard.LEFT:			moveMap(mapwidth/2,0); break;		// left cursor
				case Keyboard.UP:			moveMap(0,mapheight/2); break;		// up cursor
				case Keyboard.RIGHT:		moveMap(-mapwidth/2,0); break;		// right cursor
				case Keyboard.DOWN:			moveMap(0,-mapheight/2); break;		// down cursor
			}
		}
	}
}
