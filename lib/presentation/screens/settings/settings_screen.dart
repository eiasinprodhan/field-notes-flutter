import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../bloc/auth/auth_bloc.dart';
import '../../../bloc/settings/settings_bloc.dart';
import '../../../bloc/sync/sync_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/note_status.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final userName =
        authState is Authenticated ? authState.name : 'Field Worker';
    final userEmail = authState is Authenticated ? authState.email : '';

    final initials = userName.isNotEmpty
        ? userName
            .split(' ')
            .take(2)
            .map((w) => w.isEmpty ? '' : w[0].toUpperCase())
            .join()
        : 'U';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocListener<SyncBloc, SyncState>(
        listener: (context, state) {
          if (state is SyncSuccess) {
            context.read<SettingsBloc>().add(LoadSettings());
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle_outline_rounded,
                        color: Colors.white, size: 18),
                    const SizedBox(width: 10),
                    const Text('Sync completed successfully!'),
                  ],
                ),
                backgroundColor: AppColors.success,
              ),
            );
          } else if (state is SyncFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Sync failed: ${state.message}'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: _buildProfileCard(initials, userName, userEmail),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Text(
                  'PREFERENCES',
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurfaceMuted,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: _buildDefaultStatusCard(context),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Text(
                  'SYNCHRONIZATION',
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurfaceMuted,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: _buildSyncCard(context),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Text(
                  'APPLICATION TOUR',
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurfaceMuted,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: _buildTourCard(context),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
                child: _buildLogoutButton(context),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(
      String initials, String userName, String userEmail) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.15),
            AppColors.surfaceCard,
          ],
        ),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: AppColors.primaryGradient,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Center(
              child: Text(
                initials,
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  userEmail,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    color: AppColors.onSurfaceMuted,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.success.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'Active',
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultStatusCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.surfaceCard,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: AppColors.primary.withValues(alpha: 0.12),
                ),
                child: const Icon(Icons.flag_outlined,
                    color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Default Note Status',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                    Text(
                      'Pre-filled when creating new notes',
                      style: GoogleFonts.outfit(
                          fontSize: 12, color: AppColors.onSurfaceMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          BlocBuilder<SettingsBloc, SettingsState>(
            builder: (context, state) {
              String currentStatus = 'OPEN';
              if (state is SettingsLoaded) {
                currentStatus = state.defaultStatus;
              }

              return DropdownButtonFormField<String>(
                initialValue: currentStatus,
                dropdownColor: AppColors.surfaceCard,
                style: GoogleFonts.outfit(
                    color: AppColors.onSurface, fontSize: 14),
                icon: const Icon(Icons.expand_more_rounded,
                    color: AppColors.onSurfaceMuted),
                decoration: const InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                items: NoteStatus.values.map((status) {
                  return DropdownMenuItem<String>(
                    value: status.toServer(),
                    child: Text(status.displayName),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    context
                        .read<SettingsBloc>()
                        .add(UpdateDefaultStatus(val));
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSyncCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.surfaceCard,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: AppColors.accent.withValues(alpha: 0.12),
                ),
                child: const Icon(Icons.sync_rounded,
                    color: AppColors.accent, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Data Synchronization',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                    BlocBuilder<SettingsBloc, SettingsState>(
                      builder: (context, state) {
                        String lastSyncText = 'Never synced';
                        if (state is SettingsLoaded &&
                            state.lastSyncTime != null) {
                          try {
                            final dt =
                                DateTime.parse(state.lastSyncTime!).toLocal();
                            lastSyncText =
                                DateFormat('MMM dd, HH:mm').format(dt);
                          } catch (_) {
                            lastSyncText = state.lastSyncTime!;
                          }
                        }
                        return Text(
                          'Last synced: $lastSyncText',
                          style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: AppColors.onSurfaceMuted),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          BlocBuilder<SyncBloc, SyncState>(
            builder: (context, syncState) {
              final isSyncing = syncState is SyncInProgress;
              return GestureDetector(
                onTap: isSyncing
                    ? null
                    : () =>
                        context.read<SyncBloc>().add(SyncRequested()),
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: isSyncing
                        ? AppColors.surfaceCardLight
                        : AppColors.accent.withValues(alpha: 0.15),
                    border: Border.all(
                      color: isSyncing
                          ? Colors.white.withValues(alpha: 0.06)
                          : AppColors.accent.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      isSyncing
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.accent,
                              ),
                            )
                          : const Icon(Icons.cloud_sync_outlined,
                              color: AppColors.accent, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        isSyncing ? 'Syncing...' : 'Sync Now',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isSyncing
                              ? AppColors.onSurfaceMuted
                              : AppColors.accent,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTourCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.surfaceCard,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.07),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: AppColors.primary.withValues(alpha: 0.15),
          ),
          child: const Icon(Icons.auto_awesome_rounded,
              color: AppColors.primary, size: 20),
        ),
        title: Text(
          'Revisit Feature Tour',
          style: GoogleFonts.outfit(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        subtitle: Text(
          'Review offline sync and intelligent field capture guide',
          style: GoogleFonts.outfit(
            fontSize: 12,
            color: AppColors.onSurfaceMuted,
          ),
        ),
        trailing:
            const Icon(Icons.chevron_right, color: AppColors.onSurfaceMuted),
        onTap: () {
          Navigator.pushNamed(context, '/onboarding');
        },
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Sign Out'),
            content: const Text(
                'Are you sure you want to sign out of Field Notes?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              FilledButton(
                style:
                    FilledButton.styleFrom(backgroundColor: AppColors.error),
                onPressed: () {
                  Navigator.pop(ctx);
                  context.read<AuthBloc>().add(LogoutRequested());
                  Navigator.of(context).pushNamedAndRemoveUntil('/auth', (r) => false);
                },
                child: const Text('Sign Out'),
              ),
            ],
          ),
        );
      },
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: AppColors.error.withValues(alpha: 0.1),
          border: Border.all(
            color: AppColors.error.withValues(alpha: 0.25),
            width: 1,
          ),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.logout_rounded,
                  color: AppColors.error, size: 18),
              const SizedBox(width: 8),
              Text(
                'Sign Out',
                style: GoogleFonts.outfit(
                  color: AppColors.error,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
