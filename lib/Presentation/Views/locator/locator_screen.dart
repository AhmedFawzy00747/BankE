import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/locator/locator_bloc.dart';
import '../../bloc/locator/locator_event.dart';
import '../../bloc/locator/locator_state.dart';
import '../../../domain/entities/bank_location_entity.dart';

class LocatorScreen extends StatefulWidget {
  const LocatorScreen({super.key});

  @override
  State<LocatorScreen> createState() => _LocatorScreenState();
}

class _LocatorScreenState extends State<LocatorScreen> {
  bool _onlyAtms = false;
  bool _onlyBranches = false;
  bool _hasDeposit = false;

  void _applyFilters() {
    context.read<LocatorBloc>().add(FilterLocationsEvent(
      onlyAtms: _onlyAtms,
      onlyBranches: _onlyBranches,
      openNow: false,
      hasDeposit: _hasDeposit,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('ATM & Branch Locator', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Simulated Map Background
          _buildSimulatedMap(context),
          
          // Search & Filters Overlays
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: _buildSearchBar(context),
          ),
          
          // Bottom Sheet with List
          _buildDraggableList(context),
        ],
      ),
    );
  }

  Widget _buildSimulatedMap(BuildContext context) {
    return Container(
      color: const Color(0xFF0F172A), // Dark Navy
      child: Stack(
        children: [
          // Grid Pattern
          CustomPaint(
            painter: GridPainter(),
            size: Size.infinite,
          ),
          // Pulsating User Location
          const Center(
            child: _PulsatingDot(color: Colors.blue, size: 20),
          ),
          // Location Markers
          BlocBuilder<LocatorBloc, LocatorState>(
            builder: (context, state) {
              if (state is LocatorLoaded) {
                return Stack(
                  children: state.filteredLocations.map((loc) {
                    // Random-ish positioning for demo based on lat/lng diff
                    final top = 300 + (loc.lat - 40.7128) * 5000;
                    final left = 200 + (loc.lng - (-74.0060)) * 5000;
                    return Positioned(
                      top: top,
                      left: left,
                      child: _LocationMarker(location: loc),
                    );
                  }).toList(),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search for a city or zip code',
              prefixIcon: const Icon(Icons.search),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 15),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _filterChip('ATMs', _onlyAtms, (val) => setState(() { _onlyAtms = val; _onlyBranches = false; _applyFilters(); })),
              const SizedBox(width: 8),
              _filterChip('Branches', _onlyBranches, (val) => setState(() { _onlyBranches = val; _onlyAtms = false; _applyFilters(); })),
              const SizedBox(width: 8),
              _filterChip('Cash Deposit', _hasDeposit, (val) => setState(() { _hasDeposit = val; _applyFilters(); })),
            ],
          ),
        ),
      ],
    );
  }

  Widget _filterChip(String label, bool selected, Function(bool) onSelected) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      selectedColor: Theme.of(context).primaryColor,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(color: selected ? Colors.white : Colors.grey, fontWeight: FontWeight.bold),
      backgroundColor: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  Widget _buildDraggableList(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.3,
      minChildSize: 0.1,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 20)],
          ),
          child: BlocBuilder<LocatorBloc, LocatorState>(
            builder: (context, state) {
              if (state is LocatorLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is LocatorLoaded) {
                return ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  itemCount: state.filteredLocations.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Column(
                        children: [
                          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${state.filteredLocations.length} Locations Near You', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                              const Icon(Icons.sort),
                            ],
                          ),
                          const SizedBox(height: 24),
                        ],
                      );
                    }
                    final loc = state.filteredLocations[index - 1];
                    return _LocationTile(location: loc);
                  },
                );
              }
              return const Center(child: Text('Search for nearby locations'));
            },
          ),
        );
      },
    );
  }
}

class _LocationMarker extends StatelessWidget {
  final BankLocationEntity location;
  const _LocationMarker({required this.location});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
          ),
          child: Text(location.name, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black)),
        ),
        const SizedBox(height: 4),
        Icon(
          location.type == LocationType.atm ? Icons.atm : Icons.account_balance,
          color: location.type == LocationType.atm ? Colors.tealAccent : Colors.amberAccent,
          size: 30,
        ),
      ],
    );
  }
}

class _LocationTile extends StatelessWidget {
  final BankLocationEntity location;
  const _LocationTile({required this.location});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: (location.type == LocationType.atm ? Colors.teal : Colors.amber).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              location.type == LocationType.atm ? Icons.atm : Icons.account_balance,
              color: location.type == LocationType.atm ? Colors.teal : Colors.amber,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(location.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(location.address, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (location.isOpen247) 
                      _tag('24/7', Colors.green),
                    if (location.hasCashDeposit)
                      _tag('Cash Deposit', Colors.blue),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${location.distance.toStringAsFixed(1)} km', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
              const SizedBox(height: 4),
              const Text('Open', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tag(String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 4),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
      child: Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}

class _PulsatingDot extends StatefulWidget {
  final Color color;
  final double size;
  const _PulsatingDot({required this.color, required this.size});

  @override
  State<_PulsatingDot> createState() => _PulsatingDotState();
}

class _PulsatingDotState extends State<_PulsatingDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.size * (1 + _controller.value * 2),
          height: widget.size * (1 + _controller.value * 2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color.withOpacity(1 - _controller.value),
          ),
          child: Center(
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(shape: BoxShape.circle, color: widget.color, border: Border.all(color: Colors.white, width: 2)),
            ),
          ),
        );
      },
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1.0;

    const double step = 40.0;
    for (double i = 0; i < size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += step) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
