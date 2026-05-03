import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../features/auth/viewmodel/auth_viewmodel.dart';
import '../viewmodel/assignments_viewmodel.dart';

/// Teacher-only screen to create a new assignment.
class CreateAssignmentScreen extends ConsumerStatefulWidget {
  const CreateAssignmentScreen({super.key});

  @override
  ConsumerState<CreateAssignmentScreen> createState() =>
      _CreateAssignmentScreenState();
}

class _CreateAssignmentScreenState
    extends ConsumerState<CreateAssignmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  DateTime? _deadline;
  bool _isSaving = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _deadline = picked.copyWith(hour: 23, minute: 59));
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_deadline == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please pick a deadline.')));
      return;
    }

    setState(() => _isSaving = true);
    final user = ref.read(authProvider).user;
    await ref.read(assignmentsProvider.notifier).createAssignment(
          title: _titleCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          deadline: _deadline!,
          createdBy: user!.id,
        );
    setState(() => _isSaving = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Assignment created!')),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Assignment')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title field
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Assignment Title',
                  prefixIcon: Icon(Icons.assignment),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Title is required' : null,
              ),
              const SizedBox(height: 16),

              // Description field
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.description),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Description is required' : null,
              ),
              const SizedBox(height: 16),

              // Deadline picker
              OutlinedButton.icon(
                onPressed: _pickDeadline,
                icon: const Icon(Icons.calendar_today),
                label: Text(
                  _deadline == null
                      ? 'Pick Deadline'
                      : 'Deadline: ${DateFormat('MMM d, yyyy').format(_deadline!)}',
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  side: const BorderSide(color: Color(0xFF3D5AF1)),
                  foregroundColor: const Color(0xFF3D5AF1),
                ),
              ),
              const SizedBox(height: 32),

              // Submit button
              ElevatedButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Create Assignment'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
