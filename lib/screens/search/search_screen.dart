import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_routes.dart';
import '../../constants/app_theme.dart';
import '../../models/provider_model.dart';
import '../../providers/provider_provider.dart';
import '../../widgets/provider_card.dart';
import '../../widgets/common/loading_indicator.dart';
import 'package:provider/provider.dart';

enum SortOption {
  ratingDesc,
  reviewsDesc,
  nameAsc,
  nameDesc,
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctrl = TextEditingController();
  String _filter = 'all';
  SortOption _sort = SortOption.ratingDesc;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is String && args.isNotEmpty) {
        final lower = args.toLowerCase();
        if (lower == 'pharmacy') {
          setState(() => _filter = 'pharmacy');
          context.read<ProviderProvider>().search('');
        } else if (['cardiologist', 'pediatrics', 'dermatology', 'neurology', 'orthopedics'].contains(lower)) {
          setState(() {
            _filter = 'doctor';
            _ctrl.text = args;
          });
          context.read<ProviderProvider>().search(args);
        } else {
          setState(() => _ctrl.text = args);
          context.read<ProviderProvider>().search(args);
        }
      } else {
        context.read<ProviderProvider>().search('');
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    context.read<ProviderProvider>().search(value);
  }

  List<ProviderModel> _sortedResults(List<ProviderModel> raw) {
    final list = List<ProviderModel>.from(raw);
    switch (_sort) {
      case SortOption.ratingDesc:
        list.sort((a, b) {
          final cmp = b.averageRating.compareTo(a.averageRating);
          if (cmp != 0) return cmp;
          return b.totalReviews.compareTo(a.totalReviews);
        });
      case SortOption.reviewsDesc:
        list.sort((a, b) {
          final cmp = b.totalReviews.compareTo(a.totalReviews);
          if (cmp != 0) return cmp;
          return b.averageRating.compareTo(a.averageRating);
        });
      case SortOption.nameAsc:
        list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      case SortOption.nameDesc:
        list.sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
    }
    return list;
  }

  String _sortLabel(SortOption s) {
    switch (s) {
      case SortOption.ratingDesc:
        return 'Top Rated';
      case SortOption.reviewsDesc:
        return 'Most Reviewed';
      case SortOption.nameAsc:
        return 'Name A–Z';
      case SortOption.nameDesc:
        return 'Name Z–A';
    }
  }

  IconData _sortIcon(SortOption s) {
    switch (s) {
      case SortOption.ratingDesc:
        return Icons.star_rounded;
      case SortOption.reviewsDesc:
        return Icons.forum_rounded;
      case SortOption.nameAsc:
        return Icons.sort_by_alpha_rounded;
      case SortOption.nameDesc:
        return Icons.sort_by_alpha_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provState = context.watch<ProviderProvider>();
    final filtered = provState.searchResults.where((p) {
      if (_filter == 'all') return true;
      return p.type == _filter;
    }).toList();
    final results = _sortedResults(filtered);

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
                            context.read<ProviderProvider>().search('');
                            setState(() {
                              _filter = 'all';
                            });
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
            // Filter chips row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.containerMargin),
              child: Row(
                children: [
                  // Type filter chips
                  ...['all', 'doctor', 'pharmacy'].map((f) => Padding(
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
                  )),
                  const Spacer(),
                  // Sort button
                  _buildSortButton(),
                ],
              ),
            ),
            const SizedBox(height: 6),
            // Results header with count
            if (!provState.isLoading && results.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.containerMargin, vertical: 8),
                child: Row(
                  children: [
                    Text(
                      '${results.length} result${results.length == 1 ? '' : 's'}',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.outline,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_sortIcon(_sort), size: 12, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(
                            _sortLabel(_sort),
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: provState.isLoading
                  ? const LoadingIndicator()
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

  Widget _buildSortButton() {
    return PopupMenuButton<SortOption>(
      onSelected: (val) => setState(() => _sort = val),
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      color: AppColors.surface,
      elevation: 8,
      shadowColor: AppColors.ambientShadow,
      itemBuilder: (_) => SortOption.values.map((s) {
        final isActive = _sort == s;
        return PopupMenuItem<SortOption>(
          value: s,
          child: Row(
            children: [
              Icon(
                _sortIcon(s),
                size: 18,
                color: isActive ? AppColors.primary : AppColors.outline,
              ),
              const SizedBox(width: 10),
              Text(
                _sortLabel(s),
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
              if (isActive) ...[
                const Spacer(),
                const Icon(Icons.check_rounded, size: 18, color: AppColors.primary),
              ],
            ],
          ),
        );
      }).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.sort_rounded, size: 16, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(
              'Sort',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
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
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: () {
            _ctrl.clear();
            context.read<ProviderProvider>().search('');
            setState(() {
              _filter = 'all';
            });
          },
          icon: const Icon(Icons.clear_rounded),
          label: const Text('Clear search'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            ),
          ),
        ),
      ]),
    );
  }
}
