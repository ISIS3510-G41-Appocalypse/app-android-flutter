import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

class RideOfferUiModel {
  const RideOfferUiModel({
    required this.driverName,
    required this.rating,
    required this.tripsText,
    required this.price,
    required this.priceLabel,
    required this.origin,
    required this.originTimeLabel,
    required this.destination,
    required this.destinationTimeLabel,
    required this.seatsText,
    required this.carModel,
    required this.imageUrl,
  });

  final String driverName;
  final String rating;
  final String tripsText;
  final String price;
  final String priceLabel;
  final String origin;
  final String originTimeLabel;
  final String destination;
  final String destinationTimeLabel;
  final String seatsText;
  final String carModel;
  final String imageUrl;
}

class RideOfferCard extends StatelessWidget {
  const RideOfferCard({super.key, required this.offer});

  final RideOfferUiModel offer;

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
                  rating: offer.rating,
                  tripsText: offer.tripsText,
                  imageUrl: offer.imageUrl,
                ),
              ),
              const SizedBox(width: 12),
              _PriceInfo(price: offer.price, priceLabel: offer.priceLabel),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 94,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _RouteTimeline(),
                const SizedBox(width: 12),
                Expanded(
                  child: _RouteDetails(
                    origin: offer.origin,
                    originTimeLabel: offer.originTimeLabel,
                    destination: offer.destination,
                    destinationTimeLabel: offer.destinationTimeLabel,
                  ),
                ),
              ],
            ),
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
                    _MiniInfo(label: offer.seatsText),
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
  const _DriverInfo({
    required this.driverName,
    required this.rating,
    required this.tripsText,
    required this.imageUrl,
  });

  final String driverName;
  final String rating;
  final String tripsText;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: const Color(0xFF334155),
          backgroundImage: NetworkImage(imageUrl),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                driverName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.primary.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.slate900,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.star_rounded,
                    size: 16,
                    color: AppColors.amber700,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      '$rating ($tripsText)',
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.primary.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PriceInfo extends StatelessWidget {
  const _PriceInfo({required this.price, required this.priceLabel});

  final String price;
  final String priceLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          price,
          style: AppTextStyles.primary.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.amber700,
          ),
        ),
        Text(
          priceLabel.toUpperCase(),
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

class _RouteTimeline extends StatelessWidget {
  const _RouteTimeline();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(width: 12, height: 94);
  }
}

class _RouteDetails extends StatelessWidget {
  const _RouteDetails({
    required this.origin,
    required this.originTimeLabel,
    required this.destination,
    required this.destinationTimeLabel,
  });

  final String origin;
  final String originTimeLabel;
  final String destination;
  final String destinationTimeLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          origin,
          style: AppTextStyles.primary.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          originTimeLabel,
          style: AppTextStyles.primary.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF64748B),
          ),
        ),
        const Spacer(),
        Text(
          destination,
          style: AppTextStyles.primary.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          destinationTimeLabel,
          style: AppTextStyles.primary.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF64748B),
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
