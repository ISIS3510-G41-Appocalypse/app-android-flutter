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
import '../../../../user/presentation/view_model/user_state.dart';
import '../../../domain/entities/payment_method.dart';
import '../../../domain/entities/ride_payment.dart';
import '../../view_model/payments_cubit.dart';
import '../../view_model/payments_state.dart';

class PaymentsPage extends StatelessWidget {
  const PaymentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userState = context.read<UserCubit>().state;
    final preferredRole = _roleFromUserState(userState);

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

PaymentsRole _roleFromUserState(UserState userState) {
  if (userState.activeRole == UserRole.driver) {
    return PaymentsRole.driver;
  }
  if (userState.activeRole == UserRole.rider) {
    return PaymentsRole.rider;
  }
  if (userState.user?.driver != null && userState.user?.rider == null) {
    return PaymentsRole.driver;
  }
  return PaymentsRole.rider;
}

class _PaymentsView extends StatelessWidget {
  const _PaymentsView();

  @override
  Widget build(BuildContext context) {
    return AuthSessionListener(
      child: BlocListener<UserCubit, UserState>(
        listenWhen: (previous, current) => previous.user != current.user,
        listener: (context, userState) {
          context.read<PaymentsCubit>().load(
            driverId: userState.user?.driver?.id,
            riderId: userState.user?.rider?.id,
            preferredRole: _roleFromUserState(userState),
          );
        },
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
                            color: AppColors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.selectedRole == PaymentsRole.driver
                              ? 'Consulta los pagos asociados a tus viajes como conductor.'
                              : 'Consulta los pagos pendientes de tus viajes como pasajero.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.primary.copyWith(
                            color: AppColors.slate300,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 28),
                        if (state.isRefreshing) ...[
                          const LinearProgressIndicator(
                            color: AppColors.amber700,
                            backgroundColor: AppColors.slate800,
                          ),
                          const SizedBox(height: 14),
                        ],
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
        if (state.isOffline) ...[
          const _OfflinePaymentsBanner(),
          const SizedBox(height: 14),
        ],
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

class _OfflinePaymentsBanner extends StatelessWidget {
  const _OfflinePaymentsBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.teal600,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.teal600),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.cloud_off_outlined,
            color: AppColors.white,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Sin conexion. Mostrando la ultima informacion disponible. Necesitas conexion para cambiar estados de pago.',
              style: AppTextStyles.primary.copyWith(
                color: AppColors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
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
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.slate200),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowSelected,
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _RideRouteTable(payment: first),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
            child: Row(
              children: [
                Expanded(
                  child: _MetaPill(
                    icon: Icons.calendar_month_outlined,
                    label: first.date,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _MetaPill(
                    icon: Icons.schedule_outlined,
                    label: first.departureTime,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
            child: Text(
              role == PaymentsRole.driver ? 'Pasajeros' : 'Pagos pendientes',
              style: AppTextStyles.primary.copyWith(
                color: AppColors.slate900,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          for (var index = 0; index < payments.length; index++) ...[
            _PaymentRow(
              payment: payments[index],
              role: role,
              state: state,
              isLast: index == payments.length - 1,
            ),
          ],
        ],
      ),
    );
  }
}

class _RideRouteTable extends StatelessWidget {
  const _RideRouteTable({required this.payment});

  final RidePayment payment;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      child: Table(
        columnWidths: const {0: FlexColumnWidth(), 1: FlexColumnWidth()},
        border: TableBorder(
          horizontalInside: BorderSide(color: AppColors.slate200),
          verticalInside: BorderSide(color: AppColors.slate200),
        ),
        children: [
          TableRow(
            children: const [
              _RouteCell(text: 'Origen', isHeader: true),
              _RouteCell(text: 'Destino', isHeader: true),
            ],
          ),
          TableRow(
            children: [
              _RouteCell(text: payment.source),
              _RouteCell(text: payment.destination),
            ],
          ),
        ],
      ),
    );
  }
}

class _RouteCell extends StatelessWidget {
  const _RouteCell({required this.text, this.isHeader = false});

  final String text;
  final bool isHeader;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 12,
        vertical: isHeader ? 9 : 12,
      ),
      child: Text(
        text.isEmpty ? '-' : text,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.primary.copyWith(
          color: isHeader ? AppColors.slate400 : AppColors.slate900,
          fontSize: isHeader ? 11 : 15,
          fontWeight: isHeader ? FontWeight.w800 : FontWeight.w700,
        ),
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.slate400),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.primary.copyWith(
                color: AppColors.slate900,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  const _PaymentRow({
    required this.payment,
    required this.role,
    required this.state,
    required this.isLast,
  });

  final RidePayment payment;
  final PaymentsRole role;
  final PaymentsState state;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final isUpdating =
        state.isUpdating && state.updatingPaymentId == payment.id;
    final canUpdate = !state.isOffline && !isUpdating;
    return Padding(
      padding: EdgeInsets.fromLTRB(14, 0, 14, isLast ? 14 : 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.gray50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.slate200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            role == PaymentsRole.driver
                                ? payment.riderName
                                : payment.driverName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.primary.copyWith(
                              color: AppColors.slate900,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              _StatusBadge(label: _stateLabel(payment.state)),
                              if (payment.type != null &&
                                  payment.type!.trim().isNotEmpty)
                                _StatusBadge(
                                  label: 'Metodo: ${payment.type}',
                                  muted: true,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '\$ ${payment.amount}',
                      style: AppTextStyles.primary.copyWith(
                        color: AppColors.amber700,
                        fontSize: 19,
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
                    onPressed: !canUpdate
                        ? null
                        : () => context
                              .read<PaymentsCubit>()
                              .submitPassengerPayment(payment),
                    style: _primaryButtonStyle(),
                    child: Text(isUpdating ? 'Enviando...' : 'Pagado'),
                  ),
                ],
                if (role == PaymentsRole.driver &&
                    payment.isWaitingDriverConfirmation) ...[
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: !canUpdate
                              ? null
                              : () => context
                                    .read<PaymentsCubit>()
                                    .rejectPayment(payment),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.slate900,
                            side: const BorderSide(color: AppColors.slate300),
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('No se pago'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: !canUpdate
                              ? null
                              : () => context
                                    .read<PaymentsCubit>()
                                    .confirmPayment(payment),
                          style: _primaryButtonStyle(),
                          child: Text(isUpdating ? 'Confirmando...' : 'Pago'),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, this.muted = false});

  final String label;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: muted
            ? AppColors.slate100
            : AppColors.amber700.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: AppTextStyles.primary.copyWith(
          color: muted ? AppColors.slate400 : AppColors.amber700,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
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
    backgroundColor: AppColors.amber700,
    disabledBackgroundColor: AppColors.amber700.withValues(alpha: 0.55),
    foregroundColor: AppColors.white,
    padding: const EdgeInsets.symmetric(vertical: 13),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  );
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
          color: AppColors.slate900,
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
      dropdownColor: AppColors.white,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.slate200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.amber700, width: 1.4),
        ),
      ),
      style: AppTextStyles.primary.copyWith(
        color: AppColors.slate900,
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
        color: AppColors.white,
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
