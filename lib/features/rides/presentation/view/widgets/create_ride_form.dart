import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/vehicle.dart';
import '../../../domain/entities/zone.dart';
import '../../view_model/create_ride_state.dart';
import '../../view_model/create_ride_cubit.dart';

class CreateRideForm extends StatefulWidget {
  const CreateRideForm({super.key});

  @override
  State<CreateRideForm> createState() => _CreateRideFormState();
}

class _CreateRideFormState extends State<CreateRideForm> {
  final _formKey         = GlobalKey<FormState>();
  final _sourceCtrl      = TextEditingController();
  final _destinationCtrl = TextEditingController();
  final _dateCtrl        = TextEditingController();
  final _timeCtrl        = TextEditingController();
  final _priceCtrl       = TextEditingController();

  final String _selectedType = 'TO_UNIVERSITY';

  @override
  void dispose() {
    _sourceCtrl.dispose();
    _destinationCtrl.dispose();
    _dateCtrl.dispose();
    _timeCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context:     context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate:   DateTime.now(),
      lastDate:    DateTime.now().add(const Duration(days: 90)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.amber700),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      _dateCtrl.text =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context:     context,
      initialTime: TimeOfDay.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.amber700),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      _timeCtrl.text =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    }
  }

  Widget _buildRouteSection() {
    return Stack(
      children: [
        Positioned(
          left: 26,
          top: 50,
          bottom: 0,
          child: Container(
            width: 2,
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: AppColors.amber700.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
            ),
          ),
        ),
        Column(
          spacing: 10,
          children: [
            _StyledField(
              controller: _sourceCtrl,
              hint: 'Punto de salida',
              icon: Icons.location_on_outlined,
              iconColor: AppColors.amber700,
              validator: (v) => context
                  .read<CreateRideCubit>()
                  .validateRequired(v, 'El inicio'),
            ),
            _StyledField(
              controller: _destinationCtrl,
              hint: 'Destino final',
              icon: Icons.flag_outlined,
              iconColor: AppColors.teal600,
              validator: (v) => context
                  .read<CreateRideCubit>()
                  .validateRequired(v, 'El destino'),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _submit(Vehicle? selectedVehicle, Zone? selectedZone) async {
    final vm = context.read<CreateRideCubit>();

    if (vm.validateVehicleSelected(selectedVehicle) != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:         Text('Selecciona un vehículo'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (vm.validateZoneSelected(selectedZone) != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:         Text('Selecciona una zona'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    await vm.createRide(
      source:        _sourceCtrl.text,
      destination:   _destinationCtrl.text,
      date:          _dateCtrl.text,
      departureTime: _timeCtrl.text,
      type:          _selectedType,
      price:         double.tryParse(_priceCtrl.text) ?? 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CreateRideCubit, CreateRideState>(
      listener: (context, state) {
        if (state is CreateRideSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:         Text('¡Viaje publicado exitosamente!'),
              backgroundColor: AppColors.teal600,
            ),
          );
        }
        if (state is CreateRideError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:         Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {

      
        if (state is CreateRideLoadingVehicles) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.amber700),
          );
        }

        if (state is CreateRideError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 12),
                Text(
                  state.message,
                  style: AppTextStyles.primary
                      .copyWith(color: Colors.red, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () =>
                      context.read<CreateRideCubit>().loadVehicles(),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        if (state is! CreateRideReady) return const SizedBox.shrink();

        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 20,
            children: [
              // Vehículo
              _FieldLabel('VEHÍCULO'),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: AppColors.gray50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<Vehicle>(
                    value: state.selectedVehicle,
                    isExpanded: true,
                    hint: Text(
                      'Selecciona tu vehículo',
                      style: AppTextStyles.primary.copyWith(
                        color: AppColors.slate400,
                        fontSize: 14,
                      ),
                    ),
                    icon: const Icon(Icons.expand_more, color: AppColors.slate400),
                    items: state.vehicles
                        .map((v) => DropdownMenuItem<Vehicle>(
                              value: v,
                              child: Text(v.infoCarro),
                            ))
                        .toList(),
                    onChanged: (v) =>
                        context.read<CreateRideCubit>().selectVehicle(v!),
                    style: AppTextStyles.primary.copyWith(
                      color: AppColors.slate900,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),

              // Zona
              _FieldLabel('ZONA'),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: AppColors.gray50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<Zone>(
                    value: state.selectedZone,
                    isExpanded: true,
                    hint: Text(
                      'Selecciona tu zona',
                      style: AppTextStyles.primary.copyWith(
                        color: AppColors.slate400,
                        fontSize: 14,
                      ),
                    ),
                    icon: const Icon(Icons.expand_more, color: AppColors.slate400),
                    items: state.zones
                        .map((z) => DropdownMenuItem<Zone>(
                              value: z,
                              child: Text(z.name),
                            ))
                        .toList(),
                    onChanged: (z) =>
                        context.read<CreateRideCubit>().selectZone(z!),
                    style: AppTextStyles.primary.copyWith(
                      color: AppColors.slate900,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),

              // Ruta
              _FieldLabel('RUTA'),
              _buildRouteSection(),

              // Precio
              _FieldLabel('PRECIO'),
              _StyledField(
                controller: _priceCtrl,
                hint: 'Precio por pasajero',
                icon: Icons.payments_outlined,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'El precio es requerido';
                  }
                  final parsed = double.tryParse(v);
                  if (parsed == null || parsed <= 0) {
                    return 'Ingresa un precio válido';
                  }
                  return null;
                },
              ),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _FieldLabel('FECHA'),
                        const SizedBox(height: 8),
                        _StyledField(
                          controller: _dateCtrl,
                          hint: 'yyyy-MM-dd',
                          icon: Icons.calendar_today_outlined,
                          readOnly: true,
                          onTap: _pickDate,
                          validator: (v) => context
                              .read<CreateRideCubit>()
                              .validateRequired(v, 'La fecha'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _FieldLabel('HORA SALIDA'),
                        const SizedBox(height: 8),
                        _StyledField(
                          controller: _timeCtrl,
                          hint: 'HH:mm',
                          icon: Icons.schedule_outlined,
                          readOnly: true,
                          onTap: _pickTime,
                          validator: (v) => context
                              .read<CreateRideCubit>()
                              .validateRequired(v, 'La hora'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: state.isSubmitting
                      ? null
                      : () => _submit(state.selectedVehicle, state.selectedZone),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.amber700,
                    disabledBackgroundColor:
                        AppColors.amber700.withValues(alpha: 0.6),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: state.isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.send_rounded,
                          color: Colors.white, size: 20),
                  label: Text(
                    state.isSubmitting ? 'Publicando...' : 'Publicar viaje',
                    style: AppTextStyles.primary.copyWith(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}


class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: AppTextStyles.primary.copyWith(
          fontSize:      10,
          fontWeight:    FontWeight.w700,
          letterSpacing: 1.5,
          color:         AppColors.slate400,
        ),
      );
}

class _StyledField extends StatelessWidget {
  final TextEditingController      controller;
  final String                     hint;
  final IconData                   icon;
  final Color?                     iconColor;
  final bool                       readOnly;
  final VoidCallback?              onTap;
  final String? Function(String?)? validator;
  final TextInputType?             keyboardType;

  const _StyledField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.iconColor,
    this.readOnly    = false,
    this.onTap,
    this.validator,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller:   controller,
      readOnly:     readOnly,
      onTap:        onTap,
      validator:    validator,
      keyboardType: keyboardType,
      style: AppTextStyles.primary
          .copyWith(color: AppColors.slate900, fontSize: 14),
      decoration: InputDecoration(
        hintText:  hint,
        hintStyle: AppTextStyles.primary
            .copyWith(color: AppColors.slate400, fontSize: 14),
        prefixIcon:     Icon(icon,
            color: iconColor ?? AppColors.slate400, size: 20),
        filled:         true,
        fillColor:      AppColors.gray50,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:   const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:   const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.amber700, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:   const BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
    );
  }
}