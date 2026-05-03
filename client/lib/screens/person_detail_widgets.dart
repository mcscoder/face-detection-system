import 'package:flutter/material.dart';

import '../models/domain.dart';

class PersonEditFields extends StatelessWidget {
  const PersonEditFields({
    super.key,
    required this.isBusy,
    required this.nameController,
    required this.employeeController,
    required this.jobController,
    required this.onSave,
    required this.onCancel,
  });

  final bool isBusy;
  final TextEditingController nameController;
  final TextEditingController employeeController;
  final TextEditingController jobController;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Display name'),
        ),
        TextField(
          controller: employeeController,
          decoration: const InputDecoration(labelText: 'Employee code'),
        ),
        TextField(
          controller: jobController,
          decoration: const InputDecoration(labelText: 'Job title'),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: isBusy ? null : onSave,
          icon: const Icon(Icons.save),
          label: const Text('Save'),
        ),
        TextButton(
          onPressed: isBusy ? null : onCancel,
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

class PersonReadOnlyDetail extends StatelessWidget {
  const PersonReadOnlyDetail({
    super.key,
    required this.person,
    required this.isBusy,
    required this.canEdit,
    required this.canRemove,
    required this.onEdit,
    required this.onRemove,
  });

  final PersonSummary person;
  final bool isBusy;
  final bool canEdit;
  final bool canRemove;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            person.displayName,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        const SizedBox(height: 12),
        _DetailRow(label: 'Person ID', value: person.id),
        _DetailRow(label: 'Employee code', value: person.employeeCode ?? '-'),
        _DetailRow(label: 'Job title', value: person.jobTitle ?? '-'),
        _DetailRow(label: 'Access', value: person.accessStatus),
        const SizedBox(height: 16),
        if (canEdit)
          FilledButton.icon(
            onPressed: isBusy ? null : onEdit,
            icon: const Icon(Icons.edit),
            label: const Text('Edit'),
          ),
        if (canRemove) ...[
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: isBusy ? null : onRemove,
            icon: const Icon(Icons.delete),
            label: const Text('Remove'),
          ),
        ],
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      subtitle: Text(value),
    );
  }
}
