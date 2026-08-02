// Angel Daniel Genao 2024-1169
// Pruebas de la pantalla de videos: loading, error, lista vacía y lista
// con videos, usando un repositorio falso (fake).

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ocupa2/app/theme/app_theme.dart';
import 'package:ocupa2/core/errors/api_exception.dart';
import 'package:ocupa2/core/widgets/app_empty_state.dart';
import 'package:ocupa2/core/widgets/app_error_view.dart';
import 'package:ocupa2/core/widgets/app_skeleton_list.dart';
import 'package:ocupa2/features/videos/data/providers/videos_data_providers.dart';
import 'package:ocupa2/features/videos/domain/entities/video.dart';
import 'package:ocupa2/features/videos/domain/repositories/videos_repository.dart';
import 'package:ocupa2/features/videos/presentation/pages/videos_screen.dart';

void main() {
  testWidgets('muestra skeleton mientras carga inicialmente', (tester) async {
    final repository = _FakeVideosRepository(delay: true);

    await tester.pumpWidget(_testApp(repository));
    await tester.pump();

    expect(find.byType(AppSkeletonList), findsOneWidget);
  });

  testWidgets('muestra error sin videos con boton de reintentar', (
    tester,
  ) async {
    final repository = _FakeVideosRepository(
      error: const ApiException(message: 'Fallo controlado'),
    );

    await tester.pumpWidget(_testApp(repository));
    await tester.pumpAndSettle();

    expect(find.byType(AppErrorView), findsOneWidget);
    expect(find.text('Fallo controlado'), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);
  });

  testWidgets('muestra EmptyState sin videos', (tester) async {
    final repository = _FakeVideosRepository(videos: const []);

    await tester.pumpWidget(_testApp(repository));
    await tester.pumpAndSettle();

    expect(find.byType(AppEmptyState), findsOneWidget);
  });

  testWidgets('muestra lista con varios videos', (tester) async {
    final repository = _FakeVideosRepository(
      videos: [_video('1', 'Tutorial uno'), _video('2', 'Tutorial dos')],
    );

    await tester.pumpWidget(_testApp(repository));
    await tester.pumpAndSettle();

    expect(find.text('Tutorial uno'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Tutorial dos'),
      420,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('Tutorial dos'), findsOneWidget);
  });
}

Widget _testApp(_FakeVideosRepository repository) {
  return ProviderScope(
    overrides: [videosRepositoryProvider.overrideWithValue(repository)],
    child: MaterialApp(theme: AppTheme.light, home: const VideosScreen()),
  );
}

Video _video(String id, String title) {
  return Video(
    id: id,
    youtubeId: 'fmeNtmRRwQM',
    url: 'https://www.youtube.com/watch?v=fmeNtmRRwQM',
    title: title,
    description: 'Descripción',
    thumbnail: '',
    order: 1,
  );
}

class _FakeVideosRepository implements VideosRepository {
  _FakeVideosRepository({
    this.videos = const [],
    this.error,
    this.delay = false,
  });

  final List<Video> videos;
  final Exception? error;
  final bool delay;

  @override
  Future<List<Video>> getVideos({bool forceRefresh = false}) async {
    if (delay) {
      return Completer<List<Video>>().future;
    }

    if (error != null) {
      throw error!;
    }

    return videos;
  }
}
