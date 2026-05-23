import 'package:flutter/material.dart';

import '../../../../../core/theme/app_text_styles.dart';

class RatingScoreSelector extends StatelessWidget {
  const RatingScoreSelector({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final int? value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: AppTextStyles.primary.copyWith(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            for (int score = 1; score <= 5; score++) ...[
              Expanded(
                child: _ScoreButton(
                  score: score,
                  isSelected: value == score,
                  onTap: () => onChanged(score),
                ),
              ),
              if (score < 5) const SizedBox(width: 8),
            ],
          ],
        ),
      ],
    );
  }
}

class _ScoreButton extends StatelessWidget {
  const _ScoreButton({
    required this.score,
    required this.isSelected,
    required this.onTap,
  });

  final int score;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: Material(
        color: isSelected ? const Color(0xFFC65A05) : const Color(0xFF5A5564),
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Center(
            child: Text(
              score.toString(),
              style: AppTextStyles.primary.copyWith(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
