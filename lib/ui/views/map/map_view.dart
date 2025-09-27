import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../../ui/viewmodels/map_viewmodel.dart';
import '../../../ui/viewmodels/auth_viewmodel.dart';
import '../../../app/routes.dart';
import '../../widgets/marker.dart';
import '../../../data/models/coffee_shop.dart';

class MapView extends StatelessWidget {
  const MapView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MapViewModel>();
    final auth = context.read<AuthViewModel>();

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Cofiee Map'),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () async {
            await auth.logout();
            if (context.mounted) {
              Navigator.pushReplacementNamed(context, AppRoutes.login);
            }
          },
          child: const Icon(
            CupertinoIcons.square_arrow_left,
            color: CupertinoColors.activeBlue,
          ),
        ),
      ),
      child: SafeArea(
        child: FutureBuilder<Set<Marker>>(
          future: _buildMarkers(context, vm.shops), // build markers with nav
          builder: (context, snapshot) {
            final markers = snapshot.data ?? {};

            return Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: vm.cameraPosition,
                  markers: markers,
                  myLocationEnabled: vm.locationPermissionGranted,
                  myLocationButtonEnabled: false,
                  onMapCreated: vm.onMapCreated,
                ),
                // Center on user
                Positioned(
                  top: 16,
                  right: 16,
                  child: CupertinoButton.filled(
                    padding: const EdgeInsets.all(12),
                    borderRadius: BorderRadius.circular(30),
                    onPressed: vm.centerOnUser,
                    child: const Icon(Icons.my_location,
                        color: CupertinoColors.white),
                  ),
                ),
                // Refresh shops
                Positioned(
                  bottom: 24,
                  right: 16,
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    color: CupertinoColors.activeBlue,
                    borderRadius: BorderRadius.circular(24),
                    onPressed: vm.loadShops,
                    child: vm.isLoading
                        ? const CupertinoActivityIndicator(
                            color: CupertinoColors.white)
                        : const Text(
                            'Refresh',
                            style: TextStyle(color: CupertinoColors.white),
                          ),
                  ),
                ),
                // Go to onboarding owner
                Positioned(
                  bottom: 24,
                  left: 16,
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    color: CupertinoColors.activeOrange,
                    borderRadius: BorderRadius.circular(24),
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.onboardingOwner);
                    },
                    child: const Text(
                      'Become Owner',
                      style: TextStyle(color: CupertinoColors.white),
                    ),
                  ),
                ),
                // Small status chip
                if (vm.errorMessage != null)
                  Positioned(
                    left: 12,
                    right: 12,
                    bottom: 80, // moved up to avoid overlap with buttons
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemRed.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        vm.errorMessage!,
                        style:
                            const TextStyle(color: CupertinoColors.systemRed),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Build markers with navigation to ShopDetailView
  Future<Set<Marker>> _buildMarkers(
      BuildContext context, List<CoffeeShop> shops) async {
    final markers = <Marker>{};
    for (final shop in shops) {
      final marker = await createShopMarker(context, shop);
      markers.add(marker);
    }
    return markers;
  }
}
