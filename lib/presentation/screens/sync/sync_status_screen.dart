import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../bloc/connectivity/connectivity_bloc.dart';
import '../../../bloc/sync/sync_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/field_repository.dart';

class SyncStatusScreen extends StatefulWidget {
  const SyncStatusScreen({super.key});

  @override
  State<SyncStatusScreen> createState() => _SyncStatusScreenState();
}

class _SyncStatusScreenState extends State<SyncStatusScreen> {
  Map<String, int> _counts = {'customers': 0, 'sites': 0, 'notes': 0, 'total': 0};

  @override
  void initState() {
    super.initState();
    _refreshCounts();
  }

  Future<void> _refreshCounts() async {
    final repo = context.read<FieldRepository>();
    final c = await repo.getPendingSyncCounts();
    if (mounted) {
      setState(() {
        _counts = c;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scaffoldBg = context.scaffoldBg;
    final cardBg = context.surfaceColor;
    final borderCol = context.borderColor;
    final textPrimary = context.textPrimaryColor;
    final textMuted = context.textMutedColor;
    final surfaceSubtle = context.surfaceSubtle;

    final connectivity = context.watch<ConnectivityBloc>().state;
    final isOnline = connectivity.isOnline;
    final syncState = context.watch<SyncBloc>().state;
    final isSyncing = syncState is SyncInProgress;

    final repo = context.read<FieldRepository>();
    final lastSyncTimeStr = repo.settings.getLastSyncTime();
    String lastSyncFormatted = 'Never';
    if (lastSyncTimeStr != null) {
      try {
        final dt = DateTime.parse(lastSyncTimeStr).toLocal();
        lastSyncFormatted = DateFormat('MMM dd, yyyy · HH:mm:ss').format(dt);
      } catch (_) {
        lastSyncFormatted = lastSyncTimeStr;
      }
    }

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: scaffoldBg,
        leading: IconButton(
          icon: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: surfaceSubtle,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: borderCol, width: 1),
            ),
            child: Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: textPrimary),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Synchronization Hub',
          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: textPrimary),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: textMuted),
            onPressed: () {
              _refreshCounts();
            },
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          border: Border(top: BorderSide(color: borderCol, width: 1)),
        ),
        child: FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          icon: isSyncing
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.sync_rounded),
          label: Text(
            isSyncing ? 'Synchronizing with Cloud...' : 'Synchronize Now',
            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          onPressed: (!isOnline || isSyncing)
              ? null
              : () {
                  context.read<SyncBloc>().add(SyncRequested());
                  Future.delayed(const Duration(seconds: 1), _refreshCounts);
                },
        ),
      ),
      body: BlocListener<SyncBloc, SyncState>(
        listener: (context, state) {
          if (state is SyncSuccess || state is SyncFailure) {
            _refreshCounts();
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Connectivity Status Banner
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: (isOnline ? AppColors.success : AppColors.error).withValues(alpha: 0.1),
                  border: Border.all(
                    color: (isOnline ? AppColors.success : AppColors.error).withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Icon(
                      isOnline ? Icons.wifi_rounded : Icons.wifi_off_rounded,
                      color: isOnline ? AppColors.success : AppColors.error,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isOnline ? 'Online — Connected to Network' : 'Offline — Operating Locally',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: isOnline ? AppColors.success : AppColors.error,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isOnline
                                ? 'Changes will sync automatically to the Spring Boot REST backend.'
                                : 'All changes are durably persisted in local SQLite and queued.',
                            style: GoogleFonts.outfit(fontSize: 12, color: textMuted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Pending Changes Metric Cards
              Text(
                'LOCAL PENDING OUTBOX',
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: textMuted,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      label: 'Customers',
                      count: _counts['customers'] ?? 0,
                      icon: Icons.business_outlined,
                      color: AppColors.primary,
                      cardBg: cardBg,
                      borderCol: borderCol,
                      textPrimary: textPrimary,
                      textMuted: textMuted,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildMetricCard(
                      label: 'Sites',
                      count: _counts['sites'] ?? 0,
                      icon: Icons.location_on_outlined,
                      color: AppColors.accent,
                      cardBg: cardBg,
                      borderCol: borderCol,
                      textPrimary: textPrimary,
                      textMuted: textMuted,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildMetricCard(
                      label: 'Notes',
                      count: _counts['notes'] ?? 0,
                      icon: Icons.note_alt_outlined,
                      color: AppColors.accentCyan,
                      cardBg: cardBg,
                      borderCol: borderCol,
                      textPrimary: textPrimary,
                      textMuted: textMuted,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Synchronization Health Card
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: cardBg,
                  border: Border.all(color: borderCol, width: 1),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Synchronization Health',
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: (_counts['total'] == 0 ? AppColors.success : AppColors.warning)
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _counts['total'] == 0 ? 'Fully Synced' : '${_counts['total']} Queued',
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: _counts['total'] == 0 ? AppColors.success : AppColors.warning,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _buildInfoRow('Last successful sync', lastSyncFormatted, textPrimary, textMuted),
                    const SizedBox(height: 8),
                    _buildInfoRow('Sync protocol', 'Bidirectional Delta (Push & Pull)', textPrimary, textMuted),
                    const SizedBox(height: 8),
                    _buildInfoRow('Dependency ordering', 'Customer -> Site -> Field Note', textPrimary, textMuted),
                    const SizedBox(height: 8),
                    _buildInfoRow('Conflict resolution', 'Server-managed optimistic concurrency', textPrimary, textMuted),

                    if (syncState is SyncFailure) ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.error.withValues(alpha: 0.25)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                syncState.message,
                                style: GoogleFonts.outfit(fontSize: 12, color: AppColors.error),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // How it works card
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: cardBg,
                  border: Border.all(color: borderCol, width: 1),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Offline Architecture Guarantee',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'All customer records, sites, and notes are saved locally in SQLite with client-generated UUIDs before syncing. When connectivity is restored, operations are transmitted in dependency order to prevent foreign key errors.',
                      style: GoogleFonts.outfit(fontSize: 12, color: textMuted, height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String label,
    required int count,
    required IconData icon,
    required Color color,
    required Color cardBg,
    required Color borderCol,
    required Color textPrimary,
    required Color textMuted,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderCol, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 10),
          Text(
            '$count',
            style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w700, color: textPrimary),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w500, color: textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, Color textPrimary, Color textMuted) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: GoogleFonts.outfit(fontSize: 12, color: textMuted),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 3,
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: textPrimary),
          ),
        ),
      ],
    );
  }
}
