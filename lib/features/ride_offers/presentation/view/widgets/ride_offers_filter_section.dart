import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/zone.dart';

class RideOffersFiltersSection extends StatelessWidget {
  const RideOffersFiltersSection({
    super.key,
    required this.zones,
    required this.zoneId,
    required this.date,
    required this.type,
    required this.sortBy,
    required this.quickFilters,
    required this.onZoneChanged,
    required this.onDateChanged,
    required this.onTypeChanged,
    required this.onSortByChanged,
    required this.onQuickFilterToggled,
    required this.onApply,
    required this.onClear,
  });

  final List<Zone> zones;
  final String? zoneId;
  final DateTime? date;
  final String? type;
  final String? sortBy;
  final List<String> quickFilters;
  final ValueChanged<String?> onZoneChanged;
  final ValueChanged<DateTime?> onDateChanged;
  final ValueChanged<String?> onTypeChanged;
  final ValueChanged<String?> onSortByChanged;
  final ValueChanged<String> onQuickFilterToggled;
  final VoidCallback onApply;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 18,
            offset: Offset(4, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionLabel(text: 'Zona'),
          const SizedBox(height: 6),
          _SelectField(
            value: _zoneLabel(zones, zoneId),
            onTap: () => _selectZone(context),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionLabel(text: 'Día'),
                    const SizedBox(height: 6),
                    _SelectField(
                      value: _dateLabel(date),
                      onTap: () => _selectDate(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionLabel(text: 'Tipo de viaje'),
                    const SizedBox(height: 6),
                    _SelectField(
                      value: _typeLabel(type),
                      onTap: () => _selectType(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const _SectionLabel(text: 'Ordenar por'),
          const SizedBox(height: 6),
          _SelectField(
            value: _sortByLabel(sortBy),
            onTap: () => _selectSortBy(context),
          ),
          const SizedBox(height: 16),
          const _SectionLabel(text: 'Filtros'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _FilterChip(
                label: 'Hora',
                selected: quickFilters.contains('departure_time'),
                onTap: () => onQuickFilterToggled('departure_time'),
              ),
              _FilterChip(
                label: 'Precio',
                selected: quickFilters.contains('price'),
                onTap: () => onQuickFilterToggled('price'),
              ),
              _FilterChip(
                label: 'Cupos',
                selected: quickFilters.contains('slots'),
                onTap: () => onQuickFilterToggled('slots'),
              ),
              _FilterChip(
                label: 'Calificación',
                selected: quickFilters.contains('driver_rating'),
                onTap: () => onQuickFilterToggled('driver_rating'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: onClear,
                child: Text(
                  'Limpiar',
                  style: AppTextStyles.primary.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: onApply,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.amber700,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Aplicar',
                  style: AppTextStyles.primary.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _selectZone(BuildContext context) async {
    final selectedOption = await _showOptionsSheet<String?>(
      context: context,
      title: 'Zona',
      options: [
        const _FilterOption(label: 'Todas las zonas', value: null),
        ...zones.map((zone) => _FilterOption(label: zone.name, value: zone.id)),
      ],
    );

    if (selectedOption != null) {
      onZoneChanged(selectedOption.value);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: date ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (selectedDate != null) {
      onDateChanged(selectedDate);
    }
  }

  Future<void> _selectType(BuildContext context) async {
    final selectedOption = await _showOptionsSheet<String?>(
      context: context,
      title: 'Tipo de viaje',
      options: const [
        _FilterOption(label: 'Todos', value: null),
        _FilterOption(
          label: 'Llegada a la universidad',
          value: 'TO_UNIVERSITY',
        ),
        _FilterOption(
          label: 'Salida de la universidad',
          value: 'FROM_UNIVERSITY',
        ),
      ],
    );

    if (selectedOption != null) {
      onTypeChanged(selectedOption.value);
    }
  }

  Future<void> _selectSortBy(BuildContext context) async {
    final selectedOption = await _showOptionsSheet<String?>(
      context: context,
      title: 'Ordenar por',
      options: const [
        _FilterOption(label: 'Sin ordenar', value: null),
        _FilterOption(label: 'Hora de salida', value: 'departure_time'),
        _FilterOption(label: 'Precio', value: 'price'),
        _FilterOption(label: 'Cupos', value: 'slots'),
        _FilterOption(label: 'Calificación', value: 'driver_rating'),
      ],
    );

    if (selectedOption != null) {
      onSortByChanged(selectedOption.value);
    }
  }

  Future<_FilterOption<T>?> _showOptionsSheet<T>({
    required BuildContext context,
    required String title,
    required List<_FilterOption<T>> options,
  }) {
    return showModalBottomSheet<_FilterOption<T>>(
      context: context,
      backgroundColor: Colors.white,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Text(
                  title,
                  style: AppTextStyles.primary.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.slate900,
                  ),
                ),
              ),
              ...options.map(
                (option) => ListTile(
                  title: Text(option.label),
                  onTap: () => Navigator.of(context).pop(option),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _zoneLabel(List<Zone> zones, String? value) {
    if (value == null) {
      return 'Todas las zonas';
    }

    for (final zone in zones) {
      if (zone.id == value) {
        return zone.name;
      }
    }

    return 'Todas las zonas';
  }

  String _dateLabel(DateTime? value) {
    if (value == null) {
      return 'Todas las fechas';
    }

    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final year = value.year.toString();
    return '$day/$month/$year';
  }

  String _typeLabel(String? value) {
    switch (value) {
      case 'TO_UNIVERSITY':
        return 'Llegada a la universidad';
      case 'FROM_UNIVERSITY':
        return 'Salida de la universidad';
      default:
        return 'Todos';
    }
  }

  String _sortByLabel(String? value) {
    switch (value) {
      case 'departure_time':
        return 'Hora de salida';
      case 'price':
        return 'Precio';
      case 'slots':
        return 'Cupos';
      case 'driver_rating':
        return 'Calificación';
      default:
        return 'Sin ordenar';
    }
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.primary.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF64748B),
        letterSpacing: 0.5,
      ),
    );
  }
}

class _SelectField extends StatelessWidget {
  const _SelectField({required this.value, required this.onTap});

  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.primary.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.slate900,
                  ),
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Color(0xFF64748B),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.teal600 : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? AppColors.teal600 : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.primary.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }
}

class _FilterOption<T> {
  const _FilterOption({required this.label, required this.value});

  final String label;
  final T value;
}
