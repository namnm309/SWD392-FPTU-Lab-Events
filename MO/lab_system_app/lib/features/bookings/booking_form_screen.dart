import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/models/lab.dart';
import '../../domain/enums/repeat_rule.dart';
import '../../data/repositories/lab_repository.dart';
import '../../data/repositories/booking_repository.dart';
import '../../core/utils/result.dart';
import '../auth/auth_controller.dart';

class BookingFormScreen extends ConsumerStatefulWidget {
  final String? eventId;
  final String? labId;
  final DateTime? selectedDate;
  final DateTime? selectedStartTime;
  final DateTime? selectedEndTime;

  const BookingFormScreen({
    super.key,
    this.eventId,
    this.labId,
    this.selectedDate,
    this.selectedStartTime,
    this.selectedEndTime,
  });

  @override
  ConsumerState<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends ConsumerState<BookingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _participantsController = TextEditingController();
  final _notesController = TextEditingController();
  
  Lab? _selectedLab;
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  RepeatRule _repeatRule = RepeatRule.none;
  List<Lab> _labs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeForm();
    _loadLabs();
  }

  void _initializeForm() {
    _selectedDate = widget.selectedDate ?? DateTime.now();
    if (widget.selectedStartTime != null) {
      _startTime = TimeOfDay.fromDateTime(widget.selectedStartTime!);
    }
    if (widget.selectedEndTime != null) {
      _endTime = TimeOfDay.fromDateTime(widget.selectedEndTime!);
    }
  }

  Future<void> _loadLabs() async {
    final labRepository = LabRepository();
    await labRepository.init();
    
    final result = await labRepository.getAllLabs();
    if (result.isSuccess) {
      setState(() {
        _labs = result.data!;
        if (widget.labId != null) {
          _selectedLab = _labs.firstWhere(
            (lab) => lab.id == widget.labId,
            orElse: () => _labs.first,
          );
        }
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _selectStartTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _startTime ?? const TimeOfDay(hour: 9, minute: 0),
    );
    
    if (time != null) {
      setState(() {
        _startTime = time;
      });
    }
  }

  Future<void> _selectEndTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _endTime ?? const TimeOfDay(hour: 10, minute: 0),
    );
    
    if (time != null) {
      setState(() {
        _endTime = time;
      });
    }
  }

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedLab == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a lab')),
      );
      return;
    }
    
    if (_selectedDate == null || _startTime == null || _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select date and time')),
      );
      return;
    }

    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login first')),
      );
      return;
    }

    final startDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _startTime!.hour,
      _startTime!.minute,
    );
    
    final endDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _endTime!.hour,
      _endTime!.minute,
    );

    if (endDateTime.isBefore(startDateTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End time must be after start time')),
      );
      return;
    }

    final bookingRepository = BookingRepository();
    await bookingRepository.init();

    final result = await bookingRepository.createBooking(
      eventId: widget.eventId,
      labId: _selectedLab!.id,
      userId: currentUser.id,
      title: _titleController.text.trim(),
      date: _selectedDate!,
      start: startDateTime,
      end: endDateTime,
      repeatRule: _repeatRule.name,
      participants: int.tryParse(_participantsController.text) ?? 1,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    );

    if (result.isSuccess) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking created successfully')),
        );
        context.pop();
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

  @override
  void dispose() {
    _titleController.dispose();
    _participantsController.dispose();
    _notesController.dispose();
    super.dispose();
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Booking'),
        actions: [
          TextButton(
            onPressed: _submitBooking,
            child: const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Lab selection
            DropdownButtonFormField<Lab>(
              value: _selectedLab,
              decoration: const InputDecoration(
                labelText: 'Lab',
                prefixIcon: Icon(Icons.science),
              ),
              items: _labs.map((lab) {
                return DropdownMenuItem(
                  value: lab,
                  child: Text(lab.name),
                );
              }).toList(),
              onChanged: (lab) {
                setState(() {
                  _selectedLab = lab;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select a lab';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Activity Title',
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Title is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Date selection
            InkWell(
              onTap: _selectDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  _selectedDate != null
                      ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                      : 'Select date',
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Time selection
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _selectStartTime,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Start Time',
                        prefixIcon: Icon(Icons.access_time),
                      ),
                      child: Text(
                        _startTime != null
                            ? _startTime!.format(context)
                            : 'Select start time',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: _selectEndTime,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'End Time',
                        prefixIcon: Icon(Icons.access_time),
                      ),
                      child: Text(
                        _endTime != null
                            ? _endTime!.format(context)
                            : 'Select end time',
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Participants
            TextFormField(
              controller: _participantsController,
              decoration: const InputDecoration(
                labelText: 'Number of Participants',
                prefixIcon: Icon(Icons.people),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Number of participants is required';
                }
                final participants = int.tryParse(value);
                if (participants == null || participants < 1) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Repeat rule
            DropdownButtonFormField<RepeatRule>(
              value: _repeatRule,
              decoration: const InputDecoration(
                labelText: 'Repeat',
                prefixIcon: Icon(Icons.repeat),
              ),
              items: RepeatRule.values.map((rule) {
                return DropdownMenuItem(
                  value: rule,
                  child: Text(rule.displayName),
                );
              }).toList(),
              onChanged: (rule) {
                setState(() {
                  _repeatRule = rule!;
                });
              },
            ),
            const SizedBox(height: 16),
            
            // Notes
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 32),
            
            // Submit button
            FilledButton(
              onPressed: _submitBooking,
              child: const Text('Create Booking'),
            ),
          ],
        ),
      ),
    );
  }
}
