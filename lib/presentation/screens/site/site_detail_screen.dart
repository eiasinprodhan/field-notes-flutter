import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../bloc/customer/customer_bloc.dart';
import '../../../bloc/note/note_bloc.dart';
import '../../../bloc/site/site_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/site.dart';
import '../note/note_detail_screen.dart';
import '../note/note_form_screen.dart';
import 'site_form_screen.dart';

class SiteDetailScreen extends StatefulWidget {
  final Site site;

  const SiteDetailScreen({super.key, required this.site});

  @override
  State<SiteDetailScreen> createState() => _SiteDetailScreenState();
}

class _SiteDetailScreenState extends State<SiteDetailScreen> {
  late Site _site;

  @override
  void initState() {
    super.initState();
    _site = widget.site;
    context.read<NoteBloc>().add(LoadNotes(siteUuid: _site.uuid));
  }

  void _showDeleteDialog() {
    final surfaceColor = context.surfaceColor;
    final textPrimary = context.textPrimaryColor;
    final textMuted = context.textMutedColor;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Delete Site',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: textPrimary,
          ),
        ),
        content: Text(
          'Delete "${_site.siteName}"? All associated inspection notes will also be removed.',
          style: GoogleFonts.outfit(fontSize: 14, color: textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.outfit(color: textMuted)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<SiteBloc>().add(DeleteSite(_site.uuid));
              Navigator.pop(context);
            },
            child: Text('Delete', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
          ),
        ],
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

    final customerState = context.watch<CustomerBloc>().state;
    String? customerName;
    String? customerContact;
    if (customerState is CustomerLoaded) {
      final match = customerState.customers.where((c) => c.uuid == _site.customerUuid);
      if (match.isNotEmpty) {
        customerName = match.first.name;
        customerContact = match.first.contactInfo;
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
          _site.siteName,
          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: textPrimary),
        ),
        actions: [
          IconButton(
            icon: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: surfaceSubtle,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: borderCol, width: 1),
              ),
              child: Icon(Icons.edit_outlined, size: 18, color: textPrimary),
            ),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SiteFormScreen(site: _site)),
              );
              if (!context.mounted) return;
              final siteState = context.read<SiteBloc>().state;
              if (siteState is SiteLoaded) {
                final found = siteState.sites.firstWhere(
                  (s) => s.uuid == _site.uuid,
                  orElse: () => _site,
                );
                setState(() => _site = found);
              }
            },
          ),
          IconButton(
            icon: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.error.withValues(alpha: 0.25), width: 1),
              ),
              child: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
            ),
            onPressed: _showDeleteDialog,
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_site_detail_screen',
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text('New Note', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
        onPressed: () async {
          final noteBloc = context.read<NoteBloc>();
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => NoteFormScreen(initialSiteUuid: _site.uuid)),
          );
          if (!mounted) return;
          noteBloc.add(LoadNotes(siteUuid: _site.uuid));
        },
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Site Overview Card
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: cardBg,
                border: Border.all(color: borderCol, width: 1),
              ),
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: AppColors.accent.withValues(alpha: 0.12),
                          border: Border.all(color: AppColors.accent.withValues(alpha: 0.25), width: 1),
                        ),
                        child: const Icon(Icons.location_on_outlined, color: AppColors.accent, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _site.siteName,
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              customerName != null ? 'Customer: $customerName' : 'Facility Site',
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: (_site.syncPending ? AppColors.warning : AppColors.success)
                              .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _site.syncPending ? 'Local Only' : 'Synced',
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: _site.syncPending ? AppColors.warning : AppColors.success,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_site.address != null && _site.address!.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.map_outlined, size: 16, color: textMuted),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _site.address!,
                            style: GoogleFonts.outfit(fontSize: 13, color: textMuted),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (customerContact != null && customerContact.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.phone_outlined, size: 16, color: textMuted),
                        const SizedBox(width: 8),
                        Text(
                          customerContact,
                          style: GoogleFonts.outfit(fontSize: 13, color: textMuted),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Site Field Notes section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'INSPECTION NOTES',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: textMuted,
                    letterSpacing: 1.2,
                  ),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Note'),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => NoteFormScreen(initialSiteUuid: _site.uuid)),
                    );
                    if (context.mounted) {
                      context.read<NoteBloc>().add(LoadNotes(siteUuid: _site.uuid));
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),

            BlocBuilder<NoteBloc, NoteState>(
              builder: (context, state) {
                if (state is NoteLoading) {
                  return const Center(child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ));
                }

                if (state is NoteLoaded) {
                  final siteNotes = state.notes.where((n) => n.siteUuid == _site.uuid).toList();

                  if (siteNotes.isEmpty) {
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
                            Icon(Icons.note_alt_outlined, size: 36, color: textMuted),
                            const SizedBox(height: 10),
                            Text(
                              'No field notes found for this site',
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tap "+ New Note" to capture observations or photos',
                              style: GoogleFonts.outfit(fontSize: 12, color: textMuted),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: siteNotes.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final note = siteNotes[index];
                      return GestureDetector(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => NoteDetailScreen(note: note)),
                          );
                          if (context.mounted) {
                            context.read<NoteBloc>().add(LoadNotes(siteUuid: _site.uuid));
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: cardBg,
                            border: Border.all(color: borderCol, width: 1),
                          ),
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              Container(
                                width: 10,
                                height: 36,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: note.status.name == 'completed'
                                      ? AppColors.statusResolved
                                      : (note.status.name == 'inProgress'
                                          ? AppColors.statusInProgress
                                          : AppColors.statusOpen),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      note.title,
                                      style: GoogleFonts.outfit(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: textPrimary,
                                      ),
                                    ),
                                    if (note.description != null && note.description!.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        note.description!,
                                        style: GoogleFonts.outfit(fontSize: 12, color: textMuted),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(Icons.arrow_forward_ios_rounded, size: 14, color: textMuted),
                            ],
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
        ),
      ),
    );
  }
}
