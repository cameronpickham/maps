plot = (place) ->
  latLng = place.latLng

  infoWindow = new google.maps.InfoWindow
    content: "#{place.name} | #{place.count}"
    state:   'closed'

  marker = new google.maps.Marker
    map: map
    position: new google.maps.LatLng(latLng[0], latLng[1])

  google.maps.event.addListener marker, 'mouseover', ->
    unless infoWindow.state is 'zoom_open'
      infoWindow.state = 'mouseover_open'
      infoWindow.open(map, marker)
  
  google.maps.event.addListener marker, 'mouseout', ->
    unless infoWindow.state is 'zoom_open'
      infoWindow.state = 'closed'
      infoWindow.close()
  
  google.maps.event.addListener marker, 'click', ->
    infoWindow.state = 'closed'
    infoWindow.close()
  
  popups["#{latLng[0]}#{latLng[1]}"] = { marker: marker, infoWindow: infoWindow }

mapOptions =
  zoom: 12
  center: new google.maps.LatLng(34.02234, -118.28512)
  mapTypeId: google.maps.MapTypeId.ROADMAP
  disableDefaultUI: true

map = new google.maps.Map d3.select("#map-canvas").node(), mapOptions
voronoiOverlay = null

popups = {}

$.getJSON "./checkins.json", (data) ->
  google.maps.event.addDomListener window, "load", do ->
    plot(place) for place in data
  
  voronoiOverlay = new App.Overlay(map, data)

$("#recent").click ->
  $("#menu").collapse('toggle')

$(".recent").click (event) ->
  clickedId = $(this).attr("id").substring(3)
  ele    = $("body").find('#' + "input-" + clickedId)
  vals   = ele.val().split(/[, ]+/)
  latLng = vals.map (v) -> parseFloat(v)
  map.setCenter(new google.maps.LatLng(latLng[0], latLng[1]))
  map.setZoom(16)
  { marker, infoWindow } = popups["#{latLng[0]}#{latLng[1]}"]
  infoWindow.state = 'zoom_open'
  infoWindow.open(map, marker)

  $("#menu").collapse('toggle')

$("#close").click ->
  $("#menu").collapse('toggle')

$("#overlay-toggle").click (event) ->
  voronoiOverlay.toggleDOM()
