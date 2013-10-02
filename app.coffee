map = null
places = []
$.getJSON "./checkins.json", (data) ->
  places = data
  makeMap()

makeMap = ->
  google.maps.event.addDomListener window, "load", initialize()

initialize = ->
  mapOptions =
    zoom: 11
    center: new google.maps.LatLng(34.02234, -118.28512)
    mapTypeId: google.maps.MapTypeId.ROADMAP
    disableDefaultUI: true

  map = new google.maps.Map(document.getElementById("map-canvas"), mapOptions)
  
  plot(place, map) for place in places

plot = (place, map) ->
  latLng = place.latLng

  info_window = new google.maps.InfoWindow
    content: "#{place.name}: #{place.count}"

  marker = new google.maps.Marker
    map: map
    position: new google.maps.LatLng(latLng[0], latLng[1])

  google.maps.event.addListener marker, 'mouseover', ->
    info_window.open(map, marker)
  
  google.maps.event.addListener marker, 'mouseout', ->
    info_window.close()

$("#list").click ->
  $("#menu").collapse('toggle')

$(".recent").click (event) ->
  clickedId = $(this).attr("id").substring(3)
  ele = $("body").find('#' + "input-" + clickedId)
  vals = ele.val().split(/[, ]+/)
  latLng = vals.map((v) -> parseFloat(v))
  map.setCenter(new google.maps.LatLng(latLng[0], latLng[1]))

