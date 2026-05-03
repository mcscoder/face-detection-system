import 'package:flutter/material.dart';

class EnrollmentPersonForm extends StatelessWidget {
  const EnrollmentPersonForm({
    super.key,
    required this.isActive,
    required this.isBusy,
    required this.canCreate,
    required this.personIdController,
    required this.onDisplayNameChanged,
    required this.onPersonIdChanged,
    required this.onCreatePerson,
  });

  final bool isActive;
  final bool isBusy;
  final bool canCreate;
  final TextEditingController personIdController;
  final ValueChanged<String> onDisplayNameChanged;
  final ValueChanged<String> onPersonIdChanged;
  final VoidCallback onCreatePerson;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          enabled: !isActive,
          decoration: const InputDecoration(labelText: 'Display name'),
          onChanged: onDisplayNameChanged,
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: canCreate ? onCreatePerson : null,
            icon: const Icon(Icons.person_add),
            label: Text(isBusy ? 'Working...' : 'Create Person'),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          enabled: !isActive,
          controller: personIdController,
          decoration: const InputDecoration(labelText: 'Person ID'),
          onChanged: onPersonIdChanged,
        ),
      ],
    );
  }
}
