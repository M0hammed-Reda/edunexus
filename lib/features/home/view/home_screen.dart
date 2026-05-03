import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../features/auth/viewmodel/auth_viewmodel.dart';
import '../viewmodel/home_viewmodel.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final String classroomId;
  const HomeScreen({super.key, required this.classroomId});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeProvider(widget.classroomId));
    final user = ref.watch(authProvider).user;
    final isTeacherOrManager = user?.role == 'teacher' || user?.role == 'manager';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Classroom', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Hello, ${user?.name ?? ''}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w300)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.assignment),
            tooltip: 'Assignments',
            onPressed: () => context.push('/assignments'), // Should ideally pass classroomId too
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.campaign), text: 'Announcements'),
            Tab(icon: Icon(Icons.folder), text: 'Materials'),
          ],
        ),
      ),
      body: homeState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : homeState.error != null
              ? Center(child: Text('Error: ${homeState.error}'))
              : TabBarView(
                  controller: _tabController,
                  children: [
                    RefreshIndicator(
                      onRefresh: () => ref.read(homeProvider(widget.classroomId).notifier).refresh(),
                      child: homeState.announcements.isEmpty
                          ? const Center(child: Text('No announcements yet.'))
                          : ListView.builder(
                              itemCount: homeState.announcements.length,
                              itemBuilder: (ctx, i) {
                                final a = homeState.announcements[i];
                                return Card(
                                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  child: ListTile(
                                    leading: const CircleAvatar(
                                      backgroundColor: Color(0xFF3D5AF1),
                                      child: Icon(Icons.campaign, color: Colors.white),
                                    ),
                                    title: Text(a.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 4),
                                        Text(a.content),
                                        const SizedBox(height: 4),
                                        Text(
                                          DateFormat('MMM d, yyyy').format(a.createdAt),
                                          style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                                        ),
                                      ],
                                    ),
                                    isThreeLine: true,
                                  ),
                                );
                              },
                            ),
                    ),
                    RefreshIndicator(
                      onRefresh: () => ref.read(homeProvider(widget.classroomId).notifier).refresh(),
                      child: homeState.materials.isEmpty
                          ? const Center(child: Text('No materials uploaded yet.'))
                          : ListView.builder(
                              itemCount: homeState.materials.length,
                              itemBuilder: (ctx, i) {
                                final m = homeState.materials[i];
                                return Card(
                                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  child: ListTile(
                                    leading: const CircleAvatar(
                                      backgroundColor: Color(0xFF2EC4B6),
                                      child: Icon(Icons.picture_as_pdf, color: Colors.white),
                                    ),
                                    title: Text(m.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                                    subtitle: Text(
                                      DateFormat('MMM d, yyyy').format(m.createdAt),
                                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                                    ),
                                    trailing: const Icon(Icons.download, color: Color(0xFF2EC4B6)),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
      floatingActionButton: isTeacherOrManager
          ? FloatingActionButton.extended(
              onPressed: () => _showAddDialog(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('Add Content'),
            )
          : null,
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final isAnnouncementTab = _tabController.index == 0;
    if (isAnnouncementTab) {
       _showAnnouncementDialog(context, ref);
    } else {
       _showMaterialDialog(context, ref);
    }
  }

  void _showAnnouncementDialog(BuildContext context, WidgetRef ref) {
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Post Announcement'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Title')),
            TextField(controller: contentCtrl, decoration: const InputDecoration(labelText: 'Content'), maxLines: 3),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (titleCtrl.text.trim().isNotEmpty) {
                ref.read(homeProvider(widget.classroomId).notifier).postAnnouncement(
                  title: titleCtrl.text.trim(),
                  content: contentCtrl.text.trim(),
                  teacherId: ref.read(authProvider).user!.id,
                );
                Navigator.pop(ctx);
              }
            },
            child: const Text('Post'),
          ),
        ],
      ),
    );
  }

  void _showMaterialDialog(BuildContext context, WidgetRef ref) {
    final titleCtrl = TextEditingController();
    final urlCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Upload Material'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Title')),
            TextField(controller: urlCtrl, decoration: const InputDecoration(labelText: 'URL')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (titleCtrl.text.trim().isNotEmpty) {
                ref.read(homeProvider(widget.classroomId).notifier).uploadMaterial(
                  title: titleCtrl.text.trim(),
                  fileUrl: urlCtrl.text.trim(),
                  teacherId: ref.read(authProvider).user!.id,
                );
                Navigator.pop(ctx);
              }
            },
            child: const Text('Upload'),
          ),
        ],
      ),
    );
  }
}
