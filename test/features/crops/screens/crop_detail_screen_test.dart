import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:smart_farm2/features/crops/screens/crop_detail_screen.dart';
import 'package:smart_farm2/core/models/crop_model.dart';
import 'package:smart_farm2/core/models/care_guide_model.dart';
import 'package:smart_farm2/core/providers/auth_provider.dart';
import 'package:smart_farm2/features/crops/providers/crops_provider.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthProvider extends Mock implements AuthProvider {}
class MockCropsProvider extends Mock implements CropsProvider {}

void main() {
  late Crop mockCrop;
  late MockAuthProvider mockAuthProvider;
  late MockCropsProvider mockCropsProvider;
  
  setUp(() {
    mockAuthProvider = MockAuthProvider();
    mockCropsProvider = MockCropsProvider();

    // Mock basic auth state
    when(() => mockAuthProvider.currentUser).thenReturn(null);

    mockCrop = Crop(
      id: '1',
      name: 'طماطم',
      scientificName: 'Solanum lycopersicum',
      description: 'نبات الطماطم المتميز',
      category: 'خضروات',
      plantingSeason: 'الربيع',
      waterNeeds: 'متوسطة',
      harvestTime: '3-4 أشهر',
      imageUrl: '',
      careGuide: CareGuide(
        minTemp: 20,
        maxTemp: 30,
        lightType: 'شمس كاملة',
        rainfall: '400 - 600 mm/سنة',
        minHumidity: 60,
        maxHumidity: 80,
        irrigationLevel: 'متوسط',
        lifeCycle: 'قصيرة (90 يوم)',
        cultivationMethod: 'شتلات',
        soilTexture: 'طينية خصبة',
        minPh: 6.0,
        maxPh: 7.5,
        seedRate: '1200 kg/ha',
        nAmount: 100,
        pAmount: 60,
        kAmount: 140,
        companionPlants: ['الثوم', 'البصل'],
        combativePlants: ['الفلفل'],
        succeedingCrops: ['البقوليات'],
        forbiddenCrops: ['نفس فصيلة النبات'],
      ),
    );
  });

  testWidgets('CropDetailScreen shows all required agricultural sections and icons', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
          ChangeNotifierProvider<CropsProvider>.value(value: mockCropsProvider),
        ],
        child: MaterialApp(
          home: CropDetailScreen(crop: mockCrop),
        ),
      ),
    );

    // 1. Growth Conditions
    expect(find.text('ظروف النمو البيئية'), findsOneWidget);
    expect(find.byIcon(Icons.thermostat_rounded), findsOneWidget); // Temp
    expect(find.byIcon(Icons.wb_sunny_rounded), findsOneWidget);   // Sun
    expect(find.byIcon(Icons.cloud_queue_rounded), findsOneWidget); // Rain
    expect(find.byIcon(Icons.water_drop_rounded), findsOneWidget); // Humidity
    expect(find.byIcon(Icons.opacity_rounded), findsOneWidget);    // Irrigation

    // 2. Cultivation Details
    expect(find.text('بيانات الاستزراع'), findsOneWidget);
    expect(find.byIcon(Icons.hourglass_empty_rounded), findsOneWidget); // Life Cycle
    expect(find.byIcon(Icons.agriculture_rounded), findsOneWidget);     // Method

    // 3. Soil & Nutrition
    expect(find.text('معايير التربة والتسميد'), findsOneWidget);
    expect(find.byIcon(Icons.layers_rounded), findsOneWidget); // Soil Layers
    expect(find.byIcon(Icons.science_rounded), findsOneWidget); // pH
    expect(find.byIcon(Icons.grain_rounded), findsOneWidget);   // Seed Rate
    
    // NPK (should be present in circles)
    expect(find.text('N'), findsOneWidget);
    expect(find.text('P'), findsOneWidget);
    expect(find.text('K'), findsOneWidget);

    // 4. Management & Rotation
    expect(find.text('التوافق والدورة الزراعية'), findsOneWidget);
    expect(find.byIcon(Icons.verified_user_rounded), findsOneWidget); // Success Shield
    expect(find.byIcon(Icons.report_problem_rounded), findsOneWidget); // Warning Shield
    expect(find.byIcon(Icons.sync_rounded), findsOneWidget);           // Rotation Arrow
    expect(find.byIcon(Icons.block_rounded), findsOneWidget);          // Blocked Rotation

    // 5. Interactive Elements
    expect(find.text('حاسبة الأسمدة'), findsOneWidget);
    expect(find.textContaining('تحذير هام'), findsOneWidget);
  });
}
