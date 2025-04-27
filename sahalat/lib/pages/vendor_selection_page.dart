import 'package:flutter/material.dart';
import 'package:sahalat/models/restaurant.dart';
import 'package:sahalat/services/restaurant_service.dart';
import 'package:sahalat/pages/restaurant_details_page.dart';
import 'package:sahalat/widgets/custom_search_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';

class VendorSelectionPage extends StatefulWidget {
  const VendorSelectionPage({super.key});

  @override
  State<VendorSelectionPage> createState() => _VendorSelectionPageState();
}

class _VendorSelectionPageState extends State<VendorSelectionPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  late List<Restaurant> _restaurants;
  late List<Restaurant> _filteredRestaurants;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRestaurants();
  }

  Future<void> _loadRestaurants() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _restaurants = RestaurantService.getAllRestaurants();
        _filteredRestaurants = _restaurants;
        _isLoading = false;
      });
    }
  }

  void _filterRestaurants(String query) {
    setState(() {
      if (query.isEmpty && _selectedCategory == 'All') {
        _filteredRestaurants = _restaurants;
      } else {
        _filteredRestaurants = _restaurants.where((restaurant) {
          final matchesSearch =
              restaurant.name.toLowerCase().contains(query.toLowerCase()) ||
                  restaurant.description
                      .toLowerCase()
                      .contains(query.toLowerCase());
          final matchesCategory = _selectedCategory == 'All' ||
              restaurant.categories.any((category) =>
                  category.toLowerCase() == _selectedCategory.toLowerCase());
          return matchesSearch && matchesCategory;
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final categories = ['All', ...RestaurantService.getAllCategories()];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurants'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                CustomSearchBar(
                  controller: _searchController,
                  onSubmitted: (value) => _filterRestaurants(value),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final isSelected = category == _selectedCategory;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = category;
                              _filterRestaurants(_searchController.text);
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredRestaurants.length,
                    itemBuilder: (context, index) {
                      final restaurant = _filteredRestaurants[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RestaurantDetailsPage(
                                  restaurant: restaurant,
                                ),
                              ),
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CachedNetworkImage(
                                imageUrl: restaurant.image,
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  height: 200,
                                  color: Colors.grey[300],
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  height: 200,
                                  color: Colors.grey[300],
                                  child: const Center(
                                    child: Icon(Icons.restaurant, size: 64),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          restaurant.name,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge,
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: restaurant.isOpen
                                                ? Colors.green
                                                : Colors.red,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            restaurant.isOpen
                                                ? 'Open'
                                                : 'Closed',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      restaurant.description,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(Icons.star,
                                            color: Colors.amber, size: 20),
                                        const SizedBox(width: 4),
                                        Text(
                                          restaurant.rating.toString(),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
                                        ),
                                        const SizedBox(width: 16),
                                        const Icon(Icons.delivery_dining,
                                            size: 20),
                                        const SizedBox(width: 4),
                                        Text(
                                          'OMR ${restaurant.deliveryFee.toStringAsFixed(3)}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
                                        ),
                                        const SizedBox(width: 16),
                                        const Icon(Icons.shopping_basket,
                                            size: 20),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Min: OMR ${restaurant.minimumOrder.toStringAsFixed(3)}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
