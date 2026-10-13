import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../bloc/auth/auth_bloc.dart';
import '../../../bloc/connectivity/connectivity_bloc.dart';
import '../../../bloc/customer/customer_bloc.dart';
import '../../../bloc/note/note_bloc.dart';
import '../../../bloc/site/site_bloc.dart';
import '../../../bloc/sync/sync_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/note_status.dart';
import '../customer/customer_form_screen.dart';
import '../note/note_form_screen.dart';
import '../site/site_form_screen.dart';

class DashboardScreen extends StatelessWidget {
  final Function(int tabIndex, {NoteStatus? filterStatus})? onNavigateToTab;

  const DashboardScreen({super.key, this.onNavigateToTab});

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

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final cardBg = context.surfaceColor;
    final borderCol = context.borderColor;
    final textPrimary = context.textPrimaryColor;
    final textMuted = context.textMutedColor;

    final authState = context.watch<AuthBloc>().state;
    final userName = authState is Authenticated ? authState.name : 'Field Specialist';

    final notesState = context.watch<NoteBloc>().state;
    final customersState = context.watch<CustomerBloc>().state;
    final sitesState = context.watch<SiteBloc>().state;
    final syncState = context.watch<SyncBloc>().state;
    final isSyncing = syncState is SyncInProgress;

    final notes = notesState is NoteLoaded ? notesState.notes : [];
    final customers = customersState is CustomerLoaded ? customersState.customers : [];
    final sites = sitesState is SiteLoaded ? sitesState.sites : [];

