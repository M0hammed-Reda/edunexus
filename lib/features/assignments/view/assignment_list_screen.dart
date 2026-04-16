import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../features/auth/viewmodel/auth_viewmodel.dart';
import '../viewmodel/assignments_viewmodel.dart';

class AssignmentListScreen extends ConsumerWidget {
  const AssignmentListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // OBSERVER: rebuilds whenever assignment state changes
    final state = ref.watch(assignmentsProvider);
    final user = ref.watch(authProvider);
    final isTeacher = user?.isTeacher ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assignments'),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? Center(child: Text('Error: ${state.error}'))
              : state.assignments.isEmpty
                  ? const Center(child: Text('No assignments yet.'))
                  : RefreshIndicator(
                      onRefresh: () =>
                          ref.read(assignmentsProvider.notifier).refresh(),
                      child: ListView.builder(
                        itemCount: state.assignments.length,
                        itemBuilder: (ctx, i) {
                          final a = state.assignments[i];
                          final isOverdue = a.isOverdue;

                          return Card(
                            child: ListTile(
                              // Color-coded icon: red if overdue, blue if not
                              leading: CircleAvatar(
                                backgroundColor: isOverdue
                                    ? Colors.red[50]
                                    : const Color(0xFFEEF0FF),
                                child: Icon(
                                  Icons.assignment,
                                  color: isOverdue
                                      ? Colors.red
                                      : const Color(0xFF3D5AF1),
                                ),
                              ),
                              title: Text(
                                a.title,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    a.description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  // Deadline row — Flexible prevents right overflow
                                  // when the trailing Submit button competes for space
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.schedule,
                                        size: 14,
                                        color: isOverdue
                                            ? Colors.red
                                            : Colors.grey[600],
                                      ),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          'Due: ${DateFormat('MMM d, yyyy').format(a.deadline)}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isOverdue
                                                ? Colors.red
                                                : Colors.grey[600],
                                            fontWeight: isOverdue
                                                ? FontWeight.bold
                                                : null,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              isThreeLine: true,
                              // Student gets a Submit button; teacher sees nothing
                              trailing: !isTeacher
                                  ? TextButton(
                                      onPressed: () => context
                                          .push('/assignments/${a.id}/submit'),
                                      child: const Text('Submit'),
                                    )
                                  : null,
                            ),
                          );
                        },
                      ),
                    ),

      // ── FAB for teachers to create assignments ────────────────────────────
      floatingActionButton: isTeacher
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/assignments/create'),
              icon: const Icon(Icons.add),
              label: const Text('New Assignment'),
            )
          : null,
    );
  }
}
