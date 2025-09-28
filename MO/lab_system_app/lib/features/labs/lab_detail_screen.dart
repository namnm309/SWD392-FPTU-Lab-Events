import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/models/lab.dart';
import '../../domain/models/event.dart';
import '../../data/repositories/lab_repository.dart';
import '../../data/repositories/event_repository.dart';
import '../../core/utils/result.dart';

class LabDetailScreen extends ConsumerStatefulWidget {
  final String labId;

  const LabDetailScreen({
    super.key,
    required this.labId,
  });

  @override
  ConsumerState<LabDetailScreen> createState() => _LabDetailScreenState();
}

class _LabDetailScreenState extends ConsumerState<LabDetailScreen> {
  Lab? _lab;
  List<Event> _events = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLabDetails();
  }

  Future<void> _loadLabDetails() async {
    final labRepository = LabRepository();
    final eventRepository = EventRepository();
    
    await labRepository.init();
    await eventRepository.init();
    
    // Load lab details
    final labResult = await labRepository.getLabById(widget.labId);
    if (labResult.isSuccess) {
      setState(() {
        _lab = labResult.data;
      });
    }
    
    // Load events for this lab
    final eventsResult = await eventRepository.getEventsForLab(widget.labId);
    if (eventsResult.isSuccess) {
      setState(() {
        _events = eventsResult.data!;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_lab == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Lab Details'),
        ),
        body: const Center(
          child: Text('Lab not found'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_lab!.name),
        actions: [
          IconButton(
            onPressed: () {
              context.pushNamed(
                'booking-form',
                extra: {
                  'labId': _lab!.id,
                  'selectedDate': DateTime.now(),
                },
              );
            },
            icon: const Icon(Icons.add),
            tooltip: 'Book Lab',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Lab info card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.science,
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _lab!.name,
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _lab!.location,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Lab details
                    _buildInfoRow(
                      Icons.people,
                      'Capacity',
                      '${_lab!.capacity} people',
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      Icons.description,
                      'Description',
                      _lab!.description,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Schedule section
            Text(
              'Schedule',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            if (_events.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.event_available,
                          size: 48,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No events scheduled',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              ..._events.map((event) => _buildEventCard(event)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.pushNamed(
            'booking-form',
            extra: {
              'labId': _lab!.id,
              'selectedDate': DateTime.now(),
            },
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Book Lab'),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEventCard(Event event) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            Icons.event,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(event.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(event.description),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  '${_formatDateTime(event.start)} - ${_formatDateTime(event.end)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
        trailing: FilledButton(
          onPressed: () {
            context.pushNamed(
              'booking-form',
              extra: {
                'eventId': event.id,
                'labId': event.labId,
                'selectedDate': event.start,
                'selectedStartTime': event.start,
                'selectedEndTime': event.end,
              },
            );
          },
          child: const Text('Join'),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
