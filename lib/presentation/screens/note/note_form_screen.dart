import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../bloc/note/note_bloc.dart';
import '../../../bloc/settings/settings_bloc.dart';
import '../../../bloc/site/site_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/field_note.dart';
import '../../../models/note_status.dart';
import '../../utils/permissions.dart';

class NoteFormScreen extends StatefulWidget {
  final FieldNote? note;
  final String? initialSiteUuid;

  const NoteFormScreen({super.key, this.note, this.initialSiteUuid});

  @override
  State<NoteFormScreen> createState() => _NoteFormScreenState();
}

class _NoteFormScreenState extends State<NoteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  late final TextEditingController _locationController;

  String? _selectedSiteUuid;
  NoteStatus _selectedStatus = NoteStatus.open;
  File? _selectedPhoto;
  String? _existingPhotoUrl;
  bool _isLocating = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _descController =
        TextEditingController(text: widget.note?.description ?? '');
    _locationController =
        TextEditingController(text: widget.note?.location ?? '');

    _selectedSiteUuid = widget.note?.siteUuid ?? widget.initialSiteUuid;
    _existingPhotoUrl = widget.note?.photoUrl;

    if (widget.note != null) {
      _selectedStatus = widget.note!.status;
    } else {
      final settingsState = context.read<SettingsBloc>().state;
      if (settingsState is SettingsLoaded) {
        _selectedStatus = NoteStatus.fromServer(settingsState.defaultStatus);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _fetchLocation() async {
    setState(() => _isLocating = true);
    final loc = await PermissionHelper.getCurrentLocationString();
    setState(() => _isLocating = false);

    if (loc != null) {
      _locationController.text = loc;
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Could not obtain GPS location. Ensure location permission is granted.')),
        );
      }
    }
  }

  void _choosePhotoSource() {
    final surfaceColor = context.surfaceColor;
    final textPrimary = context.textPrimaryColor;
    final borderCol = context.borderColor;

    showModalBottomSheet(
      context: context,
      backgroundColor: surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: borderCol,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Attach Photo',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              _BottomSheetOption(
                icon: Icons.camera_alt_outlined,
                label: 'Take Photo',
                subtitle: 'Open device camera',
                onTap: () async {
                  Navigator.pop(ctx);
                  final file = await PermissionHelper.pickFromCamera();
                  if (file != null) setState(() => _selectedPhoto = file);
                },
              ),
              const SizedBox(height: 8),
              _BottomSheetOption(
                icon: Icons.photo_library_outlined,
                label: 'Choose from Gallery',
                subtitle: 'Select from media library',
                onTap: () async {
                  Navigator.pop(ctx);
                  final file = await PermissionHelper.pickFromGallery();
                  if (file != null) setState(() => _selectedPhoto = file);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSiteUuid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a site')),
      );
      return;
    }

    final title = _titleController.text.trim();
    final description = _descController.text.trim();
    final location = _locationController.text.trim();

    if (widget.note == null) {
      context.read<NoteBloc>().add(CreateNoteEvent(
            siteUuid: _selectedSiteUuid!,
            title: title,
            description: description.isEmpty ? null : description,
            location: location.isEmpty ? null : location,
            status: _selectedStatus,
            photoFile: _selectedPhoto,
          ));
    } else {
      final updated = widget.note!.copyWith(
        siteUuid: _selectedSiteUuid!,
        title: title,
        description: description.isEmpty ? null : description,
        location: location.isEmpty ? null : location,
        status: _selectedStatus,
      );
      context.read<NoteBloc>().add(UpdateNoteEvent(
            updated,
            newPhotoFile: _selectedPhoto,
          ));
    }

    Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.note != null;
    final scaffoldBg = context.scaffoldBg;
    final textPrimary = context.textPrimaryColor;
    final textMuted = context.textMutedColor;
    final cardBg = context.surfaceColor;
    final surfaceSubtle = context.surfaceSubtle;
    final borderCol = context.borderColor;

    final sitesState = context.watch<SiteBloc>().state;
    final sites = sitesState is SiteLoaded ? sitesState.sites : [];

    if (_selectedSiteUuid == null && sites.isNotEmpty) {
      _selectedSiteUuid = sites.first.uuid;
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
            child: Icon(Icons.arrow_back_ios_new_rounded,
                size: 16, color: textPrimary),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEditing ? 'Edit Field Note' : 'New Field Note',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
        ),
        actions: [
          if (isEditing)
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
                      color: AppColors.error.withValues(alpha: 0.25),
                      width: 1),
                ),
                child: const Icon(Icons.delete_outline_rounded,
                    size: 18, color: AppColors.error),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (sites.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.warning.withValues(alpha: 0.25),
                        width: 1),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded,
                          color: AppColors.warning, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'No sites available. Create a customer and site first.',
                          style: GoogleFonts.outfit(
                            color: AppColors.warning,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else ...[
                Text(
                  'FACILITY / SITE',
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: textMuted,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _selectedSiteUuid,
                  dropdownColor: cardBg,
                  style: GoogleFonts.outfit(
                      color: textPrimary, fontSize: 14),
                  icon: Icon(Icons.expand_more_rounded,
                      color: textMuted),
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.location_city_rounded,
                        size: 20, color: textMuted),
                    hintText: 'Select a site',
                  ),
                  items: sites.map((s) {
                    return DropdownMenuItem<String>(
                      value: s.uuid,
                      child: Text(s.siteName),
                    );
                  }).toList(),
                  onChanged: (val) =>
                      setState(() => _selectedSiteUuid = val),
                  validator: (v) =>
                      v == null ? 'Please select a site' : null,
                ),
              ],
              const SizedBox(height: 20),
              Text(
                'NOTE TITLE',
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: textMuted,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                style: GoogleFonts.outfit(
                    color: textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.title_rounded, size: 20, color: textMuted),
                  hintText: 'Enter observation or issue title',
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 20),
              Text(
                'STATUS',
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: textMuted,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: NoteStatus.values.map((status) {
                    final isSelected = _selectedStatus == status;
                    final color = _getStatusColor(status);
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _selectedStatus = status),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? color.withValues(alpha: 0.18)
                                : surfaceSubtle,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? color.withValues(alpha: 0.6)
                                  : borderCol,
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Text(
                            status.displayName,
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected ? color : textMuted,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'GPS LOCATION',
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: textMuted,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _locationController,
                      style: GoogleFonts.outfit(
                          color: textPrimary, fontSize: 14),
                      decoration: InputDecoration(
                        prefixIcon:
                            Icon(Icons.my_location_rounded, size: 20, color: textMuted),
                        hintText: 'GPS coordinates or tag',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _isLocating ? null : _fetchLocation,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: _isLocating
                            ? null
                            : AppColors.primaryGradient,
                        color: _isLocating
                            ? surfaceSubtle
                            : null,
                        boxShadow: _isLocating
                            ? []
                            : [
                                BoxShadow(
                                  color: AppColors.primary
                                      .withValues(alpha: 0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                      ),
                      child: _isLocating
                          ? const Center(
                              child: SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primary),
                              ),
                            )
                          : const Icon(Icons.gps_fixed_rounded,
                              color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'OBSERVATIONS & NOTES',
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: textMuted,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descController,
                maxLines: 4,
                style: GoogleFonts.outfit(
                    color: textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(bottom: 60),
                    child: Icon(Icons.notes_rounded, size: 20, color: textMuted),
                  ),
                  hintText: 'Detailed field observations, measurements, equipment condition...',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'PHOTO ATTACHMENT',
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: textMuted,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              _buildPhotoSection(context),
              const SizedBox(height: 32),
              GestureDetector(
                onTap: _save,
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: AppColors.primaryGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.save_rounded,
                            color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          isEditing ? 'Save Changes' : 'Create Note',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoSection(BuildContext context) {
    final hasPhoto = _selectedPhoto != null ||
        (_existingPhotoUrl != null && _existingPhotoUrl!.isNotEmpty);
    final cardBg = context.surfaceColor;
    final surfaceSubtle = context.surfaceSubtle;
    final borderCol = context.borderColor;
    final textMuted = context.textMutedColor;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: cardBg,
        border: Border.all(color: borderCol, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_selectedPhoto != null) ...[
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.file(
                _selectedPhoto!,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ] else if (_existingPhotoUrl != null &&
              _existingPhotoUrl!.isNotEmpty) ...[
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: _existingPhotoUrl!.startsWith('http')
                  ? Image.network(
                      _existingPhotoUrl!,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    )
                  : Image.file(
                      File(_existingPhotoUrl!),
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'Photo: $_existingPhotoUrl',
                          style: GoogleFonts.outfit(
                              color: textMuted, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
            ),
          ] else ...[
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: surfaceSubtle,
                      border: Border.all(color: borderCol, width: 1),
                    ),
                    child: Icon(Icons.camera_alt_outlined,
                        color: textMuted, size: 24),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'No photo attached yet',
                    style: GoogleFonts.outfit(
                        color: textMuted, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
          Padding(
            padding: const EdgeInsets.all(12),
            child: OutlinedButton.icon(
              onPressed: _choosePhotoSource,
              icon: const Icon(Icons.add_a_photo_outlined, size: 18),
              label: Text(
                hasPhoto ? 'Change Photo' : 'Attach Photo',
                style: GoogleFonts.outfit(fontSize: 14),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.5)),
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Field Note'),
        content: const Text(
            'Are you sure you want to delete this note? It will be marked for deletion locally and removed upon next cloud sync.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<NoteBloc>().add(DeleteNoteEvent(widget.note!.uuid));
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _BottomSheetOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _BottomSheetOption({
    required this.icon,
    required this.label,
    required this.subtitle,
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
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: surfaceSubtle,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderCol, width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: AppColors.primary.withValues(alpha: 0.15),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.outfit(
                      fontSize: 12, color: textMuted),
                ),
              ],
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: textMuted),
          ],
        ),
      ),
    );
  }
}
