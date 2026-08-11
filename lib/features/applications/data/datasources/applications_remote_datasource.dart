import '../../../../core/errors/api_exception.dart';
import '../../../../core/network/api_client.dart';
import '../../../offers/data/models/api_list_response.dart';
import '../../domain/entities/application.dart';
import '../models/application_model.dart';

abstract class ApplicationsRemoteDataSource {
  Future<List<Application>> getMyApplications();

  Future<List<Application>> getOfferApplications(
      String offerId,
      );

  Future<Application> updateApplication({
    required String applicationId,
    int? rating,
    String? status,
    double? salary,
    String? currency,
    DateTime? startDate,
    String? duration,
  });
}

class ApplicationsRemoteDataSourceImpl
    implements ApplicationsRemoteDataSource {
  const ApplicationsRemoteDataSourceImpl(
      this._apiClient,
      );

  final ApiClient _apiClient;

  @override
  Future<List<Application>> getMyApplications() async {
    final response = await _apiClient.get<Object?>(
      '/me/applications',
    );

    final parsed = ApiListResponse<Application>.fromJson(
      response.data,
      ApplicationModel.fromJson,
    );

    return parsed.data;
  }

  @override
  Future<List<Application>> getOfferApplications(
      String offerId,
      ) async {
    final normalizedOfferId = offerId.trim();

    if (normalizedOfferId.isEmpty) {
      return const [];
    }

    final response = await _apiClient.get<Object?>(
      '/offers/$normalizedOfferId/applications',
    );

    final parsed = ApiListResponse<Application>.fromJson(
      response.data,
      ApplicationModel.fromJson,
    );

    return parsed.data;
  }

  @override
  Future<Application> updateApplication({
    required String applicationId,
    int? rating,
    String? status,
    double? salary,
    String? currency,
    DateTime? startDate,
    String? duration,
  }) async {
    final normalizedApplicationId =
    applicationId.trim();

    if (normalizedApplicationId.isEmpty) {
      throw const ApiException(
        message:
        'El identificador de la aplicación es requerido.',
      );
    }

    final body = <String, dynamic>{};

    if (rating != null) {
      body['rating'] = rating;
    }

    if (status != null &&
        status.trim().isNotEmpty) {
      body['status'] = status.trim();
    }

    if (salary != null) {
      body['salary'] = salary;
    }

    if (currency != null &&
        currency.trim().isNotEmpty) {
      body['currency'] = currency.trim();
    }

    if (startDate != null) {
      body['startDate'] =
          _formatDate(startDate);
    }

    if (duration != null &&
        duration.trim().isNotEmpty) {
      body['duration'] = duration.trim();
    }

    if (body.isEmpty) {
      throw const ApiException(
        message:
        'Debes indicar al menos un dato para actualizar.',
      );
    }

    final response =
    await _apiClient.patch<Object?>(
      '/applications/$normalizedApplicationId',
      data: body,
    );

    final responseData = response.data;

    if (responseData is! Map) {
      throw const ApiException(
        message:
        'La respuesta al actualizar la aplicación no es válida.',
      );
    }

    if (responseData['ok'] != true) {
      throw ApiException(
        message:
        responseData['error']?.toString() ??
            'No fue posible actualizar la aplicación.',
      );
    }

    final applicationData =
    responseData['data'];

    if (applicationData is! Map) {
      throw const ApiException(
        message:
        'La aplicación actualizada no fue devuelta correctamente.',
      );
    }

    return ApplicationModel.fromJson(
      Map<String, dynamic>.from(
        applicationData,
      ),
    );
  }

  String _formatDate(DateTime date) {
    final year =
    date.year.toString().padLeft(4, '0');

    final month =
    date.month.toString().padLeft(2, '0');

    final day =
    date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }
}