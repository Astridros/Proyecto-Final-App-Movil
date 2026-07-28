import 'package:flutter/material.dart';

import '../../../../app/theme/app_dimensions.dart';
import '../../domain/entities/job_type.dart';

class JobTypeFilter extends StatelessWidget {
  const JobTypeFilter({
    super.key,
    required this.jobTypes,
    required this.selectedJobTypeKey,
    required this.onChanged,
    this.enabled = true,
    this.isLoading = false,
  });

  final List<JobType> jobTypes;
  final String? selectedJobTypeKey;
  final ValueChanged<String?> onChanged;
  final bool enabled;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final selectedValue =
        jobTypes.any((jobType) => jobType.key == selectedJobTypeKey)
        ? selectedJobTypeKey
        : null;

    return DropdownButtonFormField<String?>(
      initialValue: selectedValue,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: 'Tipo de trabajo',
        prefixIcon: const Icon(Icons.work_outline_rounded),
        suffixIcon: isLoading
            ? const Padding(
                padding: EdgeInsets.all(AppDimensions.spacing16),
                child: SizedBox.square(
                  dimension: AppDimensions.iconSmall,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : null,
      ),
      items: [
        const DropdownMenuItem<String?>(
          value: null,
          child: Text('Todos', overflow: TextOverflow.ellipsis),
        ),
        ...jobTypes.map(
          (jobType) => DropdownMenuItem<String?>(
            value: jobType.key,
            child: Text(jobType.name, overflow: TextOverflow.ellipsis),
          ),
        ),
      ],
      onChanged: enabled ? onChanged : null,
    );
  }
}
