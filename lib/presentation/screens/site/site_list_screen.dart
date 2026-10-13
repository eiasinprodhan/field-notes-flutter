import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../bloc/customer/customer_bloc.dart';
import '../../../bloc/note/note_bloc.dart';
import '../../../bloc/site/site_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/site.dart';
import 'site_detail_screen.dart';
import 'site_form_screen.dart';

class SiteListScreen extends StatefulWidget {
  final String? initialCustomerUuid;
  final bool showAppBar;

  const SiteListScreen({
    super.key,
    this.initialCustomerUuid,
    this.showAppBar = true,
  });

  @override
  State<SiteListScreen> createState() => _SiteListScreenState();
}

class _SiteListScreenState extends State<SiteListScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  String? _selectedCustomerUuid;
  String _selectedFilter = 'all'; // 'all', 'has_address', 'local_only'
  String _selectedSort = 'a_z'; // 'a_z', 'z_a', 'newest', 'oldest'
  int _displayedCount = 10;
  bool _isLoadingMore = false;

  static const Map<String, String> _sortOptions = {
    'a_z': 'Site A–Z',
    'z_a': 'Site Z–A',
    'newest': 'Recently Updated',
    'oldest': 'Oldest First',
  };

  @override
  void initState() {
    super.initState();
    _selectedCustomerUuid = widget.initialCustomerUuid;
    _scrollController.addListener(_onScroll);
    context.read<SiteBloc>().add(LoadSites(customerUuid: _selectedCustomerUuid));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  void _loadMore() {
    if (_isLoadingMore) return;
    setState(() => _isLoadingMore = true);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _displayedCount += 10;
          _isLoadingMore = false;
        });
      }
    });
  }

  void _resetPaging() {
    setState(() {
      _displayedCount = 10;
    });
  }

  void _onFilterChanged() {
    _resetPaging();
    context.read<SiteBloc>().add(LoadSites(customerUuid: _selectedCustomerUuid));
  }

  Widget _buildSortMenu(Color textPrimary, Color textMuted, Color surfaceSubtle, Color borderCol, Color cardBg) {
    return PopupMenuButton<String>(
      initialValue: _selectedSort,
      tooltip: 'Sort sites',
      onSelected: (val) {
        setState(() => _selectedSort = val);
        _resetPaging();
      },
      color: cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: borderCol),
      ),
      itemBuilder: (ctx) => _sortOptions.entries.map((entry) {
        final isSelected = entry.key == _selectedSort;
        return PopupMenuItem<String>(
          value: entry.key,
          child: Row(
            children: [
              Icon(
                isSelected ? Icons.check_rounded : Icons.radio_button_unchecked_rounded,
                size: 16,
                color: isSelected ? AppColors.primary : textMuted,
              ),
              const SizedBox(width: 8),
              Text(
                entry.value,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? AppColors.primary : textPrimary,
                ),
              ),
            ],
          ),
        );
      }).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: surfaceSubtle,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderCol, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.sort_rounded, size: 15, color: AppColors.primary),
            const SizedBox(width: 5),
            Text(
              _sortOptions[_selectedSort] ?? 'Sort',
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
            ),
            const SizedBox(width: 2),
            Icon(Icons.arrow_drop_down_rounded, size: 16, color: textMuted),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scaffoldBg = context.scaffoldBg;
    final cardBg = context.surfaceColor;
    final borderCol = context.borderColor;
    final textPrimary = context.textPrimaryColor;
    final textMuted = context.textMutedColor;
    final surfaceSubtle = context.surfaceSubtle;

    final customersState = context.watch<CustomerBloc>().state;
    final customers = customersState is CustomerLoaded ? customersState.customers : [];

    return Scaffold(
      backgroundColor: widget.showAppBar ? scaffoldBg : Colors.transparent,
      appBar: widget.showAppBar
          ? AppBar(
              backgroundColor: scaffoldBg,
              title: Text(
                'Sites & Facilities',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.refresh_rounded, color: textMuted),
                  onPressed: () {
                    context.read<SiteBloc>().add(LoadSites(customerUuid: _selectedCustomerUuid));
                  },
                ),
              ],
            )
          : null,
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_site_screen',
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_location_alt_rounded),
        label: Text(
          'New Site',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
        ),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SiteFormScreen(initialCustomerUuid: _selectedCustomerUuid),
            ),
          );
          if (mounted) _onFilterChanged();
        },
      ),
      body: Column(
        children: [
          // Search & Filter header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  style: GoogleFonts.outfit(color: textPrimary, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Search site name, address...',
                    prefixIcon: Icon(Icons.search_rounded, size: 20, color: textMuted),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear_rounded, size: 18, color: textMuted),
                            onPressed: () {
                              _searchController.clear();
                              _resetPaging();
                              setState(() {});
                            },
                          )
                        : null,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onChanged: (_) {
                    _resetPaging();
                    setState(() {});
                  },
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildSortMenu(textPrimary, textMuted, surfaceSubtle, borderCol, cardBg),
                      const SizedBox(width: 6),
                      _buildFilterChip('all', 'All Sites', surfaceSubtle, borderCol, textPrimary),
                      const SizedBox(width: 6),
                      _buildFilterChip('has_address', 'Has Address', surfaceSubtle, borderCol, textPrimary),
                      const SizedBox(width: 6),
                      _buildFilterChip('local_only', '🔄 Local Only', surfaceSubtle, borderCol, textPrimary),
                    ],
                  ),
                ),
                if (customers.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: surfaceSubtle,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: borderCol, width: 1),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                    child: DropdownButton<String?>(
                      isExpanded: true,
                      value: _selectedCustomerUuid,
                      underline: const SizedBox.shrink(),
                      dropdownColor: cardBg,
                      hint: Text('Filter by customer',
                          style: GoogleFonts.outfit(color: textMuted, fontSize: 13)),
                      style: GoogleFonts.outfit(color: textPrimary, fontSize: 13),
                      icon: Icon(Icons.expand_more_rounded, color: textMuted, size: 20),
                      items: [
                        DropdownMenuItem<String?>(
                          value: null,
                          child: Text('All Customers (${customers.length})',
                              style: GoogleFonts.outfit(fontSize: 13)),
                        ),
                        ...customers.map((c) => DropdownMenuItem<String?>(
                              value: c.uuid,
                              child: Text(c.name, style: GoogleFonts.outfit(fontSize: 13)),
                            )),
                      ],
                      onChanged: (val) {
                        setState(() => _selectedCustomerUuid = val);
                        _onFilterChanged();
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Sites list
          Expanded(
            child: BlocBuilder<SiteBloc, SiteState>(
              builder: (context, state) {
                if (state is SiteLoading) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                }

                if (state is SiteLoaded) {
                  final query = _searchController.text.trim().toLowerCase();
                  var sites = state.sites;

                  if (_selectedCustomerUuid != null) {
                    sites = sites.where((s) => s.customerUuid == _selectedCustomerUuid).toList();
                  }

                  if (query.isNotEmpty) {
                    sites = sites.where((s) {
                      final nameMatch = s.siteName.toLowerCase().contains(query);
                      final addrMatch = (s.address ?? '').toLowerCase().contains(query);
                      return nameMatch || addrMatch;
                    }).toList();
                  }

                  if (_selectedFilter == 'has_address') {
                    sites = sites.where((s) => s.address != null && s.address!.trim().isNotEmpty).toList();
                  } else if (_selectedFilter == 'local_only') {
                    sites = sites.where((s) => s.syncPending).toList();
                  }

                  switch (_selectedSort) {
                    case 'z_a':
                      sites = List.of(sites)..sort((a, b) => b.siteName.toLowerCase().compareTo(a.siteName.toLowerCase()));
                      break;
                    case 'newest':
                      sites = List.of(sites)..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
                      break;
                    case 'oldest':
                      sites = List.of(sites)..sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
                      break;
                    case 'a_z':
                    default:
                      sites = List.of(sites)..sort((a, b) => a.siteName.toLowerCase().compareTo(b.siteName.toLowerCase()));
                      break;
                  }

                  final isFiltered = query.isNotEmpty || _selectedCustomerUuid != null || _selectedFilter != 'all' || _selectedSort != 'a_z';

                  if (sites.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: surfaceSubtle,
                                border: Border.all(color: borderCol, width: 1),
                              ),
                              child: Icon(
                                isFiltered ? Icons.search_off_rounded : Icons.location_off_outlined,
                                size: 36,
                                color: textMuted,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              isFiltered
                                  ? (query.isNotEmpty
                                      ? 'No sites found for "$query"'
                                      : 'No sites found with selected filters')
                                  : 'No sites found',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              isFiltered
                                  ? 'Try checking your search terms or clear filters to view all sites'
                                  : 'Tap "+ New Site" to register a facility or location',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.outfit(fontSize: 14, color: textMuted),
                            ),
                            const SizedBox(height: 16),
                            if (isFiltered)
                              OutlinedButton.icon(
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _selectedCustomerUuid = null;
                                    _selectedFilter = 'all';
                                    _selectedSort = 'a_z';
                                  });
                                  _onFilterChanged();
                                },
                                icon: const Icon(Icons.clear_all_rounded, size: 16),
                                label: const Text('Clear Filters'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                  side: const BorderSide(color: AppColors.primary),
                                ),
                              )
                            else
                              ElevatedButton.icon(
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => SiteFormScreen(initialCustomerUuid: _selectedCustomerUuid),
                                    ),
                                  );
                                  if (mounted) _onFilterChanged();
                                },
                                icon: const Icon(Icons.add_location_alt_rounded, size: 16),
                                label: const Text('New Site'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }

                  final visibleSites = sites.take(_displayedCount).toList();

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 2, 20, 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${sites.length} Site${sites.length == 1 ? '' : 's'}${visibleSites.length < sites.length ? ' (showing ${visibleSites.length})' : ''}',
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                color: textMuted,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              _sortOptions[_selectedSort] ?? '',
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.separated(
                          controller: _scrollController,
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
                          itemCount: visibleSites.length + (_isLoadingMore ? 1 : 0),
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            if (index >= visibleSites.length) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                child: Center(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                                      ),
                                      const SizedBox(width: 10),
                                      Text('Loading more sites...', style: GoogleFonts.outfit(fontSize: 12, color: textMuted)),
                                    ],
                                  ),
                                ),
                              );
                            }
                            final site = visibleSites[index];
                            return _SiteItemCard(
                              site: site,
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => SiteDetailScreen(site: site),
                                  ),
                                );
                                if (context.mounted) _onFilterChanged();
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label, Color surfaceSubtle, Color borderCol, Color textPrimary) {
    final isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedFilter = value);
        _resetPaging();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : surfaceSubtle,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : borderCol,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Colors.white : textPrimary,
          ),
        ),
      ),
    );
  }
}

