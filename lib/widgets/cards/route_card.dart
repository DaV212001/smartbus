import 'dart:math' as Math;

import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:logger/logger.dart';

import '../../constants/constants.dart';
import '../../models/route.dart' as r;
import '../../models/stop_tcs.dart';
import '../../utils/wrappers/shimmer_wrapper.dart';

class RoutCard extends StatelessWidget {
  final r.Route route;
  final bool? isShimmer;

  const RoutCard({super.key, required this.route, this.isShimmer});

  @override
  Widget build(BuildContext context) {
    const smallTextStyle = TextStyle(fontSize: 10);
    return Card(
      margin: const EdgeInsets.all(10.0),
      color: Theme.of(context).cardColor,
      child: ShimmerWrapper(
        isEnabled: isShimmer ?? false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (route.stops != null && route.stops!.isNotEmpty)
              SizedBox(
                height:
                    MediaQuery.of(context).size.height *
                    0.15, // Map preview height
                child: IgnorePointer(child: RouteMapPreview(route: route)),
              ),
            const SizedBox(height: 10.0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                route.name ?? "Unnamed Route",
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.compare_arrows_sharp, color: maincolor),
                      const SizedBox(width: 5),
                      Text(
                        "${route.distance?.toStringAsFixed(2) ?? '-'} km,",
                        style: smallTextStyle,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.timelapse, color: maincolor, size: 15),
                      const SizedBox(width: 5),
                      Text(
                        "${route.duration?.toStringAsFixed(2) ?? '-'} mins",
                        style: smallTextStyle,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RouteMapPreview extends StatefulWidget {
  final r.Route route;
  final GlobalKey<RouteMapPreviewState>? mapKey;

  const RouteMapPreview({super.key, required this.route, this.mapKey});

  @override
  RouteMapPreviewState createState() => RouteMapPreviewState();
}

class RouteMapPreviewState extends State<RouteMapPreview> {
  late final MapController _mapController;

  @override
  void initState() {
    super.initState();

    _mapController = MapController(
      initPosition: GeoPoint(
        latitude:
            ((widget.route.stops!.first.latitude ?? 0) +
                (widget.route.stops!.last.latitude ?? 0)) /
            2,
        longitude:
            ((widget.route.stops!.first.longitude ?? 0) +
                (widget.route.stops!.last.longitude ?? 0)) /
            2,
      ),
    );
    _mapController.init();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          _drawRoute();
        }
      });
    });
  }

  Future<void> _drawRoute() async {
    if (widget.route.stops == null || widget.route.stops!.isEmpty) return;

    List<GeoPoint> geoPoints = widget.route.stops!
        .where((stop) => stop.latitude != null && stop.longitude != null)
        .map(
          (stop) =>
              GeoPoint(latitude: stop.latitude!, longitude: stop.longitude!),
        )
        .toList();

    await _mapController.goToLocation(geoPoints.first);

    if (geoPoints.length > 1) {
      await _mapController.drawRoad(
        geoPoints.first,
        geoPoints.last,
        roadType: RoadType.car,
        roadOption: RoadOption(roadColor: maincolor, roadWidth: 10),
        intersectPoint: geoPoints.sublist(1, geoPoints.length - 1),
      );

      // Add start marker
      await _mapController.addMarker(
        geoPoints.first,
        markerIcon: MarkerIcon(
          iconWidget: _buildMarkerLabel(
            widget.route.stops?.first.name ?? 'Start',
            maincolor,
          ),
        ),
      );

      // Add end marker
      await _mapController.addMarker(
        geoPoints.last,
        markerIcon: MarkerIcon(
          iconWidget: _buildMarkerLabel(
            widget.route.stops?.last.name ?? 'End',
            Colors.black,
          ),
        ),
      );
      for (int i = 0; i < geoPoints.length - 1; i++) {
        final current = geoPoints[i];
        final next = geoPoints[i + 1];

        final angle = _bearingBetweenPoints(current, next);
        // if (i == 0 || i == geoPoints.length - 1) continue;
        await _mapController.addMarker(
          current,
          markerIcon: MarkerIcon(
            iconWidget: Transform.rotate(
              angle: angle,
              child: const Icon(
                Icons.navigation,
                color: Colors.black,
                size: 16,
              ),
            ),
          ),
        );
      }
    }
  }

  double _bearingBetweenPoints(GeoPoint from, GeoPoint to) {
    final lat1 = from.latitude * (3.1415926 / 180.0);
    final lon1 = from.longitude * (3.1415926 / 180.0);
    final lat2 = to.latitude * (3.1415926 / 180.0);
    final lon2 = to.longitude * (3.1415926 / 180.0);

    final dLon = lon2 - lon1;
    final y = Math.sin(dLon) * Math.cos(lat2);
    final x =
        Math.cos(lat1) * Math.sin(lat2) -
        Math.sin(lat1) * Math.cos(lat2) * Math.cos(dLon);

    final bearing = Math.atan2(y, x);
    return bearing; // in radians, suitable for Transform.rotate
  }

  Widget _buildMarkerLabel(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(2, 2)),
        ],
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }

  GeoPoint? _lastMarkerPoint;

  Future<void> zoomToStop(Stop stop, bool isDestination) async {
    Logger().d(stop.name);
    if (stop.latitude == null || stop.longitude == null) return;

    GeoPoint point = GeoPoint(
      latitude:
          stop.latitude! +
          0.00005, //offset to avoid removing the arrows on this stop
      longitude: stop.longitude!,
    );

    // Move the map camera
    await _mapController.goToLocation(point);
    await _mapController.setZoom(zoomLevel: 15);

    // Remove the last marker if it exists
    if (_lastMarkerPoint != null) {
      await _mapController.removeMarker(_lastMarkerPoint!);
    }
    if (!isDestination && stop.sequence != 1) {
      // Add a new marker
      await _mapController.addMarker(
        point,
        markerIcon: MarkerIcon(
          iconWidget: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: stop.sequence == 1
                      ? maincolor
                      : isDestination
                      ? Colors.black
                      : Colors.white,
                  // borderRadius: BorderRadius.circular(10),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDestination
                        ? Colors.black
                        : const Color(0xFF6D28D9),
                    width: 2,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "${stop.sequence ?? ''}",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: stop.sequence == 1 || isDestination
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  // shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    stop.name.isEmpty ? 'Stop' : stop.name,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Update last marker reference
    _lastMarkerPoint = point;
  }

  @override
  Widget build(BuildContext context) {
    return OSMFlutter(
      controller: _mapController,
      osmOption: const OSMOption(
        zoomOption: ZoomOption(initZoom: 7, minZoomLevel: 2, maxZoomLevel: 18),
        showDefaultInfoWindow: true,
        isPicker: false,
      ),
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}
