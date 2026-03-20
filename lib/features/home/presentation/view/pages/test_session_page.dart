import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../auth/presentation/view_model/auth_cubit.dart';
import '../../../../auth/presentation/view_model/auth_state.dart';
import '../../../../auth/presentation/view/widgets/auth_session_listener.dart';

class TestSessionPage extends StatelessWidget {
  const TestSessionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthSessionListener(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Sesión iniciada'),
        ),
        body: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            final user = state.user;

            if (state.status == AuthStatus.loading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (user == null) {
              return const Center(
                child: Text('No hay usuario autenticado'),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Login exitoso',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('ID: ${user.id}'),
                  Text('Rider ID: ${user.riderId ?? 'No es rider'}'),
                  Text('Driver ID: ${user.driverId ?? 'No es driver'}'),
                  Text('Nombre: ${user.firstName} ${user.lastName}'),
                  Text('Email: ${user.email}'),
                  Text('Zona: ${user.zoneId}'),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<AuthCubit>().logout();
                      },
                      child: const Text('Cerrar sesión'),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}