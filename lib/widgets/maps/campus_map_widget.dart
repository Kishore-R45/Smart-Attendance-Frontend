import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../config/app_config.dart';

class CampusMapWidget extends StatelessWidget {
  final double? userLatitude;
  final double? userLongitude;
  final bool showGeofence;
  final double height;

  const CampusMapWidget({
    Key? key,
    this.userLatitude,
    this.userLongitude,
    this.showGeofence = true,
    this.height = 200,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: FlutterMap(
          options: MapOptions(
            center: LatLng(
              userLatitude ?? AppConfig.campusLatitude,
              userLongitude ?? AppConfig.campusLongitude,
            ),
            zoom: 16.0,
            maxZoom: 18.0,
            minZoom: 14.0,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.yourcompany.attendance_app',
            ),
            
            // Campus geofence circle
            if (showGeofence)
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: LatLng(
                      AppConfig.campusLatitude,
                      AppConfig.campusLongitude,
                    ),
                    radius: AppConfig.campusRadius,
                    color: Theme.of(context).primaryColor.withOpacity(0.2),
                    borderColor: Theme.of(context).primaryColor,
                    borderStrokeWidth: 2,
                  ),
                ],
              ),
            
            // Markers
            MarkerLayer(
              markers: [
                // Campus center marker
                Marker(
                  width: 40.0,
                  height: 40.0,
                  point: LatLng(
                    AppConfig.campusLatitude,
                    AppConfig.campusLongitude,
                  ),
                  child: Icon(
                    Icons.school,
                    color: Theme.of(context).primaryColor,
                    size: 30,
                  ),
                ),
                
                // User location marker
                if (userLatitude != null && userLongitude != null)
                  Marker(
                    width: 40.0,
                    height: 40.0,
                    point: LatLng(userLatitude!, userLongitude!),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: Icon(
                        Icons.person_pin,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}