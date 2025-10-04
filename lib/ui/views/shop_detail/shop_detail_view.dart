import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/models/coffee_shop.dart';
import '../../../ui/viewmodels/shop_detail_viewmodel.dart';
import 'edit_shop_view.dart'; // 👈 import your edit view

class ShopDetailView extends StatefulWidget {
  final String shopId;
  const ShopDetailView({super.key, required this.shopId});

  @override
  State<ShopDetailView> createState() => _ShopDetailViewState();
}

class _ShopDetailViewState extends State<ShopDetailView> {
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    // Load shop on init
    Future.microtask(() =>
        context.read<ShopDetailViewModel>().loadShop(widget.shopId));
  }

  Future<List<String>> _fetchGalleryImages(String shopId) async {
    final supabase = Supabase.instance.client;
    final response =
        await supabase.from('shop_images').select('url').eq('shop_id', shopId);

    if (response is List) {
      return response.map((e) => e['url'] as String).toList();
    }
    return [];
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
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    final isOwner = shop.owner_id == currentUserId;

    return FutureBuilder<List<String>>(
      future: _fetchGalleryImages(shop.id),
      builder: (context, snapshot) {
        final images = snapshot.data ?? [];

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gallery
              if (images.isNotEmpty) ...[
                SizedBox(
                  height: 360,
                  child: PageView.builder(
                    itemCount: images.length,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                    },
                    itemBuilder: (context, index) {
                      return ClipRRect(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                        child: Image.network(
                          images[index],
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(images.length, (index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentPage == index
                              ? CupertinoColors.activeBlue
                              : CupertinoColors.systemGrey,
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Row(
                      children: [
                        const Icon(Icons.store,
                            color: CupertinoColors.activeOrange),
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
                        if (isOwner)
                          CupertinoButton(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            color: CupertinoColors.activeBlue,
                            borderRadius: BorderRadius.circular(8),
                            onPressed: () {
                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (_) => EditShopView(shop: shop),
                                ),
                              );
                            },
                            child: const Text(
                              'Edit Shop',
                              style: TextStyle(
                                  color: CupertinoColors.white, fontSize: 14),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Description
                    if (shop.description != null &&
                        shop.description!.isNotEmpty) ...[
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
                          shop.wifiAvailable
                              ? 'Wi-Fi available'
                              : 'No Wi-Fi',
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
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
              ),
            ],
          ),
        );
      },
    );
  }
}
