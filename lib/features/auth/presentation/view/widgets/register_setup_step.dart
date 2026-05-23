import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../ride_offers/domain/entities/zone.dart';
import '../models/register_payment_method.dart';
import '../models/register_vehicle_draft.dart';
import 'primary_action_button.dart';
import 'register_payment_methods_section.dart';
import 'register_role_selector.dart';
import 'register_step_header.dart';
import 'register_vehicle_card.dart';
import 'register_zone_selector.dart';
import 'secondary_action_button.dart';

class RegisterSetupStep extends StatelessWidget {
  const RegisterSetupStep({
    super.key,
    required this.formKey,
    required this.zones,
    required this.isLoadingZones,
    required this.selectedZoneId,
    required this.zoneErrorText,
    required this.wantsDriverRole,
    required this.vehicles,
    required this.maxVehicles,
    required this.selectedPaymentMethods,
    required this.paymentControllers,
    required this.paymentErrorText,
    required this.onZoneSelected,
    required this.onDriverRoleChanged,
    required this.onAddVehicle,
    required this.onRemoveVehicle,
    required this.onPaymentMethodToggled,
    required this.onBack,
    required this.onSubmit,
    required this.submitLabel,
  });

  final GlobalKey<FormState> formKey;
  final List<Zone> zones;
  final bool isLoadingZones;
  final String? selectedZoneId;
  final String? zoneErrorText;
  final bool wantsDriverRole;
  final List<RegisterVehicleDraft> vehicles;
  final int maxVehicles;
  final Set<RegisterPaymentMethod> selectedPaymentMethods;
  final Map<RegisterPaymentMethod, TextEditingController> paymentControllers;
  final String? paymentErrorText;
  final ValueChanged<String?> onZoneSelected;
  final ValueChanged<bool> onDriverRoleChanged;
  final VoidCallback onAddVehicle;
  final ValueChanged<int> onRemoveVehicle;
  final ValueChanged<RegisterPaymentMethod> onPaymentMethodToggled;
  final VoidCallback onBack;
  final VoidCallback onSubmit;
  final String submitLabel;

  @override
  Widget build(BuildContext context) {
    final hasReachedVehicleLimit = vehicles.length >= maxVehicles;

    return Form(
      key: formKey,
      child: Column(
        children: [
          const RegisterStepHeader(
            title: 'Configuracion',
            subtitle: 'Completa la informacion necesaria para empezar en wheels',
            currentStep: 1,
            totalSteps: 2,
          ),
          const SizedBox(height: 24),
          RegisterZoneSelector(
            zones: zones,
            isLoading: isLoadingZones,
            selectedZoneId: selectedZoneId,
            onSelected: onZoneSelected,
            errorText: zoneErrorText,
          ),
          const SizedBox(height: 18),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Que roles vas a usar en la app',
              style: AppTextStyles.secondary.copyWith(
                color: AppColors.slate800,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 8),
          RegisterRoleSelector(
            wantsDriverRole: wantsDriverRole,
            onDriverRoleChanged: onDriverRoleChanged,
          ),
          const SizedBox(height: 18),
          if (wantsDriverRole) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Configura tus vehiculos',
                style: AppTextStyles.secondary.copyWith(
                  color: AppColors.slate900,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: RichText(
                text: TextSpan(
                  style: AppTextStyles.primary.copyWith(
                    color: AppColors.slate400,
                    fontSize: 12,
                  ),
                  children: [
                    const TextSpan(
                      text:
                          'Agrega la informacion de los vehiculos que va a ofrecer en wheels. ',
                    ),
                    TextSpan(
                      text: 'Tiene un limite de $maxVehicles carros.',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            ...List.generate(vehicles.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: RegisterVehicleCard(
                  index: index,
                  vehicle: vehicles[index],
                  canRemove: vehicles.length > 1,
                  onRemove: () => onRemoveVehicle(index),
                ),
              );
            }),
            ElevatedButton.icon(
              onPressed: hasReachedVehicleLimit ? null : onAddVehicle,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.teal600,
                disabledBackgroundColor: AppColors.teal600,
                foregroundColor: AppColors.white,
                minimumSize: const Size.fromHeight(50),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.add, color: AppColors.white),
              label: Text(
                'Agregar vehiculo',
                style: AppTextStyles.primary.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 18),
          ],
          if (wantsDriverRole)
            RegisterPaymentMethodsSection(
              selectedMethods: selectedPaymentMethods,
              controllers: paymentControllers,
              onMethodToggled: onPaymentMethodToggled,
              errorText: paymentErrorText,
            ),
          const SizedBox(height: 24),
          PrimaryActionButton(
            label: submitLabel,
            onPressed: onSubmit,
          ),
          const SizedBox(height: 12),
          SecondaryActionButton(label: 'Anterior', onPressed: onBack),
        ],
      ),
    );
  }
}
