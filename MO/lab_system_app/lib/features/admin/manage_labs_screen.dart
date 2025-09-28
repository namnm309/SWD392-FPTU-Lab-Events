import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/models/lab.dart';
import '../../data/repositories/lab_repository.dart';
import '../../core/utils/result.dart';

class ManageLabsScreen extends ConsumerStatefulWidget {
  const ManageLabsScreen({super.key});

  @override
  ConsumerState<ManageLabsScreen> createState() => _ManageLabsScreenState();
}

class _ManageLabsScreenState extends ConsumerState<ManageLabsScreen> {
  List<Lab> _labs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLabs();
  }

  Future<void> _loadLabs() async {
    final labRepository = LabRepository();
    await labRepository.init();
    
    final result = await labRepository.getAllLabs();
    if (result.isSuccess) {
      setState(() {
        _labs = result.data!;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteLab(Lab lab) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Lab'),
        content: Text('Are you sure you want to delete "${lab.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final labRepository = LabRepository();
      await labRepository.init();
      
      final result = await labRepository.deleteLab(lab.id);
      if (result.isSuccess) {
        _loadLabs(); // Refresh the list
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Lab deleted successfully')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.error!),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Labs'),
        actions: [
          IconButton(
            onPressed: () {
              _showAddLabDialog();
            },
            icon: const Icon(Icons.add),
            tooltip: 'Add Lab',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _labs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.science,
                        size: 64,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No labs found',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      FilledButton.icon(
                        onPressed: () => _showAddLabDialog(),
                        icon: const Icon(Icons.add),
                        label: const Text('Add First Lab'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _labs.length,
                  itemBuilder: (context, index) {
                    final lab = _labs[index];
                    return _buildLabCard(lab);
                  },
                ),
    );
  }

  Widget _buildLabCard(Lab lab) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            Icons.science,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(lab.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(lab.location),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.people,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  'Capacity: ${lab.capacity}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            switch (value) {
              case 'edit':
                _showEditLabDialog(lab);
                break;
              case 'delete':
                _deleteLab(lab);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: ListTile(
                leading: Icon(Icons.edit),
                title: Text('Edit'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Delete', style: TextStyle(color: Colors.red)),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddLabDialog() {
    _showLabDialog();
  }

  void _showEditLabDialog(Lab lab) {
    _showLabDialog(lab: lab);
  }

  void _showLabDialog({Lab? lab}) {
    final isEditing = lab != null;
    final nameController = TextEditingController(text: lab?.name ?? '');
    final locationController = TextEditingController(text: lab?.location ?? '');
    final capacityController = TextEditingController(text: lab?.capacity.toString() ?? '');
    final descriptionController = TextEditingController(text: lab?.description ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Edit Lab' : 'Add Lab'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Lab Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: capacityController,
                decoration: const InputDecoration(
                  labelText: 'Capacity',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty ||
                  locationController.text.trim().isEmpty ||
                  capacityController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill in all required fields')),
                );
                return;
              }

              final capacity = int.tryParse(capacityController.text);
              if (capacity == null || capacity < 1) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a valid capacity')),
                );
                return;
              }

              final labRepository = LabRepository();
              await labRepository.init();

              Result<Lab> result;
              if (isEditing) {
                final updatedLab = lab!.copyWith(
                  name: nameController.text.trim(),
                  location: locationController.text.trim(),
                  capacity: capacity,
                  description: descriptionController.text.trim(),
                );
                result = await labRepository.updateLab(updatedLab);
              } else {
                result = await labRepository.createLab(
                  name: nameController.text.trim(),
                  location: locationController.text.trim(),
                  capacity: capacity,
                  description: descriptionController.text.trim(),
                );
              }

              if (result.isSuccess) {
                Navigator.of(context).pop();
                _loadLabs(); // Refresh the list
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isEditing ? 'Lab updated successfully' : 'Lab created successfully'),
                    ),
                  );
                }
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result.error!),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                }
              }
            },
            child: Text(isEditing ? 'Update' : 'Create'),
          ),
        ],
      ),
    );
  }
}
