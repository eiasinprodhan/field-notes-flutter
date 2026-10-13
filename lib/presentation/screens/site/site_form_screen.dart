import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../bloc/customer/customer_bloc.dart';
import '../../../bloc/site/site_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/site.dart';

class SiteFormScreen extends StatefulWidget {
  final Site? site;
  final String? initialCustomerUuid;

  const SiteFormScreen({super.key, this.site, this.initialCustomerUuid});

  @override
  State<SiteFormScreen> createState() => _SiteFormScreenState();
}

class _SiteFormScreenState extends State<SiteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _siteNameController;
  late final TextEditingController _addressController;
  String? _selectedCustomerUuid;

  @override
  void initState() {
    super.initState();
    _siteNameController =
        TextEditingController(text: widget.site?.siteName ?? '');
    _addressController =
        TextEditingController(text: widget.site?.address ?? '');
    _selectedCustomerUuid =
        widget.site?.customerUuid ?? widget.initialCustomerUuid;
  }

  @override
  void dispose() {
    _siteNameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCustomerUuid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a customer for this site')),
      );
      return;
    }

    final siteName = _siteNameController.text.trim();
    final address = _addressController.text.trim();

    if (widget.site == null) {
      context.read<SiteBloc>().add(CreateSite(
            customerUuid: _selectedCustomerUuid!,
            siteName: siteName,
            address: address.isEmpty ? null : address,
          ));
    } else {
      context.read<SiteBloc>().add(UpdateSite(
            widget.site!.copyWith(
              customerUuid: _selectedCustomerUuid!,
              siteName: siteName,
              address: address.isEmpty ? null : address,
            ),
          ));
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.site != null;
    final scaffoldBg = context.scaffoldBg;
    final textPrimary = context.textPrimaryColor;
    final textMuted = context.textMutedColor;
    final cardBg = context.surfaceColor;
    final surfaceSubtle = context.surfaceSubtle;
    final borderCol = context.borderColor;

    final customersState = context.watch<CustomerBloc>().state;
    final customers =
        customersState is CustomerLoaded ? customersState.customers : [];

    if (_selectedCustomerUuid == null && customers.isNotEmpty) {
      _selectedCustomerUuid = customers.first.uuid;
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
          isEditing ? 'Edit Site' : 'New Site',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (customers.isEmpty)
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
                          'No customers found. Create a customer before adding a site.',
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
                  'ASSOCIATED CUSTOMER',
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: textMuted,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _selectedCustomerUuid,
                  dropdownColor: cardBg,
                  style: GoogleFonts.outfit(
                      color: textPrimary, fontSize: 14),
                  icon: Icon(Icons.expand_more_rounded,
                      color: textMuted),
                  decoration: InputDecoration(
                    prefixIcon:
                        Icon(Icons.business_rounded, size: 20, color: textMuted),
                    hintText: 'Select customer',
                  ),
                  items: customers.map((c) {
                    return DropdownMenuItem<String>(
                      value: c.uuid,
                      child: Text(c.name),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedCustomerUuid = val;
                    });
                  },
                  validator: (v) =>
                      v == null ? 'Please select a customer' : null,
                ),
              ],
              const SizedBox(height: 20),
              Text(
                'SITE / FACILITY NAME',
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: textMuted,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _siteNameController,
                style: GoogleFonts.outfit(
                    color: textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  prefixIcon:
                      Icon(Icons.location_city_rounded, size: 20, color: textMuted),
                  hintText: 'Enter site, warehouse, or plant name',
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Please enter site name'
                    : null,
              ),
              const SizedBox(height: 20),
              Text(
                'ADDRESS & LOCATION DETAILS',
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: textMuted,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _addressController,
                maxLines: 3,
                style: GoogleFonts.outfit(
                    color: textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(bottom: 40),
                    child: Icon(Icons.place_outlined, size: 20, color: textMuted),
                  ),
                  hintText: 'Street address, building, floor, or GPS description',
                  alignLabelWithHint: true,
                ),
              ),
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
                          isEditing ? 'Save Changes' : 'Create Site',
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
            ],
          ),
        ),
      ),
    );
  }
}
