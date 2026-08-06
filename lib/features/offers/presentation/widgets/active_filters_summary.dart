import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../domain/constants/contract_types.dart';
import '../../domain/entities/job_type.dart';

class ActiveFiltersSummary extends StatelessWidget {
  const ActiveFiltersSummary({
    super.key,
    required this.jobTypes,
    required this.selectedJobTypeKey,
    required this.selectedContractType,
    required this.onClearFilters,
  });

  final List<JobType> jobTypes;
  final String? selectedJobTypeKey;
  final String? selectedContractType;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    final labels = <String>[?_selectedJobTypeName, ?_contractTypeLabel];

    if (labels.isEmpty) {
      return const SizedBox.shrink();
    }

    return Semantics(
      label: '${labels.length} filtros activos',
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surfaceSoft,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          border: Border.all(color: AppColors.border),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacing12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${labels.length} ${labels.length == 1 ? 'filtro activo' : 'filtros activos'}',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacing4),
                    Text(
                      labels.join(' · '),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimensions.spacing8),
              TextButton(
                onPressed: onClearFilters,
                child: const Text('Limpiar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? get _selectedJobTypeName {
    for (final jobType in jobTypes) {
      if (jobType.key == selectedJobTypeKey) {
        return jobType.name;
      }
    }

    return null;
  }

  String? get _contractTypeLabel {
    return ContractTypes.labelFor(selectedContractType);
  }
}
