
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:share_plus/share_plus.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  Position? currentPosition;
  bool isLoading = false;
  String message = 'Your current location has not been fetched yet.';

  Future<void> getLocation() async {
    setState(() {
      isLoading = true;
      message = 'Getting your location...';
    });

    try {
      bool serviceEnabled =
          await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        setState(() {
          message = 'Please enable location services.';
          isLoading = false;
        });
        return;
      }

      LocationPermission permission =
          await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        setState(() {
          message = 'Location permission was denied.';
          isLoading = false;
        });
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          message = 'Location permission is permanently denied. Please enable it in settings.';
          isLoading = false;
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      setState(() {
        currentPosition = position;
        message = 'Location fetched successfully!';
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        message = 'Unable to get location. Please try again.';
        isLoading = false;
      });
    }
  }

  Future<void> shareLocation() async {
    if (currentPosition == null) return;

    final latitude = currentPosition!.latitude;
    final longitude = currentPosition!.longitude;

    final mapLink =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';

    await SharePlus.instance.share(
      ShareParams(
        text: 'My current location:\n$mapLink',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Location'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.location_on,
                size: 90,
                color: Colors.red,
              ),
              const SizedBox(height: 20),

              const Text(
                'Location Sharing',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                message,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              if (currentPosition != null) ...[
                Text(
                  'Latitude: ${currentPosition!.latitude}',
                ),
                Text(
                  'Longitude: ${currentPosition!.longitude}',
                ),
                const SizedBox(height: 20),
              ],

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : getLocation,
                  icon: const Icon(Icons.my_location),
                  label: Text(
                    isLoading ? 'Getting Location...' : 'Get Current Location',
                  ),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed:
                      currentPosition == null ? null : shareLocation,
                  icon: const Icon(Icons.share),
                  label: const Text('Share My Location'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
