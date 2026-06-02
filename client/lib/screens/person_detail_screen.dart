import 'dart:async';

import 'package:flutter/material.dart';

import '../models/domain.dart';
import '../state/app_controller.dart';
import '../widgets/status_banner.dart';
import 'person_detail_widgets.dart';

class PersonDetailScreen extends StatefulWidget {
  const PersonDetailScreen({
    super.key,
    required this.controller,
    required this.initialPerson,
  });

  final AppController controller;
  final PersonSummary initialPerson;

  @override
  State<PersonDetailScreen> createState() => _PersonDetailScreenState();
}

class _PersonDetailScreenState extends State<PersonDetailScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _employeeController = TextEditingController();
  final TextEditingController _jobController = TextEditingController();
  late PersonSummary person = widget.initialPerson;
  bool editing = false;

  @override
  void initState() {
    super.initState();
    _setFields(person);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_loadDetail());
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _employeeController.dispose();
    _jobController.dispose();
    super.dispose();
  }

  Future<void> _loadDetail() async {
    final loaded = await widget.controller.loadPerson(person.id);
    if (!mounted || loaded == null) return;
    setState(() {
      person = loaded;
      _setFields(loaded);
    });
  }

  Future<void> _save() async {
    final updated = await widget.controller.updatePerson(
      personId: person.id,
      displayName: _nameController.text.trim(),
      employeeCode: _emptyToNull(_employeeController.text),
      jobTitle: _emptyToNull(_jobController.text),
    );
    if (!mounted || updated == null) return;
    setState(() {
      person = updated;
      editing = false;
      _setFields(updated);
    });
  }

  Future<void> _remove() async {
    final removed = await widget.controller.deletePerson(person.id);
    if (mounted && removed) Navigator.of(context).pop();
  }

  void _setFields(PersonSummary value) {
    _nameController.text = value.displayName;
    _employeeController.text = value.employeeCode ?? '';
    _jobController.text = value.jobTitle ?? '';
  }

  String? _emptyToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final state = widget.controller.value;
        final canEdit = state.session?.canEnroll ?? false;
        final canRemove = state.session?.canAdmin ?? false;
        return Scaffold(
          backgroundColor: const Color(0xfff5f7fb),
          appBar: AppBar(title: const Text('Person Detail')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (state.message != null) ...[
                StatusBanner(label: state.message!, tone: BannerTone.error),
                const SizedBox(height: 12),
              ],
              if (editing)
                PersonEditFields(
                  isBusy: state.isBusy,
                  nameController: _nameController,
                  employeeController: _employeeController,
                  jobController: _jobController,
                  onSave: _save,
                  onCancel: () => setState(() {
                    editing = false;
                    _setFields(person);
                  }),
                )
              else
                PersonReadOnlyDetail(
                  person: person,
                  isBusy: state.isBusy,
                  canEdit: canEdit,
                  canRemove: canRemove,
                  onEdit: () => setState(() => editing = true),
                  onRemove: _remove,
                ),
            ],
          ),
        );
      },
    );
  }
}
