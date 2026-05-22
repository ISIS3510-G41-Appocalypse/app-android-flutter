import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/rate_driver.dart';
import '../../../domain/entities/rate_rider.dart';
import '../../../domain/entities/rating_passenger.dart';
import '../../view_model/ratings_cubit.dart';
import '../../view_model/ratings_state.dart';
import '../widgets/rating_score_selector.dart';
import 'ratings_page_args.dart';

class RatingsPage extends StatelessWidget {
  const RatingsPage({super.key, required this.args});

  final RatingsPageArgs args;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<RatingsCubit>(),
      child: _RatingsView(args: args),
    );
  }
}

class _RatingsView extends StatefulWidget {
  const _RatingsView({required this.args});

  final RatingsPageArgs args;

  @override
  State<_RatingsView> createState() => _RatingsViewState();
}

class _RatingsViewState extends State<_RatingsView> {
  late final Map<int, _RatingScores> _scoresByRiderId;
  late final String _draftKey;
  bool _draftRequested = false;

  @override
  void initState() {
    super.initState();
    _scoresByRiderId = {
      for (final passenger in widget.args.passengers)
        passenger.riderId: _RatingScores(),
    };

    if (widget.args.mode == RatingsMode.riderRatesDriver &&
        widget.args.riderId != null) {
      _scoresByRiderId[widget.args.riderId!] = _RatingScores();
    }

    _draftKey = _buildDraftKey();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_draftRequested) {
      return;
    }

    _draftRequested = true;
    context.read<RatingsCubit>().loadDraft(_draftKey);
  }

  @override
  Widget build(BuildContext context) {
    final isDriverMode = widget.args.mode == RatingsMode.driverRatesRiders;

    return BlocConsumer<RatingsCubit, RatingsState>(
      listenWhen: (previous, current) =>
          previous.status != current.status ||
          previous.draftData != current.draftData,
      listener: (context, state) {
        if (state.draftData != null) {
          _restoreDraft(state.draftData!);
        }

        if (state.status == RatingsStatus.success) {
          Navigator.of(context).pop(true);
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.slate900,
          body: SafeArea(
            child: ScrollConfiguration(
              behavior: const MaterialScrollBehavior().copyWith(
                overscroll: false,
              ),
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      isDriverMode
                          ? 'Calificar pasajeros'
                          : 'Calificar conductor',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.primary.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Califica tu experiencia despues de este viaje.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.primary.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.slate300,
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (isDriverMode)
                      ..._buildPassengerForms(widget.args.passengers)
                    else
                      _DriverForm(
                        driverName: widget.args.driverName ?? 'Conductor',
                        scores: _scoresByRiderId[widget.args.riderId]!,
                        onChanged: _refresh,
                      ),
                    if (state.message != null &&
                        state.message!.trim().isNotEmpty) ...[
                      const SizedBox(height: 18),
                      _MessageBox(message: state.message!),
                    ],
                    if (state.isOffline) ...[
                      const SizedBox(height: 18),
                      _OfflineDraftCard(onRetry: _submit),
                    ],
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: state.status == RatingsStatus.submitting
                          ? null
                          : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC65A05),
                        disabledBackgroundColor: const Color(
                          0xFFC65A05,
                        ).withValues(alpha: 0.55),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: Text(
                        state.status == RatingsStatus.submitting
                            ? 'Enviando...'
                            : isDriverMode
                            ? 'Enviar calificaciones'
                            : 'Enviar calificacion',
                        style: AppTextStyles.primary.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextButton(
                      onPressed: state.status == RatingsStatus.submitting
                          ? null
                          : () async {
                              await context.read<RatingsCubit>().clearDraft(
                                _draftKey,
                              );
                              if (context.mounted) {
                                Navigator.of(context).pop(false);
                              }
                            },
                      child: Text(
                        'Omitir',
                        style: AppTextStyles.primary.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.amber700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildPassengerForms(List<RatingPassenger> passengers) {
    if (passengers.isEmpty) {
      return [
        _MessageBox(
          message: 'No hay pasajeros confirmados para calificar en este viaje.',
        ),
      ];
    }

    return [
      Text(
        'Pasajeros',
        style: AppTextStyles.primary.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
      const SizedBox(height: 12),
      for (int i = 0; i < passengers.length; i++) ...[
        _PassengerForm(
          passenger: passengers[i],
          scores: _scoresByRiderId[passengers[i].riderId]!,
          onChanged: _refresh,
        ),
        if (i < passengers.length - 1) const SizedBox(height: 18),
      ],
    ];
  }

  void _submit() {
    final validationMessage = _validateScores();
    if (validationMessage != null) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(validationMessage)));
      return;
    }

    if (widget.args.mode == RatingsMode.driverRatesRiders) {
      final ratings = widget.args.passengers.map((passenger) {
        final scores = _scoresByRiderId[passenger.riderId]!;
        return RateRider(
          riderId: passenger.riderId,
          driverId: widget.args.driverId,
          punctuality: scores.punctuality!,
          behavior: scores.behavior!,
          communication: scores.communication!,
          paymentPunctuality: scores.paymentPunctuality!,
          rideId: widget.args.rideId,
        );
      }).toList();

      context.read<RatingsCubit>().submitRiderRatings(
        draftKey: _draftKey,
        ratings: ratings,
      );
      return;
    }

    final riderId = widget.args.riderId;
    if (riderId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No pudimos identificar tu perfil.')),
      );
      return;
    }

    final scores = _scoresByRiderId[riderId]!;
    context.read<RatingsCubit>().submitDriverRating(
      draftKey: _draftKey,
      rating: RateDriver(
        riderId: riderId,
        driverId: widget.args.driverId,
        punctuality: scores.punctuality!,
        behavior: scores.behavior!,
        communication: scores.communication!,
        security: scores.security!,
        rideId: widget.args.rideId,
      ),
    );
  }

  String? _validateScores() {
    if (widget.args.mode == RatingsMode.driverRatesRiders &&
        widget.args.passengers.isEmpty) {
      return 'No hay pasajeros para calificar.';
    }

    for (final scores in _scoresByRiderId.values) {
      if (!scores.isComplete(widget.args.mode)) {
        return 'Completa todos los puntajes antes de enviar.';
      }
    }

    return null;
  }

  void _refresh() {
    context.read<RatingsCubit>().saveDraft(_draftKey, _toDraftData());
    setState(() {});
  }

  String _buildDraftKey() {
    if (widget.args.mode == RatingsMode.driverRatesRiders) {
      return 'driver:${widget.args.rideId}:${widget.args.driverId}';
    }

    return 'rider:${widget.args.rideId}:${widget.args.riderId}:${widget.args.driverId}';
  }

  Map<String, dynamic> _toDraftData() {
    return {
      'scores': {
        for (final entry in _scoresByRiderId.entries)
          entry.key.toString(): entry.value.toJson(),
      },
    };
  }

  void _restoreDraft(Map<String, dynamic> draftData) {
    final rawScores = draftData['scores'];
    if (rawScores is! Map) {
      return;
    }

    for (final entry in rawScores.entries) {
      final riderId = int.tryParse(entry.key.toString());
      final scores = entry.value;

      if (riderId == null ||
          scores is! Map ||
          !_scoresByRiderId.containsKey(riderId)) {
        continue;
      }

      _scoresByRiderId[riderId]!.loadFromMap(Map<String, dynamic>.from(scores));
    }

    setState(() {});
  }
}

class _PassengerForm extends StatelessWidget {
  const _PassengerForm({
    required this.passenger,
    required this.scores,
    required this.onChanged,
  });

  final RatingPassenger passenger;
  final _RatingScores scores;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return _RatingCard(
      title: passenger.name,
      children: [
        RatingScoreSelector(
          label: 'Puntualidad',
          value: scores.punctuality,
          onChanged: (value) {
            scores.punctuality = value;
            onChanged();
          },
        ),
        RatingScoreSelector(
          label: 'Comportamiento',
          value: scores.behavior,
          onChanged: (value) {
            scores.behavior = value;
            onChanged();
          },
        ),
        RatingScoreSelector(
          label: 'Comunicacion',
          value: scores.communication,
          onChanged: (value) {
            scores.communication = value;
            onChanged();
          },
        ),
        RatingScoreSelector(
          label: 'Puntualidad en el pago',
          value: scores.paymentPunctuality,
          onChanged: (value) {
            scores.paymentPunctuality = value;
            onChanged();
          },
        ),
      ],
    );
  }
}

class _DriverForm extends StatelessWidget {
  const _DriverForm({
    required this.driverName,
    required this.scores,
    required this.onChanged,
  });

  final String driverName;
  final _RatingScores scores;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return _RatingCard(
      title: driverName,
      children: [
        RatingScoreSelector(
          label: 'Puntualidad',
          value: scores.punctuality,
          onChanged: (value) {
            scores.punctuality = value;
            onChanged();
          },
        ),
        RatingScoreSelector(
          label: 'Comportamiento',
          value: scores.behavior,
          onChanged: (value) {
            scores.behavior = value;
            onChanged();
          },
        ),
        RatingScoreSelector(
          label: 'Comunicacion',
          value: scores.communication,
          onChanged: (value) {
            scores.communication = value;
            onChanged();
          },
        ),
        RatingScoreSelector(
          label: 'Seguridad',
          value: scores.security,
          onChanged: (value) {
            scores.security = value;
            onChanged();
          },
        ),
      ],
    );
  }
}

class _RatingCard extends StatelessWidget {
  const _RatingCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF5B526B),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.primary.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 18),
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1) const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}