    final pendingCount = notes.where((n) => n.status == NoteStatus.pending).length;
    final inProgressCount = notes.where((n) => n.status == NoteStatus.inProgress).length;
    final completedCount = notes.where((n) => n.status == NoteStatus.completed).length;
    final pendingSyncCount = notes.where((n) => n.syncPending).length +
        customers.where((c) => c.syncPending).length +
        sites.where((s) => s.syncPending).length;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<CustomerBloc>().add(LoadCustomers());
          context.read<SiteBloc>().add(const LoadSites());
          context.read<NoteBloc>().add(const LoadNotes());
          final conn = context.read<ConnectivityBloc>().state;
          if (conn.isOnline) {
            context.read<SyncBloc>().add(SyncRequested());
          }
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            // Welcome & Executive Overview Banner
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? [
                              AppColors.primary.withValues(alpha: 0.25),
                              AppColors.accent.withValues(alpha: 0.12),
                              AppColors.darkSurfaceCard,
                            ]
                          : [
                              AppColors.primary.withValues(alpha: 0.10),
                              AppColors.accent.withValues(alpha: 0.08),
                              Colors.white,
                            ],
                    ),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: isDark ? 0.3 : 0.2),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: isDark ? 0.12 : 0.06),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'EXECUTIVE DASHBOARD',
                                  style: GoogleFonts.outfit(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.5,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Hello, $userName',
                                  style: GoogleFonts.outfit(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: pendingSyncCount > 0
                                  ? AppColors.warning.withValues(alpha: 0.15)
                                  : AppColors.success.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: pendingSyncCount > 0
                                    ? AppColors.warning.withValues(alpha: 0.3)
                                    : AppColors.success.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  pendingSyncCount > 0
                                      ? Icons.cloud_upload_outlined
                                      : Icons.cloud_done_rounded,
                                  size: 14,
                                  color: pendingSyncCount > 0
                                      ? AppColors.warning
                                      : AppColors.success,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  pendingSyncCount > 0
                                      ? '$pendingSyncCount Pending'
                                      : 'All Synced',
                                  style: GoogleFonts.outfit(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: pendingSyncCount > 0
                                        ? AppColors.warning
                                        : AppColors.success,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Real-time operations summary. Offline records automatically sync when connected.',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          color: textMuted,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // KPI Metrics Row
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildMetricTile(
                        context: context,
                        title: 'Total Notes',
                        value: '${notes.length}',
                        icon: Icons.note_alt_rounded,
                        color: AppColors.primary,
                        onTap: () => onNavigateToTab?.call(1),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricTile(
                        context: context,
                        title: 'Customers',
                        value: '${customers.length}',
                        icon: Icons.business_rounded,
                        color: AppColors.accentCyan,
                        onTap: () => onNavigateToTab?.call(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricTile(
                        context: context,
                        title: 'Sites',
                        value: '${sites.length}',
                        icon: Icons.location_city_rounded,
                        color: AppColors.accent,
                        onTap: () => onNavigateToTab?.call(3),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Note Status Breakdown Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'STATUS BREAKDOWN',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: textMuted,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      'Tap to filter',
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatusCard(
                        context: context,
                        label: 'Pending',
                        count: pendingCount,
                        color: AppColors.statusOpen,
                        icon: Icons.radio_button_unchecked_rounded,
                        onTap: () => onNavigateToTab?.call(1, filterStatus: NoteStatus.pending),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildStatusCard(
                        context: context,
                        label: 'In Progress',
                        count: inProgressCount,
                        color: AppColors.statusInProgress,
                        icon: Icons.pending_outlined,
                        onTap: () => onNavigateToTab?.call(1, filterStatus: NoteStatus.inProgress),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildStatusCard(
                        context: context,
                        label: 'Completed',
                        count: completedCount,
                        color: AppColors.statusResolved,
                        icon: Icons.check_circle_outline_rounded,
                        onTap: () => onNavigateToTab?.call(1, filterStatus: NoteStatus.completed),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Quick Actions Center
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
                child: Text(
                  'QUICK ACTIONS',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: textMuted,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 2.3,
                  children: [
                    _buildActionCard(
                      context: context,
                      title: 'New Note',
                      subtitle: 'Capture observations',
                      icon: Icons.add_circle_outline_rounded,
                      color: AppColors.primary,
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const NoteFormScreen()),
                        );
                        if (!context.mounted) return;
                        context.read<NoteBloc>().add(const LoadNotes());
                      },
                    ),
                    _buildActionCard(
                      context: context,
                      title: 'Add Customer',
                      subtitle: 'Register client',
                      icon: Icons.person_add_alt_1_rounded,
                      color: AppColors.accentCyan,
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CustomerFormScreen()),
                        );
                        if (!context.mounted) return;
                        context.read<CustomerBloc>().add(LoadCustomers());
                      },
                    ),
                    _buildActionCard(
                      context: context,
                      title: 'Add Site',
                      subtitle: 'Register site or facility',
                      icon: Icons.add_location_alt_rounded,
                      color: AppColors.accent,
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SiteFormScreen()),
                        );
                        if (!context.mounted) return;
                        context.read<SiteBloc>().add(const LoadSites());
                      },
                    ),
                    _buildActionCard(
                      context: context,
                      title: isSyncing ? 'Syncing...' : 'Sync Cloud',
                      subtitle: 'Push & pull deltas',
                      icon: isSyncing ? Icons.sync_rounded : Icons.cloud_sync_rounded,
                      color: AppColors.amberGradient.colors.first,
                      isLoading: isSyncing,
                      onTap: isSyncing
                          ? null
                          : () {
                              context.read<SyncBloc>().add(SyncRequested());
                            },
                    ),
                  ],
                ),
              ),
            ),

            // Recent Field Activity / Notes
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'RECENT FIELD NOTES',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: textMuted,
                        letterSpacing: 1.2,
                      ),
                    ),
                    if (notes.isNotEmpty)
                      GestureDetector(
                        onTap: () => onNavigateToTab?.call(1),
                        child: Text(
                          'View All (${notes.length})',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            if (notes.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderCol, width: 1),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.edit_note_rounded,
                            size: 40, color: textMuted.withValues(alpha: 0.5)),
                        const SizedBox(height: 12),
                        Text(
                          'No field notes found',
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tap "+ New Note" to begin recording field data offline.',
                          style: GoogleFonts.outfit(fontSize: 13, color: textMuted),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                sliver: SliverList.separated(
                  itemCount: notes.take(5).length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    final statusColor = _getStatusColor(note.status);
                    final formattedDate =
                        DateFormat('MMM dd, HH:mm').format(note.dateTime.toLocal());

                    return GestureDetector(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => NoteFormScreen(note: note)),
                        );
                        if (!context.mounted) return;
                        context.read<NoteBloc>().add(const LoadNotes());
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: borderCol, width: 1),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              Container(
                                width: 10,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: statusColor,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            note.title,
                                            style: GoogleFonts.outfit(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: textPrimary,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 7, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: statusColor.withValues(alpha: 0.12),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            note.status.displayName,
                                            style: GoogleFonts.outfit(
                                              color: statusColor,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        if (note.customerName != null || note.siteName != null) ...[
                                          Icon(Icons.location_on_outlined,
                                              size: 12, color: textMuted),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              '${note.customerName ?? 'Customer'} · ${note.siteName ?? 'Site'}',
                                              style: GoogleFonts.outfit(
                                                fontSize: 11,
                                                color: textMuted,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ] else
                                          Expanded(
                                            child: Text(
                                              formattedDate,
                                              style: GoogleFonts.outfit(
                                                fontSize: 11,
                                                color: textMuted,
                                              ),
                                            ),
                                          ),
                                        if (note.syncPending) ...[
                                          const SizedBox(width: 6),
                                          const Icon(Icons.cloud_upload_outlined,
                                              size: 12, color: AppColors.warning),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(Icons.chevron_right_rounded,
                                  size: 18, color: textMuted.withValues(alpha: 0.5)),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final cardBg = context.surfaceColor;
    final borderCol = context.borderColor;
    final textPrimary = context.textPrimaryColor;
    final textMuted = context.textMutedColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderCol, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: textMuted,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard({
    required BuildContext context,
    required String label,
    required int count,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final cardBg = context.surfaceColor;
    final borderCol = context.borderColor;
    final textPrimary = context.textPrimaryColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderCol, width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(height: 6),
            Text(
              '$count',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback? onTap,
    bool isLoading = false,
  }) {
    final cardBg = context.surfaceColor;
    final borderCol = context.borderColor;
    final textPrimary = context.textPrimaryColor;
    final textMuted = context.textMutedColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderCol, width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: isLoading
                  ? Center(
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: color,
                        ),
                      ),
                    )
                  : Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.outfit(
                      fontSize: 10,
                      color: textMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
