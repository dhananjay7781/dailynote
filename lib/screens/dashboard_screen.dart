import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:dailynote/models/note.dart';
import 'package:dailynote/services/cross_platform_database.dart';

// Dashboard view types
enum DashboardView { overview, pieChart, barChart, lineChart, statistics }

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  final CrossPlatformDatabaseHelper _dbHelper = CrossPlatformDatabaseHelper.instance;
  
  List<Note> _allNotes = [];
  List<Note> _filteredNotes = [];
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  
  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  DashboardView _currentView = DashboardView.overview;
  
  // Statistics
  Map<NoteStatus, int> _statusCounts = {};
  Map<String, int> _categoryCounts = {};
  Map<DateTime, int> _dailyCounts = {};
  double _completionRate = 0.0;
  int _totalNotes = 0;
  int _completedThisWeek = 0;
  int _completedThisMonth = 0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadDashboardData();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    final notes = await _dbHelper.getAllNotes();
    _filterNotesByDateRange(notes);
    _calculateStatistics();
    setState(() {});
  }

  void _filterNotesByDateRange(List<Note> notes) {
    _allNotes = notes;
    _filteredNotes = notes.where((note) {
      final noteDate = DateTime(
        note.createdAt.year,
        note.createdAt.month,
        note.createdAt.day,
      );
      final startDate = DateTime(_startDate.year, _startDate.month, _startDate.day);
      final endDate = DateTime(_endDate.year, _endDate.month, _endDate.day);
      
      return (noteDate.isAfter(startDate) || noteDate.isAtSameMomentAs(startDate)) &&
             (noteDate.isBefore(endDate) || noteDate.isAtSameMomentAs(endDate));
    }).toList();
  }

  void _calculateStatistics() {
    _statusCounts.clear();
    _categoryCounts.clear();
    _dailyCounts.clear();
    
    _totalNotes = _filteredNotes.length;
    
    // Status counts
    for (var note in _filteredNotes) {
      _statusCounts[note.status] = (_statusCounts[note.status] ?? 0) + 1;
      
      // Category counts
      if (note.category.name.isNotEmpty) {
        _categoryCounts[note.category.name] = (_categoryCounts[note.category.name] ?? 0) + 1;
      }
      
      // Daily counts
      final day = DateTime(note.createdAt.year, note.createdAt.month, note.createdAt.day);
      _dailyCounts[day] = (_dailyCounts[day] ?? 0) + 1;
    }
    
    // Completion rate
    final completed = _statusCounts[NoteStatus.completed] ?? 0;
    _completionRate = _totalNotes > 0 ? completed / _totalNotes * 100 : 0.0;
    
    // Weekly and monthly completed tasks
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final monthStart = DateTime(now.year, now.month, 1);
    
    _completedThisWeek = _allNotes.where((note) => 
      note.status == NoteStatus.completed && 
      note.createdAt.isAfter(weekStart)
    ).length;
    
    _completedThisMonth = _allNotes.where((note) => 
      note.status == NoteStatus.completed && 
      note.createdAt.isAfter(monthStart)
    ).length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            children: [
              _buildDateRangeSelector(),
              _buildViewSelector(),
              Expanded(child: _buildCurrentView()),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.purple, Colors.pink],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      title: const Row(
        children: [
          Icon(Icons.dashboard, color: Colors.white, size: 28),
          SizedBox(width: 12),
          Text(
            'Dashboard',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: _loadDashboardData,
          icon: const Icon(Icons.refresh, color: Colors.white),
          tooltip: 'Refresh Data',
        ),
      ],
    );
  }

  Widget _buildDateRangeSelector() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Date Range Filter',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDateSelector(
                  'From',
                  _startDate,
                  (date) {
                    setState(() {
                      _startDate = date;
                    });
                    _filterNotesByDateRange(_allNotes);
                    _calculateStatistics();
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDateSelector(
                  'To',
                  _endDate,
                  (date) {
                    setState(() {
                      _endDate = date;
                    });
                    _filterNotesByDateRange(_allNotes);
                    _calculateStatistics();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector(String label, DateTime date, Function(DateTime) onChanged) {
    return GestureDetector(
      onTap: () async {
        final selectedDate = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        if (selectedDate != null) {
          onChanged(selectedDate);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('MMM dd, yyyy').format(date),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewSelector() {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: DashboardView.values.map((view) {
          final isSelected = _currentView == view;
          return Container(
            margin: const EdgeInsets.only(right: 12),
            child: FilterChip(
              label: Text(_getViewName(view)),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _currentView = view;
                });
              },
              backgroundColor: Colors.white,
              selectedColor: Colors.blue.withOpacity(0.2),
              checkmarkColor: Colors.blue,
              labelStyle: TextStyle(
                color: isSelected ? Colors.blue : Colors.black87,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              elevation: isSelected ? 4 : 2,
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getViewName(DashboardView view) {
    switch (view) {
      case DashboardView.overview:
        return 'Overview';
      case DashboardView.pieChart:
        return 'Pie Chart';
      case DashboardView.barChart:
        return 'Bar Chart';
      case DashboardView.lineChart:
        return 'Line Chart';
      case DashboardView.statistics:
        return 'Statistics';
    }
  }

  Widget _buildCurrentView() {
    switch (_currentView) {
      case DashboardView.overview:
        return _buildOverviewView();
      case DashboardView.pieChart:
        return _buildPieChartView();
      case DashboardView.barChart:
        return _buildBarChartView();
      case DashboardView.lineChart:
        return _buildLineChartView();
      case DashboardView.statistics:
        return _buildStatisticsView();
    }
  }

  Widget _buildOverviewView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildOverviewCards(),
          const SizedBox(height: 20),
          _buildMiniPieChart(),
          const SizedBox(height: 20),
          _buildRecentActivity(),
        ],
      ),
    );
  }

  Widget _buildOverviewCards() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildOverviewCard(
          'Total Notes',
          _totalNotes.toString(),
          Icons.note_alt,
          Colors.blue,
        ),
        _buildOverviewCard(
          'Completion Rate',
          '${_completionRate.toStringAsFixed(1)}%',
          Icons.check_circle,
          Colors.green,
        ),
        _buildOverviewCard(
          'This Week',
          _completedThisWeek.toString(),
          Icons.date_range,
          Colors.orange,
        ),
        _buildOverviewCard(
          'This Month',
          _completedThisMonth.toString(),
          Icons.calendar_month,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildOverviewCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMiniPieChart() {
    if (_statusCounts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Status Distribution',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              constraints: const BoxConstraints(
                maxHeight: 220,
                maxWidth: 220,
              ),
              child: PieChart(
                PieChartData(
                  sections: _buildMiniPieChartSections(),
                  sectionsSpace: 2,
                  centerSpaceRadius: 35,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChartView() {
    if (_statusCounts.isEmpty) {
      return const Center(
        child: Text(
          'No data available for the selected date range',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        height: 400,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            const Text(
              'Task Status Distribution',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: PieChart(
                PieChartData(
                  sections: _buildPieChartSections(),
                  sectionsSpace: 4,
                  centerSpaceRadius: 50,
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildPieChartLegend(),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections() {
    final colors = {
      NoteStatus.newNote: Colors.purple,
      NoteStatus.inProgress: Colors.orange,
      NoteStatus.completed: Colors.green,
      NoteStatus.hold: Colors.blue,
    };

    return _statusCounts.entries.map((entry) {
      final percentage = (entry.value / _totalNotes * 100);
      return PieChartSectionData(
        value: entry.value.toDouble(),
        title: '${percentage.toStringAsFixed(1)}%',
        color: colors[entry.key] ?? Colors.grey,
        radius: 100,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  List<PieChartSectionData> _buildMiniPieChartSections() {
    final colors = {
      NoteStatus.newNote: Colors.purple,
      NoteStatus.inProgress: Colors.orange,
      NoteStatus.completed: Colors.green,
      NoteStatus.hold: Colors.blue,
    };

    return _statusCounts.entries.map((entry) {
      final percentage = (entry.value / _totalNotes * 100);
      return PieChartSectionData(
        value: entry.value.toDouble(),
        title: '${percentage.toStringAsFixed(0)}%',
        color: colors[entry.key] ?? Colors.grey,
        radius: 70,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildPieChartLegend() {
    final statusNames = {
      NoteStatus.newNote: 'New',
      NoteStatus.inProgress: 'In Progress',
      NoteStatus.completed: 'Completed',
      NoteStatus.hold: 'On Hold',
    };

    final colors = {
      NoteStatus.newNote: Colors.purple,
      NoteStatus.inProgress: Colors.orange,
      NoteStatus.completed: Colors.green,
      NoteStatus.hold: Colors.blue,
    };

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: _statusCounts.entries.map((entry) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: colors[entry.key],
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${statusNames[entry.key]} (${entry.value})',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildBarChartView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        height: 400,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            const Text(
              'Daily Notes Creation',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SfCartesianChart(
                primaryXAxis: const DateTimeAxis(),
                primaryYAxis: const NumericAxis(),
                series: <CartesianSeries>[
                  ColumnSeries<MapEntry<DateTime, int>, DateTime>(
                    dataSource: _dailyCounts.entries.toList(),
                    xValueMapper: (MapEntry<DateTime, int> data, _) => data.key,
                    yValueMapper: (MapEntry<DateTime, int> data, _) => data.value,
                    color: Colors.blue,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChartView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        height: 400,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            const Text(
              'Notes Trend Over Time',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SfCartesianChart(
                primaryXAxis: const DateTimeAxis(),
                primaryYAxis: const NumericAxis(),
                series: <CartesianSeries>[
                  LineSeries<MapEntry<DateTime, int>, DateTime>(
                    dataSource: _dailyCounts.entries.toList(),
                    xValueMapper: (MapEntry<DateTime, int> data, _) => data.key,
                    yValueMapper: (MapEntry<DateTime, int> data, _) => data.value,
                    color: Colors.purple,
                    width: 3,
                    markerSettings: const MarkerSettings(
                      isVisible: true,
                      color: Colors.purple,
                      borderColor: Colors.white,
                      borderWidth: 2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildStatCard('Total Notes Created', _totalNotes.toString(), Icons.note_add),
          const SizedBox(height: 16),
          _buildStatCard('Average Completion Rate', '${_completionRate.toStringAsFixed(1)}%', Icons.trending_up),
          const SizedBox(height: 16),
          _buildStatCard('Most Productive Day', _getMostProductiveDay(), Icons.calendar_today),
          const SizedBox(height: 16),
          _buildStatCard('Most Used Category', _getMostUsedCategory(), Icons.category),
          const SizedBox(height: 16),
          if (_categoryCounts.isNotEmpty) _buildCategoryBreakdown(),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.blue, size: 32),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getMostProductiveDay() {
    if (_dailyCounts.isEmpty) return 'No data';
    
    final maxEntry = _dailyCounts.entries.reduce((a, b) => a.value > b.value ? a : b);
    return DateFormat('MMM dd, yyyy').format(maxEntry.key);
  }

  String _getMostUsedCategory() {
    if (_categoryCounts.isEmpty) return 'No categories';
    
    final maxEntry = _categoryCounts.entries.reduce((a, b) => a.value > b.value ? a : b);
    return maxEntry.key;
  }

  Widget _buildCategoryBreakdown() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Category Breakdown',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ..._categoryCounts.entries.map((entry) {
            final percentage = (entry.value / _totalNotes * 100);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entry.key,
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    '${entry.value} (${percentage.toStringAsFixed(1)}%)',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    final recentNotes = _filteredNotes
        .where((note) => note.createdAt.isAfter(DateTime.now().subtract(const Duration(days: 7))))
        .take(5)
        .toList();

    if (recentNotes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Activity',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ...recentNotes.map((note) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Icon(
                  _getStatusIcon(note.status),
                  color: _getStatusColor(note.status),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    note.content.length > 50 
                        ? '${note.content.substring(0, 50)}...'
                        : note.content,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                Text(
                  DateFormat('MMM dd').format(note.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  IconData _getStatusIcon(NoteStatus status) {
    switch (status) {
      case NoteStatus.newNote:
        return Icons.fiber_new;
      case NoteStatus.inProgress:
        return Icons.access_time;
      case NoteStatus.completed:
        return Icons.check_circle;
      case NoteStatus.hold:
        return Icons.pause_circle;
      case NoteStatus.deleted:
        return Icons.delete;
    }
  }

  Color _getStatusColor(NoteStatus status) {
    switch (status) {
      case NoteStatus.newNote:
        return Colors.purple;
      case NoteStatus.inProgress:
        return Colors.orange;
      case NoteStatus.completed:
        return Colors.green;
      case NoteStatus.hold:
        return Colors.blue;
      case NoteStatus.deleted:
        return Colors.red;
    }
  }
}