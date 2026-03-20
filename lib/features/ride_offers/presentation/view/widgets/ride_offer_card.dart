import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../models/ride_offer_view_data.dart';

class RideOfferCard extends StatelessWidget {
  const RideOfferCard({super.key, required this.offer});

  final RideOfferViewData offer;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 14,
            offset: Offset(4, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _DriverInfo(
                  driverName: offer.driverName,
                  rating: offer.ratingText,
                ),
              ),
              const SizedBox(width: 12),
              _OfferSummary(
                departureTimeLabel: offer.departureTimeLabel,
                price: offer.priceText,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _RouteDetails(
                  origin: offer.source,
                  destination: offer.destination,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _MiniInfo(label: offer.slotsText),
                    _MiniInfo(label: offer.carModel),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const _ReserveButton(),
            ],
          ),
        ],
      ),
    );
  }
}

class _DriverInfo extends StatelessWidget {
  const _DriverInfo({required this.driverName, required this.rating});

  final String driverName;
  final String rating;

  @override
  Widget build(BuildContext context) {
    final nameParts = _splitDriverName(driverName);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          nameParts.firstLine,
          style: AppTextStyles.primary.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.slate900,
          ),
        ),
        if (nameParts.secondLine != null) ...[
          const SizedBox(height: 2),
          Text(
            nameParts.secondLine!,
            style: AppTextStyles.primary.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.slate900,
            ),
          ),
        ],
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.star_rounded, size: 20, color: AppColors.amber700),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                rating,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.primary.copyWith(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

_DriverNameParts _splitDriverName(String fullName) {
  final parts = fullName
      .trim()
      .split(' ')
      .where((part) => part.isNotEmpty)
      .toList();

  if (parts.isEmpty) {
    return const _DriverNameParts(firstLine: '');
  }

  if (parts.length == 1) {
    return _DriverNameParts(firstLine: parts.first);
  }

  return _DriverNameParts(
    firstLine: parts.sublist(0, parts.length - 1).join(' '),
    secondLine: parts.last,
  );
}

class _DriverNameParts {
  const _DriverNameParts({required this.firstLine, this.secondLine});

  final String firstLine;
  final String? secondLine;
}

class _OfferSummary extends StatelessWidget {
  const _OfferSummary({required this.departureTimeLabel, required this.price});

  final String departureTimeLabel;
  final String price;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          departureTimeLabel,
          style: AppTextStyles.primary.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.amber700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          price,
          style: AppTextStyles.primary.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.slate900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'POR CUPO',
          style: AppTextStyles.primary.copyWith(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }
}

class _RouteDetails extends StatelessWidget {
  const _RouteDetails({required this.origin, required this.destination});

  final String origin;
  final String destination;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Inicio',
          style: AppTextStyles.primary.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          origin,
          style: AppTextStyles.primary.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 6),
        const Icon(
          Icons.arrow_downward_rounded,
          size: 18,
          color: Color(0xFF64748B),
        ),
        const SizedBox(height: 6),
        Text(
          'Destino',
          style: AppTextStyles.primary.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          destination,
          style: AppTextStyles.primary.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }
}

class _MiniInfo extends StatelessWidget {
  const _MiniInfo({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: Color(0xFF64748B),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTextStyles.primary.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }
}

class _ReserveButton extends StatelessWidget {
  const _ReserveButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.amber700,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Reservar',
          style: AppTextStyles.primary.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
