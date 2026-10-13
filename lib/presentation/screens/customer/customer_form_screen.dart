import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../bloc/customer/customer_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/customer.dart';

class CustomerFormScreen extends StatefulWidget {
  final Customer? customer;

  const CustomerFormScreen({super.key, this.customer});

  @override
  State<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends State<CustomerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _contactController;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.customer?.name ?? '');
    _contactController =
        TextEditingController(text: widget.customer?.contactInfo ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final name = _nameController.text.trim();
    final contact = _contactController.text.trim();

    if (widget.customer == null) {
      context.read<CustomerBloc>().add(CreateCustomer(
            name: name,
            contactInfo: contact.isEmpty ? null : contact,
          ));
    } else {
      context.read<CustomerBloc>().add(UpdateCustomer(
            widget.customer!.copyWith(
              name: name,
              contactInfo: contact.isEmpty ? null : contact,
            ),
          ));
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.customer != null;
    final scaffoldBg = context.scaffoldBg;
    final textPrimary = context.textPrimaryColor;
    final textMuted = context.textMutedColor;
    final surfaceSubtle = context.surfaceSubtle;
    final borderCol = context.borderColor;

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
          isEditing ? 'Edit Customer' : 'New Customer',
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
              Text(
                'CUSTOMER / COMPANY NAME',
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: textMuted,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                style: GoogleFonts.outfit(
                    color: textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.business_rounded, size: 20, color: textMuted),
                  hintText: 'Enter customer or company name',
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Please enter customer name'
                    : null,
              ),
              const SizedBox(height: 20),
              Text(
                'CONTACT INFORMATION',
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: textMuted,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _contactController,
                maxLines: 3,
                style: GoogleFonts.outfit(
                    color: textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(bottom: 40),
                    child: Icon(Icons.contact_mail_outlined, size: 20, color: textMuted),
                  ),
                  hintText: 'Phone, email, address, or contact person...',
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
                          isEditing ? 'Save Changes' : 'Create Customer',
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
