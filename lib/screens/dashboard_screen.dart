import 'package:flutter/material.dart';
import '../main.dart';
import '../models/biometric_data.dart';
import '../models/journal_entry.dart';
import '../services/data_service.dart';
import '../services/decimation_service.dart';
import '../widgets/charts/hrv_chart.dart';
import '../widgets/charts/rhr_chart.dart';
import '../widgets/charts/steps_chart.dart';
import '../widgets/controls/range_selector.dart';
import '../widgets/controls/large_dataset_toggle.dart';
import '../widgets/states/loading_skeleton.dart';
import '../widgets/states/error_view.dart';
import '../widgets/states/empty_view.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DataService _dataService = DataService();
  final DecimationService _decimationService = DecimationService();

  List<BiometricData> _allData = [];
  List<BiometricData> _filteredData = [];
  List<BiometricData> _displayData = [];
  List<JournalEntry> _journals = [];

  DateRange _selectedRange = DateRange.sevenDays;
  DateTime? _selectedDate;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  bool _useLargeDataset = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      if (_useLargeDataset) {
        _allData = _dataService.generateLargeDataset(10000);
        _journals = [];
      } else {
        final results = await Future.wait([
          _dataService.loadBiometricData(),
          _dataService.loadJournalEntries(),
        ]);
        _allData = results[0] as List<BiometricData>;
        _journals = results[1] as List<JournalEntry>;
      }

      _filterDataByRange();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  void _filterDataByRange() {
    if (_allData.isEmpty) return;

    final now = _allData.last.date;
    DateTime startDate;

    switch (_selectedRange) {
      case DateRange.sevenDays:
        startDate = now.subtract(const Duration(days: 6));
        break;
      case DateRange.thirtyDays:
        startDate = now.subtract(const Duration(days: 29));
        break;
      case DateRange.ninetyDays:
        startDate = now.subtract(const Duration(days: 89));
        break;
    }

    setState(() {
      _filteredData = _allData
          .where(
            (d) =>
                d.date.isAfter(startDate) || d.date.isAtSameMomentAs(startDate),
          )
          .toList();

      if (_filteredData.length > 500) {
        _displayData = _decimationService.decimateLTTB(_filteredData, 500);
      } else {
        _displayData = _filteredData;
      }
    });
  }

  void _onRangeChanged(DateRange range) {
    setState(() {
      _selectedRange = range;
      _selectedDate = null;
    });
    _filterDataByRange();
  }

  void _onDateSelected(DateTime? date) {
    setState(() {
      _selectedDate = date;
    });
  }

  void _toggleLargeDataset(bool value) {
    setState(() {
      _useLargeDataset = value;
    });
    _loadData();
  }

  JournalEntry? _getJournalForDate(DateTime? date) {
    if (date == null) return null;
    try {
      return _journals.firstWhere(
        (j) =>
            j.date.year == date.year &&
            j.date.month == date.month &&
            j.date.day == date.day,
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Biometrics Dashboard'),
        actions: [
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () {
              final appState = MyApp.of(context);
              if (appState != null) {
                appState.toggleTheme();
              }
            },
            tooltip: 'Toggle theme',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: LoadingSkeleton(),
      );
    }

    if (_hasError) {
      return ErrorView(message: _errorMessage, onRetry: _loadData);
    }

    if (_allData.isEmpty) {
      return const EmptyView(
        message: 'No biometric data available',
        icon: Icons.favorite_border,
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 600) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: RangeSelector(
                        selectedRange: _selectedRange,
                        onRangeChanged: _onRangeChanged,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: LargeDatasetToggle(
                        isEnabled: _useLargeDataset,
                        onChanged: _toggleLargeDataset,
                      ),
                    ),
                  ],
                );
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RangeSelector(
                    selectedRange: _selectedRange,
                    onRangeChanged: _onRangeChanged,
                  ),
                  LargeDatasetToggle(
                    isEnabled: _useLargeDataset,
                    onChanged: _toggleLargeDataset,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          if (_selectedDate != null) _buildSelectedDateInfo(),

          if (_useLargeDataset)
            Card(
              color: Theme.of(context).colorScheme.secondaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 20,
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Large dataset: ${_allData.length} points → ${_displayData.length} displayed (LTTB decimation)',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (_useLargeDataset) const SizedBox(height: 16),

          HrvChart(
            data: _displayData,
            journals: _journals,
            selectedDate: _selectedDate,
            onDateSelected: _onDateSelected,
            showBands: !_useLargeDataset,
          ),
          const SizedBox(height: 16),
          RhrChart(
            data: _displayData,
            selectedDate: _selectedDate,
            onDateSelected: _onDateSelected,
          ),
          const SizedBox(height: 16),
          StepsChart(
            data: _displayData,
            selectedDate: _selectedDate,
            onDateSelected: _onDateSelected,
          ),
          const SizedBox(height: 24),

          _buildStats(),
        ],
      ),
    );
  }

  Widget _buildSelectedDateInfo() {
    final journal = _getJournalForDate(_selectedDate);
    final dataPoint = _filteredData.firstWhere(
      (d) =>
          d.date.year == _selectedDate!.year &&
          d.date.month == _selectedDate!.month &&
          d.date.day == _selectedDate!.day,
      orElse: () => _filteredData.first,
    );

    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Selected: ${_selectedDate!.month}/${_selectedDate!.day}/${_selectedDate!.year}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => _onDateSelected(null),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('HRV: ${dataPoint.hrv.toStringAsFixed(1)} ms'),
            Text('RHR: ${dataPoint.rhr} bpm'),
            Text('Steps: ${dataPoint.steps}'),
            if (journal != null) ...[
              const Divider(height: 24),
              Row(
                children: [
                  Text(journal.moodEmoji, style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      journal.note,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStats() {
    final avgHrv =
        _filteredData.map((d) => d.hrv).reduce((a, b) => a + b) /
        _filteredData.length;
    final avgRhr =
        _filteredData.map((d) => d.rhr).reduce((a, b) => a + b) /
        _filteredData.length;
    final avgSteps =
        _filteredData.map((d) => d.steps).reduce((a, b) => a + b) /
        _filteredData.length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Period Statistics',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 500) {
                  return Column(
                    children: [
                      _buildStatItem(
                        'Avg HRV',
                        avgHrv.toStringAsFixed(1),
                        'ms',
                        Icons.favorite,
                      ),
                      const SizedBox(height: 16),
                      _buildStatItem(
                        'Avg RHR',
                        avgRhr.toStringAsFixed(0),
                        'bpm',
                        Icons.monitor_heart,
                      ),
                      const SizedBox(height: 16),
                      _buildStatItem(
                        'Avg Steps',
                        avgSteps.toStringAsFixed(0),
                        'steps',
                        Icons.directions_walk,
                      ),
                    ],
                  );
                }

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      'Avg HRV',
                      avgHrv.toStringAsFixed(1),
                      'ms',
                      Icons.favorite,
                    ),
                    _buildStatItem(
                      'Avg RHR',
                      avgRhr.toStringAsFixed(0),
                      'bpm',
                      Icons.monitor_heart,
                    ),
                    _buildStatItem(
                      'Avg Steps',
                      avgSteps.toStringAsFixed(0),
                      'steps',
                      Icons.directions_walk,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    String unit,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(unit, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}
