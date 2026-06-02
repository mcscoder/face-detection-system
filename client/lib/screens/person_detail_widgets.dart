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
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xffe5e7eb)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Display name',
              prefixIcon: Icon(Icons.badge_outlined),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: employeeController,
            decoration: const InputDecoration(
              labelText: 'Employee code',
              prefixIcon: Icon(Icons.tag),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: jobController,
            decoration: const InputDecoration(
              labelText: 'Job title',
              prefixIcon: Icon(Icons.work_outline),
            ),
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
      ),
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
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xffe5e7eb)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: const Color(0xffe0f2fe),
                foregroundColor: const Color(0xff0369a1),
                child: Text(
                  person.displayName.isEmpty
                      ? '?'
                      : person.displayName[0].toUpperCase(),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  person.displayName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
            ],
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
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xfff8fafc),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 116,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xff64748b),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
