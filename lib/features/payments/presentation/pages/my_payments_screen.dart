import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loading.dart';
import '../providers/my_payments_controller.dart';
import '../providers/my_payments_presentation_providers.dart';
import '../providers/my_payments_state.dart';
import '../widgets/payment_card.dart';

// Yeison Familia - modulo Mis Pagos.
// Historial de pagos realizados. Maneja los cuatro estados: cargando, con
// datos, vacio y error.
class MyPaymentsScreen extends ConsumerStatefulWidget {
  const MyPaymentsScreen({super.key});

  @override
  ConsumerState<MyPaymentsScreen> createState() => _MyPaymentsScreenState();
}

class _MyPaymentsScreenState extends ConsumerState<MyPaymentsScreen> {
  @override
  void initState() {
    super.initState();
    // Se pide despues del primer frame para no modificar providers durante el
    // build de la pantalla.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(myPaymentsControllerProvider.notifier).loadPayments();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(myPaymentsControllerProvider);
    final controller = ref.read(myPaymentsControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Mis pagos')),
      body: SafeArea(child: _buildBody(state, controller)),
    );
  }

  Widget _buildBody(MyPaymentsState state, MyPaymentsController controller) {
    if (state.isInitialLoading && !state.hasPayments) {
      return const AppLoading(message: 'Cargando tus pagos...');
    }

    if (state.hasError && !state.hasPayments) {
      return AppErrorView(
        title: 'No pudimos cargar tus pagos',
        message: state.error!.message,
        onRetry: controller.loadPayments,
      );
    }

    if (state.isEmpty) {
      return const AppEmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'Aún no has hecho pagos',
        description:
            'Cuando publiques una oferta, el pago aparecerá aquí con su '
            'monto, estado y fecha.',
      );
    }

    return RefreshIndicator(
      onRefresh: controller.refresh,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.screenHorizontalPadding,
          vertical: AppDimensions.spacing20,
        ),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: state.payments.length,
        separatorBuilder: (_, _) =>
            const SizedBox(height: AppDimensions.spacing12),
        itemBuilder: (context, index) {
          return PaymentCard(payment: state.payments[index]);
        },
      ),
    );
  }
}
