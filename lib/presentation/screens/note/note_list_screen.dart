import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../bloc/note/note_bloc.dart';
import '../../../bloc/site/site_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/note_status.dart';
import 'note_form_screen.dart';

class NoteListScreen extends StatefulWidget {
  const NoteListScreen({super.key});

  @override
  State<NoteListScreen> createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreen> {
  final _searchController = TextEditingController();
  NoteStatus? _selectedStatus;
  String? _selectedSiteUuid;

  @override
  void initState() {
    super.initState();
    context.read<NoteBloc>().add(const LoadNotes());
    context.read<SiteBloc>().add(const LoadSites());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onFilterChanged() {
    context.read<NoteBloc>().add(LoadNotes(
          search: _searchController.text.trim(),
          status: _selectedStatus,
          siteUuid: _selectedSiteUuid,
        ));
  }

  Color _getStatusColor(NoteStatus status) {
    switch (status) {
      case NoteStatus.open:
        return AppColors.statusOpen;
      case NoteStatus.inProgress:
        return AppColors.statusInProgress;
      case NoteStatus.resolved:
        return AppColors.statusResolved;
      case NoteStatus.closed:
        return AppColors.statusClosed;
    }
  }

  IconData _getStatusIcon(NoteStatus status) {
    switch (status) {
      case NoteStatus.open:
        return Icons.radio_button_unchecked_rounded;
      case NoteStatus.inProgress:
        return Icons.pending_outlined;
      case NoteStatus.resolved:
        return Icons.check_circle_outline_rounded;
      case NoteStatus.closed:
        return Icons.cancel_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sitesState = context.watch<SiteBloc>().state;
    final sites = sitesState is SiteLoaded ? sitesState.sites : [];

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NoteFormScreen()),
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
                    child:
                        CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                if (state is NoteLoaded) {
                  final notes = state.notes;

                  if (notes.isEmpty) {
                    return _buildEmptyState();
                  }

                  return CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding:
                              const EdgeInsets.fromLTRB(20, 16, 20, 4),
                          child: Text(
                            '${notes.length} field note${notes.length == 1 ? '' : 's'}',
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              color: AppColors.onSurfaceMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                        sliver: SliverList.separated(
                          itemCount: notes.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final note = notes[index];
                            return _NoteCard(
                              note: note,
                              statusColor: _getStatusColor(note.status),
                              statusIcon: _getStatusIcon(note.status),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          NoteFormScreen(note: note)),
                                ).then((_) => _onFilterChanged());
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

  Widget _buildFilterSection(List sites) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _searchController,
            style: GoogleFonts.outfit(
                color: AppColors.onSurface, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Search notes, sites, customers...',
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18),
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
                _StatusChip(
                  label: 'All',
                  isSelected: _selectedStatus == null,
                  color: AppColors.primary,
                  onTap: () {
                    setState(() => _selectedStatus = null);
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
              ],
            ),
          ),
          if (sites.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceCardLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.07),
                  width: 1,
                ),
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              child: DropdownButton<String?>(
                isExpanded: true,
                value: _selectedSiteUuid,
                underline: const SizedBox.shrink(),
                dropdownColor: AppColors.surfaceCard,
                hint: Text('Filter by site',
                    style: GoogleFonts.outfit(
                        color: AppColors.onSurfaceMuted, fontSize: 13)),
                style: GoogleFonts.outfit(
                    color: AppColors.onSurface, fontSize: 13),
                icon: const Icon(Icons.expand_more_rounded,
                    color: AppColors.onSurfaceMuted, size: 20),
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.heroGradient,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.06),
                width: 1,
              ),
            ),
            child: const Icon(Icons.note_alt_outlined,
                size: 36, color: AppColors.onSurfaceMuted),
          ),
          const SizedBox(height: 16),
          Text(
            'No notes found',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tap "+ New Note" to capture your observations',
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: AppColors.onSurfaceMuted,
            ),
          ),
        ],
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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.2)
              : AppColors.surfaceCardLight,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? color.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.06),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? color : AppColors.onSurfaceMuted,
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
    final dateStr = DateFormat('MMM dd · HH:mm')
        .format(note.dateTime.toLocal());

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppColors.surfaceCard,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.06),
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
                            color: AppColors.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.15),
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
                        Icon(Icons.location_on_outlined,
                            size: 13, color: AppColors.accent),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${note.customerName ?? 'Customer'} · ${note.siteName ?? 'Site'}',
                            style: GoogleFonts.outfit(
                              color: AppColors.accent.withValues(alpha: 0.8),
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
                        color: AppColors.onSurfaceMuted,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ],
                  if (note.photoUrl != null &&
                      note.photoUrl!.isNotEmpty &&
                      !note.photoUrl!.startsWith('http') &&
                      !note.photoUrl!.startsWith('/')) ...[
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        File(note.photoUrl!),
                        height: 110,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.schedule_outlined,
                          size: 12,
                          color:
                              AppColors.onSurfaceMuted.withValues(alpha: 0.6)),
                      const SizedBox(width: 4),
                      Text(
                        dateStr,
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          color: AppColors.onSurfaceMuted
                              .withValues(alpha: 0.7),
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
                              Icon(Icons.cloud_upload_outlined,
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
