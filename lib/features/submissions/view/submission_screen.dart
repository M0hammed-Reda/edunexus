import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../features/assignments/viewmodel/assignments_viewmodel.dart';
import '../../../features/auth/viewmodel/auth_viewmodel.dart';
import '../viewmodel/submissions_viewmodel.dart';

/// Student screen to submit an assignment.
/// Shows assignment details and a file URL field (simulating file upload).
class SubmissionScreen extends ConsumerStatefulWidget {
  final String assignmentId;
  const SubmissionScreen({super.key, required this.assignmentId});

  @override
  ConsumerState<SubmissionScreen> createState() => _SubmissionScreenState();
}

class _SubmissionScreenState extends ConsumerState<SubmissionScreen> {
  final _fileUrlCtrl = TextEditingController();

  @override
  void dispose() {
    _fileUrlCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    final params = (assignmentId: widget.assignmentId, studentId: user!.id);

    // OBSERVER: watch submission state for this specific assignment + student
    final subState = ref.watch(submissionProvider(params));

    // Find the matching assignment for display
    final assignment = ref
        .watch(assignmentsProvider)
        .assignments
        .where((a) => a.id == widget.assignmentId)
        .firstOrNull;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Assignment'),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: subState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Assignment details card ──────────────────────────────
                  if (assignment != null) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              assignment.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(assignment.description,
                                style: Theme.of(context).textTheme.bodyMedium),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(Icons.schedule,
                                    size: 16,
                                    color: assignment.isOverdue
                                        ? Colors.red
                                        : Colors.grey[600]),
                                const SizedBox(width: 6),
                                Text(
                                  'Due: ${DateFormat('MMM d, yyyy – hh:mm a').format(assignment.deadline)}',
                                  style: TextStyle(
                                    color: assignment.isOverdue
                                        ? Colors.red
                                        : Colors.grey[600],
                                    fontWeight: assignment.isOverdue
                                        ? FontWeight.bold
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // ── Already submitted banner ─────────────────────────────
                  if (subState.existingSubmission != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.check_circle, color: Colors.green),
                              const SizedBox(width: 8),
                              Text(
                                'Submitted!',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('File: ${subState.existingSubmission!.fileUrl}',
                              style: const TextStyle(fontSize: 13)),
                          const SizedBox(height: 4),
                          Text(
                            'Submitted on: ${DateFormat('MMM d, yyyy – hh:mm a').format(subState.existingSubmission!.submittedAt)}',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                          if (subState.existingSubmission!.grade != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Grade: ${subState.existingSubmission!.grade!.toStringAsFixed(1)} / 100',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ] else ...[
                    // ── Submit form ─────────────────────────────────────────
                    Text(
                      'Upload Your Work',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _fileUrlCtrl,
                      decoration: const InputDecoration(
                        labelText: 'File URL or File Name',
                        prefixIcon: Icon(Icons.attach_file),
                        hintText: 'e.g. my_assignment.pdf',
                      ),
                    ),
                    const SizedBox(height: 24),

                    if (subState.error != null) ...[
                      Text(subState.error!,
                          style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 12),
                    ],

                    ElevatedButton.icon(
                      onPressed: subState.isSubmitting
                          ? null
                          : () {
                              final url = _fileUrlCtrl.text.trim();
                              if (url.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Please enter a file URL.')),
                                );
                                return;
                              }
                              ref
                                  .read(submissionProvider(params).notifier)
                                  .submitAssignment(url);
                            },
                      icon: subState.isSubmitting
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.upload),
                      label: Text(subState.isSubmitting ? 'Submitting…' : 'Submit'),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
