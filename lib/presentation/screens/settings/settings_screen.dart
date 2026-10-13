import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../bloc/auth/auth_bloc.dart';
import '../../../bloc/connectivity/connectivity_bloc.dart';
import '../../../bloc/settings/settings_bloc.dart';
import '../../../bloc/sync/sync_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/note_status.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textMuted = context.textMutedColor;

    final authState = context.watch<AuthBloc>().state;
    final userName =
        authState is Authenticated ? authState.name : 'Field Specialist';
    final userEmail = authState is Authenticated ? authState.email : '';

    final initials = userName.isNotEmpty
        ? userName
            .split(' ')
            .take(2)
            .map((w) => w.isEmpty ? '' : w[0].toUpperCase())
            .join()
        : 'U';

    final connState = context.watch<ConnectivityBloc>().state;
    final isOnline = connState.isOnline;

    final scaffoldBg = context.scaffoldBg;
    final textPrimary = context.textPrimaryColor;
    final surfaceSubtle = context.surfaceSubtle;
    final borderCol = context.borderColor;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: scaffoldBg,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Settings',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
        ),
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: surfaceSubtle,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: borderCol, width: 1),
                  ),
                  child: Icon(Icons.arrow_back_ios_new_rounded,
                      size: 16, color: textPrimary),
                ),
                onPressed: () => Navigator.pop(context),
              )
            : null,
      ),
      body: BlocListener<SyncBloc, SyncState>(
        listener: (context, state) {
          if (state is SyncSuccess) {
            context.read<SettingsBloc>().add(LoadSettings());
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.check_circle_outline_rounded,
                        color: Colors.white, size: 18),
                    SizedBox(width: 10),
                    Text('Data synchronized successfully with server!'),
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
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Account & Profile Link Card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: _buildProfileLinkCard(
                  context,
                  initials: initials,
                  userName: userName,
                  userEmail: userEmail,
                ),
              ),
            ),

            // Appearance & Theme Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Text(
                  'APPEARANCE & DISPLAY',
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: textMuted,
                    letterSpacing: 1.3,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: _buildThemeSelectorCard(context),
              ),
            ),

            // Note Defaults
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Text(
                  'FIELD PREFERENCES',
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: textMuted,
                    letterSpacing: 1.3,
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

            // Sync Card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Text(
                  'OFFLINE & CLOUD SYNC',
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: textMuted,
                    letterSpacing: 1.3,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: _buildSyncCard(context, isOnline: isOnline),
              ),
            ),

            // Feature Guide
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Text(
                  'SYSTEM & SUPPORT',
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: textMuted,
                    letterSpacing: 1.3,
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

            // Sign Out
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                child: _buildLogoutButton(context),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 50)),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileLinkCard(
    BuildContext context, {
    required String initials,
    required String userName,
    required String userEmail,
  }) {
    final cardBg = context.surfaceColor;
    final borderCol = context.borderColor;
    final textPrimary = context.textPrimaryColor;
    final textMuted = context.textMutedColor;

    return InkWell(
      onTap: () => Navigator.pushNamed(context, '/profile'),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: cardBg,
          border: Border.all(color: borderCol, width: 1),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: AppColors.primaryGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  initials,
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        userName,
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'View Profile',
                          style: GoogleFonts.outfit(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    userEmail.isNotEmpty ? userEmail : 'Manage profile & metrics',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: textMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: textMuted, size: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSelectorCard(BuildContext context) {
    final cardBg = context.surfaceColor;
    final borderCol = context.borderColor;
    final textPrimary = context.textPrimaryColor;
    final textMuted = context.textMutedColor;

    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        final currentMode =
            state is SettingsLoaded ? state.themeMode : ThemeMode.system;

        return Container(
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
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: AppColors.primary.withValues(alpha: 0.12),
                    ),
                    child: const Icon(Icons.palette_outlined,
                        color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Theme Mode',
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                          ),
                        ),
                        Text(
                          'Select your visual experience',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildThemeOption(
                      context,
                      label: 'System',
                      icon: Icons.brightness_auto_rounded,
                      isSelected: currentMode == ThemeMode.system,
                      onTap: () {
                        context
                            .read<SettingsBloc>()
                            .add(const UpdateThemeMode(ThemeMode.system));
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildThemeOption(
                      context,
                      label: 'Light',
                      icon: Icons.light_mode_rounded,
                      isSelected: currentMode == ThemeMode.light,
                      onTap: () {
                        context
                            .read<SettingsBloc>()
                            .add(const UpdateThemeMode(ThemeMode.light));
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildThemeOption(
                      context,
                      label: 'Dark',
                      icon: Icons.dark_mode_rounded,
                      isSelected: currentMode == ThemeMode.dark,
                      onTap: () {
                        context
                            .read<SettingsBloc>()
                            .add(const UpdateThemeMode(ThemeMode.dark));
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeOption(
    BuildContext context, {
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final surfaceSubtle = context.surfaceSubtle;
    final borderCol = context.borderColor;
    final textPrimary = context.textPrimaryColor;
    final textMuted = context.textMutedColor;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.15)
              : surfaceSubtle,
          border: Border.all(
            color: isSelected ? AppColors.primary : borderCol,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? AppColors.primary : textMuted,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.primary : textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultStatusCard(BuildContext context) {
    final cardBg = context.surfaceColor;
    final borderCol = context.borderColor;
    final textPrimary = context.textPrimaryColor;
    final textMuted = context.textMutedColor;

    return Container(
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
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: AppColors.accentCyan.withValues(alpha: 0.12),
                ),
                child: const Icon(Icons.flag_outlined,
                    color: AppColors.accentCyan, size: 18),
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
                        color: textPrimary,
                      ),
                    ),
                    Text(
                      'Pre-filled state when creating new observations',
                      style: GoogleFonts.outfit(
                          fontSize: 12, color: textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          BlocBuilder<SettingsBloc, SettingsState>(
            builder: (context, state) {
              String currentStatus = 'PENDING';
              if (state is SettingsLoaded) {
                currentStatus = NoteStatus.fromString(state.defaultStatus).toServer();
              }

              return DropdownButtonFormField<String>(
                initialValue: currentStatus,
                dropdownColor: cardBg,
                style: GoogleFonts.outfit(
                    color: textPrimary, fontSize: 14),
                icon: Icon(Icons.expand_more_rounded,
                    color: textMuted),
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

  Widget _buildSyncCard(BuildContext context, {required bool isOnline}) {
    final cardBg = context.surfaceColor;
    final borderCol = context.borderColor;
    final textPrimary = context.textPrimaryColor;
    final textMuted = context.textMutedColor;
    final surfaceSubtle = context.surfaceSubtle;

    return Container(
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
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: AppColors.accent.withValues(alpha: 0.12),
                ),
                child: const Icon(Icons.sync_rounded,
                    color: AppColors.accent, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cloud Delta Synchronization',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
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
                          'Last cloud update: $lastSyncText',
                          style: GoogleFonts.outfit(
                              fontSize: 12, color: textMuted),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: surfaceSubtle,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.auto_mode_rounded,
                  size: 16,
                  color: AppColors.accent,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Automatic Sync is active: when internet restores, pending changes push to cloud automatically.',
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      color: textMuted,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          BlocBuilder<SyncBloc, SyncState>(
            builder: (context, syncState) {
              final isSyncing = syncState is SyncInProgress;
              return GestureDetector(
                onTap: (isSyncing || !isOnline)
                    ? null
                    : () =>
                        context.read<SyncBloc>().add(SyncRequested()),
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: isSyncing
                        ? surfaceSubtle
                        : AppColors.accent.withValues(alpha: isOnline ? 0.15 : 0.08),
                    border: Border.all(
                      color: isSyncing
                          ? borderCol
                          : AppColors.accent.withValues(alpha: isOnline ? 0.35 : 0.15),
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
                          : Icon(
                              Icons.cloud_sync_rounded,
                              color: isOnline
                                  ? AppColors.accent
                                  : textMuted.withValues(alpha: 0.5),
                              size: 18,
                            ),
                      const SizedBox(width: 8),
                      Text(
                        isSyncing
                            ? 'Syncing Cloud Deltas...'
                            : isOnline
                                ? 'Sync Now'
                                : 'Offline (Will sync when connected)',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isSyncing
                              ? textMuted
                              : isOnline
                                  ? AppColors.accent
                                  : textMuted.withValues(alpha: 0.5),
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
    final cardBg = context.surfaceColor;
    final borderCol = context.borderColor;
    final textPrimary = context.textPrimaryColor;
    final textMuted = context.textMutedColor;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: cardBg,
        border: Border.all(color: borderCol, width: 1),
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
            color: textPrimary,
          ),
        ),
        subtitle: Text(
          'Review offline-first architecture & capabilities',
          style: GoogleFonts.outfit(
            fontSize: 12,
            color: textMuted,
          ),
        ),
        trailing: Icon(Icons.chevron_right_rounded, color: textMuted),
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
                'Are you sure you want to sign out of Field Notes? Any local un-synced data will remain preserved locally.'),
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
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil('/auth', (r) => false);
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
          color: AppColors.error.withValues(alpha: 0.08),
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
