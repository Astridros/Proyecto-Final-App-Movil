// Angel Daniel Genao 2024-1169
// Pruebas del módulo de noticias: que el modelo parsee bien el JSON del
// backend de Ocupa2, que el datasource llame el endpoint correcto (sin
// filtrar ni transformar el contenido) y que el repositorio cachee la
// lista.

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ocupa2/core/network/api_client.dart';
import 'package:ocupa2/features/news/data/datasources/news_remote_datasource.dart';
import 'package:ocupa2/features/news/data/models/news_item_model.dart';
import 'package:ocupa2/features/news/data/providers/news_data_providers.dart';
import 'package:ocupa2/features/news/data/repositories/news_repository_impl.dart';
import 'package:ocupa2/features/news/domain/entities/news_item.dart';
import 'package:ocupa2/features/news/domain/repositories/news_repository.dart';

void main() {
  group('NewsItemModel', () {
    test('parsea una noticia completa del backend de Ocupa2', () {
      final newsItem = NewsItemModel.fromJson(_newsJson());

      expect(newsItem.title, 'Abren nuevas vacantes de empleo');
      expect(newsItem.description, 'Resumen del artículo.');
      expect(newsItem.image, 'https://remolacha.net/image.jpg');
      expect(newsItem.url, 'https://remolacha.net/articulo');
      expect(newsItem.sourceName, 'remolacha.net');
      expect(newsItem.sourceUrl, 'https://remolacha.net');
      expect(newsItem.publishedAt, DateTime.parse('2026-08-02T12:07:39-04:00'));
    });

    test('requiere el campo title', () {
      expect(
        () => NewsItemModel.fromJson(_newsJson(title: '')),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('OcupaBackendNewsRemoteDataSource', () {
    test('GET /news llama el endpoint correcto y parsea la lista', () async {
      final client = _TestApiClient({
        'ok': true,
        'data': [_newsJson(), _newsJson(title: 'Otra noticia')],
      });
      final dataSource = OcupaBackendNewsRemoteDataSource(client.apiClient);

      final news = await dataSource.getNews();

      expect(client.lastOptions.method, 'GET');
      expect(client.lastOptions.path, '/news');
      expect(news, hasLength(2));
    });

    test('no filtra ni descarta ninguna noticia', () async {
      final client = _TestApiClient({
        'ok': true,
        'data': [
          _newsJson(title: 'Accidente de tránsito deja un herido'),
          _newsJson(title: 'Abinader recibe a campeones de fútbol'),
          _newsJson(title: 'Abren nuevas vacantes de empleo'),
        ],
      });
      final dataSource = OcupaBackendNewsRemoteDataSource(client.apiClient);

      final news = await dataSource.getNews();

      expect(news, hasLength(3));
    });

    test('devuelve lista vacía cuando "ok" es false', () async {
      final client = _TestApiClient({'ok': false, 'data': []});
      final dataSource = OcupaBackendNewsRemoteDataSource(client.apiClient);

      final news = await dataSource.getNews();

      expect(news, isEmpty);
    });
  });

  group('NewsRepositoryImpl', () {
    test('cachea la lista y no vuelve a llamar al datasource', () async {
      final dataSource = _FakeNewsRemoteDataSource();
      final repository = NewsRepositoryImpl(dataSource);

      await repository.getNews();
      await repository.getNews();

      expect(dataSource.getNewsCalls, 1);
    });

    test('forceRefresh vuelve a llamar al datasource', () async {
      final dataSource = _FakeNewsRemoteDataSource();
      final repository = NewsRepositoryImpl(dataSource);

      await repository.getNews();
      await repository.getNews(forceRefresh: true);

      expect(dataSource.getNewsCalls, 2);
    });
  });

  group('News providers', () {
    test('el repositorio puede sustituirse mediante override', () {
      final fakeRepository = _FakeNewsRepository();
      final container = ProviderContainer(
        overrides: [newsRepositoryProvider.overrideWithValue(fakeRepository)],
      );
      addTearDown(container.dispose);

      expect(container.read(newsRepositoryProvider), same(fakeRepository));
    });
  });
}

Map<String, Object?> _newsJson({
  String title = 'Abren nuevas vacantes de empleo',
  String image = 'https://remolacha.net/image.jpg',
  String summary = 'Resumen del artículo.',
  String url = 'https://remolacha.net/articulo',
  String source = 'remolacha.net',
  String date = '2026-08-02T12:07:39-04:00',
}) {
  return {
    'title': title,
    'image': image,
    'summary': summary,
    'url': url,
    'source': source,
    'date': date,
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

class _FakeNewsRemoteDataSource implements NewsRemoteDataSource {
  final news = [NewsItemModel.fromJson(_newsJson())];
  int getNewsCalls = 0;

  @override
  Future<List<NewsItem>> getNews() async {
    getNewsCalls++;
    return news;
  }
}

class _FakeNewsRepository implements NewsRepository {
  @override
  Future<List<NewsItem>> getNews({bool forceRefresh = false}) async {
    return [NewsItemModel.fromJson(_newsJson())];
  }
}
