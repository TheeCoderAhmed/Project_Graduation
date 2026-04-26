import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_routes.dart';
import '../../providers/provider_provider.dart';
import '../../widgets/provider_card.dart';
import '../../widgets/common/loading_indicator.dart';
import 'package:provider/provider.dart';
import 'dart:async';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctrl = TextEditingController();
  String _filter = 'all';
  Timer? _debounce;

  @override
  void dispose() {
    _ctrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    // Cancel previous timer on every keystroke
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      context.read<ProviderProvider>().search(value.trim());
    });
  }

  @override
  Widget build(BuildContext context) {
    final provState = context.watch<ProviderProvider>();
    final results = provState.searchResults.where((p) {
      if (_filter == 'all') return true;
      return p.type == _filter;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _ctrl,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search doctors, pharmacies...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _ctrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _ctrl.clear();
                          _debounce?.cancel();
                          context.read<ProviderProvider>().search('');
                        },
                      )
                    : null,
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: ['all', 'doctor', 'pharmacy'].map((f) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(f == 'all' ? 'All' : f == 'doctor' ? 'Doctors' : 'Pharmacies'),
                  selected: _filter == f,
                  selectedColor: AppColors.primary.withValues(alpha: 0.15),
                  checkmarkColor: AppColors.primary,
                  onSelected: (_) => setState(() => _filter = f),
                ),
              )).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: provState.isLoading
                ? const LoadingIndicator()
                : _ctrl.text.isEmpty
                    ? _buildEmptySearch()
                    : results.isEmpty
                        ? _buildNoResults()
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: results.length,
                            itemBuilder: (_, i) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: ProviderCard(
                                provider: results[i],
                                onTap: () => Navigator.pushNamed(
                                  context, AppRoutes.providerProfile,
                                  arguments: results[i].providerId,
                                ),
                              ),
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySearch() {
    return const Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.search, size: 64, color: AppColors.divider),
        SizedBox(height: 16),
        Text('Search for doctors or pharmacies',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 15)),
      ]),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.search_off, size: 64, color: AppColors.divider),
        const SizedBox(height: 16),
        Text('No results for "${_ctrl.text}"',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 15)),
        const SizedBox(height: 8),
        const Text('Try a different name or specialty',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
      ]),
    );
  }
}
