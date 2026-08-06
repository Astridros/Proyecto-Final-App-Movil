import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ocupa2/app/theme/app_theme.dart';
import 'package:ocupa2/features/offers/domain/constants/contract_types.dart';
import 'package:ocupa2/features/offers/domain/entities/job_type.dart';
import 'package:ocupa2/features/offers/presentation/widgets/active_filters_summary.dart';
import 'package:ocupa2/features/offers/presentation/widgets/contract_type_filter.dart';
import 'package:ocupa2/features/offers/presentation/widgets/job_type_filter.dart';
import 'package:ocupa2/features/offers/presentation/widgets/offers_filter_bar.dart';

void main() {
  testWidgets('JobTypeFilter muestra Todos', (tester) async {
    await tester.pumpWidget(
      _testApp(
        JobTypeFilter(
          jobTypes: const [],
          selectedJobTypeKey: null,
          onChanged: (_) {},
        ),
      ),
    );

    expect(find.text('Todos'), findsOneWidget);
    expect(find.text('Tipo de trabajo'), findsOneWidget);
  });

  testWidgets('JobTypeFilter muestra los nombres dinámicos recibidos', (
    tester,
  ) async {
    await tester.pumpWidget(
      _testApp(
        JobTypeFilter(
          jobTypes: _jobTypes,
          selectedJobTypeKey: null,
          onChanged: (_) {},
        ),
      ),
    );

    await tester.tap(find.byType(DropdownButtonFormField<String?>));
    await tester.pumpAndSettle();

    expect(find.text('Chofer'), findsOneWidget);
    expect(find.text('Servicio al cliente con nombre largo'), findsOneWidget);
  });

  testWidgets('JobTypeFilter al elegir un tipo devuelve su key', (
    tester,
  ) async {
    String? selected;
    await tester.pumpWidget(
      _testApp(
        JobTypeFilter(
          jobTypes: _jobTypes,
          selectedJobTypeKey: null,
          onChanged: (value) => selected = value,
        ),
      ),
    );

    await tester.tap(find.byType(DropdownButtonFormField<String?>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Chofer').last);
    await tester.pumpAndSettle();

    expect(selected, 'chofer');
  });

  testWidgets('ContractTypeFilter muestra las opciones esperadas', (
    tester,
  ) async {
    await tester.pumpWidget(
      _testApp(
        ContractTypeFilter(selectedContractType: null, onChanged: (_) {}),
      ),
    );

    await tester.tap(find.byType(DropdownButtonFormField<String?>));
    await tester.pumpAndSettle();

    expect(find.text('Todos'), findsWidgets);
    expect(find.text('Temporal'), findsOneWidget);
    expect(find.text('Fijo'), findsOneWidget);
    expect(find.text('Por horas'), findsOneWidget);
  });

  testWidgets('ContractTypeFilter devuelve cada valor del backend', (
    tester,
  ) async {
    final selectedValues = <String?>[];
    await tester.pumpWidget(
      _testApp(
        ContractTypeFilter(
          selectedContractType: null,
          onChanged: selectedValues.add,
        ),
      ),
    );

    await _selectContract(tester, 'Temporal');
    await _selectContract(tester, 'Fijo');
    await _selectContract(tester, 'Por horas');

    expect(selectedValues, [
      ContractTypes.temporal,
      ContractTypes.fijo,
      ContractTypes.horas,
    ]);
  });

  testWidgets('OffersFilterBar se construye con lista vacía', (tester) async {
    await tester.pumpWidget(_testApp(_filterBar(jobTypes: const [])));

    expect(find.text('Filtros'), findsOneWidget);
    expect(find.text('Tipo de trabajo'), findsOneWidget);
    expect(find.text('Tipo de contrato'), findsOneWidget);
  });

  testWidgets('OffersFilterBar no produce overflow en ancho pequeño', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 760);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_testApp(_filterBar()));
    await tester.pump();

    expect(tester.takeException(), isNull);
  });

  testWidgets('Limpiar filtros no aparece sin filtros', (tester) async {
    await tester.pumpWidget(_testApp(_filterBar()));

    expect(find.text('Limpiar filtros'), findsNothing);
  });

  testWidgets('Limpiar filtros no aparece con filtros activos', (tester) async {
    await tester.pumpWidget(_testApp(_filterBar(selectedJobTypeKey: 'chofer')));

    expect(find.text('Limpiar filtros'), findsNothing);
    expect(find.text('Limpiar'), findsOneWidget);
  });

  testWidgets('la acción Limpiar del resumen ejecuta el callback', (
    tester,
  ) async {
    var clearCalls = 0;
    await tester.pumpWidget(
      _testApp(
        _filterBar(
          selectedJobTypeKey: 'chofer',
          onClearFilters: () => clearCalls++,
        ),
      ),
    );

    await tester.tap(find.text('Limpiar'));

    expect(clearCalls, 1);
  });

  testWidgets('isFiltering muestra un indicador discreto', (tester) async {
    await tester.pumpWidget(_testApp(_filterBar(isFiltering: true)));

    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });

  testWidgets('los controles respetan enabled false', (tester) async {
    String? changed;
    await tester.pumpWidget(
      _testApp(
        _filterBar(
          enabled: false,
          onJobTypeChanged: (value) => changed = value,
        ),
      ),
    );

    final field = tester.widget<DropdownButtonFormField<String?>>(
      find.byType(DropdownButtonFormField<String?>).first,
    );

    expect(field.onChanged, isNull);
    expect(changed, isNull);
  });

  testWidgets('ActiveFiltersSummary muestra nombres amigables', (tester) async {
    await tester.pumpWidget(
      _testApp(
        ActiveFiltersSummary(
          jobTypes: _jobTypes,
          selectedJobTypeKey: 'chofer',
          selectedContractType: ContractTypes.temporal,
          onClearFilters: () {},
        ),
      ),
    );

    expect(find.text('2 filtros activos'), findsOneWidget);
    expect(find.text('Chofer · Temporal'), findsOneWidget);
    expect(find.text('Limpiar'), findsOneWidget);
  });

  testWidgets('un valor inválido de contrato no rompe el widget', (
    tester,
  ) async {
    await tester.pumpWidget(
      _testApp(
        ContractTypeFilter(
          selectedContractType: 'permanent',
          onChanged: (_) {},
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Todos'), findsOneWidget);
  });
}

Future<void> _selectContract(WidgetTester tester, String label) async {
  await tester.tap(find.byType(DropdownButtonFormField<String?>));
  await tester.pumpAndSettle();
  await tester.tap(find.text(label).last);
  await tester.pumpAndSettle();
}

Widget _testApp(Widget child) {
  return MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    ),
  );
}

OffersFilterBar _filterBar({
  List<JobType>? jobTypes,
  String? selectedJobTypeKey,
  String? selectedContractType,
  bool isFiltering = false,
  bool enabled = true,
  ValueChanged<String?>? onJobTypeChanged,
  ValueChanged<String?>? onContractTypeChanged,
  VoidCallback? onClearFilters,
}) {
  return OffersFilterBar(
    jobTypes: jobTypes ?? _jobTypes,
    selectedJobTypeKey: selectedJobTypeKey,
    selectedContractType: selectedContractType,
    isFiltering: isFiltering,
    enabled: enabled,
    onJobTypeChanged: onJobTypeChanged ?? (_) {},
    onContractTypeChanged: onContractTypeChanged ?? (_) {},
    onClearFilters: onClearFilters ?? () {},
  );
}

final _jobTypes = [
  JobType(
    id: 'chofer-id',
    key: 'chofer',
    name: 'Chofer',
    active: true,
    customFields: const [],
    createdAt: DateTime(2026),
  ),
  JobType(
    id: 'servicio-id',
    key: 'servicio_cliente',
    name: 'Servicio al cliente con nombre largo',
    active: true,
    customFields: const [],
    createdAt: DateTime(2026),
  ),
];
