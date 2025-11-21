import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/access_log.dart';
import '../services/supabase_service.dart';

class AccessLogsScreen extends StatefulWidget {
  const AccessLogsScreen({super.key});

  @override
  _AccessLogsScreenState createState() => _AccessLogsScreenState();
}

class _AccessLogsScreenState extends State<AccessLogsScreen> {
  List<AccessLog> accessLogs = [];
  List<AccessLog> filteredAccessLogs = [];
  bool isLoading = true;
  String? errorMessage;

  // Filter variables
  String _nameFilter = '';
  String _companyFilter = '';
  String _floorFilter = '';
  String _tagIdFilter = '';

  @override
  void initState() {
    super.initState();
    _loadAccessLogs();
  }

  Future<void> _loadAccessLogs() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final logs = await SupabaseService.getAccessLogs();
      setState(() {
        accessLogs = logs;
        _applyFilters();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  void _applyFilters() {
    List<AccessLog> result = accessLogs;

    if (_nameFilter.isNotEmpty) {
      result = result.where((log) =>
          (log.name?.toLowerCase().contains(_nameFilter.toLowerCase()) ?? false)
      ).toList();
    }

    if (_companyFilter.isNotEmpty) {
      result = result.where((log) =>
          (log.company?.toLowerCase().contains(_companyFilter.toLowerCase()) ?? false)
      ).toList();
    }

    if (_floorFilter.isNotEmpty) {
      result = result.where((log) =>
          (log.floor?.toLowerCase().contains(_floorFilter.toLowerCase()) ?? false)
      ).toList();
    }

    if (_tagIdFilter.isNotEmpty) {
      result = result.where((log) =>
          (log.tagId?.toLowerCase().contains(_tagIdFilter.toLowerCase()) ?? false)
      ).toList();
    }

    setState(() {
      filteredAccessLogs = result;
    });
  }

  void _showFilterDialog() {
    TextEditingController nameController = TextEditingController(text: _nameFilter);
    TextEditingController companyController = TextEditingController(text: _companyFilter);
    TextEditingController floorController = TextEditingController(text: _floorFilter);
    TextEditingController tagIdController = TextEditingController(text: _tagIdFilter);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Filter Access Logs'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: companyController,
                decoration: const InputDecoration(
                  labelText: 'Company',
                  prefixIcon: Icon(Icons.business),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: floorController,
                decoration: const InputDecoration(
                  labelText: 'Floor',
                  prefixIcon: Icon(Icons.layers),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: tagIdController,
                decoration: const InputDecoration(
                  labelText: 'Tag ID',
                  prefixIcon: Icon(Icons.tag),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Clear all filters
                nameController.clear();
                companyController.clear();
                floorController.clear();
                tagIdController.clear();
              },
              child: const Text('Clear'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _nameFilter = nameController.text;
                  _companyFilter = companyController.text;
                  _floorFilter = floorController.text;
                  _tagIdFilter = tagIdController.text;
                });
                _applyFilters();
                Navigator.of(context).pop();
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }

  Map<String, List<AccessLog>> _groupByDate(List<AccessLog> logs) {
    Map<String, List<AccessLog>> groupedLogs = {};

    for (AccessLog log in logs) {
      String date = DateFormat('yyyy-MM-dd').format(log.createdAt);
      if (!groupedLogs.containsKey(date)) {
        groupedLogs[date] = [];
      }
      groupedLogs[date]!.add(log);
    }

    // Sort dates in descending order (newest first)
    List<String> sortedKeys = groupedLogs.keys.toList()
      ..sort((a, b) => DateTime.parse(b).compareTo(DateTime.parse(a)));

    Map<String, List<AccessLog>> sortedGroupedLogs = {};
    for (String date in sortedKeys) {
      sortedGroupedLogs[date] = groupedLogs[date]!;
    }

    return sortedGroupedLogs;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Access Logs'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Access Logs'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading data',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage ?? '',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadAccessLogs,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    Map<String, List<AccessLog>> groupedLogs = _groupByDate(filteredAccessLogs);

    String activeFilters = _getActiveFiltersText();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Access Logs'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (activeFilters.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 14.0),
              child: Text(
                activeFilters,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: _showFilterDialog,
            tooltip: 'Filters',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAccessLogs,
          ),
        ],
      ),
      body: groupedLogs.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.list_alt_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No access logs found',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  if (_nameFilter.isNotEmpty || _companyFilter.isNotEmpty || _floorFilter.isNotEmpty || _tagIdFilter.isNotEmpty)
                    Text(
                      'Try adjusting your filters',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadAccessLogs,
              child: ListView.builder(
                itemCount: groupedLogs.keys.length,
                itemBuilder: (context, index) {
                  String date = groupedLogs.keys.elementAt(index);
                  List<AccessLog> logsForDate = groupedLogs[date]!;

                  return Card(
                    margin: const EdgeInsets.all(10),
                    child: ExpansionTile(
                      title: Text(
                        DateFormat('EEEE, MMMM d, yyyy').format(DateTime.parse(date)),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text('${logsForDate.length} entries'),
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: logsForDate.length,
                          itemBuilder: (context, logIndex) {
                            AccessLog log = logsForDate[logIndex];
                            return ListTile(
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Icon(
                                  Icons.person,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              title: Text(
                                log.name ?? 'Unknown',
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (log.company != null && log.company!.isNotEmpty)
                                    Text('Company: ${log.company!}'),
                                  if (log.floor != null && log.floor!.isNotEmpty)
                                    Text('Floor: ${log.floor!}'),
                                  if (log.tagId != null && log.tagId!.isNotEmpty)
                                    Text('Tag ID: ${log.tagId!}'),
                                ],
                              ),
                              trailing: Text(
                                DateFormat('HH:mm').format(log.createdAt),
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }

  String _getActiveFiltersText() {
    List<String> activeFilters = [];

    if (_nameFilter.isNotEmpty) activeFilters.add('Name');
    if (_companyFilter.isNotEmpty) activeFilters.add('Company');
    if (_floorFilter.isNotEmpty) activeFilters.add('Floor');
    if (_tagIdFilter.isNotEmpty) activeFilters.add('Tag ID');

    if (activeFilters.isEmpty) return '';

    return '${activeFilters.length} filter${activeFilters.length > 1 ? 's' : ''} active';
  }
}