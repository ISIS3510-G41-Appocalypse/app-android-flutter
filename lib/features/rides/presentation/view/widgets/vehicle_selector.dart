import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/vehicle.dart';
import '../../view_model/create_ride_view_model.dart';

class VehicleSelector extends StatelessWidget {
  final List<Vehicle> vehicles;
  final Vehicle?      selected;

  const VehicleSelector({
    super.key,
    required this.vehicles,
    this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'VEHÍCULO',
          style: AppTextStyles.primary.copyWith(
            fontSize:      10,
            fontWeight:    FontWeight.w700,
            letterSpacing: 1.5,
            color:         AppColors.slate400,
          ),
        ),
        const SizedBox(height: 10),
        ...vehicles.map((v) => _VehicleCard(
              vehicle:    v,
              isSelected: selected?.id == v.id,
              onTap: () =>
                  context.read<CreateRideViewModel>().selectVehicle(v),
            )),
      ],
    );
  }
}

class _VehicleCard extends StatelessWidget {
  final Vehicle      vehicle;
  final bool         isSelected;
  final VoidCallback onTap;

  const _VehicleCard({
    required this.vehicle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin:   const EdgeInsets.only(bottom: 10),
        padding:  const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.amber700.withOpacity(0.08)
              : AppColors.gray50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.amber700 : const Color(0xFFE2E8F0),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Ícono
            Container(
              width:  40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.amber700.withOpacity(0.15)
                    : const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.directions_car_rounded,
                color: isSelected ? AppColors.amber700 : AppColors.slate400,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${vehicle.brand} ${vehicle.model}',
                    style: AppTextStyles.primary.copyWith(
                      fontSize:   14,
                      fontWeight: FontWeight.w600,
                      color:      AppColors.slate900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _Chip(label: vehicle.licensePlate),
                      const SizedBox(width: 6),
                      _Chip(label: vehicle.color),
                      const SizedBox(width: 6),
                      _Chip(
                        label:    '${vehicle.puestosDisponibles} cupos',
                        isAccent: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Check
            if (isSelected)
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.amber700, size: 20),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool   isAccent;
  const _Chip({required this.label, this.isAccent = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isAccent
            ? AppColors.teal600.withOpacity(0.1)
            : const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: AppTextStyles.primary.copyWith(
          fontSize:   10,
          fontWeight: FontWeight.w600,
          color:      isAccent ? AppColors.teal600 : AppColors.slate400,
        ),
      ),
    );
  }
}