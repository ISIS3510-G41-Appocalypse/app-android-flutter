import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../widgets/ride_offer_card.dart';
import '../widgets/ride_offers_filter_section.dart';
import '../widgets/ride_offers_intro_section.dart';

class RideOffersPage extends StatelessWidget {
  const RideOffersPage({super.key});

  static const List<RideOfferUiModel> _offers = [
    RideOfferUiModel(
      driverName: 'Carlos Méndez',
      rating: '4.9',
      tripsText: '124 viajes',
      price: '\$4.500',
      priceLabel: 'por asiento',
      origin: 'CC Parque Colina',
      originTimeLabel: 'Hora de salida: 08:15 AM',
      destination: 'Universidad de los Andes',
      destinationTimeLabel: 'Llegada estimada: 09:00 AM',
      seatsText: '3 disponibles',
      carModel: 'Mazda 2',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAOMEihq676rKEmU5UaFIIpF_oPvFByHkvKjJnjCVtXfaM-HjOWAty79NwPE6S1gXHDf9zsOu7VXy8ZwvgILTB3_WGcFqSbc9W9qOhEXoW84H1asJfy8aZ7c87noazbpzNpYyUzdmYugwy2yesn4f9f3tnosFGyg0Artx89N4al5gasLziboKNUUATZgyjoZVWshXNzXvtXa9EhH9b-FAQD4sxbmD_YrCuvI43mYO5yxaKoq6OPOFN3W5DGKpLH-t3Q3uIQRadRtgo',
    ),
    RideOfferUiModel(
      driverName: 'Ana María Silva',
      rating: '5.0',
      tripsText: '82 viajes',
      price: '\$5.000',
      priceLabel: 'por asiento',
      origin: 'Estación Mazurén',
      originTimeLabel: 'Hora de salida: 07:45 AM',
      destination: 'Universidad de los Andes',
      destinationTimeLabel: 'Llegada estimada: 08:45 AM',
      seatsText: '1 disponible',
      carModel: 'Kia Picanto',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuADtJ02vcuI87o9jLoPsSus5w0w4Ppb5Z_O5tGTCfwFEzGL2czCBwOxBj4mysO4q6T8IHfjHz8e9RT_fRvGzL0pzvsntHSq6CQlhA4FCUOjGf32Vs9atNB0VEOFevBIIgtxJKdRId-kVOF03nr1c7jKC8Fliw100ceKLa-ii2rG2nXFJ0q9pteYnLHEelue_2TilADeZQgPc5DOQb54adbrfKXAAkNISlhHUwchu5TpdvUQQFlgwqibp-No2gMZkDfRCxvw3vOxyCs',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: AppBar(
        backgroundColor: AppColors.slate900,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Happy Ride',
          style: TextStyle(color: AppColors.gray50),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(
              Icons.directions_car_rounded,
              color: AppColors.amber700,
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ScrollConfiguration(
          behavior: const MaterialScrollBehavior().copyWith(overscroll: false),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const RideOffersIntroSection(),
                const SizedBox(height: 24),
                const RideOffersFiltersSection(),
                const SizedBox(height: 24),
                ...List.generate(
                  _offers.length,
                  (index) => Padding(
                    padding: EdgeInsets.only(
                      bottom: index == _offers.length - 1 ? 0 : 24,
                    ),
                    child: RideOfferCard(offer: _offers[index]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
        ),
        child: const SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _BottomItem(
                icon: Icons.home_rounded,
                label: 'Home',
                selected: true,
              ),
              _BottomItem(icon: Icons.directions_car_outlined, label: 'Viajes'),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomItem extends StatelessWidget {
  const _BottomItem({
    required this.icon,
    required this.label,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.amber700 : AppColors.slate400;

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 22, color: color),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
