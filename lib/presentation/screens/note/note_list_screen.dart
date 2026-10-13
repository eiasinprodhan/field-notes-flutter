import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../bloc/note/note_bloc.dart';
import '../../../bloc/site/site_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/field_note.dart';
import '../../../models/note_status.dart';
import 'note_form_screen.dart';
import 'note_detail_screen.dart';

class NoteListScreen extends StatefulWidget {
  final String? initialSiteUuid;
  const NoteListScreen({super.key, this.initialSiteUuid});

  @override
  State<NoteListScreen> createState() => NoteListScreenState();
}

class NoteListScreenState extends State<NoteListScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  NoteStatus? _selectedStatus;
  String? _selectedSiteUuid;
  bool _hasPhotoOnly = false;
  bool _localOnly = false;
  String _selectedSort = 'newest';
  int _displayedCount = 10;
  bool _isLoadingMore = false;

  static const Map<String, String> _sortOptions = {
    'newest': 'Newest First',
    'oldest': 'Oldest First',
    'title_az': 'Title A–Z',
    'title_za': 'Title Z–A',
    'status': 'By Status',
  };

  @override
  void initState() {
    super.initState();
    _selectedSiteUuid = widget.initialSiteUuid;
    _scrollController.addListener(_onScroll);
    context.read<NoteBloc>().add(LoadNotes(siteUuid: _selectedSiteUuid));
    context.read<SiteBloc>().add(const LoadSites());
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

  void setStatusFilter(NoteStatus? status) {
    setState(() => _selectedStatus = status);
    _onFilterChanged();
  }

  void setSiteFilter(String? siteUuid) {
    setState(() => _selectedSiteUuid = siteUuid);
    _onFilterChanged();
  }

  void _onFilterChanged() {
    _resetPaging();
    context.read<NoteBloc>().add(LoadNotes(
          search: _searchController.text.trim(),
          status: _selectedStatus,
          siteUuid: _selectedSiteUuid,
        ));
  }

  Color _getStatusColor(NoteStatus status) {
    switch (status) {
      case NoteStatus.pending:
        return AppColors.statusOpen;
      case NoteStatus.inProgress:
        return AppColors.statusInProgress;
      case NoteStatus.completed:
        return AppColors.statusResolved;
    }
  }

  IconData _getStatusIcon(NoteStatus status) {
    switch (status) {
      case NoteStatus.pending:
        return Icons.radio_button_unchecked_rounded;
      case NoteStatus.inProgress:
        return Icons.pending_outlined;
      case NoteStatus.completed:
        return Icons.check_circle_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sitesState = context.watch<SiteBloc>().state;
    final sites = sitesState is SiteLoaded ? sitesState.sites : [];
    final textMuted = context.textMutedColor;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_note_screen',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NoteFormScreen(initialSiteUuid: _selectedSiteUuid),
            ),
          ).then((_) => _onFilterChanged());
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded, size: 20),
        label: Text('New Note',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildFilterSection(sites),
          Expanded(
            child: BlocBuilder<NoteBloc, NoteState>(
              builder: (context, state) {
                if (state is NoteLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                if (state is NoteLoaded) {
                  var notes = List<FieldNote>.from(state.notes);
                  if (_hasPhotoOnly) {
                    notes = notes
                        .where((n) =>
                            n.photoUrl != null && n.photoUrl!.trim().isNotEmpty)
                        .toList();
                  }
                  if (_localOnly) {
                    notes = notes.where((n) => n.syncPending).toList();
                  }

                  switch (_selectedSort) {
                    case 'oldest':
                      notes.sort((a, b) => a.dateTime.compareTo(b.dateTime));
                      break;
                    case 'title_az':
                      notes.sort((a, b) =>
                          a.title.toLowerCase().compareTo(b.title.toLowerCase()));
                      break;
                    case 'title_za':
                      notes.sort((a, b) =>
                          b.title.toLowerCase().compareTo(a.title.toLowerCase()));
                      break;
                    case 'status':
                      notes.sort((a, b) => a.status.index.compareTo(b.status.index));
                      break;
                    case 'newest':
                    default:
                      notes.sort((a, b) => b.dateTime.compareTo(a.dateTime));
                      break;
                  }

                  if (notes.isEmpty) {
                    return _buildEmptyState();
                  }

                  final visibleNotes = notes.take(_displayedCount).toList();

                  return CustomScrollView(
                    controller: _scrollController,
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${notes.length} Field Note${notes.length == 1 ? '' : 's'}${visibleNotes.length < notes.length ? ' (showing ${visibleNotes.length})' : ''}',
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
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                        sliver: SliverList.separated(
                          itemCount: visibleNotes.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final note = visibleNotes[index];
                            return _NoteCard(
                              note: note,
                              statusColor: _getStatusColor(note.status),
                              statusIcon: _getStatusIcon(note.status),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          NoteDetailScreen(note: note)),
                                ).then((_) => _onFilterChanged());
                              },
                            );
                          },
                        ),
                      ),
                      if (_isLoadingMore)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Loading more notes...',
                                    style: GoogleFonts.outfit(
                                      fontSize: 12,
                                      color: textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      const SliverToBoxAdapter(
                        child: SizedBox(height: 80),
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

  Widget _buildSortMenu(Color textPrimary, Color textMuted, Color surfaceSubtle, Color borderCol, Color cardBg) {
    return PopupMenuButton<String>(
      initialValue: _selectedSort,
      tooltip: 'Sort notes',
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

  Widget _buildFilterSection(List sites) {
    final textPrimary = context.textPrimaryColor;
    final textMuted = context.textMutedColor;
    final surfaceSubtle = context.surfaceSubtle;
    final borderCol = context.borderColor;
    final cardBg = context.surfaceColor;

    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _searchController,
            style: GoogleFonts.outfit(
                color: textPrimary, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Search notes, sites, customers...',
              prefixIcon: Icon(Icons.search_rounded, size: 20, color: textMuted),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear_rounded, size: 18, color: textMuted),
                      onPressed: () {
                        _searchController.clear();
                        _onFilterChanged();
                      },
                    )
                  : null,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
            ),
            onChanged: (_) => _onFilterChanged(),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildSortMenu(textPrimary, textMuted, surfaceSubtle, borderCol, cardBg),
                const SizedBox(width: 6),
                _StatusChip(
                  label: 'All',
                  isSelected: _selectedStatus == null && !_hasPhotoOnly && !_localOnly,
                  color: AppColors.primary,
                  onTap: () {
                    setState(() {
                      _selectedStatus = null;
                      _hasPhotoOnly = false;
                      _localOnly = false;
                    });
                    _onFilterChanged();
                  },
                ),
                const SizedBox(width: 6),
                ...NoteStatus.values.map((status) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: _StatusChip(
                      label: status.displayName,
                      isSelected: _selectedStatus == status,
                      color: _getStatusColor(status),
                      onTap: () {
                        setState(() {
                          _selectedStatus =
                              _selectedStatus == status ? null : status;
                        });
                        _onFilterChanged();
                      },
                    ),
                  );
                }),
                _StatusChip(
                  label: '📷 Has Photo',
                  isSelected: _hasPhotoOnly,
                  color: AppColors.accent,
                  onTap: () {
                    setState(() {
                      _hasPhotoOnly = !_hasPhotoOnly;
                    });
                    _onFilterChanged();
                  },
                ),
                const SizedBox(width: 6),
                _StatusChip(
                  label: '🔄 Local Only',
                  isSelected: _localOnly,
                  color: AppColors.warning,
                  onTap: () {
                    setState(() {
                      _localOnly = !_localOnly;
                    });
                    _resetPaging();
                  },
                ),
              ],
            ),
          ),
          if (sites.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: surfaceSubtle,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: borderCol,
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              child: DropdownButton<String?>(
                isExpanded: true,
                value: _selectedSiteUuid,
                underline: const SizedBox.shrink(),
                dropdownColor: cardBg,
                hint: Text('Filter by site',
                    style: GoogleFonts.outfit(
                        color: textMuted, fontSize: 13)),
                style: GoogleFonts.outfit(
                    color: textPrimary, fontSize: 13),
                icon: Icon(Icons.expand_more_rounded,
                    color: textMuted, size: 20),
                items: [
                  DropdownMenuItem<String?>(
                    value: null,
                    child: Text('All Sites',
                        style: GoogleFonts.outfit(fontSize: 13)),
                  ),
                  ...sites.map((s) => DropdownMenuItem<String?>(
                        value: s.uuid,
                        child: Text(s.siteName,
                            style: GoogleFonts.outfit(fontSize: 13)),
                      )),
                ],
                onChanged: (val) {
                  setState(() => _selectedSiteUuid = val);
                  _onFilterChanged();
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final surfaceSubtle = context.surfaceSubtle;
    final borderCol = context.borderColor;
    final textPrimary = context.textPrimaryColor;
    final textMuted = context.textMutedColor;

    final query = _searchController.text.trim();
    final hasFilter = query.isNotEmpty ||
        _selectedStatus != null ||
        _selectedSiteUuid != null ||
        _hasPhotoOnly ||
        _localOnly ||
        _selectedSort != 'newest';

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
                border: Border.all(
                  color: borderCol,
                  width: 1,
                ),
              ),
              child: Icon(
                hasFilter ? Icons.search_off_rounded : Icons.note_alt_outlined,
                size: 36,
                color: textMuted,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              hasFilter
                  ? (query.isNotEmpty
                      ? 'No field notes found for "$query"'
                      : 'No field notes found matching filters')
                  : 'No field notes found',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              hasFilter
                  ? 'Try checking your search terms or clear filters to view all notes'
                  : 'Tap "+ New Note" to capture your observations',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: textMuted,
              ),
            ),
            const SizedBox(height: 16),
            if (hasFilter)
              OutlinedButton.icon(
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _selectedStatus = null;
                    _selectedSiteUuid = null;
                    _hasPhotoOnly = false;
                    _localOnly = false;
                    _selectedSort = 'newest';
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
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          NoteFormScreen(initialSiteUuid: _selectedSiteUuid),
                    ),
                  ).then((_) => _onFilterChanged());
                },
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('New Note'),
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
}

