import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';

import '../providers/payment_presentation_providers.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({
    super.key,
  });

  @override
  ConsumerState<PaymentScreen> createState() =>
      _PaymentScreenState();
}

class _PaymentScreenState
    extends ConsumerState<PaymentScreen> {

  final _formKey = GlobalKey<FormState>();

  final _cardNumberController =
      TextEditingController();

  final _cvvController =
      TextEditingController();

  final _expMonthController =
      TextEditingController();

  final _expYearController =
      TextEditingController();

  final _cardholderController =
      TextEditingController();

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cvvController.dispose();
    _expMonthController.dispose();
    _expYearController.dispose();
    _cardholderController.dispose();

    super.dispose();
  }

  Future<void> _pay() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await ref
        .read(paymentControllerProvider.notifier)
        .createPayment(
          cardNumber:
              _cardNumberController.text.trim(),
          cvv:
              _cvvController.text.trim(),
          expMonth:
              int.parse(
                _expMonthController.text.trim(),
              ),
          expYear:
              int.parse(
                _expYearController.text.trim(),
              ),
          cardholder:
              _cardholderController.text.trim(),
        );

    if (!mounted) return;

    final state =
        ref.read(paymentControllerProvider);

    if (state.payment != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Pago aprobado correctamente.',
          ),
        ),
      );

      Navigator.pop(
        context,
        state.payment!.id,
      );

      return;
    }

    if (state.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            state.error!,
          ),
        ),
      );
    }
  }

  String? _validateCardNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingrese el número de tarjeta';
    }

    final card = value.replaceAll(' ', '');

    if (card.length < 13 || card.length > 19) {
      return 'Número de tarjeta inválido';
    }

    if (int.tryParse(card) == null) {
      return 'Solo se permiten números';
    }

    return null;
  }

  String? _validateCvv(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingrese el CVV';
    }

    if (value.length < 3 || value.length > 4) {
      return 'CVV inválido';
    }

    if (int.tryParse(value) == null) {
      return 'Solo se permiten números';
    }

    return null;
  }

  String? _validateMonth(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingrese el mes';
    }

    final month = int.tryParse(value);

    if (month == null || month < 1 || month > 12) {
      return 'Mes inválido';
    }

    return null;
  }

  String? _validateYear(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingrese el año';
    }

    final year = int.tryParse(value);

    if (year == null) {
      return 'Año inválido';
    }

    if (year < DateTime.now().year) {
      return 'La tarjeta está vencida';
    }

    return null;
  }

  String? _validateCardholder(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingrese el nombre del titular';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final paymentState =
        ref.watch(paymentControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pago de publicación',
        ),
      ),

      body: SafeArea(
        child: Form(
          key: _formKey,

          child: ListView(
            padding: const EdgeInsets.all(20),

            children: [
              const Icon(
                Icons.credit_card,
                size: 70,
              ),

              const SizedBox(height: 20),

              Text(
                'Pago para publicar oferta',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall,
              ),

              const SizedBox(height: 8),

              const Text(
                'Costo de publicación: \$1 USD',
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 30),

              AppTextField(
                label: 'Número de tarjeta',
                hint: '4242 4242 4242 4242',
                controller:
                    _cardNumberController,
                keyboardType:
                    TextInputType.number,
                prefixIcon:
                    Icons.credit_card,
                validator:
                    _validateCardNumber,
              ),

              const SizedBox(height: 16),

              Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'CVV',
                      controller:
                          _cvvController,
                      keyboardType:
                          TextInputType.number,
                      prefixIcon:
                          Icons.lock_outline,
                      validator:
                          _validateCvv,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: AppTextField(
                      label: 'Mes',
                      hint: '12',
                      controller:
                          _expMonthController,
                      keyboardType:
                          TextInputType.number,
                      validator:
                          _validateMonth,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: AppTextField(
                      label: 'Año',
                      hint: '2030',
                      controller:
                          _expYearController,
                      keyboardType:
                          TextInputType.number,
                      validator:
                          _validateYear,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              AppTextField(
                label: 'Titular de la tarjeta',
                hint: 'Nombre del titular',
                controller:
                    _cardholderController,
                prefixIcon:
                    Icons.person_outline,
                validator:
                    _validateCardholder,
              ),

              const SizedBox(height: 30),

              AppButton(
                label: 'Pagar \$1 USD',
                isLoading:
                    paymentState.isLoading,
                onPressed: _pay,
              ),

              const SizedBox(height: 16),

              const Text(
                'Utiliza una tarjeta de prueba proporcionada por la API.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}