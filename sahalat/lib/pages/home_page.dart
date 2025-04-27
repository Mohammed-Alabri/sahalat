import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sahalat/theme/app_theme.dart';
import 'package:sahalat/widgets/custom_search_bar.dart';
import 'package:sahalat/widgets/category_card.dart';
import 'package:sahalat/widgets/restaurant_card.dart';
import 'package:sahalat/widgets/restaurant_card_skeleton.dart';
import 'package:sahalat/widgets/app_logo.dart';
import 'package:sahalat/services/navigation_service.dart';
import 'package:sahalat/services/restaurant_service.dart';
import 'package:sahalat/models/restaurant.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  final _searchController = TextEditingController();
  final _navigationService = NavigationService();
  late List<Restaurant> _popularRestaurants;
  bool _isLoading = true;

  @override
  bool get wantKeepAlive => true;

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
        _popularRestaurants = RestaurantService.getPopularRestaurants();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Decorative elements
            Positioned(
              top: -20,
              right: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              top: 60,
              left: -30,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Main content
            Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: RefreshIndicator(
                      onRefresh: _loadRestaurants,
                      child: _buildContent(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const AppLogo(size: 100),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.notifications_outlined,
                    color: AppTheme.primaryColor,
                    size: 28,
                  ),
                  onPressed: () {
                    // TODO: Implement notifications
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          CustomSearchBar(
            controller: _searchController,
            onSubmitted: (value) {
              // TODO: Implement search
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Restaurant & Store',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textColor,
            ),
          ),
          const SizedBox(height: 20),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.1,
            children: [
              CategoryCard(
                title: 'Food',
                icon: Icons.restaurant,
                onTap: () {
                  _navigationService
                      .navigateTo('/main', arguments: {'initialIndex': 1});
                },
              ),
              CategoryCard(
                title: 'Groceries',
                icon: Icons.shopping_basket,
                onTap: () {
                  // TODO: Navigate to groceries category
                },
              ),
              CategoryCard(
                title: 'Grocers',
                icon: Icons.store,
                onTap: () {
                  // TODO: Navigate to grocers category
                },
              ),
              CategoryCard(
                title: 'Retail',
                icon: Icons.shopping_cart,
                onTap: () {
                  // TODO: Navigate to retail category
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Popular Restaurants',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textColor,
                ),
              ),
              TextButton(
                onPressed: () {
                  _navigationService
                      .navigateTo('/main', arguments: {'initialIndex': 1});
                },
                child: const Text('See All'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 260,
            child: _isLoading
                ? ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 3,
                    itemBuilder: (context, index) {
                      return const RestaurantCardSkeleton();
                    },
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _popularRestaurants.length,
                    itemBuilder: (context, index) {
                      final restaurant = _popularRestaurants[index];
                      return RestaurantCard(
                        name: restaurant.name,
                        imageUrl: restaurant.image,
                        rating: restaurant.rating,
                        categories: restaurant.categories,
                        isOpen: restaurant.isOpen,
                        deliveryTime: restaurant.deliveryTime,
                        onTap: () {
                          _navigationService.navigateTo(
                            '/restaurant-details',
                            arguments: restaurant,
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
