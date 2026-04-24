import '../../../../core/services/base_api_service.dart';
import '../models/irrigation_schedule_model.dart';

class IotService extends BaseApiService {
  IotService(super.dio);

  Future<Map<String, dynamic>> getStatus() async {
    return await get<Map<String, dynamic>>(
          '/iot/status',
          mapper: (data) => data as Map<String, dynamic>,
        ) ??
        {'has_device': false};
  }

  Future<bool> toggleIrrigation(bool status) async {
    final result = await post<bool>(
      '/iot/toggle',
      data: {'status': status},
      mapper: (_) => true,
    );
    return result ?? false;
  }

  Future<bool> updateAutoIrrigation(bool auto) async {
    final result = await post<bool>(
      '/iot/auto-irrigation',
      data: {'auto_irrigation': auto},
      mapper: (_) => true,
    );
    return result ?? false;
  }

  Future<IrrigationSchedule?> addSchedule(String time, List<String> days) async {
    return post<IrrigationSchedule>(
      '/iot/schedules',
      data: {'start_time': time, 'days': days},
      mapper: (data) => IrrigationSchedule.fromJson(data),
    );
  }

  Future<bool> deleteSchedule(int id) async {
    return delete('/iot/schedules/$id');
  }

  Future<bool> requestService() async {
    final result = await post<bool>(
      '/iot/request-service',
      mapper: (_) => true,
    );
    return result ?? false;
  }
}
