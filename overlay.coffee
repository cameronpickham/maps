class App.Overlay extends google.maps.OverlayView
  constructor: (map, data) ->
    @map_        = map
    @div_        = null
    @data       = data
    @svgOverlay = null

  onAdd: ->
    layer = d3.select(@getPanes().overlayLayer).append("div").attr("id", "stations")
    svg = layer.append("svg")
    @div_ = document.getElementById "stations"
    @svgOverlay = svg.append("g").attr("class", "lol")

  draw: ->
    padding = 10
    overlayProjection = @getProjection()

    googleMapProjection = (coordinates) ->
      googleCoordinates = new google.maps.LatLng(coordinates[0], coordinates[1])
      pixelCoordinates = overlayProjection.fromLatLngToDivPixel(googleCoordinates)
      return [pixelCoordinates.x + 4000, pixelCoordinates.y + 4000]

    positions = []
    @data.forEach (d) ->
      positions.push(googleMapProjection(d.latLng))

    polygons = d3.geom.voronoi(positions)

    pathAttr =
      d: (d, i) ->
        "M" + polygons[i].join("L") + "Z"
      stroke: "red"
      fill: "none"

    @svgOverlay.selectAll("path").data(@data).attr(pathAttr).enter().append("svg:path").attr("class", "cell").attr(pathAttr)

  onRemove: ->
    @div_.parentNode.removeChild @div_
    @div_ = null

  toggleDOM: ->
    if @getMap()
      @setMap null
    else
      @setMap @map_
