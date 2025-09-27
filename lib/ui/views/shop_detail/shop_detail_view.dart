import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:provider/provider.dart';

import '../../../data/models/coffee_shop.dart';
import '../../../ui/viewmodels/shop_detail_viewmodel.dart';

class ShopDetailView extends StatefulWidget {
  final String shopId;
  const ShopDetailView({super.key, required this.shopId});

  @override
  State<ShopDetailView> createState() => _ShopDetailViewState();
}

class _ShopDetailViewState extends State<ShopDetailView> {
  @override
  void initState() {
    super.initState();
    // Load shop on init
    Future.microtask(() =>
        context.read<ShopDetailViewModel>().loadShop(widget.shopId));
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ShopDetailViewModel>();

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Shop Details'),
      ),
      child: SafeArea(
        child: vm.isLoading
            ? const Center(child: CupertinoActivityIndicator())
            : vm.error != null
                ? Center(
                    child: Text(
                      vm.error!,
                      style: const TextStyle(color: CupertinoColors.systemRed),
                    ),
                  )
                : vm.shop == null
                    ? const Center(child: Text('Shop not found'))
                    : _buildContent(vm.shop!),
      ),
    );
  }

  Widget _buildContent(CoffeeShop shop) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Row(
            children: [
              const Icon(Icons.store, color: CupertinoColors.activeOrange),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  shop.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Description
          if (shop.description != null && shop.description!.isNotEmpty) ...[
            Text(
              shop.description!,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
          ],

          // Address
          if (shop.address != null && shop.address!.isNotEmpty) ...[
            Row(
              children: [
                const Icon(CupertinoIcons.map_pin,
                    size: 18, color: CupertinoColors.activeBlue),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    shop.address!,
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],

          // Wifi
          Row(
            children: [
              Icon(
                shop.wifiAvailable
                    ? CupertinoIcons.wifi
                    : CupertinoIcons.wifi_slash,
                size: 18,
                color: shop.wifiAvailable
                    ? CupertinoColors.activeGreen
                    : CupertinoColors.systemGrey,
              ),
              const SizedBox(width: 6),
              Text(
                shop.wifiAvailable ? 'Wi-Fi available' : 'No Wi-Fi',
                style: const TextStyle(fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Seats
          Text(
            'Seats: ${shop.seatsAvailable}/${shop.seatCapacity}',
            style: const TextStyle(fontSize: 15),
          ),
          const SizedBox(height: 12),

          // Opening time
          if (shop.openingTime != null) ...[
            Text(
              'Opens at: ${shop.openingTime}',
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 12),
          ],

          // Rating
          Row(
            children: [
              const Icon(CupertinoIcons.star_fill,
                  size: 18, color: CupertinoColors.systemYellow),
              const SizedBox(width: 6),
              Text(
                '${shop.averageRating.toStringAsFixed(1)} '
                '(${shop.ratingsCount} ratings)',
                style: const TextStyle(fontSize: 15),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Verified badge
          if (shop.isVerified)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: CupertinoColors.activeGreen.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Verified Shop',
                style: TextStyle(
                    color: CupertinoColors.activeGreen,
                    fontWeight: FontWeight.w600),
              ),
            ),
        ],
      ),
    );
  }
}
