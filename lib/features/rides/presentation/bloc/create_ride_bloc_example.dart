// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../repositories/rides_offline_sync_repository.dart';
// import '../models/ride_model.dart';

// // EVENTOS
// abstract class CreateRideEvent {}

// class CheckConnectivityEvent extends CreateRideEvent {}

// class SubmitRideFormEvent extends CreateRideEvent {
//   final RideModel ride;
//   SubmitRideFormEvent(this.ride);
// }

// class LoadPendingFormEvent extends CreateRideEvent {}

// class ClearPendingFormEvent extends CreateRideEvent {}

// // ESTADOS
// abstract class CreateRideState {}

// class CreateRideInitialState extends CreateRideState {}

// class CreateRideLoadingState extends CreateRideState {}

// class NoConnectivityState extends CreateRideState {
//   final String message;
//   NoConnectivityState(this.message);
// }

// class WaitingForConnectionState extends CreateRideState {
//   final String message;
//   WaitingForConnectionState(this.message);
// }

// class RideCreatedSuccessState extends CreateRideState {
//   final RideModel ride;
//   final String message;
//   RideCreatedSuccessState(this.ride, this.message);
// }

// class PendingFormLoadedState extends CreateRideState {
//   final Map<String, dynamic> formData;
//   PendingFormLoadedState(this.formData);
// }

// class CreateRideErrorState extends CreateRideState {
//   final String message;
//   CreateRideErrorState(this.message);
// }

// // BLoC
// class CreateRideBloc extends Bloc<CreateRideEvent, CreateRideState> {
//   final RidesOfflineSyncRepository syncRepository;

//   CreateRideBloc({required this.syncRepository}) : super(CreateRideInitialState()) {
//     on<CheckConnectivityEvent>(_onCheckConnectivity);
//     on<SubmitRideFormEvent>(_onSubmitRideForm);
//     on<LoadPendingFormEvent>(_onLoadPendingForm);
//     on<ClearPendingFormEvent>(_onClearPendingForm);
//   }

//   Future<void> _onCheckConnectivity(
//     CheckConnectivityEvent event,
//     Emitter<CreateRideState> emit,
//   ) async {
//     final networkChecker = syncRepository.networkChecker;
//     final hasInternet = await networkChecker.hasInternet;

//     if (!hasInternet) {
//       emit(NoConnectivityState(
//         'No hay conexión a internet. No puedes crear un viaje en este momento.',
//       ));
//     }
//   }

//   Future<void> _onSubmitRideForm(
//     SubmitRideFormEvent event,
//     Emitter<CreateRideState> emit,
//   ) async {
//     emit(CreateRideLoadingState());

//     final result = await syncRepository.createRideWithOfflineSupport(event.ride);

//     switch (result.status) {
//       case RideSyncStatus.success:
//         emit(RideCreatedSuccessState(result.rideData!, result.message));
//         break;

//       case RideSyncStatus.waitingForConnection:
//         emit(WaitingForConnectionState(result.message));
//         // Escuchar sincronización automática
//         _listenToSync(emit);
//         break;

//       case RideSyncStatus.serverError:
//       case RideSyncStatus.networkError:
//       case RideSyncStatus.error:
//         emit(CreateRideErrorState(result.message));
//         break;

//       case RideSyncStatus.syncing:
//         emit(CreateRideLoadingState());
//         break;
//     }
//   }

//   Future<void> _onLoadPendingForm(
//     LoadPendingFormEvent event,
//     Emitter<CreateRideState> emit,
//   ) async {
//     final formData = syncRepository.getPendingRideForm();
//     if (formData != null) {
//       emit(PendingFormLoadedState(formData));
//     }
//   }

//   Future<void> _onClearPendingForm(
//     ClearPendingFormEvent event,
//     Emitter<CreateRideState> emit,
//   ) async {
//     await syncRepository.clearPendingRide();
//     emit(CreateRideInitialState());
//   }

//   void _listenToSync(Emitter<CreateRideState> emit) {
//     syncRepository.listenToConnectivityChanges().listen((result) {
//       switch (result.status) {
//         case RideSyncStatus.syncing:
//           emit(CreateRideLoadingState());
//           break;

//         case RideSyncStatus.success:
//           emit(RideCreatedSuccessState(result.rideData!, result.message));
//           break;

//         case RideSyncStatus.serverError:
//         case RideSyncStatus.networkError:
//         case RideSyncStatus.error:
//           emit(CreateRideErrorState(result.message));
//           break;

//         case RideSyncStatus.waitingForConnection:
//           break;
//       }
//     });
//   }
// }

// // USO EN WIDGET
// class CreateRideScreen extends StatefulWidget {
//   @override
//   State<CreateRideScreen> createState() => _CreateRideScreenState();
// }

// class _CreateRideScreenState extends State<CreateRideScreen> {
//   @override
//   void initState() {
//     super.initState();
//     // Verificar conectividad al entrar
//     context.read<CreateRideBloc>().add(CheckConnectivityEvent());
//     // Cargar formulario pendiente si existe
//     context.read<CreateRideBloc>().add(LoadPendingFormEvent());
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocListener<CreateRideBloc, CreateRideState>(
//       listener: (context, state) {
//         if (state is NoConnectivityState) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text(state.message)),
//           );
//           Navigator.of(context).pop();
//         } else if (state is RideCreatedSuccessState) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text(state.message)),
//           );
//           Navigator.of(context).pop();
//         } else if (state is WaitingForConnectionState) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text(state.message)),
//           );
//         } else if (state is CreateRideErrorState) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Error: ${state.message}')),
//           );
//         }
//       },
//       child: BlocBuilder<CreateRideBloc, CreateRideState>(
//         builder: (context, state) {
//           return Scaffold(
//             appBar: AppBar(title: const Text('Crear Viaje')),
//             body: _buildContent(context, state),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildContent(BuildContext context, CreateRideState state) {
//     if (state is CreateRideLoadingState) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     if (state is PendingFormLoadedState) {
//       // Mostrar diálogo y restaurar datos
//       _restoreFormData(state.formData);
//     }

//     return SingleChildScrollView(
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: _buildForm(context),
//       ),
//     );
//   }

//   Widget _buildForm(BuildContext context) {
//     // Tu formulario aquí
//     return Column(
//       children: [
//         // Campos del formulario
//         ElevatedButton(
//           onPressed: () {
//             // Crear modelo y enviar evento
//             final ride = RideModel(
//               driverId: 1,
//               vehicleId: 1,
//               zoneId: 1,
//               source: 'source',
//               destination: 'destination',
//               date: '2026-04-25',
//               departureTime: '14:30',
//               state: 'OFERTADO',
//               type: 'COMPARTIDO',
//               price: 25000,
//             );
//             context.read<CreateRideBloc>().add(SubmitRideFormEvent(ride));
//           },
//           child: const Text('Crear Viaje'),
//         ),
//       ],
//     );
//   }

//   void _restoreFormData(Map<String, dynamic> formData) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Formulario Guardado'),
//         content: const Text(
//           'Se encontró un viaje incompleto. Los datos han sido restaurados.',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('OK'),
//           ),
//         ],
//       ),
//     );
//   }
// }
