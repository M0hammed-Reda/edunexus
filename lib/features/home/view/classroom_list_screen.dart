import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../auth/viewmodel/auth_viewmodel.dart';
import '../viewmodel/classrooms_viewmodel.dart';

class ClassroomListScreen extends ConsumerWidget {
  const ClassroomListScreen({super.key});

  void _showCreateDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create Classroom'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Classroom Name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                ref.read(classroomsProvider.notifier).createClassroom(controller.text.trim());
                Navigator.pop(ctx);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showJoinDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Join Classroom'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Enter Unique Code'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                ref.read(classroomsProvider.notifier).joinClassroom(controller.text.trim());
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Join request sent. Waiting for manager approval.')),
                );
              }
            },
            child: const Text('Join'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(classroomsProvider);
    final user = ref.watch(authProvider).user;

    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Classrooms'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authProvider.notifier).logout(),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? Center(child: Text('Error: ${state.error}'))
              : state.classrooms.isEmpty
                  ? Center(
                      child: Text(
                        user.role == 'manager'
                            ? 'You have not created any classrooms yet.\nTap + to create one.'
                            : 'You are not in any classrooms.\nTap + to join one with a code.',
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.classrooms.length,
                      itemBuilder: (ctx, i) {
                        final cls = state.classrooms[i];
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            title: Text(cls.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: user.role == 'manager' ? Text('Code: ${cls.uniqueCode}') : null,
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              // Navigate to classroom detail/home screen
                              context.push('/home/${cls.id}');
                            },
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (user.role == 'manager') {
            _showCreateDialog(context, ref);
          } else {
            _showJoinDialog(context, ref);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
