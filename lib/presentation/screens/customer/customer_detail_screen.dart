import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../bloc/customer/customer_bloc.dart';
import '../../../bloc/note/note_bloc.dart';
import '../../../bloc/site/site_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/customer.dart';
import '../../../models/site.dart';
import 'customer_form_screen.dart';
import '../note/note_form_screen.dart';
import '../note/note_list_screen.dart';
import '../site/site_form_screen.dart';

class CustomerDetailScreen extends StatefulWidget {
  final Customer? customer;

  const CustomerDetailScreen({super.key, this.customer});

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  late Customer? _customer;

  @override
  void initState() {
    super.initState();
    _customer = widget.customer;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_customer == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Customer) {
        _customer = args;
      }
    }
    if (_customer != null) {
      context.read<SiteBloc>().add(LoadSites(customerUuid: _customer!.uuid));
    }
  }

  void _showSiteOptions(BuildContext context, Site site) {
    final surfaceColor = context.surfaceColor;
    final textPrimary = context.textPrimaryColor;
    final textMuted = context.textMutedColor;
    final borderCol = context.borderColor;

    showModalBottomSheet(
      context: context,
      backgroundColor: surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: borderCol,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.location_on_rounded,
                        color: AppColors.accent, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          site.siteName,
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                          ),
                        ),
                        Text(
                          site.address ?? 'No address provided',
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
                ],
              ),
              const SizedBox(height: 20),
              // Option 1: View Site Notes
              _BottomSheetAction(
                icon: Icons.notes_rounded,
                title: 'View Site Notes',
                subtitle: 'All notes associated with this site',
                color: AppColors.primary,
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => Scaffold(
                        appBar: AppBar(
                          title: Text('${site.siteName} Notes'),
                        ),
                        body: NoteListScreen(initialSiteUuid: site.uuid),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              // Option 2: Add Note for this Site
              _BottomSheetAction(
                icon: Icons.add_comment_rounded,
                title: 'Add Note for this Site',
                subtitle: 'Record observation or issue immediately',
                color: AppColors.accent,
                onTap: () async {
                  Navigator.pop(ctx);
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => NoteFormScreen(initialSiteUuid: site.uuid),
                    ),
                  );
                  if (!context.mounted) return;
                  context.read<NoteBloc>().add(const LoadNotes());
                },
              ),
              const SizedBox(height: 8),
              // Option 3: Edit Site
              _BottomSheetAction(
                icon: Icons.edit_outlined,
                title: 'Edit Site Details',
                subtitle: 'Update name, facility, or address',
                color: AppColors.info,
                onTap: () async {
                  Navigator.pop(ctx);
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => SiteFormScreen(site: site)),
                  );
                  if (context.mounted) {
                    context.read<SiteBloc>().add(LoadSites(customerUuid: _customer!.uuid));
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scaffoldBg = context.scaffoldBg;
    final textPrimary = context.textPrimaryColor;
    final surfaceSubtle = context.surfaceSubtle;
    final borderCol = context.borderColor;

    if (_customer == null) {
      return Scaffold(
        backgroundColor: scaffoldBg,
        appBar: AppBar(title: const Text('Customer Detail')),
        body: const Center(child: Text('No customer selected')),
      );
    }

    final initials = _customer!.name.isNotEmpty
        ? _customer!.name
            .split(' ')
            .take(2)
            .map((w) => w.isEmpty ? '' : w[0].toUpperCase())
            .join()
        : 'C';

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
            child: Icon(Icons.arrow_back_ios_new_rounded,
                size: 16, color: textPrimary),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _customer!.name,
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CustomerFormScreen(customer: _customer),
                ),
              );
              if (!context.mounted) return;
              final custState = context.read<CustomerBloc>().state;
              if (custState is CustomerLoaded) {
                final found = custState.customers.firstWhere(
                  (c) => c.uuid == _customer!.uuid,
                  orElse: () => _customer!,
                );
                setState(() => _customer = found);
              }
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: surfaceSubtle,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: borderCol, width: 1),
              ),
              child: Icon(Icons.edit_outlined,
                  size: 18, color: textPrimary),
            ),
          ),
          GestureDetector(
            onTap: () => _showDeleteDialog(context),
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.25), width: 1),
              ),
              child: const Icon(Icons.delete_outline_rounded,
                  size: 18, color: AppColors.error),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildCustomerCard(context, initials),
            const SizedBox(height: 24),
            _buildSitesSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerCard(BuildContext context, String initials) {
    final isDark = context.isDarkMode;
    final textPrimary = context.textPrimaryColor;
    final textMuted = context.textMutedColor;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  AppColors.primary.withValues(alpha: 0.2),
                  AppColors.darkSurfaceCard,
                ]
              : [
                  AppColors.primary.withValues(alpha: 0.08),
                  Colors.white,
                ],
        ),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
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
                  fontSize: 22,
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
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _customer!.name,
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                        ),
                      ),
                    ),
                    if (_customer!.syncPending)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.cloud_upload_outlined,
                                size: 11, color: AppColors.warning),
                            const SizedBox(width: 3),
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
                      ),
                  ],
                ),
                if (_customer!.contactInfo != null &&
                    _customer!.contactInfo!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.contact_page_outlined,
                          size: 14, color: textMuted),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _customer!.contactInfo!,
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            color: textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSitesSection(BuildContext context) {
    final textPrimary = context.textPrimaryColor;
    final textMuted = context.textMutedColor;
    final cardBg = context.surfaceColor;
    final borderCol = context.borderColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SITES & FACILITIES',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: textMuted,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  'Tap site card for site notes & actions',
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    color: textMuted,
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        SiteFormScreen(initialCustomerUuid: _customer!.uuid),
                  ),
                );
                if (!context.mounted) return;
                context
                    .read<SiteBloc>()
                    .add(LoadSites(customerUuid: _customer!.uuid));
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: AppColors.primary.withValues(alpha: 0.15),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add_rounded,
                        size: 16, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      'Add Site',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        BlocBuilder<SiteBloc, SiteState>(
          builder: (context, state) {
            if (state is SiteLoading) {
              return const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
              );
            }

            if (state is SiteLoaded) {
              final sites = state.sites
                  .where((s) => s.customerUuid == _customer!.uuid)
                  .toList();

              if (sites.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: cardBg,
                    border: Border.all(color: borderCol, width: 1),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.location_off_outlined,
                            color: textMuted, size: 36),
                        const SizedBox(height: 12),
                        Text(
                          'No sites found for this customer',
                          style: GoogleFonts.outfit(
                            color: textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tap "+ Add Site" above to register facility locations.',
                          style: GoogleFonts.outfit(
                            color: textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sites.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final site = sites[index];
                  return GestureDetector(
                    onTap: () => _showSiteOptions(context, site),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: cardBg,
                        border: Border.all(color: borderCol, width: 1),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(11),
                                color: AppColors.accent.withValues(alpha: 0.12),
                                border: Border.all(
                                  color: AppColors.accent.withValues(alpha: 0.25),
                                  width: 1,
                                ),
                              ),
                              child: const Icon(Icons.location_on_outlined,
                                  color: AppColors.accent, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    site.siteName,
                                    style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    site.address ?? 'No address provided',
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
                            // Quick button: Site Notes
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => Scaffold(
                                      appBar: AppBar(
                                        title: Text('${site.siteName} Notes'),
                                      ),
                                      body: NoteListScreen(initialSiteUuid: site.uuid),
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 5),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.note_alt_outlined,
                                        size: 13, color: AppColors.primary),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Notes',
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
                            const SizedBox(width: 4),
                            IconButton(
                              icon: Icon(Icons.more_vert_rounded,
                                  size: 18, color: textMuted),
                              onPressed: () => _showSiteOptions(context, site),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Customer'),
        content: Text(
            'Delete "${_customer!.name}"? All associated sites and references will also be removed.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<CustomerBloc>().add(DeleteCustomer(_customer!.uuid));
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _BottomSheetAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _BottomSheetAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final surfaceSubtle = context.surfaceSubtle;
    final textPrimary = context.textPrimaryColor;
    final textMuted = context.textMutedColor;
    final borderCol = context.borderColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: surfaceSubtle,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderCol, width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      color: textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 13, color: textMuted.withValues(alpha: 0.6)),
          ],
        ),
      ),
    );
  }
}
