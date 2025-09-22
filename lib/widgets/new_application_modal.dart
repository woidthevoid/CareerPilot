import 'package:CareerPilot/services/job_applications_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:CareerPilot/models/job_application.dart';

class NewApplicationModal extends StatefulWidget {
  const NewApplicationModal({super.key});

  @override
  State<NewApplicationModal> createState() => _NewApplicationModalState();
}

class _NewApplicationModalState extends State<NewApplicationModal> {
  final _formKey = GlobalKey<FormState>();
  final _jobTitleController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _jobLinkController = TextEditingController();

  String _selectedStatus = 'not_applied';
  bool _isLoading = false;

  final List<String> _statusOptions = [
    'not_applied',
    'applied',
    'declined',
    'interview',
    'accepted'
  ];

  @override
  void dispose() {
    _jobTitleController.dispose();
    _companyNameController.dispose();
    _descriptionController.dispose();
    _jobLinkController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final provider = context.read<JobApplicationsProvider>();

      final newApplication = JobApplication(
        id: '',
        userId: '',
        title: _jobTitleController.text.trim(),
        companyName: _companyNameController.text.trim(),
        description: _descriptionController.text.trim(),
        jobLink: _jobLinkController.text.trim(),
        applicationStatus: _selectedStatus,
        createdAt: DateTime.now(),
      );

      await provider.addApplication(newApplication);

      if(mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Job application added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Add New Application',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),

          // Form content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Job Title
                    TextFormField(
                      controller: _jobTitleController,
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                      decoration: InputDecoration(
                        labelText: 'Job Title',
                        labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                        border: const OutlineInputBorder(),
                        prefixIcon: Icon(Icons.work, color: Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a job title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Company Name
                    TextFormField(
                      controller: _companyNameController,
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                      decoration: InputDecoration(
                        labelText: 'Company Name',
                        labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                        border: const OutlineInputBorder(),
                        prefixIcon: Icon(Icons.business, color: Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a company name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Status Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedStatus,
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                      decoration: InputDecoration(
                        labelText: 'Application Status',
                        labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                        border: const OutlineInputBorder(),
                        prefixIcon: Icon(Icons.flag, color: Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                      items: _statusOptions.map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(
                            status.replaceAll('_', ' ').toUpperCase(),
                            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedStatus = value!);
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Job Link (Optional)
                    TextFormField(
                      controller: _jobLinkController,
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                      decoration: InputDecoration(
                        labelText: 'Job Link (Optional)',
                        labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                        border: const OutlineInputBorder(),
                        prefixIcon: Icon(Icons.link, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        hintText: 'https://...',
                        hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.6)),
                      ),
                      keyboardType: TextInputType.url,
                    ),
                    const SizedBox(height: 16),
                    
                    // Description (Optional)
                    TextFormField(
                      controller: _descriptionController,
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                      decoration: InputDecoration(
                        labelText: 'Description (Optional)',
                        labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                        border: const OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        alignLabelWithHint: true,
                        hintText: 'Notes about this application...',
                        hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.6)),
                      ),
                      maxLines: 4,
                      maxLength: 500,
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
          
          // Submit button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      )
                    : const Text(
                        'Add Application',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}