class _StatusChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _StatusChip({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final surfaceSubtle = context.surfaceSubtle;
    final borderCol = context.borderColor;
    final textMuted = context.textMutedColor;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.18)
              : surfaceSubtle,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? color.withValues(alpha: 0.5)
                : borderCol,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? color : textMuted,
          ),
        ),
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  final dynamic note;
  final Color statusColor;
  final IconData statusIcon;
  final VoidCallback onTap;

  const _NoteCard({
    required this.note,
    required this.statusColor,
    required this.statusIcon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = context.surfaceColor;
    final borderCol = context.borderColor;
    final textPrimary = context.textPrimaryColor;
    final textMuted = context.textMutedColor;

    final dateStr = DateFormat('MMM dd · HH:mm')
        .format(note.dateTime.toLocal());

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: cardBg,
          border: Border.all(
            color: borderCol,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 3,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                color: statusColor,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          note.title,
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(statusIcon, size: 11, color: statusColor),
                            const SizedBox(width: 4),
                            Text(
                              note.status.displayName,
                              style: GoogleFonts.outfit(
                                color: statusColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (note.customerName != null || note.siteName != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 13, color: AppColors.accent),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${note.customerName ?? 'Customer'} · ${note.siteName ?? 'Site'}',
                            style: GoogleFonts.outfit(
                              color: AppColors.accent,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (note.description != null &&
                      note.description!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      note.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        color: textMuted,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ],
                  if (note.photoUrl != null && note.photoUrl!.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: note.photoUrl!.startsWith('http')
                          ? Image.network(
                              note.photoUrl!,
                              height: 110,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const SizedBox.shrink(),
                            )
                          : Image.file(
                              File(note.photoUrl!),
                              height: 110,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const SizedBox.shrink(),
                            ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.schedule_outlined,
                          size: 12,
                          color: textMuted.withValues(alpha: 0.7)),
                      const SizedBox(width: 4),
                      Text(
                        dateStr,
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          color: textMuted,
                        ),
                      ),
                      const Spacer(),
                      if (note.syncPending)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: AppColors.warning.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.cloud_upload_outlined,
                                  size: 11, color: AppColors.warning),
                              const SizedBox(width: 4),
                              Text(
                                'Local',
                                style: GoogleFonts.outfit(
                                  fontSize: 10,
                                  color: AppColors.warning,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Icon(Icons.cloud_done_outlined,
                            size: 14,
                            color: AppColors.success.withValues(alpha: 0.7)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
