import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../models/register_vehicle_draft.dart';
import 'register_text_field.dart';

class RegisterVehicleCard extends StatelessWidget {
  const RegisterVehicleCard({
    super.key,
    required this.index,
    required this.vehicle,
    required this.canRemove,
    required this.onRemove,
  });

  final int index;
  final RegisterVehicleDraft vehicle;
  final bool canRemove;
  final VoidCallback onRemove;

  String? _requiredValidator(String? value, String fieldName) {
    final normalized = value?.trim() ?? '';
    if (normalized.isEmpty) {
      return '$fieldName es obligatorio';
    }
    if (normalized.length < 3) {
      return '$fieldName debe tener al menos 3 caracteres';
    }
    return null;
  }

  String? _plateValidator(String? value) {
    final normalized = (value?.trim() ?? '').toUpperCase();
    if (normalized.isEmpty) {
      return 'Placa requerida';
    }
    if (!RegExp(r'^[A-Z]{3}[0-9]{3}$').hasMatch(normalized)) {
      return 'Placa invalida';
    }
    return null;
  }

  String? _slotsValidator(String? value) {
    final normalized = value?.trim() ?? '';
    if (normalized.isEmpty) {
      return 'Numero de cupos es obligatorio';
    }
    final slots = int.tryParse(normalized);
    if (slots == null || slots < 1 || slots > 7) {
      return 'El numero de cupos debe estar entre 1 y 7';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${index + 1}. Configura tu vehiculo',
                  style: AppTextStyles.secondary.copyWith(
                    color: AppColors.slate900,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
              if (canRemove)
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete_outline, color: AppColors.errorRed),
                ),
            ],
          ),
          Text(
            'Agrega la informacion del vehiculo que vas a ofrecer en wheels.',
            style: AppTextStyles.primary.copyWith(
              color: AppColors.slate400,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          RegisterTextField(
            label: 'Marca del vehiculo',
            hintText: 'Mazda',
            icon: Icons.directions_car_outlined,
            controller: vehicle.brandController,
            maxLength: 32,
            validator: (value) => _requiredValidator(value, 'Marca'),
          ),
          const SizedBox(height: 12),
          RegisterTextField(
            label: 'Modelo del vehiculo',
            hintText: 'Mazda 2',
            icon: Icons.tune,
            controller: vehicle.modelController,
            maxLength: 32,
            validator: (value) => _requiredValidator(value, 'Modelo'),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: RegisterTextField(
                  label: 'Color',
                  hintText: 'Gris',
                  icon: Icons.palette_outlined,
                  controller: vehicle.colorController,
                  maxLength: 20,
                  validator: (value) => _requiredValidator(value, 'Color'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: RegisterTextField(
                  label: 'Placa',
                  hintText: 'ABC123',
                  icon: Icons.confirmation_number_outlined,
                  controller: vehicle.plateController,
                  maxLength: 6,
                  textCapitalization: TextCapitalization.characters,
                  validator: _plateValidator,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          RegisterTextField(
            label: 'Numero de cupos disponibles',
            hintText: '4',
            icon: Icons.event_seat_outlined,
            controller: vehicle.seatsController,
            maxLength: 1,
            keyboardType: TextInputType.number,
            textCapitalization: TextCapitalization.none,
            validator: _slotsValidator,
          ),
        ],
      ),
    );
  }
}
