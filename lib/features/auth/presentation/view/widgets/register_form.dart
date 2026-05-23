import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../home/presentation/view/widgets/brand_header_section.dart';
import '../../../../../app/routes.dart';
import '../../../../../core/network/network_checker.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../injection/auth_injection.dart';
import '../../view_model/auth_cubit.dart';
import '../../view_model/auth_state.dart';
import '../models/register_payment_method.dart';
import '../models/register_vehicle_draft.dart';
import 'register_basic_info_step.dart';
import 'register_card_shell.dart';
import 'register_setup_step.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  static const int _maxVehicles = 3;

  final _basicInfoFormKey = GlobalKey<FormState>();
  final _setupFormKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _paymentControllers = {
    RegisterPaymentMethod.nequi: TextEditingController(),
    RegisterPaymentMethod.daviplata: TextEditingController(),
    RegisterPaymentMethod.llave: TextEditingController(),
  };

  int _currentStep = 0;
  String? _selectedZoneId;
  String? _zoneErrorText;
  String? _paymentErrorText;
  bool _wantsDriverRole = false;
  late final List<RegisterVehicleDraft> _vehicles;
  bool _restoredDraftPromptHandled = false;
  Set<RegisterPaymentMethod> _selectedPaymentMethods = {
    RegisterPaymentMethod.efectivo,
  };

  @override
  void initState() {
    super.initState();
    _vehicles = [RegisterVehicleDraft()];
    _addDraftListeners();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AuthCubit>().loadRegisterZones();
      _maybePromptRestoreDraft();
    });
  }

  @override
  void dispose() {
    _removeDraftListeners();
    _nameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    for (final controller in _paymentControllers.values) {
      controller.dispose();
    }
    for (final vehicle in _vehicles) {
      vehicle.dispose();
    }
    super.dispose();
  }

  void _addDraftListeners() {
    _nameController.addListener(_persistDraft);
    _lastNameController.addListener(_persistDraft);
    _emailController.addListener(_persistDraft);
    for (final controller in _paymentControllers.values) {
      controller.addListener(_persistDraft);
    }
    for (final vehicle in _vehicles) {
      _attachVehicleListeners(vehicle);
    }
  }

  void _removeDraftListeners() {
    _nameController.removeListener(_persistDraft);
    _lastNameController.removeListener(_persistDraft);
    _emailController.removeListener(_persistDraft);
    for (final controller in _paymentControllers.values) {
      controller.removeListener(_persistDraft);
    }
    for (final vehicle in _vehicles) {
      _detachVehicleListeners(vehicle);
    }
  }

  void _attachVehicleListeners(RegisterVehicleDraft vehicle) {
    vehicle.brandController.addListener(_persistDraft);
    vehicle.modelController.addListener(_persistDraft);
    vehicle.colorController.addListener(_persistDraft);
    vehicle.plateController.addListener(_persistDraft);
    vehicle.seatsController.addListener(_persistDraft);
  }

  void _detachVehicleListeners(RegisterVehicleDraft vehicle) {
    vehicle.brandController.removeListener(_persistDraft);
    vehicle.modelController.removeListener(_persistDraft);
    vehicle.colorController.removeListener(_persistDraft);
    vehicle.plateController.removeListener(_persistDraft);
    vehicle.seatsController.removeListener(_persistDraft);
  }
  Future<void> _persistDraft() async {
    if (!mounted) return;

    final draft = _buildSignupDraft();
    if (draft == null) {
      await context.read<AuthCubit>().clearRegisterDraft();
      return;
    }

    await context.read<AuthCubit>().saveRegisterDraft(draft);
  }

  Map<String, dynamic>? _buildSignupDraft() {
    final firstName = _nameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final zoneId = _selectedZoneId;
    final paymentMethods = _buildPaymentMethodsDraft();
    final vehicles = _buildVehiclesDraft();

    final hasUsefulData = firstName.isNotEmpty ||
        lastName.isNotEmpty ||
        email.isNotEmpty ||
        zoneId != null ||
        _wantsDriverRole ||
        paymentMethods.isNotEmpty ||
        vehicles.any((vehicle) => vehicle.values.any((value) => '$value'.trim().isNotEmpty));

    if (!hasUsefulData) {
      return null;
    }

    return {
      'current_step': _currentStep,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'zone_id': zoneId,
      'wants_driver_role': _wantsDriverRole,
      'selected_payment_methods':
          _selectedPaymentMethods.map((method) => method.name).toList(),
      'payment_values': {
        for (final entry in _paymentControllers.entries)
          entry.key.name: entry.value.text.trim(),
      },
      'vehicles': vehicles,
    };
  }

  List<Map<String, dynamic>> _buildVehiclesDraft() {
    return _vehicles
        .map(
          (vehicle) => {
            'brand': vehicle.brandController.text.trim(),
            'model': vehicle.modelController.text.trim(),
            'color': vehicle.colorController.text.trim(),
            'plate': vehicle.plateController.text.trim().toUpperCase(),
            'seats': vehicle.seatsController.text.trim(),
          },
        )
        .toList();
  }

  List<Map<String, dynamic>> _buildPaymentMethodsDraft() {
    return _selectedPaymentMethods
        .map(
          (method) => {
            'type': method.name,
            'value': method.requiresValue
                ? _paymentControllers[method]?.text.trim()
                : null,
          },
        )
        .toList();
  }

  Future<void> _maybePromptRestoreDraft() async {
    final authCubit = context.read<AuthCubit>();
    if (_restoredDraftPromptHandled || !authCubit.hasRegisterDraft()) {
      return;
    }

    _restoredDraftPromptHandled = true;
    final draft = authCubit.getRegisterDraft();
    if (draft == null || !mounted) {
      return;
    }

    final shouldRestore = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Recuperar registro',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.slate900,
                  fontWeight: FontWeight.w700,
                ),
          ),
          content: Text(
            'Encontramos informacion guardada de un registro anterior. ¿Quieres reutilizarla?',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.slate400,
                  height: 1.4,
                ),
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.slate800,
                side: const BorderSide(color: AppColors.slate300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.amber700,
                foregroundColor: AppColors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Si'),
            ),
          ],
        );
      },
    );

    if (shouldRestore == true) {
      _applyDraft(draft);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Recuperamos tu informacion guardada del registro. La contrasena no se guarda por seguridad.',
          ),
          backgroundColor: AppColors.teal600,
        ),
      );
      return;
    }

    await authCubit.clearRegisterDraft();
  }

  void _applyDraft(Map<String, dynamic> draft) {
    final wantsDriverRole = draft['wants_driver_role'] == true;
    final savedPaymentMethodsRaw =
        (draft['selected_payment_methods'] as List?) ?? const [];
    final savedPaymentMethods = savedPaymentMethodsRaw
        .map((item) => RegisterPaymentMethod.values.firstWhere(
              (method) => method.name == item.toString(),
              orElse: () => RegisterPaymentMethod.efectivo,
            ))
        .toSet();
    final paymentValues =
        Map<String, dynamic>.from(draft['payment_values'] as Map? ?? const {});
    final vehiclesRaw = (draft['vehicles'] as List?) ?? const [];

    setState(() {
      _nameController.text = draft['first_name'] as String? ?? '';
      _lastNameController.text = draft['last_name'] as String? ?? '';
      _emailController.text = draft['email'] as String? ?? '';
      _selectedZoneId = draft['zone_id'] as String?;
      _wantsDriverRole = wantsDriverRole;
      _selectedPaymentMethods = savedPaymentMethods.isEmpty
          ? {RegisterPaymentMethod.efectivo}
          : savedPaymentMethods;
      _currentStep = 0;
      _zoneErrorText = null;
      _paymentErrorText = null;

      for (final entry in _paymentControllers.entries) {
        entry.value.text = paymentValues[entry.key.name]?.toString() ?? '';
      }

      for (final vehicle in _vehicles) {
        _detachVehicleListeners(vehicle);
        vehicle.dispose();
      }
      _vehicles
        ..clear()
        ..addAll(
          vehiclesRaw.isEmpty
              ? [
                  () {
                    final vehicle = RegisterVehicleDraft();
                    _attachVehicleListeners(vehicle);
                    return vehicle;
                  }(),
                ]
              : vehiclesRaw.take(_maxVehicles).map((item) {
                  final map = Map<String, dynamic>.from(item as Map);
                  final vehicle = RegisterVehicleDraft();
                  vehicle.brandController.text = map['brand']?.toString() ?? '';
                  vehicle.modelController.text = map['model']?.toString() ?? '';
                  vehicle.colorController.text = map['color']?.toString() ?? '';
                  vehicle.plateController.text = map['plate']?.toString() ?? '';
                  vehicle.seatsController.text =
                      map['seats']?.toString().isNotEmpty == true
                          ? map['seats'].toString()
                          : '4';
                  _attachVehicleListeners(vehicle);
                  return vehicle;
                }),
        );
    });
  }

  Future<void> _goToSetupStep() async {
    if (!_basicInfoFormKey.currentState!.validate()) {
      return;
    }

    final authCubit = context.read<AuthCubit>();
    final zonesReady = await authCubit.ensureRegisterZonesLoaded();
    if (!mounted) return;
    if (!zonesReady && authCubit.state.registerZonesErrorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authCubit.state.registerZonesErrorMessage!),
        ),
      );
      return;
    }

    final hasInternet = await sl<NetworkChecker>().hasInternet;
    if (!hasInternet) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No tienes internet. Intenta de nuevo mas tarde.'),
        ),
      );
      return;
    }

    if (!mounted) return;
    setState(() {
      _currentStep = 1;
    });
    await _persistDraft();
  }

  void _goBackToBasicStep() {
    setState(() {
      _currentStep = 0;
    });
    unawaited(_persistDraft());
  }

  void _toggleDriverRole(bool wantsDriverRole) {
    setState(() {
      _wantsDriverRole = wantsDriverRole;
      if (!wantsDriverRole) {
        _paymentErrorText = null;
        _selectedPaymentMethods = {RegisterPaymentMethod.efectivo};
        for (final controller in _paymentControllers.values) {
          controller.clear();
        }
      }
    });
    unawaited(_persistDraft());
  }

  void _selectZone(String? zoneId) {
    setState(() {
      _selectedZoneId = zoneId;
      _zoneErrorText = null;
    });
    unawaited(_persistDraft());
  }

  void _addVehicle() {
    if (_vehicles.length >= _maxVehicles) {
      return;
    }

    setState(() {
      final vehicle = RegisterVehicleDraft();
      _attachVehicleListeners(vehicle);
      _vehicles.add(vehicle);
    });
    unawaited(_persistDraft());
  }

  void _removeVehicle(int index) {
    if (_vehicles.length == 1) {
      return;
    }

    setState(() {
      final vehicle = _vehicles.removeAt(index);
      _detachVehicleListeners(vehicle);
      vehicle.dispose();
    });
    unawaited(_persistDraft());
  }

  void _togglePaymentMethod(RegisterPaymentMethod method) {
    if (method == RegisterPaymentMethod.efectivo) {
      return;
    }

    setState(() {
      if (_selectedPaymentMethods.contains(method)) {
        _selectedPaymentMethods.remove(method);
        _paymentControllers[method]?.clear();
      } else {
        _selectedPaymentMethods = {..._selectedPaymentMethods, method};
      }
      _paymentErrorText = null;
    });
    unawaited(_persistDraft());
  }

  bool _validateSetupSelections() {
    String? zoneError;
    String? paymentError;

    if (_selectedZoneId == null || _selectedZoneId!.isEmpty) {
      zoneError = 'Debes seleccionar una zona preferida';
    }

    if (_wantsDriverRole && _selectedPaymentMethods.isEmpty) {
      paymentError = 'Selecciona al menos un metodo de pago';
    }

    setState(() {
      _zoneErrorText = zoneError;
      _paymentErrorText = paymentError;
    });

    return zoneError == null && paymentError == null;
  }

  List<Map<String, dynamic>> _buildPaymentMethodsPayload() {
    return _selectedPaymentMethods.map((method) {
      final controller = _paymentControllers[method];
      return {
        'type': switch (method) {
          RegisterPaymentMethod.nequi => 'NEQUI',
          RegisterPaymentMethod.daviplata => 'DAVIPLATA',
          RegisterPaymentMethod.llave => 'KEY',
          RegisterPaymentMethod.efectivo => 'CASH',
        },
        'number_account': method.requiresValue ? controller?.text.trim() : null,
      };
    }).toList();
  }

  List<Map<String, dynamic>> _buildVehiclesPayload() {
    return _vehicles.map((vehicle) {
      return {
        'license_plate': vehicle.plateController.text.trim().toUpperCase(),
        'number_slots': int.parse(vehicle.seatsController.text.trim()),
        'brand': vehicle.brandController.text.trim(),
        'model': vehicle.modelController.text.trim(),
        'color': vehicle.colorController.text.trim(),
      };
    }).toList();
  }

  Future<void> _submitSetup() async {
    final formsAreValid = _setupFormKey.currentState!.validate();
    final selectionsAreValid = _validateSetupSelections();

    if (!formsAreValid || !selectionsAreValid) {
      return;
    }

    final zoneId = int.tryParse(_selectedZoneId ?? '');
    if (zoneId == null) {
      setState(() {
        _zoneErrorText = 'Debes seleccionar una zona preferida';
      });
      return;
    }

    final hasInternet = await sl<NetworkChecker>().hasInternet;
    if (!hasInternet) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No tienes internet. Tu informacion sera guardada. Intenta de nuevo mas tarde.',
          ),
        ),
      );
      await _persistDraft();
      return;
    }

    final roles = _wantsDriverRole ? ['rider', 'driver'] : ['rider'];

    context.read<AuthCubit>().signup(
      firstName: _nameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      zoneId: zoneId,
      roles: roles,
      paymentMethods: _wantsDriverRole ? _buildPaymentMethodsPayload() : const [],
      vehicles: _wantsDriverRole ? _buildVehiclesPayload() : const [],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          unawaited(context.read<AuthCubit>().clearRegisterDraft());
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.rideOffers,
            (route) => false,
          );
        }

        if (state.registerZonesErrorMessage != null) {
          setState(() {
            _zoneErrorText = state.registerZonesErrorMessage;
          });
        } else if (state.registerZones.isNotEmpty && _zoneErrorText != null) {
          setState(() {
            _zoneErrorText = null;
          });
        }
      },
      builder: (context, state) {
        final isLoading = state.status == AuthStatus.loading;
        final errorMessage =
            state.status == AuthStatus.error ? state.errorMessage : null;

        return Column(
          children: [
            const BrandHeaderSection(),
            const SizedBox(height: 32),
            RegisterCardShell(
              child: Column(
                children: [
                  _currentStep == 0
                      ? RegisterBasicInfoStep(
                          formKey: _basicInfoFormKey,
                          nameController: _nameController,
                          lastNameController: _lastNameController,
                          emailController: _emailController,
                          passwordController: _passwordController,
                          confirmPasswordController: _confirmPasswordController,
                          onNext: _goToSetupStep,
                        )
                      : RegisterSetupStep(
                          formKey: _setupFormKey,
                          zones: state.registerZones,
                          isLoadingZones: state.isLoadingRegisterZones,
                          selectedZoneId: _selectedZoneId,
                          zoneErrorText: _zoneErrorText,
                          wantsDriverRole: _wantsDriverRole,
                          vehicles: _vehicles,
                          maxVehicles: _maxVehicles,
                          selectedPaymentMethods: _selectedPaymentMethods,
                          paymentControllers: _paymentControllers,
                          paymentErrorText: _paymentErrorText,
                          onZoneSelected: _selectZone,
                          onDriverRoleChanged: _toggleDriverRole,
                          onAddVehicle: _addVehicle,
                          onRemoveVehicle: _removeVehicle,
                          onPaymentMethodToggled: _togglePaymentMethod,
                          onBack: _goBackToBasicStep,
                          onSubmit: isLoading ? () {} : _submitSetup,
                          submitLabel: isLoading ? 'Creando cuenta...' : 'Crear cuenta',
                        ),
                  if (_currentStep == 1 && errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      errorMessage,
                      style: const TextStyle(
                        color: AppColors.errorRed,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
