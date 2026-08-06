// Angel Daniel Genao 2024-1169
// Pruebas del módulo de videos: que el modelo parsee bien el JSON del
// backend de Ocupa2, que el datasource llame el endpoint correcto y
// ordene por "order", y que el repositorio cachee la lista.

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ocupa2/core/network/api_client.dart';
import 'package:ocupa2/features/videos/data/datasources/videos_remote_datasource.dart';
import 'package:ocupa2/features/videos/data/models/video_model.dart';
import 'package:ocupa2/features/videos/data/providers/videos_data_providers.dart';
import 'package:ocupa2/features/videos/data/repositories/videos_repository_impl.dart';
import 'package:ocupa2/features/videos/domain/entities/video.dart';
import 'package:ocupa2/features/videos/domain/repositories/videos_repository.dart';

void main() {
  group('VideoModel', () {
    test('parsea un video completo del backend de Ocupa2', () {
      final video = VideoModel.fromJson(_videoJson());

      expect(video.id, '6a446adfa7eceacf02e1a10d');
      expect(video.youtubeId, 'fmeNtmRRwQM');
      expect(video.url, 'https://www.youtube.com/watch?v=fmeNtmRRwQM');
      expect(video.title, '¿Cómo conseguir el trabajo que te mereces?');
      expect(video.description, 'Consejos para buscar empleo.');
      expect(video.thumbnail, 'https://img.youtube.com/vi/fmeNtmRRwQM/hqdefault.jpg');
      expect(video.order, 2);
      expect(video.embedUrl, 'https://www.youtube.com/embed/fmeNtmRRwQM');
    });

    test('requiere el campo youtubeId', () {
      expect(
        () => VideoModel.fromJson(_videoJson(youtubeId: '')),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('OcupaBackendVideosRemoteDataSource', () {
    test('GET /videos llama el endpoint correcto y ordena por order', () async {
      final client = _TestApiClient({
        'ok': true,
        'data': [
          _videoJson(id: 'video-2', order: 2),
          _videoJson(id: 'video-1', order: 1),
        ],
      });
      final dataSource = OcupaBackendVideosRemoteDataSource(client.apiClient);

      final videos = await dataSource.getVideos();

      expect(client.lastOptions.method, 'GET');
      expect(client.lastOptions.path, '/videos');
      expect(videos.map((video) => video.id), ['video-1', 'video-2']);
    });

    test('devuelve lista vacía cuando "ok" es false', () async {
      final client = _TestApiClient({'ok': false, 'data': []});
      final dataSource = OcupaBackendVideosRemoteDataSource(client.apiClient);

      final videos = await dataSource.getVideos();

      expect(videos, isEmpty);
    });
  });

  group('VideosRepositoryImpl', () {
    test('cachea la lista y no vuelve a llamar al datasource', () async {
      final dataSource = _FakeVideosRemoteDataSource();
      final repository = VideosRepositoryImpl(dataSource);

      await repository.getVideos();
      await repository.getVideos();

      expect(dataSource.getVideosCalls, 1);
    });

    test('forceRefresh vuelve a llamar al datasource', () async {
      final dataSource = _FakeVideosRemoteDataSource();
      final repository = VideosRepositoryImpl(dataSource);

      await repository.getVideos();
      await repository.getVideos(forceRefresh: true);

      expect(dataSource.getVideosCalls, 2);
    });
  });

  group('Videos providers', () {
    test('el repositorio puede sustituirse mediante override', () {
      final fakeRepository = _FakeVideosRepository();
      final container = ProviderContainer(
        overrides: [
          videosRepositoryProvider.overrideWithValue(fakeRepository),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(videosRepositoryProvider), same(fakeRepository));
    });
  });
}

Map<String, Object?> _videoJson({
  String id = '6a446adfa7eceacf02e1a10d',
  String youtubeId = 'fmeNtmRRwQM',
  String url = 'https://www.youtube.com/watch?v=fmeNtmRRwQM',
  String title = '¿Cómo conseguir el trabajo que te mereces?',
  String description = 'Consejos para buscar empleo.',
  String thumbnail = 'https://img.youtube.com/vi/fmeNtmRRwQM/hqdefault.jpg',
  int order = 2,
}) {
  return {
    'id': id,
    'youtubeId': youtubeId,
    'url': url,
    'title': title,
    'description': description,
    'thumbnail': thumbnail,
    'order': order,
  };
}

class _TestApiClient {
  _TestApiClient(this.responseData) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          lastOptions = options;
          handler.resolve(
            Response<Object?>(
              requestOptions: options,
              statusCode: 200,
              data: responseData,
            ),
          );
        },
      ),
    );
  }

  final Object? responseData;
  final Dio dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
  late RequestOptions lastOptions;

  ApiClient get apiClient => ApiClient(dio);
}

class _FakeVideosRemoteDataSource implements VideosRemoteDataSource {
  final videos = [VideoModel.fromJson(_videoJson())];
  int getVideosCalls = 0;

  @override
  Future<List<Video>> getVideos() async {
    getVideosCalls++;
    return videos;
  }
}

class _FakeVideosRepository implements VideosRepository {
  @override
  Future<List<Video>> getVideos({bool forceRefresh = false}) async {
    return [VideoModel.fromJson(_videoJson())];
  }
}
