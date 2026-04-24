import 'package:flutter_test/flutter_test.dart';
import 'package:smart_farm2/core/models/product_model.dart';
import 'package:smart_farm2/core/constants.dart';

void main() {
  group('ProductModel Tests', () {
    test('يجب أن يدعم fromJson قراءة كافة الحقول بما في ذلك catalog_id', () {
      final json = {
        'id': 1,
        'name': 'بذور طماطم',
        'description': 'بذور ممتازة للزراعة',
        'price': '50.5',
        'unit': 'كيس',
        'stock_quantity': 100,
        'store_id': '10',
        'catalog_id': '5',
        'created_at': '2026-04-01T10:00:00.000000Z',
        'image_url': 'images/tomato.jpg',
        'store': {
          'store_name': 'متجر المزارع',
          'address': 'الرياض',
          'user_id': 12,
        },
      };

      final product = ProductModel.fromJson(json);

      expect(product.id, '1');
      expect(product.title, 'بذور طماطم');
      expect(product.price, 50.5);
      expect(product.unit, 'كيس');
      expect(product.quantity, 100);
      expect(product.storeId, '10');
      expect(product.catalogId, '5'); // أهم نقطة تم إصلاحها للارتباط الديناميكي
      expect(product.storeName, 'متجر المزارع');
      expect(product.location, 'الرياض');
      expect(product.sellerId, '12');
      expect(
        product.images.first,
        '${AppConstants.apiBaseUrl}/storage/images/tomato.jpg',
      );
    });

    test('يجب أن يقوم toJson بتصدير catalog_id', () {
      final product = ProductModel(
        id: '1',
        title: 'طماطم',
        description: 'وصف',
        category: 'بذور',
        price: 15.0,
        unit: 'حبة',
        quantity: 10,
        storeName: 'متجر',
        storeId: '5',
        catalogId: '20',
        images: [],
        paymentMethods: ['cash'],
        location: 'الرياض',
        phoneNumber: '055',
        createdAt: DateTime.parse('2026-04-01T10:00:00Z'),
        sellerId: '9',
      );

      final json = product.toJson();

      expect(json['id'], '1');
      expect(json['catalog_id'], '20');
      expect(json['price'], 15.0);
    });
  });
}
