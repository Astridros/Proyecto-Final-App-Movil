import 'package:flutter/material.dart';

import '../../domain/constants/contract_types.dart';

class ContractTypeFilter extends StatelessWidget {
  const ContractTypeFilter({
    super.key,
    required this.selectedContractType,
    required this.onChanged,
    this.enabled = true,
  });

  final String? selectedContractType;
  final ValueChanged<String?> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final selectedValue =
        selectedContractType != null &&
            ContractTypes.isValid(selectedContractType!)
        ? selectedContractType
        : null;

    return DropdownButtonFormField<String?>(
      initialValue: selectedValue,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Tipo de contrato',
        prefixIcon: Icon(Icons.assignment_outlined),
      ),
      items: const [
        DropdownMenuItem<String?>(
          value: null,
          child: Text('Todos', overflow: TextOverflow.ellipsis),
        ),
        DropdownMenuItem<String?>(
          value: ContractTypes.temporal,
          child: Text('Temporal', overflow: TextOverflow.ellipsis),
        ),
        DropdownMenuItem<String?>(
          value: ContractTypes.fijo,
          child: Text('Fijo', overflow: TextOverflow.ellipsis),
        ),
        DropdownMenuItem<String?>(
          value: ContractTypes.horas,
          child: Text('Por horas', overflow: TextOverflow.ellipsis),
        ),
      ],
      onChanged: enabled ? onChanged : null,
    );
  }
}
