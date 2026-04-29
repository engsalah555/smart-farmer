import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../providers/marketplace_provider.dart';
import '../../../core/models/store_model.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/constants.dart';

class StoreMapScreen extends StatefulWidget {
  const StoreMapScreen({super.key});

  @override
  State<StoreMapScreen> createState() => _StoreMapScreenState();
}

class _StoreMapScreenState extends State<StoreMapScreen> {
  final MapController _mapController = MapController();
  String _searchQuery = '';
  String _selectedCategory = 'الكل';
  final TextEditingController _searchController = TextEditingController();
  StoreModel? _selectedStore;
  LatLng? _userPosition;
  bool _isMapLoading = true;

  final List<String> _categories = [
    'الكل',
    'بذور',
    'اسمدة',
    'مبيدات',
    'محاصيل',
    'معدات',
    'المشاتل',
  ];

  @override
  void initState() {
    super.initState();
    _determineInitialPosition();
  }

  Future<void> _determineInitialPosition() async {
    setState(() => _isMapLoading = true);
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('Location services are disabled.');
      if (mounted) setState(() => _isMapLoading = false);
      _loadStoresWithPosition(null, null);
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint('Location permissions are denied');
        if (mounted) setState(() => _isMapLoading = false);
        _loadStoresWithPosition(null, null);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      debugPrint('Location permissions are permanently denied.');
      if (mounted) setState(() => _isMapLoading = false);
      _loadStoresWithPosition(null, null);
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          _userPosition = LatLng(position.latitude, position.longitude);
          _isMapLoading = false;
        });
        _mapController.move(_userPosition!, 14.5);
        _loadStoresWithPosition(position.latitude, position.longitude);
      }
    } catch (e) {
      debugPrint('Error getting initial position: $e');
      if (mounted) {
        setState(() => _isMapLoading = false);
        _loadStoresWithPosition(null, null);
      }
    }
  }

  void _loadStoresWithPosition(double? lat, double? lng) {
    final provider = context.read<MarketplaceProvider>();
    provider.loadStores(latitude: lat, longitude: lng);
  }


  @override
  void dispose() {
    _mapController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<StoreModel> _filterStores(List<StoreModel> stores) {
    return stores.where((store) {
      if (store.latitude == null || store.longitude == null) return false;

      final matchesCategory =
          _selectedCategory == 'الكل' ||
          store.category == _selectedCategory ||
          store.category == 'شامل';

      final matchesSearch =
          _searchQuery.isEmpty ||
          store.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          store.description.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          store.location.toLowerCase().contains(_searchQuery.toLowerCase());

      return matchesCategory && matchesSearch;
    }).toList();
  }

  void _moveToStore(StoreModel store) {
    if (store.latitude != null && store.longitude != null) {
      _mapController.move(LatLng(store.latitude!, store.longitude!), 14.0);
      setState(() => _selectedStore = store);
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'بذور':
        return const Color(0xFF2ECC71); // Brand Primary
      case 'اسمدة':
        return const Color(0xFFF1C40F); // Brand Accent
      case 'مبيدات':
        return const Color(0xFFE74C3C); // Semantic Error/Danger
      case 'محاصيل':
        return const Color(0xFF27AE60); // Darker Growth
      case 'معدات':
        return const Color(0xFF34495E); // Industrial/Steel
      case 'المشاتل':
        return const Color(0xFF9B59B6); // Amethyst/Nursery
      default:
        return context.primary;
    }
  }

  @override
  Widget build(BuildContext context) {

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: context.backgroundColor,
        body: Consumer<MarketplaceProvider>(
          builder: (context, provider, _) {
              final filteredStores = _filterStores(provider.stores);


            return Stack(
              children: [
                // Map
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter:
                        _userPosition ?? const LatLng(15.377944, 44.204972),
                    initialZoom: 14.0,
                    onTap: (_, _) => setState(() => _selectedStore = null),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
                      subdomains: const ['a', 'b', 'c', 'd'],
                      userAgentPackageName: 'com.example.smart_farm2',
                      maxZoom: 19,
                      minZoom: 3,
                      tileDisplay: const TileDisplay.fadeIn(),
                    ),
                    // Legal Attribution
                    RichAttributionWidget(
                      alignment: AttributionAlignment.bottomLeft,
                      attributions: [
                        TextSourceAttribution(
                          '© OpenStreetMap contributors, © CARTO',
                          onTap: () => debugPrint('attribution tapped'),
                        ),
                      ],
                    ),
                    MarkerLayer(
                      markers: [
                        // User Location Marker - Modern pulsing blue dot
                        if (_userPosition != null)
                          Marker(
                            width: 44,
                            height: 44,
                            point: _userPosition!,
                            child: Semantics(
                              label: 'موقعك الحالي',
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: context.primary.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: context.white, width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: context.primary.withValues(alpha: 0.2),
                                      blurRadius: 12,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Container(
                                    width: 14,
                                    height: 14,
                                    decoration: BoxDecoration(
                                      color: context.primary,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: context.white, width: 2),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        // Stores Markers - Modern pin with category icon
                        ...filteredStores.map((store) {
                          final isSelected = _selectedStore?.id == store.id;
                          final catColor = _getCategoryColor(store.category);
                          return Marker(
                            width: isSelected ? 56 : 46,
                            height: isSelected ? 66 : 56,
                            point: LatLng(store.latitude!, store.longitude!),
                            child: Semantics(
                              label: 'متجر: ${store.name}, الفئة: ${store.category}',
                              button: true,
                              onTap: () => setState(() => _selectedStore = store),
                              child: GestureDetector(
                                onTap: () => setState(() => _selectedStore = store),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: isSelected ? 48 : 38,
                                      height: isSelected ? 48 : 38,
                                      decoration: BoxDecoration(
                                        color: isSelected ? catColor : context.cardBackground,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: catColor,
                                          width: isSelected ? 0 : 2,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: catColor.withValues(alpha: isSelected ? 0.4 : 0.15),
                                            blurRadius: isSelected ? 12 : 6,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        _getCategoryIcon(store.category),
                                        size: isSelected ? 24 : 18,
                                        color: isSelected ? context.white : catColor,
                                      ),
                                    ),
                                    CustomPaint(
                                      size: const Size(10, 6),
                                      painter: _TrianglePainter(catColor),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ],
                ),

                // Top Controls
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    child: Column(
                      children: [
                        // AppBar Row
                        Container(
                          margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                          child: Row(
                            children: [
                              // Back Button
                              Container(
                                decoration: BoxDecoration(
                                  color: context.cardBackground,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: context.black.withValues(alpha: 0.1),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                child: IconButton(
                                  tooltip: 'رجوع',
                                  icon: const Icon(Icons.arrow_back, size: 20),
                                  onPressed: () {
                                    if (context.canPop()) {
                                      context.pop();
                                    } else {
                                      context.go('/marketplace');
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Search Bar
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: context.cardBackground,
                                    borderRadius: BorderRadius.circular(30),
                                    boxShadow: [
                                      BoxShadow(
                                        color: context.black.withValues(alpha: 0.08),
                                        blurRadius: 10,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: TextField(
                                    controller: _searchController,
                                    textDirection: TextDirection.rtl,
                                    decoration: InputDecoration(
                                      hintText: 'ابحث عن متجر أو موقع...',
                                      hintStyle: TextStyle(
                                        color: context.isDark ? context.textMuted : context.textSecondary.withValues(alpha: 0.6),
                                        fontSize: 13,
                                      ),
                                      prefixIcon: Icon(
                                        Icons.search,
                                        color: context.textSecondary,
                                        size: 20,
                                      ),
                                      suffixIcon: _searchQuery.isNotEmpty
                                          ? IconButton(
                                              tooltip: 'مسح البحث',
                                              icon: Icon(
                                                Icons.close,
                                                size: 18,
                                                color: context.textSecondary,
                                              ),
                                              onPressed: () {
                                                _searchController.clear();
                                                setState(
                                                  () => _searchQuery = '',
                                                );
                                              },
                                            )
                                          : null,
                                      border: InputBorder.none,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                    ),
                                    onChanged: (val) =>
                                        setState(() => _searchQuery = val),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Category Filter Chips
                        SizedBox(
                          height: 48,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            itemCount: _categories.length,
                            itemBuilder: (context, i) {
                              final cat = _categories[i];
                              final isSelected = _selectedCategory == cat;
                              return Padding(
                                padding: const EdgeInsets.only(left: 6),
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => _selectedCategory = cat),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? _getCategoryColor(cat)
                                          : context.cardBackground,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: context.black.withValues(alpha: 0.05),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      cat,
                                      style: TextStyle(
                                        color: isSelected
                                            ? context.white
                                            : context.textPrimary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        // Results count
                        if (filteredStores.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 12),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: context.cardBackground,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: context.black.withValues(alpha: 0.05),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            child: Text(
                              '${filteredStores.length} متجر في هذه المنطقة',
                              style: TextStyle(
                                color: context.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // Floating Locate Button
                Positioned(
                  bottom: _selectedStore != null ? 220 : 120,
                  left: 16,
                  child: Container(
                    decoration: BoxDecoration(
                      color: context.cardBackground,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: context.black.withValues(alpha: 0.12),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: IconButton(
                      tooltip: 'تحديد موقعي',
                      icon: Icon(Icons.my_location, color: context.primary),
                      onPressed: () async {
                        try {
                          final position =
                              await Geolocator.getCurrentPosition();
                          final newPos = LatLng(
                            position.latitude,
                            position.longitude,
                          );
                          setState(() {
                            _userPosition = newPos;
                          });
                          _mapController.move(newPos, 15.0);
                        } catch (e) {
                          _mapController.move(
                            const LatLng(15.377972, 44.205028),
                            14.0,
                          );
                        }
                      },
                    ),
                  ),
                ),

                // Empty State
                if (filteredStores.isEmpty && !provider.isLoading)
                  Positioned(
                    bottom: 100,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: context.cardBackground,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: context.black.withValues(alpha: 0.08),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.store_mall_directory_outlined,
                              color: context.textMuted,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'لا توجد متاجر في هذه المنطقة',
                              style: TextStyle(
                                color: context.textMuted,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // Stores List Bottom Sheet
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _selectedStore != null
                      ? _buildStoreDetailCard(_selectedStore!)
                      : _buildStoresList(filteredStores),
                ),

                // Loading Overlay
                if (_isMapLoading)
                  Container(
                    color: Colors.black.withValues(alpha: 0.1),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: context.primary),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: context.cardBackground,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'جاري تحديد موقعك...',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
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

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'بذور': return Icons.grass_rounded;
      case 'اسمدة': return Icons.science_rounded;
      case 'مبيدات': return Icons.bug_report_rounded;
      case 'محاصيل': return Icons.agriculture_rounded;
      case 'معدات': return Icons.construction_rounded;
      case 'المشاتل': return Icons.park_rounded;
      default: return Icons.storefront_rounded;
    }
  }

  Widget _buildStoresList(List<StoreModel> stores) {
    if (stores.isEmpty) return const SizedBox();
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth * 0.55).clamp(200.0, 300.0);

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        itemCount: stores.length,
        itemBuilder: (context, index) {
          final store = stores[index];
          final catColor = _getCategoryColor(store.category);
          final isSelected = _selectedStore?.id == store.id;
          return GestureDetector(
            onTap: () => _moveToStore(store),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: cardWidth,
              margin: const EdgeInsets.only(left: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isSelected ? catColor : context.cardBackground,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? catColor : catColor.withValues(alpha: 0.1),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: catColor.withValues(alpha: isSelected ? 0.25 : 0.08),
                    blurRadius: isSelected ? 12 : 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? context.white.withValues(alpha: 0.2)
                          : catColor.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getCategoryIcon(store.category),
                      color: isSelected ? context.white : catColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          store.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: isSelected ? context.white : context.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          store.category,
                          style: TextStyle(
                            fontSize: 11,
                            color: isSelected
                                ? context.white.withValues(alpha: 0.9)
                                : catColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (store.location.isNotEmpty)
                          Text(
                            '📍 ${store.location}',
                            style: TextStyle(
                              fontSize: 10,
                              color: isSelected
                                  ? context.white.withValues(alpha: 0.7)
                                  : context.textMuted,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
    );
  }

  Widget _buildStoreDetailCard(StoreModel store) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: context.black.withValues(alpha: 0.15),
            blurRadius: 15,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: context.isDark ? context.darkBorder : Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: _getCategoryColor(
                    store.category,
                  ).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.store_rounded,
                  color: _getCategoryColor(store.category),
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      store.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(
                              store.category,
                            ).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            store.category,
                            style: TextStyle(
                              fontSize: 11,
                              color: _getCategoryColor(store.category),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        if (store.location.isNotEmpty)
                          Expanded(
                            child: Text(
                              '📍 ${store.location}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: () => setState(() => _selectedStore = null),
              ),
            ],
          ),
          if (store.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              store.description,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.storefront, size: 18),
              label: const Text('عرض المتجر'),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () {
                setState(() => _selectedStore = null);
                context.push('/store_details', extra: store);
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Draws a small downward-pointing triangle used as the pin tip on markers.
class _TrianglePainter extends CustomPainter {
  final Color color;
  _TrianglePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = ui.Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_TrianglePainter old) => old.color != color;
}
