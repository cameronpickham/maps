places = []
$.getJSON "./checkins.json", (data) ->
  places = data
  go()

go = ->
  google.maps.event.addDomListener window, "load", initialize()

initialize = ->
  mapOptions =
    zoom: 8
    center: new google.maps.LatLng(34.02234, -118.28512)
    mapTypeId: google.maps.MapTypeId.ROADMAP

  map = new google.maps.Map(document.getElementById("map-canvas"), mapOptions)
  
  plot(place, map) for place in places

plot = (place, map) ->
  lat_lng = place.lat_lng

  info_window = new google.maps.InfoWindow(
    content: place.name
  )

  marker = new google.maps.Marker(
    map: map
    position: new google.maps.LatLng(lat_lng[0], lat_lng[1])
  )

  google.maps.event.addListener(marker, 'click', ->
    info_window.open(map, marker)
  )
