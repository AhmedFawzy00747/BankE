import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../bloc/transaction_bloc.dart';
import '../../bloc/transaction_state.dart';
import '../../bloc/savings_goal/savings_goal_bloc.dart';
import '../../widgets/analytics_helper.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_view.dart';
import '../../../domain/entities/savings_goal.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Financial Insights', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: "Spending"),
            Tab(text: "Comparison"),
            Tab(text: "Savings Goals"),
          ],
        ),
      ),
      body: BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, state) {
          if (state is TransactionLoading) return const AppLoadingView();
          if (state is TransactionLoaded) {
            return TabBarView(
              controller: _tabController,
              children: [
                _buildSpendingView(context, state),
                _buildComparisonView(context, state),
                _buildSavingsGoalsView(context),
              ],
            );
          }
          return const Center(child: Text('Error loading analytics'));
        },
      ),
    );
  }

  Widget _buildSpendingView(BuildContext context, TransactionLoaded state) {
    final categoryTotals = AnalyticsHelper.getExpensesByCategory(state.transactions);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildPieChart(categoryTotals),
          const SizedBox(height: 32),
          _buildLegend(context, categoryTotals),
        ],
      ),
    );
  }

  Widget _buildComparisonView(BuildContext context, TransactionLoaded state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Income vs Expenses', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 24),
          _buildBarChart(context),
          const SizedBox(height: 32),
          _buildBudgetAlert(context),
        ],
      ),
    );
  }

  Widget _buildSavingsGoalsView(BuildContext context) {
    return BlocBuilder<SavingsGoalBloc, SavingsGoalState>(
      builder: (context, state) {
        if (state.isLoading) return const Center(child: CircularProgressIndicator());
        return ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: state.goals.length,
          itemBuilder: (context, index) => _GoalCard(goal: state.goals[index]),
        );
      },
    );
  }

  Widget _buildBarChart(BuildContext context) {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(16)),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 5000,
          barGroups: [
            BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 4200, color: Colors.green, width: 16)]),
            BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 3100, color: Colors.redAccent, width: 16)]),
          ],
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) => Text(value == 0 ? 'Income' : 'Expense', style: const TextStyle(fontSize: 10)),
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  Widget _buildBudgetAlert(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.orange),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'You have spent 85% of your dining budget for this month.',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart(Map<SpendingCategory, double> data) {
    final sections = data.entries.where((e) => e.value > 0).map((e) {
      return PieChartSectionData(value: e.value, color: Color(e.key.color), radius: 50, title: '');
    }).toList();
    return SizedBox(
      height: 200,
      child: PieChart(PieChartData(sections: sections, centerSpaceRadius: 60)),
    );
  }

  Widget _buildLegend(BuildContext context, Map<SpendingCategory, double> data) {
    return Column(
      children: data.entries.where((e) => e.value > 0).map((e) {
        return ListTile(
          leading: CircleAvatar(backgroundColor: Color(e.key.color), radius: 6),
          title: Text(e.key.name),
          trailing: Text('\$${e.value.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
        );
      }).toList(),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final SavingsGoalEntity goal;
  const _GoalCard({required this.goal});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Row(
            children: [
              Text(goal.icon, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(goal.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('\$${goal.currentAmount.toInt()} of \$${goal.targetAmount.toInt()}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              Text('${(goal.progress * 100).toInt()}%', style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: goal.progress,
            backgroundColor: theme.primaryColor.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation(theme.primaryColor),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${goal.daysRemaining} days left', style: const TextStyle(color: Colors.grey, fontSize: 11)),
              const Text('Add Funds', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}