class _SiteItemCard extends StatelessWidget {
  final Site site;
  final VoidCallback onTap;

  const _SiteItemCard({required this.site, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cardBg = context.surfaceColor;
    final borderCol = context.borderColor;
    final textPrimary = context.textPrimaryColor;
    final textMuted = context.textMutedColor;

    final customerState = context.watch<CustomerBloc>().state;
    String? customerName;
    if (customerState is CustomerLoaded) {
      final match = customerState.customers.where((c) => c.uuid == site.customerUuid);
      if (match.isNotEmpty) customerName = match.first.name;
    }

    final notesState = context.watch<NoteBloc>().state;
    int noteCount = 0;
    if (notesState is NoteLoaded) {
      noteCount = notesState.notes.where((n) => n.siteUuid == site.uuid).length;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: cardBg,
          border: Border.all(color: borderCol, width: 1),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppColors.accent.withValues(alpha: 0.12),
                border: Border.all(color: AppColors.accent.withValues(alpha: 0.25), width: 1),
              ),
              child: const Icon(Icons.location_on_outlined, color: AppColors.accent, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          site.siteName,
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: textPrimary,
                          ),
                        ),
                      ),
                      if (site.syncPending)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Local',
                            style: GoogleFonts.outfit(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.warning,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (site.address != null && site.address!.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      site.address!,
                      style: GoogleFonts.outfit(fontSize: 12, color: textMuted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (customerName != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            customerName,
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        '$noteCount note${noteCount == 1 ? '' : 's'}',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          color: textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: textMuted),
          ],
        ),
      ),
    );
  }
}
