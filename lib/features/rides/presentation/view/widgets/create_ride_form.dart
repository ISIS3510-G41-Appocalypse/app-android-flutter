import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';

import '../../../../../app/routes.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../rider_rides/presentation/view_model/rider_rides_cubit.dart';
import '../../../../rider_rides/presentation/view_model/rider_rides_state.dart';
import '../../../domain/entities/vehicle.dart';
import '../../../domain/entities/zone.dart';
import '../../view_model/create_ride_cubit.dart';
import '../../view_model/create_ride_state.dart';

class CreateRideForm extends StatefulWidget {
  const CreateRideForm({super.key});

  @override
  State<CreateRideForm> createState() => _CreateRideFormState();
}

class _CreateRideFormState extends State<CreateRideForm>
    with WidgetsBindingObserver {
  static const int _locationMaxLength = 30;
  static const int _priceMaxDigits = 5;
  static const Duration _draftSaveDebounce = Duration(milliseconds: 350);

  final _formKey = GlobalKey<FormState>();
  final _sourceCtrl = TextEditingController();
  final _destinationCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();
  final _timeCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();

  String _selectedType = 'TO_UNIVERSITY';
  final String _universityName = 'Universidad de los Andes';
  bool _restoredDraftApplied = false;
  bool _isApplyingDraft = false;
  Timer? _draftSaveTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _applyUniversityRouteDefaults();
    _sourceCtrl.addListener(_persistDraft);
    _destinationCtrl.addListener(_persistDraft);
    _dateCtrl.addListener(_persistDraft);
    _timeCtrl.addListener(_persistDraft);
    _priceCtrl.addListener(_persistDraft);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _draftSaveTimer?.cancel();
    unawaited(_saveDraft());
    _sourceCtrl.dispose();
    _destinationCtrl.dispose();
    _dateCtrl.dispose();
    _timeCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _draftSaveTimer?.cancel();
      unawaited(_saveDraft());
    }
  }

  Future<void> _pickDate() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: today.add(const Duration(days: 1)),
      firstDate: today,
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: _buildPickerTheme,
    );
    if (picked != null) {
      _dateCtrl.text =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      if (_timeCtrl.text.isNotEmpty &&
          _isPastTimeForSelectedDate(_timeCtrl.text)) {
        _timeCtrl.clear();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'La hora anterior ya no es valida para la fecha seleccionada. Elige una nueva hora.',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _pickTime() async {
    if (_dateCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona primero una fecha.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final now = DateTime.now();
    final initialTime = _selectedDateIsToday()
        ? TimeOfDay.fromDateTime(now)
        : TimeOfDay.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: _buildPickerTheme,
    );
    if (picked != null) {
      final pickedText =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      if (_isPastTimeForSelectedDate(pickedText)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'No puedes crear un viaje para una hora que ya paso hoy.',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
      _timeCtrl.text = pickedText;
    }
  }

  void _onTypeChanged(String newType) {
    setState(() {
      _selectedType = newType;
      _applyUniversityRouteDefaults();
    });
    unawaited(_saveDraft());
  }

  void _applyUniversityRouteDefaults() {
    if (_selectedType == 'TO_UNIVERSITY') {
      _destinationCtrl.text = _universityName;
      _sourceCtrl.clear();
    } else if (_selectedType == 'FROM_UNIVERSITY') {
      _sourceCtrl.text = _universityName;
      _destinationCtrl.clear();
    }
  }

  void _applyDraft(RideFormDraft draft) {
    _isApplyingDraft = true;
    setState(() {
      _selectedType = draft.type;
      _sourceCtrl.text = draft.source;
      _destinationCtrl.text = draft.destination;
      _dateCtrl.text = draft.date;
      _timeCtrl.text = draft.departureTime;
      _priceCtrl.text = draft.price;
      _restoredDraftApplied = true;
    });
    _isApplyingDraft = false;
  }

  void _persistDraft() {
    if (_isApplyingDraft) {
      return;
    }

    _draftSaveTimer?.cancel();
    _draftSaveTimer = Timer(_draftSaveDebounce, () {
      unawaited(_saveDraft());
    });
  }

  Future<void> _saveDraft() async {
    if (!mounted) return;
    final vm = context.read<CreateRideCubit>();
    await vm.saveDraft(
      vehicleId: vm.state.selectedVehicle?.id,
      zoneId: vm.state.selectedZone?.id,
      source: _sourceCtrl.text,
      destination: _destinationCtrl.text,
      date: _dateCtrl.text,
      departureTime: _timeCtrl.text,
      type: _selectedType,
      price: _priceCtrl.text,
    );
  }

  DateTime? _selectedDate() {
    final raw = _dateCtrl.text.trim();
    if (raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }

  bool _selectedDateIsToday() {
    final selected = _selectedDate();
    if (selected == null) return false;
    return DateUtils.isSameDay(selected, DateTime.now());
  }

  bool _isPastTimeForSelectedDate(String value) {
    final selected = _selectedDate();
    if (selected == null) return false;

    final timeParts = value.split(':');
    if (timeParts.length != 2) return false;

    final hour = int.tryParse(timeParts[0]);
    final minute = int.tryParse(timeParts[1]);
    if (hour == null || minute == null) return false;

    final selectedDateTime = DateTime(
      selected.year,
      selected.month,
      selected.day,
      hour,
      minute,
    );

    return selectedDateTime.isBefore(DateTime.now());
  }

  String? _validateLocation(String? value, String fieldName) {
    final requiredMessage = context.read<CreateRideCubit>().validateRequired(
      value,
      fieldName,
    );
    if (requiredMessage != null) return requiredMessage;

    if (value!.trim().length > _locationMaxLength) {
      return '$fieldName no puede superar $_locationMaxLength caracteres';
    }

    return null;
  }

  String? _validateDate(String? value) {
    final requiredMessage = context.read<CreateRideCubit>().validateRequired(
      value,
      'La fecha',
    );
    if (requiredMessage != null) return requiredMessage;

    final selected = DateTime.tryParse(value!.trim());
    if (selected == null) {
      return 'Selecciona una fecha valida';
    }

    final today = DateUtils.dateOnly(DateTime.now());
    if (selected.isBefore(today)) {
      return 'No puedes crear viajes para dias pasados';
    }

    return null;
  }

  String? _validateTime(String? value) {
    final requiredMessage = context.read<CreateRideCubit>().validateRequired(
      value,
      'La hora',
    );
    if (requiredMessage != null) return requiredMessage;

    if (_isPastTimeForSelectedDate(value!.trim())) {
      return 'No puedes crear viajes para horas que ya pasaron hoy';
    }

    return null;
  }

  Widget _buildPickerTheme(BuildContext context, Widget? child) {
    final baseTheme = Theme.of(context);

    return Theme(
      data: baseTheme.copyWith(
        colorScheme: const ColorScheme.light(
          primary: AppColors.amber700,
          onPrimary: Colors.white,
          surface: Colors.white,
          onSurface: AppColors.slate900,
        ),
        dialogTheme: const DialogThemeData(backgroundColor: Colors.white),
        timePickerTheme: TimePickerThemeData(
          backgroundColor: Colors.white,
          hourMinuteColor: AppColors.slate100,
          hourMinuteTextColor: AppColors.slate900,
          hourMinuteTextStyle: AppTextStyles.primary.copyWith(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppColors.slate900,
          ),
          dayPeriodColor: AppColors.slate100,
          dayPeriodTextColor: AppColors.slate900,
          dayPeriodTextStyle: AppTextStyles.primary.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.slate900,
          ),
          dialBackgroundColor: AppColors.slate100,
          dialHandColor: AppColors.amber700,
          dialTextColor: AppColors.slate900,
          entryModeIconColor: AppColors.amber700,
          helpTextStyle: AppTextStyles.primary.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.slate400,
          ),
        ),
        datePickerTheme: DatePickerThemeData(
          backgroundColor: Colors.white,
          headerBackgroundColor: AppColors.blue900,
          headerForegroundColor: Colors.white,
          dividerColor: AppColors.slate200,
          weekdayStyle: AppTextStyles.primary.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.slate400,
          ),
          dayStyle: AppTextStyles.primary.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.slate900,
          ),
          yearStyle: AppTextStyles.primary.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.slate900,
          ),
          dayForegroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.white;
            }
            if (states.contains(WidgetState.disabled)) {
              return AppColors.slate300;
            }
            return AppColors.slate900;
          }),
          dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.amber700;
            }
            return null;
          }),
          todayForegroundColor: const WidgetStatePropertyAll(
            AppColors.amber700,
          ),
          todayBackgroundColor: const WidgetStatePropertyAll(Colors.white),
          yearForegroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.white;
            }
            return AppColors.slate900;
          }),
          yearBackgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.teal600;
            }
            return null;
          }),
          cancelButtonStyle: TextButton.styleFrom(
            foregroundColor: AppColors.slate400,
          ),
          confirmButtonStyle: TextButton.styleFrom(
            foregroundColor: AppColors.amber700,
          ),
        ),
      ),
      child: child!,
    );
  }

  Widget _buildPendingSyncBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.teal600.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.teal600.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.cloud_upload_outlined,
            color: AppColors.teal600,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Hay un viaje pendiente por publicar. Mantendremos este formulario listo cuando tengas conexión.',
              style: AppTextStyles.primary.copyWith(
                fontSize: 12,
                color: AppColors.teal600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteSection() {
    final isToUniversity = _selectedType == 'TO_UNIVERSITY';
    final isFromUniversity = _selectedType == 'FROM_UNIVERSITY';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: [
        Row(
          spacing: 10,
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => _onTypeChanged('TO_UNIVERSITY'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isToUniversity
                      ? AppColors.amber700
                      : AppColors.gray50,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color: isToUniversity
                          ? AppColors.amber700
                          : const Color(0xFFE2E8F0),
                      width: isToUniversity ? 2 : 1,
                    ),
                  ),
                ),
                child: Text(
                  'Hacia Universidad',
                  style: AppTextStyles.primary.copyWith(
                    color: isToUniversity ? Colors.white : AppColors.slate900,
                    fontWeight: isToUniversity
                        ? FontWeight.w600
                        : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _onTypeChanged('FROM_UNIVERSITY'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isFromUniversity
                      ? AppColors.teal600
                      : AppColors.gray50,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color: isFromUniversity
                          ? AppColors.teal600
                          : const Color(0xFFE2E8F0),
                      width: isFromUniversity ? 2 : 1,
                    ),
                  ),
                ),
                child: Text(
                  'Desde Universidad',
                  style: AppTextStyles.primary.copyWith(
                    color: isFromUniversity ? Colors.white : AppColors.slate900,
                    fontWeight: isFromUniversity
                        ? FontWeight.w600
                        : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
        Stack(
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
                  maxLength: _locationMaxLength,
                  validator: (v) => _validateLocation(v, 'El inicio'),
                ),
                _StyledField(
                  controller: _destinationCtrl,
                  hint: 'Destino final',
                  icon: Icons.flag_outlined,
                  iconColor: AppColors.teal600,
                  maxLength: _locationMaxLength,
                  validator: (v) => _validateLocation(v, 'El destino'),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _submit(Vehicle? selectedVehicle, Zone? selectedZone) async {
    final vm = context.read<CreateRideCubit>();
    final riderRideState = context.read<RiderRidesCubit>().state;

    if (riderRideState.status == RiderRidesStatus.loading) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Espera un momento mientras verificamos si tienes una reserva activa.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (riderRideState.status == RiderRidesStatus.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Debes cancelar o finalizar tu reserva activa antes de publicar un viaje.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (vm.validateVehicleSelected(selectedVehicle) != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona un vehiculo'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (vm.validateZoneSelected(selectedZone) != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona una zona'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    final createRideFrontEndStopwatch = Stopwatch()..start();

    await vm.createRide(
      source: _sourceCtrl.text,
      destination: _destinationCtrl.text,
      date: _dateCtrl.text,
      departureTime: _timeCtrl.text,
      type: _selectedType,
      price: double.tryParse(_priceCtrl.text) ?? 0,
      createRideFrontEndStopwatch: createRideFrontEndStopwatch,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CreateRideCubit, CreateRideState>(
      listener: (context, state) {
        if (!_restoredDraftApplied && state.restoredDraft != null) {
          _applyDraft(state.restoredDraft!);
          context.read<CreateRideCubit>().consumeRestoredDraft();
          if (state.shouldAnnounceRestoredDraft) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Se restauro una oferta de viaje pendiente.'),
                backgroundColor: AppColors.teal600,
              ),
            );
          }
          return;
        }

        if (state.navigateToDriverRides) {
          final messenger = ScaffoldMessenger.of(context);
          if (state.message != null) {
            messenger.showSnackBar(
              SnackBar(
                content: Text(state.message!),
                backgroundColor: AppColors.teal600,
              ),
            );
          }
          context.read<CreateRideCubit>().consumeMessage();
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.driverRides,
            (route) => false,
          );
          return;
        }

        if (state.message != null) {
          final isError = state.status == CreateRideStatus.error;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message!),
              backgroundColor: isError ? Colors.red : AppColors.teal600,
            ),
          );
          if (state.status != CreateRideStatus.syncing) {
            context.read<CreateRideCubit>().consumeMessage();
          }
        }
      },
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.amber700),
          );
        }

        if (state.status == CreateRideStatus.error &&
            !state.hasLoadedFormData) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 12),
                Text(
                  state.message ?? 'Ocurrio un error inesperado.',
                  style: AppTextStyles.primary.copyWith(
                    color: Colors.red,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () =>
                      context.read<CreateRideCubit>().loadInitialData(),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        if (!state.isReadyLike) return const SizedBox.shrink();

        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 20,
            children: [
              if (state.hasPendingRideForm) _buildPendingSyncBanner(),
              if (state.hasPendingRideForm) const SizedBox(height: 4),
              _FieldLabel('VEHICULO'),
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
                      'Selecciona tu vehiculo',
                      style: AppTextStyles.primary.copyWith(
                        color: AppColors.slate400,
                        fontSize: 14,
                      ),
                    ),
                    icon: const Icon(
                      Icons.expand_more,
                      color: AppColors.slate400,
                    ),
                    items: state.vehicles
                        .map(
                          (v) => DropdownMenuItem<Vehicle>(
                            value: v,
                            child: Text(v.infoCarro),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v != null) {
                        context.read<CreateRideCubit>().selectVehicle(v);
                        unawaited(_saveDraft());
                      }
                    },
                    style: AppTextStyles.primary.copyWith(
                      color: AppColors.slate900,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
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
                    icon: const Icon(
                      Icons.expand_more,
                      color: AppColors.slate400,
                    ),
                    items: state.zones
                        .map(
                          (z) => DropdownMenuItem<Zone>(
                            value: z,
                            child: Text(z.name),
                          ),
                        )
                        .toList(),
                    onChanged: (z) {
                      if (z != null) {
                        context.read<CreateRideCubit>().selectZone(z);
                        unawaited(_saveDraft());
                      }
                    },
                    style: AppTextStyles.primary.copyWith(
                      color: AppColors.slate900,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              _FieldLabel('RUTA'),
              _buildRouteSection(),
              _FieldLabel('PRECIO'),
              _StyledField(
                controller: _priceCtrl,
                hint: 'Precio por pasajero',
                icon: Icons.payments_outlined,
                keyboardType: TextInputType.number,
                maxLength: _priceMaxDigits,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(_priceMaxDigits),
                ],
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'El precio es requerido';
                  }
                  if (v.trim().length > _priceMaxDigits) {
                    return 'El precio no puede tener mas de $_priceMaxDigits digitos';
                  }
                  final parsed = double.tryParse(v);
                  if (parsed == null || parsed <= 0) {
                    return 'Ingresa un precio valido';
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
                          validator: _validateDate,
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
                          validator: _validateTime,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: BlocBuilder<RiderRidesCubit, RiderRidesState>(
                  builder: (context, riderRideState) {
                    final publishBlockedByReservation =
                        riderRideState.status == RiderRidesStatus.success;
                    final isCheckingReservation =
                        riderRideState.status == RiderRidesStatus.loading;

                    return ElevatedButton.icon(
                      onPressed:
                          (state.isSubmitting ||
                              state.isSyncing ||
                              publishBlockedByReservation ||
                              isCheckingReservation)
                          ? null
                          : () => _submit(
                              state.selectedVehicle,
                              state.selectedZone,
                            ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.amber700,
                        disabledBackgroundColor: AppColors.amber700.withValues(
                          alpha: 0.6,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon:
                          (state.isSubmitting ||
                              state.isSyncing ||
                              isCheckingReservation)
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(
                              Icons.send_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                      label: Text(
                        isCheckingReservation
                            ? 'Verificando...'
                            : state.isSyncing
                            ? 'Sincronizando...'
                            : state.isSubmitting
                            ? 'Publicando...'
                            : publishBlockedByReservation
                            ? 'Reserva activa detectada'
                            : 'Publicar viaje',
                        style: AppTextStyles.primary.copyWith(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    );
                  },
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
      fontSize: 10,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.5,
      color: AppColors.slate400,
    ),
  );
}

class _StyledField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final Color? iconColor;
  final bool readOnly;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;

  const _StyledField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.iconColor,
    this.readOnly = false,
    this.onTap,
    this.validator,
    this.keyboardType,
    this.inputFormatters,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLength: maxLength,
      style: AppTextStyles.primary.copyWith(
        color: AppColors.slate900,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.primary.copyWith(
          color: AppColors.slate400,
          fontSize: 14,
        ),
        counterText: '',
        prefixIcon: Icon(
          icon,
          color: iconColor ?? AppColors.slate400,
          size: 20,
        ),
        filled: true,
        fillColor: AppColors.gray50,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.amber700, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
    );
  }
}
