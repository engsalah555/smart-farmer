import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants.dart';
import '../../../core/models/product_model.dart';
import '../providers/cart_provider.dart';
import '../providers/marketplace_provider.dart';

class ProductDetailsScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _currentImageIndex = 0;
  int _quantity = 1;
  bool _isLoadingReviews = true;
  List<dynamic> _reviews = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadReviews();
    });
  }

  Future<void> _loadReviews() async {
    final provider = context.read<MarketplaceProvider>();
    final data = await provider.getProductReviews(widget.product.id);
    if (mounted) {
      setState(() {
        _reviews = data['reviews'];
        _isLoadingReviews = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context, product),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, product),
                  const SizedBox(height: 24),
                  _buildDescription(context, product),
                  const SizedBox(height: 24),
                  _buildReviewsSection(context),
                  const SizedBox(height: 100), // Spacer for bottom bar
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _buildBottomBar(context, product),
    );
  }

  Widget _buildAppBar(BuildContext context, ProductModel product) {
    return SliverAppBar(
      expandedHeight: 350,
      pinned: true,
      backgroundColor: context.backgroundColor,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: Colors.black.withValues(alpha: 0.3),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 20,
            ),
            onPressed: () => context.pop(),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            // Image Carousel
            Positioned.fill(
              child: PageView.builder(
                onPageChanged: (index) =>
                    setState(() => _currentImageIndex = index),
                itemCount: product.images.length,
                itemBuilder: (context, index) => Image.network(
                  product.images[index],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: context.primary.withValues(alpha: 0.1),
                    child: Icon(
                      Icons.image_not_supported_rounded,
                      size: 50,
                      color: context.primary,
                    ),
                  ),
                ),
              ),
            ),
            // Image Indicator
            if (product.images.length > 1)
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    product.images.length,
                    (index) => Container(
                      width: _currentImageIndex == index ? 20 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: _currentImageIndex == index
                            ? context.primary
                            : Colors.white70,
                        borderRadius: BorderRadius.circular(4),
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

  Widget _buildHeader(BuildContext context, ProductModel product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: context.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                product.category,
                style: TextStyle(
                  color: context.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            Row(
              children: [
                const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                const SizedBox(width: 4),
                Text(
                  product.rating.toStringAsFixed(1),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: context.textPrimary,
                  ),
                ),
                Text(
                  ' (${product.reviewsCount}+)',
                  style: TextStyle(color: context.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          product.title,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: context.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${product.price} ر.ي / ${product.unit}',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: context.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildDescription(BuildContext context, ProductModel product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الوصف',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: context.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          product.description,
          style: TextStyle(color: context.textSecondary, height: 1.6),
        ),
      ],
    );
  }

  Widget _buildReviewsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'التقييمات (${widget.product.reviewsCount})',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
            ),
            TextButton.icon(
              onPressed: _showReviewModal,
              icon: const Icon(Icons.edit, size: 16),
              label: const Text('أضف تقييم'),
              style: TextButton.styleFrom(foregroundColor: context.primary),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_isLoadingReviews)
          const Center(child: CircularProgressIndicator())
        else if (_reviews.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'لا توجد تقييمات حتى الآن. كن أول من يقيّم!',
                style: TextStyle(color: context.textSecondary),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _reviews.length,
            separatorBuilder: (context, index) => const Divider(height: 32),
            itemBuilder: (context, index) {
              final review = _reviews[index];
              final user = review['user'] ?? {};
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundImage: user['profile_image'] != null
                        ? NetworkImage(user['profile_image'])
                        : null,
                    child: user['profile_image'] == null
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              user['name'] ?? 'مستخدم',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: context.textPrimary,
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  color: Colors.amber,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  review['rating'].toString(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: context.textPrimary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        if (review['comment'] != null &&
                            review['comment'].isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            review['comment'],
                            style: TextStyle(
                              color: context.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
      ],
    );
  }

  void _showReviewModal() {
    double selectedRating = 5.0;
    final commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.isDark ? AppColors.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'تقييم المنتج',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: context.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          onPressed: () {
                            setModalState(() {
                              selectedRating = index + 1.0;
                            });
                          },
                          icon: Icon(
                            index < selectedRating
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            color: Colors.amber,
                            size: 40,
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: commentController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'اكتب تجربتك مع المنتج (اختياري)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        final provider = context.read<MarketplaceProvider>();
                        final scaffoldMessenger = ScaffoldMessenger.of(context);
                        final errorColor = Theme.of(context).colorScheme.error;

                        context.pop();

                        final success = await provider.submitReview(
                          widget.product.id,
                          selectedRating,
                          comment: commentController.text,
                        );

                        if (!mounted) return;

                        if (success) {
                          scaffoldMessenger.showSnackBar(
                            const SnackBar(
                              content: Text('تم إرسال التقييم بنجاح'),
                            ),
                          );
                          _loadReviews();
                        } else {
                          scaffoldMessenger.showSnackBar(
                            SnackBar(
                              content: const Text(
                                'فشل إرسال التقييم، هل هذا منتجك؟ لا يمكنك تقييم منتجك.',
                              ),
                              backgroundColor: errorColor,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text(
                        'إرسال التقييم',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBottomBar(BuildContext context, ProductModel product) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Quantity Selector
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () => setState(
                      () => _quantity = _quantity > 1 ? _quantity - 1 : 1,
                    ),
                  ),
                  Text(
                    _quantity.toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => setState(() => _quantity++),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Add to Cart
            Expanded(
              child: SizedBox(
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    context.read<CartProvider>().addItem(
                      product,
                      quantity: _quantity,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تمت الإضافة للسلة')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    'إضافة للسلة',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
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
}
