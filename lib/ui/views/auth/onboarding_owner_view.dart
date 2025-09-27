import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../app/routes.dart';
import '../../viewmodels/auth_viewmodel.dart';

/// Flip this depending on your DB schema.
/// - If you ONLY have geometry(Point,4326) in `location`: keep FALSE (default).
/// - If you have numeric columns `lat` and `lng`: set TRUE.
const bool kUseLatLngColumns = false;

class OnboardingOwnerView extends StatefulWidget {
  const OnboardingOwnerView({super.key});

  @override
  State<OnboardingOwnerView> createState() => _OnboardingOwnerViewState();
}

class _OnboardingOwnerViewState extends State<OnboardingOwnerView> {
  final _displayNameCtrl = TextEditingController();
  final _shopNameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _latCtrl = TextEditingController();
  final _lngCtrl = TextEditingController();
  final _seatCapCtrl = TextEditingController(text: '20');
  final _seatsAvailCtrl = TextEditingController(text: '20');

  bool _createShopNow = true;
  bool _wifi = true;
  bool _isVerified = false;
  TimeOfDay? _openingTime;
  bool _submitting = false;
  String? _error;

  File? _businessPermitFile;
  File? _dtiFile;

  // Gallery (up to 10 images)
  final _picker = ImagePicker();
  final List<File> _gallery = [];
  static const int _galleryLimit = 10;

