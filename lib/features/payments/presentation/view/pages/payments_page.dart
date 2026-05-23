import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../../core/layout/header.dart' as header_layout;
import '../../../../../core/layout/navigation_bar.dart' as navigation_layout;
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../auth/presentation/view/widgets/auth_session_listener.dart';
import '../../../../user/domain/entities/user_role.dart';
import '../../../../user/presentation/view_model/user_cubit.dart';
import '../../../domain/entities/payment_method.dart';
import '../../../domain/entities/ride_payment.dart';
import '../../view_model/payments_cubit.dart';
import '../../view_model/payments_state.dart';

class PaymentsPage extends StatelessWidget {
  const PaymentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userState = context.read<UserCubit>().state;
    final preferredRole = userState.activeRole == UserRole.rider
        ? PaymentsRole.rider
        : PaymentsRole.driver;

    return BlocProvider(
      create: (_) => GetIt.instance<PaymentsCubit>()
        ..load(
          driverId: userState.user?.driver?.id,
          riderId: userState.user?.rider?.id,
          preferredRole: preferredRole,
        ),
      child: const _PaymentsView(),
    );
  }
}

class _PaymentsView extends StatelessWidget {
  const _PaymentsView();

  @override
  Widget build(BuildContext context) {
    return AuthSessionListener(
      child: Scaffold(
        backgroundColor: AppColors.slate900,
        appBar: const header_layout.Header(),
        body: SafeArea(
          top: false,
          child: BlocConsumer<PaymentsCubit, PaymentsState>(
            listener: (context, state) {
              if (state.message == null || state.message!.trim().isEmpty) {
                return;
              }

              ScaffoldMessenger.of(context)
                ..clearSnackBars()
                ..showSnackBar(SnackBar(content: Text(state.message!)));
            },
            builder: (context, state) {
              return ScrollConfiguration(
                behavior: const MaterialScrollBehavior().copyWith(
                  overscroll: false,
                ),
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Mis pagos',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.primary.copyWith(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Consulta tu informacion de pagos como conductor o pasajero.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.primary.copyWith(
                          color: AppColors.slate300,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _RoleSelector(state: state),
                      const SizedBox(height: 28),
                      _PaymentsContent(state: state),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        bottomNavigationBar: const navigation_layout.NavigationBar(
          selectedItem: navigation_layout.NavigationBarItem.payments,
        ),
      ),
    );
  }
}

class _RoleSelector extends StatelessWidget {
  const _RoleSelector({required this.state});

  final PaymentsState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          _RoleButton(
            label: 'Conductor',
            selected: state.selectedRole == PaymentsRole.driver,
            onTap: () =>
                context.read<PaymentsCubit>().changeRole(PaymentsRole.driver),
          ),
          const SizedBox(width: 8),
          _RoleButton(
            label: 'Pasajero',
            selected: state.selectedRole == PaymentsRole.rider,
            onTap: () =>
                context.read<PaymentsCubit>().changeRole(PaymentsRole.rider),
          ),
        ],
      ),
    );
  }
}

