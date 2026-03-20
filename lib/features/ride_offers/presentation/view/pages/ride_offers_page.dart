import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/network/dio_client.dart';
import '../../../../../core/storage/token_storage.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../data/data_sources/ride_offers_remote_datasource.dart';
import '../../../data/repositories/ride_offers_repository_impl.dart';
import '../../../domain/usecases/get_ride_offers.dart';
import '../../view_model/ride_offers_cubit.dart';
import '../../view_model/ride_offers_state.dart';
import '../widgets/ride_offers_filter_section.dart';
import '../widgets/ride_offers_intro_section.dart';
import '../widgets/ride_offers_list_section.dart';

class RideOffersPage extends StatefulWidget {
  const RideOffersPage({super.key});

  @override
  State<RideOffersPage> createState() => _RideOffersPageState();
}

class _RideOffersPageState extends State<RideOffersPage> {
  late final RideOffersCubit _cubit;

  @override
  void initState() {
    super.initState();

    final tokenStorage = TokenStorage();
    final dioClient = DioClient(tokenStorage: tokenStorage);
    final remoteDataSource = RideOffersRemoteDataSourceImpl(dio: dioClient.dio);
    final repository = RideOffersRepositoryImpl(
      remoteDataSource: remoteDataSource,
    );
    final getRideOffers = GetRideOffers(repository);

    _cubit = RideOffersCubit(getRideOffers: getRideOffers)..loadRideOffers();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
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
          child: BlocBuilder<RideOffersCubit, RideOffersState>(
            builder: (context, state) {
              final cubit = context.read<RideOffersCubit>();

              return ScrollConfiguration(
                behavior: const MaterialScrollBehavior().copyWith(
                  overscroll: false,
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const RideOffersIntroSection(),
                      const SizedBox(height: 24),
                      RideOffersFiltersSection(
                        zoneId: state.filters.zoneId,
                        date: state.filters.date,
                        tripType: state.filters.tripType,
                        sortBy: state.filters.sortBy,
                        quickFilters: state.filters.quickFilters,
                        onZoneChanged: cubit.updateZoneId,
                        onDateChanged: cubit.updateDate,
                        onTripTypeChanged: cubit.updateTripType,
                        onSortByChanged: cubit.updateSortBy,
                        onQuickFilterToggled: cubit.toggleQuickFilter,
                        onApply: cubit.applyFilters,
                        onClear: cubit.clearFilters,
                      ),
                      const SizedBox(height: 24),
                      RideOffersListSection(state: state),
                    ],
                  ),
                ),
              );
            },
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
                _BottomItem(
                  icon: Icons.directions_car_outlined,
                  label: 'Viajes',
                ),
              ],
            ),
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
