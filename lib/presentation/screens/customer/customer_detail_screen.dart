import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../bloc/customer/customer_bloc.dart';
import '../../../bloc/site/site_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/customer.dart';
import 'customer_form_screen.dart';
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

  @override
  Widget build(BuildContext context) {
    if (_customer == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.surfaceCardLight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08), width: 1),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                size: 16, color: AppColors.onSurface),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _customer!.name,
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
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
                color: AppColors.surfaceCardLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08), width: 1),
              ),
              child: const Icon(Icons.edit_outlined,
                  size: 18, color: AppColors.onSurfaceMuted),
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
            _buildCustomerCard(initials),
            const SizedBox(height: 24),
            _buildSitesSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerCard(String initials) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.12),
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
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: AppColors.primaryGradient,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
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
                          color: AppColors.onSurface,
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
                            Icon(Icons.cloud_upload_outlined,
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
                          size: 14, color: AppColors.onSurfaceMuted),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _customer!.contactInfo!,
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            color: AppColors.onSurfaceMuted,
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

  Widget _buildSitesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'SITES & FACILITIES',
              style: GoogleFonts.outfit(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurfaceMuted,
                letterSpacing: 1.2,
              ),
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
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
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
                        size: 14, color: AppColors.primary),
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
        const SizedBox(height: 12),
        BlocBuilder<SiteBloc, SiteState>(
          builder: (context, state) {
            if (state is SiteLoading) {
              return const Padding(
                padding: EdgeInsets.all(32),
                child:
                    Center(child: CircularProgressIndicator(color: AppColors.primary)),
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
                    color: AppColors.surfaceCard,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.06),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.location_off_outlined,
                          color: AppColors.onSurfaceMuted, size: 32),
                      const SizedBox(height: 10),
                      Text(
                        'No sites added yet',
                        style: GoogleFonts.outfit(
                          color: AppColors.onSurfaceMuted,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sites.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final site = sites[index];
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: AppColors.surfaceCard,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.06),
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(11),
                              color: AppColors.accent.withValues(alpha: 0.12),
                              border: Border.all(
                                color:
                                    AppColors.accent.withValues(alpha: 0.2),
                                width: 1,
                              ),
                            ),
                            child: const Icon(Icons.location_on_outlined,
                                color: AppColors.accent, size: 18),
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
                                    color: AppColors.onSurface,
                                  ),
                                ),
                                if (site.address != null &&
                                    site.address!.isNotEmpty)
                                  Text(
                                    site.address!,
                                    style: GoogleFonts.outfit(
                                      fontSize: 12,
                                      color: AppColors.onSurfaceMuted,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  )
                                else
                                  Text(
                                    'No address',
                                    style: GoogleFonts.outfit(
                                      fontSize: 12,
                                      color: AppColors.onSurfaceMuted
                                          .withValues(alpha: 0.5),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined,
                                size: 18,
                                color: AppColors.onSurfaceMuted),
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        SiteFormScreen(site: site)),
                              );
                              if (!context.mounted) return;
                              context.read<SiteBloc>().add(
                                  LoadSites(customerUuid: _customer!.uuid));
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete_outline_rounded,
                                size: 18,
                                color: AppColors.error
                                    .withValues(alpha: 0.7)),
                            onPressed: () {
                              context.read<SiteBloc>().add(DeleteSite(
                                  site.uuid,
                                  customerUuid: _customer!.uuid));
                            },
                          ),
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
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Customer'),
        content: Text(
            'Delete "${_customer!.name}"? All associated sites will also be removed.'),
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
