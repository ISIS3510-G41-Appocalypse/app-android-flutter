import 'package:flutter/material.dart';
import '../../../../home/presentation/view/widgets/brand_header_section.dart';
import '../../../../ride_offers/domain/entities/zone.dart';
import '../../../injection/auth_injection.dart';
import '../../../data/datasources/remote/auth_datasource_remote.dart';
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
  bool _isLoadingZones = true;
  late final List<RegisterVehicleDraft> _vehicles;
  List<Zone> _zones = const [];
  Set<RegisterPaymentMethod> _selectedPaymentMethods = {
    RegisterPaymentMethod.efectivo,
  };

  @override
  void initState() {
    super.initState();
    _vehicles = [RegisterVehicleDraft()];
    _loadZones();
  }

  Future<void> _loadZones() async {
    try {
      final rows = await sl<AuthDataSourceRemote>().getZonesRows();
      final zones = rows
          .map(
            (row) => Zone(
              id: row['id'].toString(),
              name: row['name'] as String? ?? '',
            ),
          )
          .where((zone) => zone.name.isNotEmpty)
          .toList();

      if (!mounted) return;

      setState(() {
        _zones = zones;
        _isLoadingZones = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _zones = const [];
        _isLoadingZones = false;
        _zoneErrorText = 'No fue posible cargar las zonas';
      });
    }
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

  void _submitSetup() {
    final formsAreValid = _setupFormKey.currentState!.validate();
    final selectionsAreValid = _validateSetupSelections();

    if (!formsAreValid || !selectionsAreValid) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Formulario listo para conectar con el backend.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const BrandHeaderSection(),
        const SizedBox(height: 32),
        RegisterCardShell(
          child: _currentStep == 0
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
                  zones: _zones,
                  isLoadingZones: _isLoadingZones,
                  selectedZoneId: _selectedZoneId,
                  zoneErrorText: _zoneErrorText,
                  wantsDriverRole: _wantsDriverRole,
                  vehicles: _vehicles,
                  selectedPaymentMethods: _selectedPaymentMethods,
                  paymentControllers: _paymentControllers,
                  paymentErrorText: _paymentErrorText,
                  onZoneSelected: _selectZone,
                  onDriverRoleChanged: _toggleDriverRole,
                  onAddVehicle: _addVehicle,
                  onRemoveVehicle: _removeVehicle,
                  onPaymentMethodToggled: _togglePaymentMethod,
                  onBack: _goBackToBasicStep,
                  onSubmit: _submitSetup,
                ),
        ),
      ],
    );
  }
}
