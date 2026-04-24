import 'package:flutter_test/flutter_test.dart';
import 'package:smart_farm2/core/models/catalog_model.dart';

void main() {
  group('CatalogModel Tests', () {
    test('يجب أن يدعم fromJson قراءة image_url', () {
      final json = {
        'id': '10',
        'store_id': '5',
        'name': 'السمادات العضوية',
        'description': 'كل ما يخص التسميد العضوي',
        'image_url': 'storage/catalogs/org_fert.jpg',
        'sort_order': 2,
        'products_count': 14,
        'created_at': '2026-04-01T10:00:00Z',
      };

      final catalog = CatalogModel.fromJson(json);

      expect(catalog.id, '10');
      expect(catalog.storeId, '5');
      expect(catalog.name, 'السمادات العضوية');
      expect(catalog.description, 'كل ما يخص التسميد العضوي');
      expect(catalog.imageUrl, 'storage/catalogs/org_fert.jpg');
      expect(catalog.sortOrder, 2);
      expect(catalog.productsCount, 14);
    });

    test('يجب أن يقوم toJson بتضمين image_url', () {
      final catalog = CatalogModel(
        id: '2',
        storeId: '1',
        name: 'بذور',
        description: '',
        imageUrl: '/images/test.png',
      );

      final json = catalog.toJson();

      expect(json['id'], '2');
      expect(json['image_url'], '/images/test.png');
    });

    test('يجب أن تكون قيم sortOrder وproductsCount صفر افتراضياً', () {
      final catalog = CatalogModel(
        id: '3',
        storeId: '1',
        name: 'أسمدة',
        description: '',
      );

      expect(catalog.sortOrder, 0);
      expect(catalog.productsCount, 0);
    });

    test('fromJson يتعامل مع قيم null بأمان', () {
      final json = {
        'id': '1',
        'store_id': '1',
        'name': 'اختبار',
        'description': null,
        'image_url': null,
        'sort_order': null,
        'products_count': null,
      };

      final catalog = CatalogModel.fromJson(json);

      expect(catalog.description, '');
      expect(catalog.imageUrl, isNull);
      expect(catalog.sortOrder, 0);
      expect(catalog.productsCount, 0);
    });
  });
}
