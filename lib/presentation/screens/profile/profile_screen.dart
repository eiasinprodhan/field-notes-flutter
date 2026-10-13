import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../bloc/auth/auth_bloc.dart';
import '../../../bloc/connectivity/connectivity_bloc.dart';
import '../../../bloc/customer/customer_bloc.dart';
import '../../../bloc/note/note_bloc.dart';
import '../../../bloc/site/site_bloc.dart';
import '../../../core/theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showEditNameDialog(BuildContext context, String currentName) {
    final controller = TextEditingController(text: currentName);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        final cardBg = dialogContext.surfaceColor;
        final textPrimary = dialogContext.textPrimaryColor;
        final textMuted = dialogContext.textMutedColor;
        final borderCol = dialogContext.borderColor;

        return AlertDialog(
          backgroundColor: cardBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: borderCol, width: 1),
          ),
          title: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: AppColors.primary.withValues(alpha: 0.15),
                ),
                child: const Icon(Icons.person_rounded,
                    color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Change Name',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
              ),
            ],
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Update your full display name as it appears on inspection notes and customer logs.',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    color: textMuted,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'FULL NAME',
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: textMuted,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: controller,
                  style: GoogleFonts.outfit(color: textPrimary, fontSize: 14),
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Enter your full name',
                    prefixIcon: Icon(Icons.person_outline_rounded,
                        size: 20, color: textMuted),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Name cannot be empty';
                    }
                    if (val.trim().length < 2) {
                      return 'Name must be at least 2 characters';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Cancel',
                style: GoogleFonts.outfit(color: textMuted),
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  final newName = controller.text.trim();
                  Navigator.pop(dialogContext);
                  context.read<AuthBloc>().add(ProfileUpdated(name: newName));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.check_circle_outline_rounded,
                              color: Colors.white, size: 18),
                          SizedBox(width: 10),
                          Text('Name updated successfully!'),
                        ],
                      ),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              },
              child: Text(
                'Save Name',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showChangeEmailDialog(BuildContext context, String currentEmail) {
    final controller = TextEditingController(text: currentEmail);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        final cardBg = dialogContext.surfaceColor;
        final textPrimary = dialogContext.textPrimaryColor;
        final textMuted = dialogContext.textMutedColor;
        final borderCol = dialogContext.borderColor;

        return AlertDialog(
          backgroundColor: cardBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: borderCol, width: 1),
          ),
          title: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: AppColors.accentCyan.withValues(alpha: 0.15),
                ),
                child: const Icon(Icons.email_rounded,
                    color: AppColors.accentCyan, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Change Email',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
              ),
            ],
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enter your new account email address. You will use this new email to log in.',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    color: textMuted,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'EMAIL ADDRESS',
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: textMuted,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: controller,
                  keyboardType: TextInputType.emailAddress,
                  style: GoogleFonts.outfit(color: textPrimary, fontSize: 14),
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'user@fieldnotes.app',
                    prefixIcon: Icon(Icons.mail_outline_rounded,
                        size: 20, color: textMuted),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Email cannot be empty';
                    }
                    final clean = val.trim();
                    if (!clean.contains('@') || !clean.contains('.')) {
                      return 'Enter a valid email address';
                    }
                    if (clean.toLowerCase() == currentEmail.toLowerCase()) {
                      return 'New email is identical to current email';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Cancel',
                style: GoogleFonts.outfit(color: textMuted),
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  final newEmail = controller.text.trim();
                  Navigator.pop(dialogContext);
                  context.read<AuthBloc>().add(ProfileUpdated(email: newEmail));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.check_circle_outline_rounded,
                              color: Colors.white, size: 18),
                          SizedBox(width: 10),
                          Text('Email address updated successfully!'),
                        ],
                      ),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              },
              child: Text(
                'Update Email',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentPassController = TextEditingController();
    final newPassController = TextEditingController();
    final confirmPassController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    bool obscureCurrent = true;
    bool obscureNew = true;
    bool obscureConfirm = true;

    showDialog(
      context: context,
      builder: (dialogContext) {
        final cardBg = dialogContext.surfaceColor;
        final textPrimary = dialogContext.textPrimaryColor;
        final textMuted = dialogContext.textMutedColor;
        final borderCol = dialogContext.borderColor;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: cardBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: borderCol, width: 1),
              ),
              title: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: AppColors.accent.withValues(alpha: 0.15),
                    ),
                    child: const Icon(Icons.lock_reset_rounded,
                        color: AppColors.accent, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Change Password',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Provide your current password and choose a secure new password (at least 6 characters).',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          color: textMuted,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'CURRENT PASSWORD',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: textMuted,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: currentPassController,
                        obscureText: obscureCurrent,
                        style: GoogleFonts.outfit(color: textPrimary, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Enter current password',
                          prefixIcon: Icon(Icons.key_rounded,
                              size: 20, color: textMuted),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureCurrent
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 18,
                              color: textMuted,
                            ),
                            onPressed: () =>
                                setState(() => obscureCurrent = !obscureCurrent),
                          ),
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Current password is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'NEW PASSWORD',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: textMuted,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: newPassController,
                        obscureText: obscureNew,
                        style: GoogleFonts.outfit(color: textPrimary, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Enter at least 6 characters',
                          prefixIcon: Icon(Icons.lock_outline_rounded,
                              size: 20, color: textMuted),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureNew
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 18,
                              color: textMuted,
                            ),
                            onPressed: () =>
                                setState(() => obscureNew = !obscureNew),
                          ),
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'New password is required';
                          }
                          if (val.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'CONFIRM NEW PASSWORD',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: textMuted,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: confirmPassController,
                        obscureText: obscureConfirm,
                        style: GoogleFonts.outfit(color: textPrimary, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Confirm new password',
                          prefixIcon: Icon(Icons.check_circle_outline_rounded,
                              size: 20, color: textMuted),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureConfirm
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 18,
                              color: textMuted,
                            ),
                            onPressed: () =>
                                setState(() => obscureConfirm = !obscureConfirm),
                          ),
                        ),
                        validator: (val) {
                          if (val != newPassController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.outfit(color: textMuted),
                  ),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    if (formKey.currentState?.validate() ?? false) {
                      final currentPass = currentPassController.text;
                      final newPass = newPassController.text;
                      Navigator.pop(dialogContext);
                      context.read<AuthBloc>().add(ProfileUpdated(
                            currentPassword: currentPass,
                            newPassword: newPass,
                          ));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Row(
                            children: [
                              Icon(Icons.check_circle_outline_rounded,
                                  color: Colors.white, size: 18),
                              SizedBox(width: 10),
                              Text('Password updated successfully!'),
                            ],
                          ),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    }
                  },
                  child: Text(
                    'Change Password',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            );
          },
        );
      },
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
    final isDark = context.isDarkMode;

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
        : 'FS';

    final connState = context.watch<ConnectivityBloc>().state;
    final isOnline = connState.isOnline;

    final customerState = context.watch<CustomerBloc>().state;
    final customerCount =
        customerState is CustomerLoaded ? customerState.customers.length : 0;

    final siteState = context.watch<SiteBloc>().state;
    final siteCount = siteState is SiteLoaded ? siteState.sites.length : 0;

    final noteState = context.watch<NoteBloc>().state;
    final noteCount = noteState is NoteLoaded ? noteState.notes.length : 0;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline_rounded,
                      color: Colors.white, size: 18),
                  const SizedBox(width: 10),
                  Expanded(child: Text(state.message)),
                ],
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: scaffoldBg,
        appBar: AppBar(
          backgroundColor: scaffoldBg,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
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
          ),
          title: Text(
            'Profile',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Profile Overview Card
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
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
                            AppColors.primary.withValues(alpha: 0.12),
                            AppColors.accent.withValues(alpha: 0.06),
                            Colors.white,
                          ],
                  ),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: isDark ? 0.3 : 0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: isDark ? 0.15 : 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      width: 86,
                      height: 86,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.primaryGradient,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.4),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          initials,
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w800,
                            fontSize: 32,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      userName,
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w700,
                        fontSize: 22,
                        color: textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userEmail.isNotEmpty ? userEmail : 'user@fieldnotes.app',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        color: textMuted,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.25),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            'Field Specialist',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: (isOnline ? AppColors.success : AppColors.error)
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: (isOnline ? AppColors.success : AppColors.error)
                                  .withValues(alpha: 0.25),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isOnline
                                      ? AppColors.success
                                      : AppColors.error,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isOnline ? 'Active Online' : 'Working Offline',
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isOnline
                                      ? AppColors.success
                                      : AppColors.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Quick Action Buttons Row
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                _showChangeEmailDialog(context, userEmail),
                            icon: const Icon(Icons.email_outlined, size: 16),
                            label: Text(
                              'Change Email',
                              style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                  color: borderCol, width: 1.2),
                              foregroundColor: textPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 11),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () =>
                                _showChangePasswordDialog(context),
                            icon: const Icon(Icons.lock_reset_rounded, size: 16),
                            label: Text(
                              'Change Password',
                              style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 11),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Activity Metrics
              Text(
                'FIELD ACTIVITY METRICS',
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: textMuted,
                  letterSpacing: 1.3,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricTile(
                      context,
                      label: 'Customers',
                      count: customerCount,
                      icon: Icons.business_rounded,
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMetricTile(
                      context,
                      label: 'Sites',
                      count: siteCount,
                      icon: Icons.location_city_rounded,
                      color: AppColors.accentCyan,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMetricTile(
                      context,
                      label: 'Notes',
                      count: noteCount,
                      icon: Icons.edit_note_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Account Credentials & Security
              Text(
                'ACCOUNT CREDENTIALS & SECURITY',
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: textMuted,
                  letterSpacing: 1.3,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: cardBg,
                  border: Border.all(color: borderCol, width: 1),
                ),
                child: Column(
                  children: [
                    _buildCredentialRow(
                      context,
                      icon: Icons.person_rounded,
                      label: 'Display Name',
                      value: userName,
                      actionLabel: 'Edit',
                      onAction: () => _showEditNameDialog(context, userName),
                    ),
                    Divider(height: 1, color: borderCol),
                    _buildCredentialRow(
                      context,
                      icon: Icons.email_rounded,
                      label: 'Email Address',
                      value: userEmail.isNotEmpty ? userEmail : 'Not set',
                      actionLabel: 'Change',
                      onAction: () =>
                          _showChangeEmailDialog(context, userEmail),
                    ),
                    Divider(height: 1, color: borderCol),
                    _buildCredentialRow(
                      context,
                      icon: Icons.lock_rounded,
                      label: 'Account Password',
                      value: '••••••••••••',
                      actionLabel: 'Change',
                      onAction: () => _showChangePasswordDialog(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricTile(
    BuildContext context, {
    required String label,
    required int count,
    required IconData icon,
    required Color color,
  }) {
    final cardBg = context.surfaceColor;
    final borderCol = context.borderColor;
    final textPrimary = context.textPrimaryColor;
    final textMuted = context.textMutedColor;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: cardBg,
        border: Border.all(color: borderCol, width: 1),
      ),
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: color.withValues(alpha: 0.12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 10),
          Text(
            count.toString(),
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 12,
              color: textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCredentialRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final textPrimary = context.textPrimaryColor;
    final textMuted = context.textMutedColor;
    final surfaceSubtle = context.surfaceSubtle;
    final borderCol = context.borderColor;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: surfaceSubtle,
              border: Border.all(color: borderCol, width: 1),
            ),
            child: Icon(icon, size: 18, color: textMuted),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: textMuted,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
              ],
            ),
          ),
          if (onAction != null && actionLabel != null)
            GestureDetector(
              onTap: onAction,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: AppColors.primary.withValues(alpha: 0.10),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    width: 1,
                  ),
                ),
                child: Text(
                  actionLabel,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
