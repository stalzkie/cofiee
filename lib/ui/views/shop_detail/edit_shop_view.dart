import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons, TimeOfDay;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../data/models/coffee_shop.dart';
import '../../viewmodels/shop_detail_viewmodel.dart';

class EditShopView extends StatefulWidget {
  final CoffeeShop shop;
  const EditShopView({super.key, required this.shop});

  @override
  State<EditShopView> createState() => _EditShopViewState();
}

class _EditShopViewState extends State<EditShopView> {
  // Text controllers
  late TextEditingController _nameCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _seatCapCtrl;
  late TextEditingController _seatsAvailCtrl;

  bool _wifi = false;
  TimeOfDay? _openingTime;
  bool _submitting = false;

  // Gallery state
  final _picker = ImagePicker();
  final List<_GalleryItem> _gallery = [];        // existing + new (UI list)
  final List<_GalleryItem> _toDelete = [];       // existing items marked for deletion
  static const int _galleryLimit = 10;

  @override
  void initState() {
    super.initState();

    // Pre-fill with shop’s existing info
    _nameCtrl = TextEditingController(text: widget.shop.name);
    _descCtrl = TextEditingController(text: widget.shop.description ?? '');
    _addressCtrl = TextEditingController(text: widget.shop.address ?? '');
    _seatCapCtrl = TextEditingController(text: widget.shop.seatCapacity.toString());
    _seatsAvailCtrl = TextEditingController(text: widget.shop.seatsAvailable.toString());
    _wifi = widget.shop.wifiAvailable;
    if (widget.shop.openingTime != null) {
      final parts = widget.shop.openingTime!.split(':');
      if (parts.length >= 2) {
        _openingTime = TimeOfDay(
          hour: int.tryParse(parts[0]) ?? 9,
          minute: int.tryParse(parts[1]) ?? 0,
        );
      }
    }

    // Load existing gallery rows from DB
    _loadExistingGallery();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _addressCtrl.dispose();
    _seatCapCtrl.dispose();
    _seatsAvailCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadExistingGallery() async {
    try {
      final supabase = Supabase.instance.client;
      final rows = await supabase
          .from('shop_images')
          .select('id, url')
          .eq('shop_id', widget.shop.id)
          .order('created_at');

      if (!mounted) return;
      setState(() {
        _gallery.clear();
        for (final r in (rows as List)) {
          _gallery.add(_GalleryItem.existing(id: r['id'] as String, url: r['url'] as String));
        }
      });
    } catch (_) {
      // silently ignore gallery load errors in UI
    }
  }

  Future<void> _pickGalleryImages() async {
    final remaining = _galleryLimit - _gallery.length;
    if (remaining <= 0) return;

    final files = await _picker.pickMultiImage(imageQuality: 90);
    if (files == null || files.isEmpty) return;

    final selected = files.take(remaining);
    setState(() {
      for (final f in selected) {
        _gallery.add(_GalleryItem.newLocal(file: File(f.path)));
      }
    });
  }

  void _removeFromGallery(_GalleryItem item) {
    setState(() {
      _gallery.remove(item);
      if (item.isExisting) {
        _toDelete.add(item);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ShopDetailViewModel>();

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Edit Shop'),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Shop name
              const Text('Shop Name'),
              const SizedBox(height: 6),
              CupertinoTextField(controller: _nameCtrl),
              const SizedBox(height: 12),

              // Address
              const Text('Address'),
              const SizedBox(height: 6),
              CupertinoTextField(controller: _addressCtrl),
              const SizedBox(height: 12),

              // Description
              const Text('Description'),
              const SizedBox(height: 6),
              CupertinoTextField(
                controller: _descCtrl,
                maxLines: 2,
              ),
              const SizedBox(height: 12),

              // Wi-Fi
              Row(
                children: [
                  const Text('Wi-Fi available'),
                  const Spacer(),
                  CupertinoSwitch(
                    value: _wifi,
                    onChanged: (v) => setState(() => _wifi = v),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Opening time
              Row(
                children: [
                  const Text('Opening Time'),
                  const Spacer(),
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    color: CupertinoColors.systemGrey5,
                    onPressed: () => _pickTime(context),
                    child: Text(
                      _openingTime == null
                          ? 'Pick Time'
                          : '${_openingTime!.hour.toString().padLeft(2, '0')}:${_openingTime!.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(color: CupertinoColors.black),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Seats
              Row(
                children: [
                  Expanded(
                    child: _LabeledField(
                      label: 'Seat Capacity',
                      controller: _seatCapCtrl,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _LabeledField(
                      label: 'Seats Available',
                      controller: _seatsAvailCtrl,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ======= Gallery (max 10 images) =======
              Row(
                children: [
                  const Text('Gallery (up to 10)'),
                  const Spacer(),
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    color: CupertinoColors.activeBlue,
                    onPressed: _pickGalleryImages,
                    child: const Text('Add Photos', style: TextStyle(color: CupertinoColors.white)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _GalleryGrid(
                items: _gallery,
                onRemove: _removeFromGallery,
              ),

              const SizedBox(height: 20),

              CupertinoButton.filled(
                onPressed: _submitting
                    ? null
                    : () async {
                        setState(() => _submitting = true);
                        try {
                          // 1) Save shop scalar fields
                          final updated = widget.shop.copyWith(
                            name: _nameCtrl.text.trim(),
                            description: _descCtrl.text.trim(),
                            address: _addressCtrl.text.trim(),
                            wifiAvailable: _wifi,
                            openingTime: _openingTime != null
                                ? '${_openingTime!.hour.toString().padLeft(2, '0')}:${_openingTime!.minute.toString().padLeft(2, '0')}:00'
                                : null,
                            seatCapacity: int.tryParse(_seatCapCtrl.text) ?? widget.shop.seatCapacity,
                            seatsAvailable: int.tryParse(_seatsAvailCtrl.text) ?? widget.shop.seatsAvailable,
                          );
                          await vm.saveShop(updated);

                          // 2) Process gallery changes
                          await _saveGalleryChanges();

                          if (!mounted) return;
                          Navigator.pop(context); // go back after save
                        } catch (e) {
                          if (!mounted) return;
                          showCupertinoDialog(
                            context: context,
                            builder: (_) => CupertinoAlertDialog(
                              title: const Text('Error'),
                              content: Text(e.toString()),
                              actions: [
                                CupertinoDialogAction(
                                  child: const Text('OK'),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ],
                            ),
                          );
                        } finally {
                          setState(() => _submitting = false);
                        }
                      },
                child: _submitting
                    ? const CupertinoActivityIndicator()
                    : const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveGalleryChanges() async {
    final supabase = Supabase.instance.client;
    final shopId = widget.shop.id;

    // A) Delete removed existing images
    for (final item in _toDelete) {
      if (!item.isExisting) continue;
      final url = item.url!;
      // Best-effort delete: remove table row and try removing storage object if key is derivable
      if (item.id != null) {
        await supabase.from('shop_images').delete().eq('id', item.id!);
      }
      // If you store storage paths in DB, delete the actual object here too.
      // Example (if you saved 'path' column): await supabase.storage.from('shop-gallery').remove([path]);
    }
    _toDelete.clear();

    // B) Upload new local images and create DB rows
    final toUpload = _gallery.where((g) => g.isNewLocal).toList();
    for (final item in toUpload) {
      final file = item.file!;
      final objectName = 'shop_gallery/$shopId/${const Uuid().v4()}.jpg';
      await supabase.storage.from('shop-gallery').upload(objectName, file);
      final publicUrl = supabase.storage.from('shop-gallery').getPublicUrl(objectName);

      // Insert row into shop_images
      await supabase.from('shop_images').insert({
        'shop_id': shopId,
        'url': publicUrl,
      });

      // Flip this item to "existing" in local state
      item
        ..id = const Uuid().v4()
        ..url = publicUrl
        ..file = null;
    }
    setState(() {}); // refresh thumbnails state
  }

  Future<void> _pickTime(BuildContext context) async {
    await showCupertinoModalPopup(
      context: context,
      builder: (_) {
        TimeOfDay temp = _openingTime ?? const TimeOfDay(hour: 9, minute: 0);
        return Container(
          height: 260,
          color: CupertinoColors.systemBackground.resolveFrom(context),
          child: Column(
            children: [
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  use24hFormat: true,
                  initialDateTime: DateTime(2000, 1, 1, temp.hour, temp.minute),
                  onDateTimeChanged: (dt) {
                    temp = TimeOfDay(hour: dt.hour, minute: dt.minute);
                  },
                ),
              ),
              CupertinoButton(
                child: const Text('Done'),
                onPressed: () {
                  setState(() => _openingTime = temp);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const _LabeledField({
    required this.label,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 6),
        CupertinoTextField(controller: controller),
      ],
    );
  }
}

/// UI grid for gallery with remove buttons
class _GalleryGrid extends StatelessWidget {
  final List<_GalleryItem> items;
  final void Function(_GalleryItem) onRemove;

  const _GalleryGrid({required this.items, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Text(
        'No photos yet.',
        style: TextStyle(color: CupertinoColors.systemGrey),
      );
    }

    // Simple responsive grid
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: items.map((item) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey5,
                borderRadius: BorderRadius.circular(10),
                image: item.isExisting
                    ? DecorationImage(image: NetworkImage(item.url!), fit: BoxFit.cover)
                    : (item.file != null
                        ? DecorationImage(image: FileImage(item.file!), fit: BoxFit.cover)
                        : null),
              ),
            ),
            Positioned(
              top: -8,
              right: -8,
              child: CupertinoButton(
                padding: const EdgeInsets.all(6),
                color: CupertinoColors.systemRed,
                borderRadius: BorderRadius.circular(16),
                onPressed: () => onRemove(item),
                child: const Icon(
                  Icons.close,
                  size: 16,
                  color: CupertinoColors.white,
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

/// Local model for gallery grid
class _GalleryItem {
  // Existing (DB) image
  String? id;
  String? url;

  // New (local) image
  File? file;

  _GalleryItem.existing({required this.id, required this.url});
  _GalleryItem.newLocal({required this.file});

  bool get isExisting => id != null && url != null && file == null;
  bool get isNewLocal => file != null;
}
