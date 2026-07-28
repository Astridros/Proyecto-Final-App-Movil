import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/job_type.dart';
import 'active_filters_summary.dart';
import 'contract_type_filter.dart';
import 'job_type_filter.dart';

class OffersFilterBar extends StatelessWidget {
  const OffersFilterBar({
    super.key,
    required this.jobTypes,
    required this.selectedJobTypeKey,
    required this.selectedContractType,
    required this.isFiltering,
    required this.enabled,
    required this.onJobTypeChanged,
    required this.onContractTypeChanged,
    required this.onClearFilters,
  });

  final List<JobType> jobTypes;
  final String? selectedJobTypeKey;
  final String? selectedContractType;
  final bool isFiltering;
  final bool enabled;
  final ValueChanged<String?> onJobTypeChanged;
  final ValueChanged<String?> onContractTypeChanged;
  final VoidCallback onClearFilters;

  bool get _hasActiveFilters =>
      selectedJobTypeKey != null || selectedContractType != null;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Filtros', style: AppTextStyles.title),
          if (isFiltering) ...[
            const SizedBox(height: AppDimensions.spacing8),
            const LinearProgressIndicator(minHeight: 2),
          ],
          const SizedBox(height: AppDimensions.spacing16),
          LayoutBuilder(
            builder: (context, constraints) {
              final useHorizontalLayout = constraints.maxWidth >= 560;
              final filters = [
                JobTypeFilter(
                  jobTypes: jobTypes,
                  selectedJobTypeKey: selectedJobTypeKey,
                  onChanged: onJobTypeChanged,
                  enabled: enabled,
                  isLoading: isFiltering,
                ),
                ContractTypeFilter(
                  selectedContractType: selectedContractType,
                  onChanged: onContractTypeChanged,
                  enabled: enabled,
                ),
              ];

              if (!useHorizontalLayout) {
                return Column(
                  children: [
                    filters[0],
                    const SizedBox(height: AppDimensions.spacing12),
                    filters[1],
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: filters[0]),
                  const SizedBox(width: AppDimensions.spacing12),
                  Expanded(child: filters[1]),
                ],
              );
            },
          ),
          if (_hasActiveFilters) ...[
            const SizedBox(height: AppDimensions.spacing16),
            ActiveFiltersSummary(
              jobTypes: jobTypes,
              selectedJobTypeKey: selectedJobTypeKey,
              selectedContractType: selectedContractType,
              onClearFilters: onClearFilters,
            ),
          ],
          if (!enabled) ...[
            const SizedBox(height: AppDimensions.spacing12),
            Text(
              'Los filtros estarán disponibles al terminar la carga inicial.',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
