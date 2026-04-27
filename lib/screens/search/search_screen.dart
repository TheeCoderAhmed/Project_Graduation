import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_routes.dart';
import '../../constants/app_theme.dart';
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
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.containerMargin),
              child: Text('Search', style: GoogleFonts.manrope(
                fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
              )),
            ),
            const SizedBox(height: 16),
            // Search field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.containerMargin),
              child: TextField(
                controller: _ctrl,
                autofocus: false,
                style: GoogleFonts.inter(fontSize: 15, color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Search doctors, pharmacies...',
                  hintStyle: GoogleFonts.inter(color: AppColors.outline, fontSize: 15),
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.outline),
                  suffixIcon: _ctrl.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, color: AppColors.outline),
                          onPressed: () {
                            _ctrl.clear();
                            _debounce?.cancel();
                            context.read<ProviderProvider>().search('');
                            setState(() {});
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    borderSide: const BorderSide(color: AppColors.divider),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    borderSide: const BorderSide(color: AppColors.divider),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
                onChanged: (v) {
                  setState(() {});
                  _onSearchChanged(v);
                },
              ),
            ),
            const SizedBox(height: 16),
            // Filter chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.containerMargin),
              child: Row(
                children: ['all', 'doctor', 'pharmacy'].map((f) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(
                      f == 'all' ? 'All' : f == 'doctor' ? 'Doctors' : 'Pharmacies',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _filter == f ? AppColors.primary : AppColors.textSecondary,
                      ),
                    ),
                    selected: _filter == f,
                    selectedColor: AppColors.primary.withValues(alpha: 0.12),
                    backgroundColor: AppColors.surfaceContainer,
                    side: _filter == f
                        ? const BorderSide(color: AppColors.primary)
                        : BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                    ),
                    showCheckmark: false,
                    onSelected: (_) => setState(() => _filter = f),
                  ),
                )).toList(),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: provState.isLoading
                  ? const LoadingIndicator()
                  : _ctrl.text.isEmpty
                      ? _buildEmptySearch()
                      : results.isEmpty
                          ? _buildNoResults()
                          : ListView.builder(
                              padding: const EdgeInsets.only(bottom: 100),
                              itemCount: results.length,
                              itemBuilder: (_, i) => ProviderCard(
                                provider: results[i],
                                onTap: () => Navigator.pushNamed(
                                  context, AppRoutes.providerProfile,
                                  arguments: results[i].providerId,
                                ),
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptySearch() {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.search_rounded, size: 64, color: AppColors.divider),
        const SizedBox(height: 16),
        Text('Search for doctors or pharmacies',
          style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 15)),
      ]),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.search_off_rounded, size: 64, color: AppColors.divider),
        const SizedBox(height: 16),
        Text('No results for "${_ctrl.text}"',
          style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 15)),
        const SizedBox(height: 8),
        Text('Try a different name or specialty',
          style: GoogleFonts.inter(color: AppColors.outline, fontSize: 13)),
      ]),
    );
  }
}
