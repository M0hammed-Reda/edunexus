import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../features/auth/viewmodel/auth_viewmodel.dart';
import '../viewmodel/home_viewmodel.dart';

/// Home screen shows two tabs: Announcements and Materials.
/// Teachers see a FAB to post/upload; students see content only.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
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
    // OBSERVER: watch triggers a rebuild whenever homeProvider state changes
    final homeState = ref.watch(homeProvider);
    final user = ref.watch(authProvider);
    final isTeacher = user?.isTeacher ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('EduNexus', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Hello, ${user?.name ?? ''}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w300)),
          ],
        ),
        actions: [
          // Assignment list button
          IconButton(
            icon: const Icon(Icons.assignment),
            tooltip: 'Assignments',
            onPressed: () => context.push('/assignments'),
          ),
          // Logout button
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => ref.read(authProvider.notifier).logout(),
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
                    // ── Announcements Tab ──────────────────────────────────
                    RefreshIndicator(
                      onRefresh: () => ref.read(homeProvider.notifier).refresh(),
                      child: homeState.announcements.isEmpty
                          ? const _EmptyState(message: 'No announcements yet.')
                          : ListView.builder(
                              itemCount: homeState.announcements.length,
                              itemBuilder: (ctx, i) {
                                final a = homeState.announcements[i];
                                return Card(
                                  child: ListTile(
                                    leading: const CircleAvatar(
                                      backgroundColor: Color(0xFF3D5AF1),
                                      child: Icon(Icons.campaign, color: Colors.white),
                                    ),
                                    title: Text(a.title,
                                        style: const TextStyle(fontWeight: FontWeight.w600)),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 4),
                                        Text(a.content),
                                        const SizedBox(height: 4),
                                        Text(
                                          DateFormat('MMM d, yyyy').format(a.createdAt),
                                          style: TextStyle(
                                              fontSize: 11, color: Colors.grey[500]),
                                        ),
                                      ],
                                    ),
                                    isThreeLine: true,
                                  ),
                                );
                              },
                            ),
                    ),

                    // ── Materials Tab ──────────────────────────────────────
                    RefreshIndicator(
                      onRefresh: () => ref.read(homeProvider.notifier).refresh(),
                      child: homeState.materials.isEmpty
                          ? const _EmptyState(message: 'No materials uploaded yet.')
                          : ListView.builder(
                              itemCount: homeState.materials.length,
                              itemBuilder: (ctx, i) {
                                final m = homeState.materials[i];
                                return Card(
                                  child: ListTile(
                                    leading: const CircleAvatar(
                                      backgroundColor: Color(0xFF2EC4B6),
                                      child: Icon(Icons.picture_as_pdf, color: Colors.white),
                                    ),
                                    title: Text(m.title,
                                        style: const TextStyle(fontWeight: FontWeight.w600)),
                                    subtitle: Text(
                                      DateFormat('MMM d, yyyy').format(m.createdAt),
                                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                                    ),
                                    trailing: const Icon(Icons.download, color: Color(0xFF2EC4B6)),
                                    onTap: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Opening ${m.title}…')),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),

      // ── FAB (Teacher only) ─────────────────────────────────────────────────
      floatingActionButton: isTeacher
          ? FloatingActionButton.extended(
              onPressed: () => _showAddDialog(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('Add Content'),
            )
          : null,
    );
  }

  // ── Dialog to post announcement or upload material ────────────────────────
  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final isAnnouncementTab = _tabController.index == 0;
    showDialog(
      context: context,
      builder: (_) => isAnnouncementTab
          ? _AddAnnouncementDialog(ref: ref)
          : _AddMaterialDialog(ref: ref),
    );
  }
}

// ── Post Announcement Dialog ──────────────────────────────────────────────────
class _AddAnnouncementDialog extends StatefulWidget {
  final WidgetRef ref;
  const _AddAnnouncementDialog({required this.ref});

  @override
  State<_AddAnnouncementDialog> createState() => _AddAnnouncementDialogState();
}

class _AddAnnouncementDialogState extends State<_AddAnnouncementDialog> {
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Post Announcement'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: _titleCtrl, decoration: const InputDecoration(labelText: 'Title')),
          const SizedBox(height: 12),
          TextField(controller: _contentCtrl, decoration: const InputDecoration(labelText: 'Content'), maxLines: 3),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            if (_titleCtrl.text.trim().isEmpty) return;
            widget.ref.read(homeProvider.notifier).postAnnouncement(
                  title: _titleCtrl.text.trim(),
                  content: _contentCtrl.text.trim(),
                  teacherId: widget.ref.read(authProvider)!.id,
                );
            Navigator.pop(context);
          },
          child: const Text('Post'),
        ),
      ],
    );
  }
}

// ── Upload Material Dialog ────────────────────────────────────────────────────
class _AddMaterialDialog extends StatefulWidget {
  final WidgetRef ref;
  const _AddMaterialDialog({required this.ref});

  @override
  State<_AddMaterialDialog> createState() => _AddMaterialDialogState();
}

class _AddMaterialDialogState extends State<_AddMaterialDialog> {
  final _titleCtrl = TextEditingController();
  final _urlCtrl   = TextEditingController();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _urlCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Upload Material'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: _titleCtrl, decoration: const InputDecoration(labelText: 'Title')),
          const SizedBox(height: 12),
          TextField(controller: _urlCtrl, decoration: const InputDecoration(labelText: 'File URL')),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            if (_titleCtrl.text.trim().isEmpty || _urlCtrl.text.trim().isEmpty) return;
            widget.ref.read(homeProvider.notifier).uploadMaterial(
                  title: _titleCtrl.text.trim(),
                  fileUrl: _urlCtrl.text.trim(),
                  teacherId: widget.ref.read(authProvider)!.id,
                );
            Navigator.pop(context);
          },
          child: const Text('Upload'),
        ),
      ],
    );
  }
}

// ── Empty state widget ────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text(message, style: TextStyle(color: Colors.grey[500])),
        ],
      ),
    );
  }
}
