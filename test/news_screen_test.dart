// Angel Daniel Genao 2024-1169
// Pruebas de la pantalla de noticias: loading, error, lista vacía
// y lista con noticias, usando un repositorio falso (fake).

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ocupa2/app/theme/app_theme.dart';
import 'package:ocupa2/core/errors/api_exception.dart';
import 'package:ocupa2/core/widgets/app_empty_state.dart';
import 'package:ocupa2/core/widgets/app_error_view.dart';
import 'package:ocupa2/core/widgets/app_skeleton_list.dart';
import 'package:ocupa2/features/news/data/providers/news_data_providers.dart';
import 'package:ocupa2/features/news/domain/entities/news_item.dart';
import 'package:ocupa2/features/news/domain/repositories/news_repository.dart';
import 'package:ocupa2/features/news/presentation/pages/news_screen.dart';

void main() {
  testWidgets('muestra loading inicial', (tester) async {
    final repository = _FakeNewsRepository(delay: true);

    await tester.pumpWidget(_testApp(repository));
    await tester.pump();

    expect(find.byType(AppSkeletonList), findsOneWidget);
  });

  testWidgets('muestra error sin noticias', (tester) async {
    final repository = _FakeNewsRepository(
      error: const ApiException(message: 'Fallo controlado'),
    );

    await tester.pumpWidget(_testApp(repository));
    await tester.pumpAndSettle();

    expect(find.byType(AppErrorView), findsOneWidget);
    expect(find.text('Fallo controlado'), findsOneWidget);
  });

  testWidgets('muestra EmptyState sin noticias', (tester) async {
    final repository = _FakeNewsRepository(items: const []);

    await tester.pumpWidget(_testApp(repository));
    await tester.pumpAndSettle();

    expect(find.byType(AppEmptyState), findsOneWidget);
  });

  testWidgets('muestra lista con varias noticias', (tester) async {
    final repository = _FakeNewsRepository(
      items: [_newsItem('Noticia uno'), _newsItem('Noticia dos')],
    );

    await tester.pumpWidget(_testApp(repository));
    await tester.pumpAndSettle();

    expect(find.text('Noticia uno'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Noticia dos'),
      420,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('Noticia dos'), findsOneWidget);
  });
}

Widget _testApp(_FakeNewsRepository repository) {
  return ProviderScope(
    overrides: [newsRepositoryProvider.overrideWithValue(repository)],
    child: MaterialApp(theme: AppTheme.light, home: const NewsScreen()),
  );
}

NewsItem _newsItem(String title) {
  return NewsItem(
    title: title,
    image: 'https://remolacha.net/image.jpg',
    description: 'Descripción',
    url: 'https://remolacha.net/articulo',
    sourceName: 'remolacha.net',
    sourceUrl: 'https://remolacha.net',
    publishedAt: DateTime(2026, 7, 1),
  );
}

class _FakeNewsRepository implements NewsRepository {
  _FakeNewsRepository({this.items = const [], this.error, this.delay = false});

  final List<NewsItem> items;
  final Exception? error;
  final bool delay;

  @override
  Future<List<NewsItem>> getNews({bool forceRefresh = false}) async {
    if (delay) {
      return Completer<List<NewsItem>>().future;
    }

    if (error != null) {
      throw error!;
    }

    return items;
  }
}