class _MessageBox extends StatelessWidget {
  const _MessageBox({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: AppTextStyles.primary.copyWith(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _OfflineDraftCard extends StatelessWidget {
  const _OfflineDraftCard({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Sin conexion',
            style: AppTextStyles.primary.copyWith(
              color: const Color(0xFF92400E),
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Guardamos tu calificacion en este dispositivo. Cuando tengas internet, toca Reintentar para enviarla.',
            style: AppTextStyles.primary.copyWith(
              color: const Color(0xFF92400E),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: onRetry,
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF92400E),
              side: const BorderSide(color: Color(0xFF92400E)),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Reintentar',
              style: AppTextStyles.primary.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingScores {
  int? punctuality;
  int? behavior;
  int? communication;
  int? paymentPunctuality;
  int? security;

  Map<String, dynamic> toJson() {
    return {
      'punctuality': punctuality,
      'behavior': behavior,
      'communication': communication,
      'paymentPunctuality': paymentPunctuality,
      'security': security,
    };
  }

  void loadFromMap(Map<String, dynamic> data) {
    punctuality = _toInt(data['punctuality']);
    behavior = _toInt(data['behavior']);
    communication = _toInt(data['communication']);
    paymentPunctuality = _toInt(data['paymentPunctuality']);
    security = _toInt(data['security']);
  }

  bool isComplete(RatingsMode mode) {
    final baseComplete =
        punctuality != null && behavior != null && communication != null;

    if (mode == RatingsMode.driverRatesRiders) {
      return baseComplete && paymentPunctuality != null;
    }

    return baseComplete && security != null;
  }

  int? _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(value.toString());
  }
}
