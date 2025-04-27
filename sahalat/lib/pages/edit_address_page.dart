import 'package:flutter/material.dart';
import 'package:sahalat/services/address_service.dart';
import 'package:sahalat/theme/app_theme.dart';

class EditAddressPage extends StatefulWidget {
  final DeliveryAddress address;

  const EditAddressPage({
    Key? key,
    required this.address,
  }) : super(key: key);

  @override
  State<EditAddressPage> createState() => _EditAddressPageState();
}

class _EditAddressPageState extends State<EditAddressPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _streetController;
  late final TextEditingController _buildingController;
  late final TextEditingController _apartmentController;
  late final TextEditingController _landmarkController;
  late String? _selectedWilayat;
  late String? _selectedArea;
  late bool _isDefault;
  bool _isLoading = false;

  // Wilayat (Governorates) in Muscat
  final List<String> _wilayat = [
    'Muscat',
    'Muttrah',
    'Seeb',
    'Bausher',
    'Al Amerat',
    'Qurayyat'
  ];

  // Areas by Wilayat
  final Map<String, List<String>> _areasByWilayat = {
    'Muscat': ['Ruwi', 'Darsait', 'Wadi Kabir', 'Wattayah', 'Qurum'],
    'Muttrah': ['Muttrah Souq', 'Corniche', 'Hamriya', 'Darsait'],
    'Seeb': ['Al Khoudh', 'Al Maabela', 'Al Hail', 'Mawaleh'],
    'Bausher': ['Ghubra', 'Azaiba', 'Khuwair', 'Madinat Sultan Qaboos'],
    'Al Amerat': ['Al Amerat City', 'Al Mahaj', 'Al Hajar'],
    'Qurayyat': ['Qurayyat City', 'Daghmar', 'Al Sahel']
  };

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing address data
    _nameController = TextEditingController(text: widget.address.name);
    _streetController = TextEditingController(text: widget.address.street);
    _buildingController = TextEditingController(text: widget.address.building);
    _apartmentController =
        TextEditingController(text: widget.address.apartment ?? '');
    _landmarkController =
        TextEditingController(text: widget.address.landmark ?? '');
    _selectedWilayat = widget.address.wilayat;
    _selectedArea = widget.address.area;
    _isDefault = widget.address.isDefault;
  }

  Future<void> _updateAddress() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final updatedAddress = DeliveryAddress(
        id: widget.address.id,
        name: _nameController.text,
        wilayat: _selectedWilayat!,
        area: _selectedArea!,
        street: _streetController.text,
        building: _buildingController.text,
        apartment: _apartmentController.text.isNotEmpty
            ? _apartmentController.text
            : null,
        landmark: _landmarkController.text.isNotEmpty
            ? _landmarkController.text
            : null,
        isDefault: _isDefault,
      );

      await AddressService.updateAddress(updatedAddress);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Address updated successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating address: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _streetController.dispose();
    _buildingController.dispose();
    _apartmentController.dispose();
    _landmarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Address'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: _inputDecoration(
                'Address Name',
                'e.g. Home, Office',
                Icons.home_outlined,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter address name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedWilayat,
              decoration: _inputDecoration(
                'Wilayat',
                'Select your wilayat',
                Icons.location_city_outlined,
              ),
              items: _wilayat.map((wilayat) {
                return DropdownMenuItem(
                  value: wilayat,
                  child: Text(wilayat),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedWilayat = value;
                  _selectedArea = null;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select wilayat';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            if (_selectedWilayat != null)
              DropdownButtonFormField<String>(
                value: _selectedArea,
                decoration: _inputDecoration(
                  'Area',
                  'Select your area',
                  Icons.map_outlined,
                ),
                items: _areasByWilayat[_selectedWilayat]!.map((area) {
                  return DropdownMenuItem(
                    value: area,
                    child: Text(area),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedArea = value);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select area';
                  }
                  return null;
                },
              ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _streetController,
              decoration: _inputDecoration(
                'Street',
                'Enter street name/number',
                Icons.add_road_outlined,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter street';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _buildingController,
              decoration: _inputDecoration(
                'Building',
                'Enter building name/number',
                Icons.business_outlined,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter building';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _apartmentController,
              decoration: _inputDecoration(
                'Apartment (Optional)',
                'Enter apartment number',
                Icons.apartment_outlined,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _landmarkController,
              decoration: _inputDecoration(
                'Landmark (Optional)',
                'Enter a nearby landmark',
                Icons.place_outlined,
              ),
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              value: _isDefault,
              onChanged: (value) {
                setState(() => _isDefault = value ?? false);
              },
              title: const Text('Set as default address'),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _updateAddress,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Update Address',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, String hint, IconData icon) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.grey[600]),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppTheme.primaryColor),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
  }
}
