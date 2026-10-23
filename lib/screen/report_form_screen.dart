import 'package:flutter/material.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';

enum ReportUiState { idle, loading, success, empty, error }

class Report {
  final String title;
  final String category;
  final String description;
  const Report(this.title, this.category, this.description);
}

class ReportFormScreen extends StatefulWidget {
  const ReportFormScreen({super.key});

  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  final List<String> _categories = ['Infrastructure', 'Safety', 'Sanitation', 'Other'];
  String _category = 'Infrastructure';

  ReportUiState _uiState = ReportUiState.idle;
  bool _simulateFailure = false; // switch ON = demo ERROR state
  bool _showList = false; // false = New Report tab, true = My Reports tab
  final List<Report> _reports = [];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _locationCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  // SIMULATED async submit (no real API/database yet)
  Future<void> submitReport() async {
    if (_uiState == ReportUiState.loading) return; // prevent duplicates
    if (!_formKey.currentState!.validate()) return;

    setState(() => _uiState = ReportUiState.loading);
    try {
      await Future<void>.delayed(const Duration(seconds: 3));
      if (_simulateFailure) throw Exception('Simulated failure');
      if (!mounted) return;
      _reports.add(Report(_titleCtrl.text.trim(), _category, _descCtrl.text.trim()));
      setState(() => _uiState = ReportUiState.success);
    } catch (_) {
      if (!mounted) return;
      setState(() => _uiState = ReportUiState.error);
    }
  }

  void _resetForm() {
    _titleCtrl.clear();
    _locationCtrl.clear();
    _descCtrl.clear();
    setState(() => _uiState = ReportUiState.idle);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report Form')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: false, label: Text('New Report'), icon: Icon(Icons.edit)),
                    ButtonSegment(value: true, label: Text('My Reports'), icon: Icon(Icons.list)),
                  ],
                  selected: {_showList},
                  onSelectionChanged: (s) => setState(() => _showList = s.first),
                ),
                const SizedBox(height: 16),
                _showList ? _buildReportList() : _buildFormArea(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormArea() {
    switch (_uiState) {
      case ReportUiState.success:
        return _successView();
      case ReportUiState.error:
        return _errorView();
      default:
        return _formView(); // idle + loading
    }
  }

  Widget _formView() {
    final loading = _uiState == ReportUiState.loading;
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            label: 'Report Title',
            controller: _titleCtrl,
            enabled: !loading,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Title is required';
              if (v.trim().length < 5) return 'Title must be at least 5 characters';
              return null;
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _category,
            decoration: const InputDecoration(
              labelText: 'Category',
              border: OutlineInputBorder(),
            ),
            items: _categories
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: loading ? null : (v) => setState(() => _category = v!),
          ),
          const SizedBox(height: 12),
          AppTextField(
            label: 'Location',
            controller: _locationCtrl,
            enabled: !loading,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Location is required' : null,
          ),
          const SizedBox(height: 12),
          AppTextField(
            label: 'Description',
            controller: _descCtrl,
            maxLines: 4,
            enabled: !loading,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Description is required';
              if (v.trim().length < 10) return 'Please enter at least 10 characters';
              return null;
            },
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Simulate failure (demo ERROR state)'),
            value: _simulateFailure,
            onChanged: loading ? null : (v) => setState(() => _simulateFailure = v),
          ),
          const SizedBox(height: 8),
          if (loading) ...[
            const Center(child: CircularProgressIndicator()),
            const SizedBox(height: 8),
            const Center(child: Text('Submitting report... (simulated request)')),
            const SizedBox(height: 12),
          ],
          AppButton(
            label: 'Submit Report',
            icon: Icons.send,
            isLoading: loading,
            onPressed: submitReport,
          ),
        ],
      ),
    );
  }

  Widget _successView() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 64),
            const SizedBox(height: 12),
            Text('Report Submitted!', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('"${_reports.last.title}" was recorded (simulated - not saved to a database).',
                textAlign: TextAlign.center),
            const SizedBox(height: 20),
            AppButton(
              label: 'View My Reports',
              icon: Icons.list,
              onPressed: () {
                _resetForm();
                setState(() => _showList = true);
              },
            ),
            const SizedBox(height: 8),
            AppButton(
              label: 'Submit Another Report',
              outlined: true,
              onPressed: _resetForm,
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorView() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.error, color: Colors.red, size: 64),
            const SizedBox(height: 12),
            Text('Submission Failed', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            const Text(
              'We could not submit your report (simulated failure). Please retry or edit your details.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            AppButton(
              label: 'Retry',
              icon: Icons.refresh,
              onPressed: () {
                setState(() {
                  _simulateFailure = false; // retry succeeds
                  _uiState = ReportUiState.idle; // rebuild the form so its key is attached
                });
                // wait one frame so the Form is mounted, then submit
                WidgetsBinding.instance.addPostFrameCallback((_) => submitReport());
              },
            ),
            const SizedBox(height: 8),
            AppButton(
              label: 'Edit Details',
              outlined: true,
              onPressed: () => setState(() => _uiState = ReportUiState.idle),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportList() {
    if (_reports.isEmpty) {
      // EMPTY state: no data (not an error or validation message)
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              const Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
              const SizedBox(height: 12),
              Text('No reports yet', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              const Text('You have not created any reports. Start by submitting one.',
                  textAlign: TextAlign.center),
              const SizedBox(height: 20),
              AppButton(
                label: 'Create a Report',
                icon: Icons.add,
                onPressed: () => setState(() => _showList = false),
              ),
            ],
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final r in _reports)
          Card(
            child: ListTile(
              leading: const Icon(Icons.description),
              title: Text(r.title),
              subtitle: Text('${r.category} • ${r.description}'),
            ),
          ),
        const SizedBox(height: 8),
        AppButton(
          label: 'Clear All Reports',
          outlined: true,
          icon: Icons.delete_outline,
          onPressed: () => setState(() => _reports.clear()),
        ),
      ],
    );
  }
}