  @override
  void dispose() {
    _displayNameCtrl.dispose();
    _shopNameCtrl.dispose();
    _addressCtrl.dispose();
    _descCtrl.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
    _seatCapCtrl.dispose();
    _seatsAvailCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFile(bool isPermit) async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        if (isPermit) {
          _businessPermitFile = File(picked.path);
        } else {
          _dtiFile = File(picked.path);
        }
      });
    }
  }

  Future<void> _pickGalleryImages() async {
    final remaining = _galleryLimit - _gallery.length;
    if (remaining <= 0) return;

    final files = await _picker.pickMultiImage(imageQuality: 90);
    if (files.isEmpty) return;

    setState(() {
      _gallery.addAll(files.take(remaining).map((x) => File(x.path)));
    });
  }

  Future<String?> _uploadFile(File file, String prefix) async {
    final supabase = Supabase.instance.client;
    final uid = supabase.auth.currentUser!.id;
    final fileName = '${prefix}_${uid}_${const Uuid().v4()}.jpg';
    final path = 'owner_docs/$fileName';

    await supabase.storage.from('documents').upload(path, file);
    return supabase.storage.from('documents').getPublicUrl(path);
  }

  Future<void> _uploadGalleryImages(String shopId) async {
    final supabase = Supabase.instance.client;
    for (final file in _gallery) {
      final objectName = 'shop_gallery/$shopId/${const Uuid().v4()}.jpg';
      await supabase.storage.from('shop-gallery').upload(objectName, file);
      final publicUrl =
          supabase.storage.from('shop-gallery').getPublicUrl(objectName);

      await supabase.from('shop_images').insert({
        'shop_id': shopId,
        'url': publicUrl,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Become a Shop Owner'),
      ),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.store_mall_directory,
                    size: 72, color: CupertinoColors.activeOrange),
                const SizedBox(height: 8),
                const Text(
                  'Owner Onboarding',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),

                // Display name
                const Text('Your Display Name'),
                const SizedBox(height: 6),
                CupertinoTextField(controller: _displayNameCtrl),
                const SizedBox(height: 16),

                // Business Permit upload
                const Text('Business Permit'),
                const SizedBox(height: 6),
                CupertinoButton(
                  color: CupertinoColors.systemGrey5,
                  onPressed: () => _pickFile(true),
                  child: Text(_businessPermitFile == null
                      ? 'Upload Business Permit'
                      : '✓ Selected'),
                ),
                const SizedBox(height: 16),

                // DTI Certificate upload
                const Text('DTI Certificate'),
                const SizedBox(height: 6),
                CupertinoButton(
                  color: CupertinoColors.systemGrey5,
                  onPressed: () => _pickFile(false),
                  child: Text(
                      _dtiFile == null ? 'Upload DTI Certificate' : '✓ Selected'),
                ),
                const SizedBox(height: 16),

                // Create shop toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Create first shop now'),
                    CupertinoSwitch(
                      value: _createShopNow,
                      onChanged: (v) => setState(() => _createShopNow = v),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                if (_createShopNow) ...[
                  const Divider(height: 24),
                  const Text('Shop Name'),
                  const SizedBox(height: 6),
                  CupertinoTextField(controller: _shopNameCtrl),
                  const SizedBox(height: 12),

                  const Text('Address'),
                  const SizedBox(height: 6),
                  CupertinoTextField(controller: _addressCtrl),
                  const SizedBox(height: 12),

                  const Text('Description (optional)'),
                  const SizedBox(height: 6),
                  CupertinoTextField(controller: _descCtrl, maxLines: 2),
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

                  // Gallery
                  Row(
                    children: [
                      const Text('Gallery (up to 10)'),
                      const Spacer(),
                      CupertinoButton(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        color: CupertinoColors.activeBlue,
                        onPressed: _pickGalleryImages,
                        child: const Text('Add Photos',
                            style: TextStyle(color: CupertinoColors.white)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _gallery.map((f) {
                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              image: DecorationImage(
                                image: FileImage(f),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: -8,
                            right: -8,
                            child: CupertinoButton(
                              padding: const EdgeInsets.all(6),
                              color: CupertinoColors.systemRed,
                              borderRadius: BorderRadius.circular(16),
                              onPressed: () {
                                setState(() => _gallery.remove(f));
                              },
                              child: const Icon(Icons.close,
                                  size: 16, color: CupertinoColors.white),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                ],

                if (_error != null)
                  Text(_error!,
                      style: const TextStyle(
                          color: CupertinoColors.systemRed, fontSize: 14)),

                const SizedBox(height: 16),
                CupertinoButton.filled(
                  onPressed: _submitting
                      ? null
                      : () async {
                          setState(() {
                            _submitting = true;
                            _error = null;
                          });
                          try {
                            final user = supabase.auth.currentUser;
                            if (user == null) {
                              throw Exception("Not signed in.");
                            }

                            // Upload docs
                            String? permitUrl;
                            String? dtiUrl;
                            if (_businessPermitFile != null) {
                              permitUrl =
                                  await _uploadFile(_businessPermitFile!, "permit");
                            }
                            if (_dtiFile != null) {
                              dtiUrl = await _uploadFile(_dtiFile!, "dti");
                            }

                            // Promote profile
                            await supabase.from('profiles').upsert({
                              'id': user.id,
                              'role': 'owner',
                              if (_displayNameCtrl.text.trim().isNotEmpty)
                                'display_name': _displayNameCtrl.text.trim(),
                              if (permitUrl != null) 'permit_url': permitUrl,
                              if (dtiUrl != null) 'dti_url': dtiUrl,
                            });

                            if (_createShopNow) {
                              final shopId = const Uuid().v4();
                              final name = _shopNameCtrl.text.trim();
                              if (name.isEmpty) {
                                throw Exception('Please enter a shop name.');
                              }

                              final seatCap =
                                  int.tryParse(_seatCapCtrl.text.trim()) ?? 0;
                              final seatsAvail =
                                  int.tryParse(_seatsAvailCtrl.text.trim()) ?? 0;

                              final lat = double.tryParse(_latCtrl.text.trim());
                              final lng = double.tryParse(_lngCtrl.text.trim());

                              final openingTimeStr = _openingTime == null
                                  ? null
                                  : _toHHmmss(_openingTime!);

                              final payload = {
                                'id': shopId,
                                'owner_id': user.id,
                                'name': name,
                                if (_descCtrl.text.trim().isNotEmpty)
                                  'description': _descCtrl.text.trim(),
                                if (_addressCtrl.text.trim().isNotEmpty)
                                  'address': _addressCtrl.text.trim(),
                                'wifi_available': _wifi,
                                if (openingTimeStr != null)
                                  'opening_time': openingTimeStr,
                                'seat_capacity': seatCap,
                                'seats_available': seatsAvail,
                                'is_verified': _isVerified,
                              };

                              if (kUseLatLngColumns) {
                                if (lat != null) payload['lat'] = lat;
                                if (lng != null) payload['lng'] = lng;
                              } else {
                                if (lat != null && lng != null) {
                                  payload['location'] = {
                                    'type': 'Point',
                                    'coordinates': [lng, lat],
                                  };
                                }
                              }

                              await supabase.from('coffee_shops').insert(payload);

                              // Upload gallery
                              await _uploadGalleryImages(shopId);
                            }

                            if (!mounted) return;
                            _showSuccess(context);
                          } catch (e) {
                            setState(() => _error = e.toString());
                          } finally {
                            setState(() => _submitting = false);
                          }
                        },
                  child: _submitting
                      ? const CupertinoActivityIndicator()
                      : const Text('Finish Onboarding'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSuccess(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Success'),
        content: const Text('You are now set as a Shop Owner.'),
        actions: [
          CupertinoDialogAction(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context)
                  .pushNamedAndRemoveUntil(AppRoutes.map, (r) => false);
            },
            child: const Text('Go to Map'),
          ),
        ],
      ),
    );
  }

  String _toHHmmss(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m:00';
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;

  const _LabeledField({
    required this.label,
    required this.controller,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 6),
        CupertinoTextField(
          controller: controller,
          keyboardType: keyboardType,
        ),
      ],
    );
  }
}
