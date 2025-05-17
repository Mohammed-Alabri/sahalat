import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sahalat/theme/app_theme.dart';
import 'package:sahalat/services/navigation_service.dart';
import 'package:sahalat/services/cart_service.dart';
import 'package:sahalat/services/payment_service.dart';
import 'package:sahalat/services/address_service.dart';
import 'package:uuid/uuid.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({Key? key}) : super(key: key);

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _navigationService = NavigationService();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _noteController = TextEditingController();

  // Credit Card Controllers
  final _cardNumberController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _cardExpiryController = TextEditingController();

  // Bank Transfer Controllers
  final _bankNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _accountHolderController = TextEditingController();

  String _selectedPaymentType = 'cash';
  List<PaymentMethod> _paymentMethods = [];
  PaymentMethod? _selectedPaymentMethod;
  bool _isLoading = false;
  String? _selectedWilayat;
  String? _selectedArea;
  List<DeliveryAddress> _addresses = [];
  DeliveryAddress? _selectedAddress;

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
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final addresses = await AddressService.getAddresses();
      final paymentMethods = await PaymentService.getPaymentMethods();

      setState(() {
        _addresses = addresses;
        _paymentMethods = paymentMethods;

        // Set default address and payment method if available
        _selectedAddress = addresses.isNotEmpty
            ? addresses.firstWhere(
                (addr) => addr.isDefault,
                orElse: () => addresses.first,
              )
            : null;

        _selectedPaymentMethod = paymentMethods.isNotEmpty
            ? paymentMethods.firstWhere(
                (method) => method.isDefault,
                orElse: () => paymentMethods.first,
              )
            : null;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _savePaymentMethod() async {
    if (!_formKey.currentState!.validate()) return;

    final method = PaymentMethod(
      id: const Uuid().v4(),
      type: _selectedPaymentType,
      cardNumber:
          _selectedPaymentType == 'card' ? _cardNumberController.text : null,
      cardHolderName:
          _selectedPaymentType == 'card' ? _cardHolderController.text : null,
      expiryDate:
          _selectedPaymentType == 'card' ? _cardExpiryController.text : null,
      bankName:
          _selectedPaymentType == 'bank' ? _bankNameController.text : null,
      accountNumber:
          _selectedPaymentType == 'bank' ? _accountNumberController.text : null,
      accountHolderName:
          _selectedPaymentType == 'bank' ? _accountHolderController.text : null,
      isDefault: _paymentMethods.isEmpty,
    );

    await PaymentService.addPaymentMethod(method);
    setState(() {
      _paymentMethods.add(method);
      _selectedPaymentMethod = method;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _noteController.dispose();
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _cardExpiryController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _accountHolderController.dispose();
    super.dispose();
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          border: InputBorder.none,
          icon: Icon(icon, color: Colors.grey[600]),
          labelText: label,
        ),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select $label';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildPaymentMethodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment Method',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        // Existing payment methods
        if (_paymentMethods.isNotEmpty) ...[
          ...List.generate(_paymentMethods.length, (index) {
            final method = _paymentMethods[index];
            return RadioListTile<PaymentMethod>(
              value: method,
              groupValue: _selectedPaymentMethod,
              title: Text(_getPaymentMethodTitle(method)),
              subtitle: Text(_getPaymentMethodSubtitle(method)),
              onChanged: (value) {
                setState(() {
                  _selectedPaymentMethod = value;
                  _selectedPaymentType = value?.type ?? 'cash';
                });
              },
            );
          }),
          const Divider(),
        ],
        // New payment method options
        RadioListTile<String>(
          value: 'cash',
          groupValue: _selectedPaymentType,
          title: const Text('Cash on Delivery'),
          onChanged: (value) {
            setState(() {
              _selectedPaymentMethod = null;
              _selectedPaymentType = value!;
            });
          },
        ),
        RadioListTile<String>(
          value: 'card',
          groupValue: _selectedPaymentType,
          title: const Text('Credit Card'),
          onChanged: (value) {
            setState(() {
              _selectedPaymentMethod = null;
              _selectedPaymentType = value!;
            });
          },
        ),
        RadioListTile<String>(
          value: 'bank',
          groupValue: _selectedPaymentType,
          title: const Text('Bank Transfer'),
          onChanged: (value) {
            setState(() {
              _selectedPaymentMethod = null;
              _selectedPaymentType = value!;
            });
          },
        ),
      ],
    );
  }

  String _getPaymentMethodTitle(PaymentMethod method) {
    switch (method.type) {
      case 'card':
        return 'Card ending in ${method.cardNumber?.substring(method.cardNumber!.length - 4)}';
      case 'bank':
        return '${method.bankName} Account';
      case 'cash':
        return 'Cash on Delivery';
      default:
        return 'Unknown Payment Method';
    }
  }

  String _getPaymentMethodSubtitle(PaymentMethod method) {
    switch (method.type) {
      case 'card':
        return method.cardHolderName ?? '';
      case 'bank':
        return '${method.accountHolderName} - ${method.accountNumber}';
      case 'cash':
        return 'Pay when you receive your order';
      default:
        return '';
    }
  }

  Widget _buildCreditCardForm() {
    if (_selectedPaymentType != 'card' || _selectedPaymentMethod != null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        TextFormField(
          controller: _cardNumberController,
          decoration: const InputDecoration(
            labelText: 'Card Number',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter card number';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _cardHolderController,
          decoration: const InputDecoration(
            labelText: 'Card Holder Name',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter card holder name';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _cardExpiryController,
          decoration: const InputDecoration(
            labelText: 'Expiry Date (MM/YY)',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter expiry date';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildBankTransferForm() {
    if (_selectedPaymentType != 'bank' || _selectedPaymentMethod != null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        TextFormField(
          controller: _bankNameController,
          decoration: const InputDecoration(
            labelText: 'Bank Name',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter bank name';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _accountNumberController,
          decoration: const InputDecoration(
            labelText: 'Account Number',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter account number';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _accountHolderController,
          decoration: const InputDecoration(
            labelText: 'Account Holder Name',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter account holder name';
            }
            return null;
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text(
                    'Contact Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    decoration: _inputDecoration(
                      'Full Name',
                      Icons.person_outline,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    decoration: _inputDecoration(
                      'Phone Number',
                      Icons.phone_outlined,
                    ),
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Delivery Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedWilayat,
                    decoration: _inputDecoration(
                      'Select Wilayat',
                      Icons.location_city_outlined,
                    ),
                    items: _wilayat.map((wilayat) {
                      return DropdownMenuItem(
                        value: wilayat,
                        child: Text(wilayat),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedWilayat = value);
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
                    _buildDropdown(
                      label: 'Select Area',
                      value: _selectedArea,
                      items: _areasByWilayat[_selectedWilayat]!,
                      onChanged: (value) {
                        setState(() {
                          _selectedArea = value;
                        });
                      },
                      icon: Icons.map_outlined,
                    ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _addressController,
                    decoration: _inputDecoration(
                      'Detailed Address',
                      Icons.location_on_outlined,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _noteController,
                    decoration: _inputDecoration(
                      'Delivery Note (Optional)',
                      Icons.note_outlined,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildPaymentMethodSelector(),
                  _buildCreditCardForm(),
                  _buildBankTransferForm(),
                  const SizedBox(height: 100), // Space for bottom button
                ],
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitOrder,
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
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Place Order',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
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
        borderSide: const BorderSide(color: AppTheme.primaryColor),
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

  Future<void> _submitOrder() async {
    if (_selectedPaymentType != 'cash' && !_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Save payment method if requested
      await _savePaymentMethod();

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Clear cart
      await CartService.clearCart();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order placed successfully!')),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error placing order: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
