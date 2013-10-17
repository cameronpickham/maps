// Generated by CoffeeScript 1.6.3
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  App.Overlay = (function(_super) {
    __extends(Overlay, _super);

    function Overlay(map, data) {
      this.map_ = map;
      this.div_ = null;
      this.data = data;
      this.svgOverlay = null;
      this.setMap(map);
    }

    Overlay.prototype.onAdd = function() {
      var layer, svg;
      layer = d3.select(this.getPanes().overlayLayer).append("div").attr("id", "stations");
      svg = layer.append("svg");
      this.div_ = document.getElementById("stations");
      return this.svgOverlay = svg.append("g").attr("class", "lol");
    };

    Overlay.prototype.draw = function() {
      var googleMapProjection, overlayProjection, padding, pathAttr, polygons, positions;
      padding = 10;
      overlayProjection = this.getProjection();
      googleMapProjection = function(coordinates) {
        var googleCoordinates, pixelCoordinates;
        googleCoordinates = new google.maps.LatLng(coordinates[0], coordinates[1]);
        pixelCoordinates = overlayProjection.fromLatLngToDivPixel(googleCoordinates);
        return [pixelCoordinates.x + 4000, pixelCoordinates.y + 4000];
      };
      positions = [];
      this.data.forEach(function(d) {
        return positions.push(googleMapProjection(d.latLng));
      });
      polygons = d3.geom.voronoi(positions);
      pathAttr = {
        d: function(d, i) {
          return "M" + polygons[i].join("L") + "Z";
        },
        stroke: "red",
        fill: "none"
      };
      return this.svgOverlay.selectAll("path").data(this.data).attr(pathAttr).enter().append("svg:path").attr("class", "cell").attr(pathAttr);
    };

    Overlay.prototype.onRemove = function() {
      this.div_.parentNode.removeChild(this.div_);
      return this.div_ = null;
    };

    Overlay.prototype.toggleDOM = function() {
      if (this.getMap()) {
        return this.setMap(null);
      } else {
        return this.setMap(this.map_);
      }
    };

    return Overlay;

  })(google.maps.OverlayView);

}).call(this);
