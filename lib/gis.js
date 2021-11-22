/* 22nov21 Software Lab. Alexander Burger */

var Map;
var Sources;

function osm(id, lat, lon, zoom, click) {
   Map = new ol.Map( {
      target: id,
      view: new ol.View( {
         center: ol.proj.fromLonLat([lon/1000000-180, lat/1000000-90]),
         zoom: zoom
      } ),
      layers: [
         new ol.layer.Tile({source: new ol.source.OSM()}),
         new ol.layer.Vector( {
            source: Sources = new ol.source.Vector({features: []})
         } )
      ]
   } );
   Map.form = document.getElementById(id).parentNode;
   while (Map.form  &&  Map.form.tagName != "FORM")
      Map.form = Map.form.parentNode;

   Map.on("pointermove", function (evt) {
      Map.getViewport().style.cursor = "";
      Map.forEachFeatureAtPixel(evt.pixel, function (feature, layer) {
         if (feature.href)
            Map.getViewport().style.cursor = "pointer";
         lisp(Map.form, "osmHover", feature.txt);
      } )
   } );

   Map.on("click", function(evt) {
      Map.forEachFeatureAtPixel(evt.pixel, function (feature, layer) {
         if (feature.href) {
            window.location.href = feature.href;
            return;
         }
      } )
      if (click > 0) {
         var pt = ol.proj.toLonLat(evt.coordinate);
         lisp(Map.form, "osmClick", (pt[1] + 90) * 1000000, (pt[0] + 180) * 1000000);
         if (click > 1)
            window.location.reload(true);
      }
   } );

   Map.on("moveend", function() {
      var view = Map.getView().calculateExtent(Map.getSize());
      var a = ol.proj.toLonLat([view[0], view[1]]);
      var b = ol.proj.toLonLat([view[2], view[3]]);
      lisp(Map.form, "osmStat",
         (a[1] + 90) * 1000000, (a[0] + 180) * 1000000,
         (b[1] + 90) * 1000000, (b[0] + 180) * 1000000,
         Map.getView().getZoom() );
   } );
}

function poi(lat, lon, img, x, y, txt, dy, col, url, drag) {
   var feature = new ol.Feature( {
      geometry: new ol.geom.Point(ol.proj.fromLonLat([lon/1000000-180, lat/1000000-90]))
   } );

   feature.setStyle( [
      new ol.style.Style( {
         image: new ol.style.Icon( {
            src: img,
            anchor: [x, y]
         } ),
         text: new ol.style.Text( {
            text: txt,
            offsetY: dy,
            fill: new ol.style.Fill({color: col})
         } )
      } )
   ] );

   if (drag > 0) {
      Map.addInteraction(new ol.interaction.Translate( {
         features: new ol.Collection([feature])
      } ) );
      feature.on('change', function() {
            var pt = ol.proj.toLonLat(this.getGeometry().getCoordinates());
            lisp(Map.form, "osmDrag", txt, (pt[1] + 90) * 1000000, (pt[0] + 180) * 1000000);
            if (drag > 1)
               window.location.reload(true);
         },
         feature );
   }
   feature.txt = txt;
   feature.href = decodeURIComponent(url);
   Sources.addFeature(feature);
}

function line(col, lat1, lon1, lat2, lon2) {
   var feature = new ol.Feature( {
      geometry: new ol.geom.LineString( [
         ol.proj.fromLonLat([lon1/1000000-180, lat1/1000000-90]),
         ol.proj.fromLonLat([lon2/1000000-180, lat2/1000000-90]) ] )
   } );
   feature.setStyle( [
      new ol.style.Style( {
         stroke: new ol.style.Stroke({color: col})
      } )
   ] );
   Sources.addFeature(feature);
}
