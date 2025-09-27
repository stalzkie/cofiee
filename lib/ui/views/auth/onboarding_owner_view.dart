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
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
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

  Future<String?> _uploadFile(File file, String prefix) async {
    final supabase = Supabase.instance.client;
    final uid = supabase.auth.currentUser!.id;
    final fileName = '${prefix}_${uid}_${const Uuid().v4()}.jpg';
    final path = 'owner_docs/$fileName';

    await supabase.storage.from('documents').upload(path, file);
    return supabase.storage.from('documents').getPublicUrl(path);
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
                CupertinoTextField(
                  controller: _displayNameCtrl,
                  placeholder: 'e.g., Juan D.',
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                // Business Permit upload
                const Text('Business Permit'),
                const SizedBox(height: 6),
                CupertinoButton(
                  color: CupertinoColors.systemGrey5,
                  onPressed: () => _pickFile(true),
                  child: Text(_businessPermitFile == null
                      ? 'Upload Business Permit'
                      : '✓ Business Permit Selected'),
                ),
                const SizedBox(height: 16),

                // DTI Certificate upload
                const Text('DTI Certificate'),
                const SizedBox(height: 6),
                CupertinoButton(
                  color: CupertinoColors.systemGrey5,
                  onPressed: () => _pickFile(false),
                  child: Text(_dtiFile == null
                      ? 'Upload DTI Certificate'
                      : '✓ DTI Certificate Selected'),
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
                  CupertinoTextField(
                    controller: _shopNameCtrl,
                    placeholder: 'e.g., Cofiee Bacolod',
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 12),

                  const Text('Address'),
                  const SizedBox(height: 6),
                  CupertinoTextField(
                    controller: _addressCtrl,
                    placeholder: 'Street, City, Province',
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 12),

                  const Text('Description (optional)'),
                  const SizedBox(height: 6),
                  CupertinoTextField(
                    controller: _descCtrl,
                    placeholder: 'Short blurb about your shop',
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),

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
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      const Text('Verified (admin use)'),
                      const Spacer(),
                      CupertinoSwitch(
                        value: _isVerified,
                        onChanged: (v) => setState(() => _isVerified = v),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Opening time
                  const Text('Opening Time (optional)'),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: CupertinoButton(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          color: CupertinoColors.systemGrey5,
                          onPressed: () => _pickTime(context),
                          child: Text(
                            _openingTime == null
                                ? 'Pick time'
                                : _formatTime(_openingTime!),
                            style: const TextStyle(color: CupertinoColors.label),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Capacity
                  Row(
                    children: [
                      Expanded(
                        child: _LabeledField(
                          label: 'Seat Capacity',
                          controller: _seatCapCtrl,
                          keyboardType:
                              const TextInputType.numberWithOptions(decimal: false),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _LabeledField(
                          label: 'Seats Available',
                          controller: _seatsAvailCtrl,
                          keyboardType:
                              const TextInputType.numberWithOptions(decimal: false),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Coordinates
                  Row(
                    children: [
                      Expanded(
                        child: _LabeledField(
                          label: 'Latitude (optional)',
                          controller: _latCtrl,
                          keyboardType:
                              const TextInputType.numberWithOptions(decimal: true),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _LabeledField(
                          label: 'Longitude (optional)',
                          controller: _lngCtrl,
                          keyboardType:
                              const TextInputType.numberWithOptions(decimal: true),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    kUseLatLngColumns
                        ? 'Your DB expects numeric lat/lng columns.'
                        : 'Your DB expects geometry in `location`. If lat/lng supplied, we will send GeoJSON Point.',
                    style: const TextStyle(
                      fontSize: 12,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                ],

                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Text(_error!,
                      style: const TextStyle(
                          color: CupertinoColors.systemRed, fontSize: 14)),
                ],

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

                            // Upload files
                            String? permitUrl;
                            String? dtiUrl;
                            if (_businessPermitFile != null) {
                              permitUrl =
                                  await _uploadFile(_businessPermitFile!, "permit");
                            }
                            if (_dtiFile != null) {
                              dtiUrl = await _uploadFile(_dtiFile!, "dti");
                            }

                            // Promote profile to owner
                            await supabase.from('profiles').upsert({
                              'id': user.id,
                              'role': 'owner',
                              if (_displayNameCtrl.text.trim().isNotEmpty)
                                'display_name': _displayNameCtrl.text.trim(),
                              if (permitUrl != null) 'permit_url': permitUrl,
                              if (dtiUrl != null) 'dti_url': dtiUrl,
                            }, onConflict: 'id');

                            // Create shop if requested
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

                              final payload = <String, dynamic>{
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
                const SizedBox(height: 10),
                CupertinoButton(
                  onPressed: _submitting
                      ? null
                      : () => Navigator.of(context)
                          .pushReplacementNamed(AppRoutes.map),
                  child: const Text('Skip for now'),
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
                  initialDateTime:
                      DateTime(2000, 1, 1, temp.hour, temp.minute),
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

  String _formatTime(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
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
