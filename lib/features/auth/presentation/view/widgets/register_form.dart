import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../home/presentation/view/widgets/brand_header_section.dart';
import '../../../../../app/routes.dart';
import '../../../../../core/theme/app_colors.dart';
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
  Set<RegisterPaymentMethod> _selectedPaymentMethods = {
    RegisterPaymentMethod.efectivo,
  };

  @override
  void initState() {
    super.initState();
    _vehicles = [RegisterVehicleDraft()];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AuthCubit>().loadRegisterZones();
    });
  }

  @override
  void dispose() {
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

  void _goToSetupStep() {
    if (!_basicInfoFormKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _currentStep = 1;
    });
  }

  void _goBackToBasicStep() {
    setState(() {
      _currentStep = 0;
    });
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
  }

  void _selectZone(String? zoneId) {
    setState(() {
      _selectedZoneId = zoneId;
      _zoneErrorText = null;
    });
  }

  void _addVehicle() {
    if (_vehicles.length >= _maxVehicles) {
      return;
    }

    setState(() {
      _vehicles.add(RegisterVehicleDraft());
    });
  }

  void _removeVehicle(int index) {
    if (_vehicles.length == 1) {
      return;
    }

    setState(() {
      final vehicle = _vehicles.removeAt(index);
      vehicle.dispose();
    });
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

  void _submitSetup() {
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
