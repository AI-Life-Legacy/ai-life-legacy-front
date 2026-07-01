import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'dio_client.dart';

/// GetX 의존성 주입을 위한 API Provider 클래스
/// DioClient를 래핑하여 각 Repository에서 주입받아 사용합니다.
class ApiProvider extends GetxService {
  final Dio _dio = DioClient.instance;

  Future<Response> get(String path,
      {Map<String, dynamic>? queryParameters}) async {
    return await _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path,
      {dynamic data,
      Map<String, dynamic>? queryParameters,
      Options? options}) async {
    return await _dio.post(path,
        data: data, queryParameters: queryParameters, options: options);
  }

  Future<Response> put(String path,
      {dynamic data, Map<String, dynamic>? queryParameters}) async {
    return await _dio.put(path, data: data, queryParameters: queryParameters);
  }

  Future<Response> patch(String path,
      {dynamic data, Map<String, dynamic>? queryParameters}) async {
    return await _dio.patch(path, data: data, queryParameters: queryParameters);
  }

  Future<Response> delete(String path,
      {dynamic data, Map<String, dynamic>? queryParameters}) async {
    return await _dio.delete(path,
        data: data, queryParameters: queryParameters);
  }
}