class _RoleButton extends StatelessWidget {
  const _RoleButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFF97316) : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.primary.copyWith(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class _PaymentsContent extends StatelessWidget {
  const _PaymentsContent({required this.state});

  final PaymentsState state;

  @override
  Widget build(BuildContext context) {
    if (state.status == PaymentsStatus.loading ||
        state.status == PaymentsStatus.initial) {
      return const _StateCard(
        child: Column(
          children: [
            CircularProgressIndicator(color: AppColors.amber700),
            SizedBox(height: 14),
            Text('Cargando pagos...'),
          ],
        ),
      );
    }

    if (state.status == PaymentsStatus.error) {
      return _StateCard(
        child: Column(
          children: [
            Text(state.message ?? 'No pudimos cargar tus pagos.'),
            const SizedBox(height: 14),
            OutlinedButton(
              onPressed: () {
                final user = context.read<UserCubit>().state.user;
                context.read<PaymentsCubit>().load(
                  driverId: user?.driver?.id,
                  riderId: user?.rider?.id,
                  preferredRole: state.selectedRole,
                );
              },
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    final payments = state.visiblePayments;
    if (payments.isEmpty) {
      return const _StateCard(child: Text('No tienes pagos para mostrar.'));
    }

    final groups = _groupByRide(payments);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final group in groups) ...[
          _RidePaymentGroupCard(
            payments: group,
            role: state.selectedRole,
            state: state,
          ),
          const SizedBox(height: 18),
        ],
      ],
    );
  }

  List<List<RidePayment>> _groupByRide(List<RidePayment> payments) {
    final grouped = <String, List<RidePayment>>{};
    for (final payment in payments) {
      grouped.putIfAbsent(payment.rideId, () => []).add(payment);
    }
    return grouped.values.toList();
  }
}

class _RidePaymentGroupCard extends StatelessWidget {
  const _RidePaymentGroupCard({
    required this.payments,
    required this.role,
    required this.state,
  });

  final List<RidePayment> payments;
  final PaymentsRole role;
  final PaymentsState state;

  @override
  Widget build(BuildContext context) {
    final first = payments.first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '${first.source} -> ${first.destination}',
          style: AppTextStyles.primary.copyWith(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text('Fecha: ${first.date}', style: _metaStyle()),
        const SizedBox(height: 6),
        Text('Hora: ${first.departureTime}', style: _metaStyle()),
        const SizedBox(height: 18),
        Text(
          role == PaymentsRole.driver ? 'Pagos del viaje' : 'Pagos pendientes',
          style: AppTextStyles.primary.copyWith(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        for (final payment in payments) ...[
          _PaymentCard(payment: payment, role: role, state: state),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  TextStyle _metaStyle() {
    return AppTextStyles.primary.copyWith(
      color: Colors.white.withValues(alpha: 0.88),
      fontSize: 15,
      fontWeight: FontWeight.w600,
    );
  }
}

class _PaymentCard extends StatelessWidget {
  const _PaymentCard({
    required this.payment,
    required this.role,
    required this.state,
  });

  final RidePayment payment;
  final PaymentsRole role;
  final PaymentsState state;

  @override
  Widget build(BuildContext context) {
    final isUpdating =
        state.isUpdating && state.updatingPaymentId == payment.id;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.20),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      role == PaymentsRole.driver
                          ? payment.riderName
                          : payment.driverName,
                      style: AppTextStyles.primary.copyWith(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _stateLabel(payment.state),
                      style: AppTextStyles.primary.copyWith(
                        color: Colors.white.withValues(alpha: 0.82),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (payment.type != null &&
                        payment.type!.trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Metodo: ${payment.type}',
                        style: AppTextStyles.primary.copyWith(
                          color: Colors.white.withValues(alpha: 0.74),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Text(
                '\$ ${payment.amount}',
                style: AppTextStyles.primary.copyWith(
                  color: const Color(0xFFF97316),
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          if (role == PaymentsRole.rider && payment.isPending) ...[
            const SizedBox(height: 14),
            _PaymentMethodSelector(payment: payment, state: state),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: isUpdating
                  ? null
                  : () => context.read<PaymentsCubit>().submitPassengerPayment(
                      payment,
                    ),
              style: _primaryButtonStyle(),
              child: Text(isUpdating ? 'Enviando...' : 'Confirmar pago'),
            ),
          ],
          if (role == PaymentsRole.driver &&
              payment.isWaitingDriverConfirmation) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: isUpdating
                        ? null
                        : () => context.read<PaymentsCubit>().rejectPayment(
                            payment,
                          ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white70),
                    ),
                    child: const Text('No recibido'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isUpdating
                        ? null
                        : () => context.read<PaymentsCubit>().confirmPayment(
                            payment,
                          ),
                    style: _primaryButtonStyle(),
                    child: Text(isUpdating ? 'Confirmando...' : 'Recibido'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _stateLabel(String state) {
    return switch (state) {
      'PENDIENTE' => 'Pago pendiente',
      'POR CONFIRMAR' => 'Por confirmar',
      'COMPLETADO' => 'Pago confirmado',
      _ => state,
    };
  }

  ButtonStyle _primaryButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFF97316),
      disabledBackgroundColor: const Color(0xFFF97316).withValues(alpha: 0.55),
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 13),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}

class _PaymentMethodSelector extends StatelessWidget {
  const _PaymentMethodSelector({required this.payment, required this.state});

  final RidePayment payment;
  final PaymentsState state;

  @override
  Widget build(BuildContext context) {
    final methods = payment.availableMethods;
    if (methods.isEmpty) {
      return Text(
        'El conductor no tiene metodos de pago registrados.',
        style: AppTextStyles.primary.copyWith(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    final selectedType =
        state.selectedMethodByPaymentId[payment.id] ?? methods.first.type;
    if (!state.selectedMethodByPaymentId.containsKey(payment.id)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          context.read<PaymentsCubit>().selectMethod(
            paymentId: payment.id,
            type: selectedType,
          );
        }
      });
    }

    return DropdownButtonFormField<String>(
      initialValue: selectedType,
      dropdownColor: AppColors.slate800,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.10),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.18)),
        ),
      ),
      style: AppTextStyles.primary.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w700,
      ),
      items: [
        for (final method in methods)
          DropdownMenuItem<String>(
            value: method.type,
            child: Text(_methodLabel(method)),
          ),
      ],
      onChanged: (value) {
        if (value == null) return;
        context.read<PaymentsCubit>().selectMethod(
          paymentId: payment.id,
          type: value,
        );
      },
    );
  }

  String _methodLabel(PaymentMethod method) {
    final account = method.numberAccount?.trim();
    if (account == null || account.isEmpty) {
      return method.type;
    }
    return '${method.type} - $account';
  }
}

class _StateCard extends StatelessWidget {
  const _StateCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: DefaultTextStyle(
        textAlign: TextAlign.center,
        style: AppTextStyles.primary.copyWith(
          color: AppColors.slate900,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        child: child,
      ),
    );
  }
}
