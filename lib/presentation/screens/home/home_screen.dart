import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../bloc/auth/auth_bloc.dart';
import '../../../bloc/connectivity/connectivity_bloc.dart';
import '../../../bloc/customer/customer_bloc.dart';
import '../../../bloc/note/note_bloc.dart';
import '../../../bloc/site/site_bloc.dart';
import '../../../bloc/sync/sync_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/note_status.dart';
import '../customer/customer_detail_screen.dart';
import '../customer/customer_form_screen.dart';
import '../dashboard/dashboard_screen.dart';
import '../note/note_list_screen.dart';
import '../site/site_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final GlobalKey<NoteListScreenState> _noteListKey = GlobalKey<NoteListScreenState>();

  void _navigateToTab(int index, {NoteStatus? filterStatus}) {
    setState(() => _currentIndex = index);
    if (index == 1 && filterStatus != null) {
      _noteListKey.currentState?.setStatusFilter(filterStatus);
    }
  }

  String _getSectionTitle(int index) {
    switch (index) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Field Notes';
      case 2:
        return 'Customers';
      case 3:
        return 'Sites & Facilities';
      default:
        return 'Field Notes';
    }
  }

  IconData _getSectionIcon(int index) {
    switch (index) {
      case 0:
        return Icons.dashboard_rounded;
      case 1:
        return Icons.edit_note_rounded;
      case 2:
        return Icons.business_rounded;
      case 3:
        return Icons.location_city_rounded;
      default:
        return Icons.edit_note_rounded;
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text(
          'Are you sure you want to sign out of Field Notes? Any local unsynced data remains preserved safely in your local database.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthBloc>().add(LogoutRequested());
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final cardBg = context.surfaceColor;
    final borderCol = context.borderColor;
    final textPrimary = context.textPrimaryColor;
    final textMuted = context.textMutedColor;
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

    final connectivityState = context.watch<ConnectivityBloc>().state;
    final isOnline = connectivityState.isOnline;

    return Drawer(
      backgroundColor: cardBg,
      child: SafeArea(
        child: Column(
          children: [
            // Drawer Header
            InkWell(
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/profile');
              },
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            AppColors.primary.withValues(alpha: 0.25),
                            AppColors.accent.withValues(alpha: 0.1),
                            AppColors.darkSurfaceCard,
                          ]
                        : [
                            AppColors.primary.withValues(alpha: 0.12),
                            AppColors.accent.withValues(alpha: 0.05),
                            Colors.white,
                          ],
                  ),
                  border: Border(bottom: BorderSide(color: borderCol, width: 1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: AppColors.primaryGradient,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.35),
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
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: (isOnline
                                    ? AppColors.success
                                    : AppColors.error)
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: (isOnline
                                      ? AppColors.success
                                      : AppColors.error)
                                  .withValues(alpha: 0.3),
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
                              const SizedBox(width: 5),
                              Text(
                                isOnline ? 'Online' : 'Offline',
                                style: GoogleFonts.outfit(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
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
                    const SizedBox(height: 12),
                    Text(
                      userName,
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      userEmail.isNotEmpty ? userEmail : 'user@fieldnotes.app',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          'Profile',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward_ios_rounded,
                            size: 10, color: AppColors.primary),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Navigation List Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
                    child: Text(
                      'MAIN MENU',
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: textMuted,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  _buildDrawerNavItem(
                    context,
                    title: 'Dashboard',
                    icon: Icons.dashboard_rounded,
                    isSelected: _currentIndex == 0,
                    onTap: () {
                      Navigator.pop(context);
                      setState(() => _currentIndex = 0);
                    },
                  ),
                  _buildDrawerNavItem(
                    context,
                    title: 'Field Notes',
                    icon: Icons.edit_note_rounded,
                    isSelected: _currentIndex == 1,
                    onTap: () {
                      Navigator.pop(context);
                      setState(() => _currentIndex = 1);
                    },
                  ),
                  _buildDrawerNavItem(
                    context,
                    title: 'Customers',
                    icon: Icons.business_rounded,
                    isSelected: _currentIndex == 2,
                    onTap: () {
                      Navigator.pop(context);
                      setState(() => _currentIndex = 2);
                    },
                  ),
                  _buildDrawerNavItem(
                    context,
                    title: 'Sites & Facilities',
                    icon: Icons.location_city_rounded,
                    isSelected: _currentIndex == 3,
                    onTap: () {
                      Navigator.pop(context);
                      setState(() => _currentIndex = 3);
                    },
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Divider(color: borderCol, height: 1),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 6),
                    child: Text(
                      'PREFERENCES & PROFILE',
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: textMuted,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  _buildDrawerNavItem(
                    context,
                    title: 'Profile',
                    icon: Icons.person_rounded,
                    isSelected: false,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/profile');
                    },
                  ),
                  _buildDrawerNavItem(
                    context,
                    title: 'Settings',
                    icon: Icons.settings_rounded,
                    isSelected: false,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/settings');
                    },
                  ),
                  _buildDrawerNavItem(
                    context,
                    title: 'Cloud Sync Status',
                    icon: Icons.cloud_sync_rounded,
                    isSelected: false,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/sync-status');
                    },
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Divider(color: borderCol, height: 1),
                  ),

                  _buildDrawerNavItem(
                    context,
                    title: 'Sign Out',
                    icon: Icons.logout_rounded,
                    isSelected: false,
                    color: AppColors.error,
                    onTap: () {
                      Navigator.pop(context);
                      _showLogoutDialog(context);
                    },
                  ),
                ],
              ),
            ),

            // Drawer Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: borderCol, width: 1)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.offline_pin_rounded,
                      size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Field Notes v1.0.0 · Offline First',
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerNavItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    Color? color,
  }) {
    final textPrimary = context.textPrimaryColor;
    final textMuted = context.textMutedColor;
    final effectiveColor =
        color ?? (isSelected ? AppColors.primary : textPrimary);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primary.withValues(alpha: 0.12)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        dense: true,
        leading: Icon(
          icon,
          color: color ?? (isSelected ? AppColors.primary : textMuted),
          size: 20,
        ),
        title: Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: effectiveColor,
          ),
        ),
        trailing: isSelected
            ? Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                ),
              )
            : null,
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final scaffoldBg = context.scaffoldBg;
    final borderCol = context.borderColor;
    final textPrimary = context.textPrimaryColor;

    final connectivityState = context.watch<ConnectivityBloc>().state;
    final syncState = context.watch<SyncBloc>().state;
    final isOnline = connectivityState.isOnline;
    final isSyncing = syncState is SyncInProgress;

    return Scaffold(
      backgroundColor: scaffoldBg,
      drawer: _buildDrawer(context),
      appBar: AppBar(
        backgroundColor: scaffoldBg,
        surfaceTintColor: Colors.transparent,
        leading: Builder(
          builder: (ctx) => IconButton(
            tooltip: 'Open Menu',
            icon: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: context.surfaceSubtle,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: borderCol, width: 1),
              ),
              child: Icon(Icons.menu_rounded, size: 20, color: textPrimary),
            ),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: AppColors.primaryGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary
                        .withValues(alpha: isDark ? 0.35 : 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                _getSectionIcon(_currentIndex),
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _getSectionTitle(_currentIndex),
                style: GoogleFonts.outfit(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          _OnlineBadge(isOnline: isOnline),
          const SizedBox(width: 8),
          _SyncButton(isSyncing: isSyncing, isOnline: isOnline),
          const SizedBox(width: 12),
        ],
      ),
      body: MultiBlocListener(
        listeners: [
          // Auto-sync when internet comes back
          BlocListener<ConnectivityBloc, ConnectivityState>(
            listenWhen: (previous, current) =>
                !previous.isOnline && current.isOnline,
            listener: (context, state) {
              final auth = context.read<AuthBloc>().state;
              if (auth is Authenticated) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.wifi_rounded, color: Colors.white, size: 18),
                        SizedBox(width: 10),
                        Text('Connection restored · Auto-syncing data...'),
                      ],
                    ),
                    backgroundColor: AppColors.info,
                    duration: Duration(seconds: 2),
                  ),
                );
                context.read<SyncBloc>().add(SyncRequested());
              }
            },
          ),
          // Navigate to auth when logged out
          BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is Unauthenticated) {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('/auth', (route) => false);
              }
            },
          ),
          // Refresh entities on sync success
          BlocListener<SyncBloc, SyncState>(
            listener: (context, state) {
              if (state is SyncSuccess) {
                context.read<CustomerBloc>().add(LoadCustomers());
                context.read<SiteBloc>().add(const LoadSites());
                context.read<NoteBloc>().add(const LoadNotes());
              }
            },
          ),
        ],
        child: IndexedStack(
          index: _currentIndex,
          children: [
            DashboardScreen(onNavigateToTab: _navigateToTab),
            NoteListScreen(key: _noteListKey),
            const _CustomersView(),
            const SiteListScreen(showAppBar: false),
          ],
        ),
      ),
    );
  }
}

class _OnlineBadge extends StatelessWidget {
  final bool isOnline;
  const _OnlineBadge({required this.isOnline});

  @override
  Widget build(BuildContext context) {
    final color = isOnline ? AppColors.success : AppColors.error;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: [
                BoxShadow(color: color.withValues(alpha: 0.6), blurRadius: 4),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isOnline ? 'Online' : 'Offline',
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _SyncButton extends StatelessWidget {
  final bool isSyncing;
  final bool isOnline;
  const _SyncButton({required this.isSyncing, required this.isOnline});

  @override
  Widget build(BuildContext context) {
    final borderCol = context.borderColor;
    final surfaceSubtle = context.surfaceSubtle;
    final textMuted = context.textMutedColor;

    return GestureDetector(
      onTap: (isSyncing || !isOnline)
          ? null
          : () => context.read<SyncBloc>().add(SyncRequested()),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: surfaceSubtle,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: borderCol,
            width: 1,
          ),
        ),
        child: isSyncing
            ? const Center(
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
              )
            : Icon(
                Icons.sync_rounded,
                size: 18,
                color: isOnline ? textMuted : textMuted.withValues(alpha: 0.4),
              ),
      ),
    );
  }
}

class _CustomersView extends StatefulWidget {
  const _CustomersView();

  @override
  State<_CustomersView> createState() => _CustomersViewState();
}

class _CustomersViewState extends State<_CustomersView> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  String _selectedFilter = 'all'; // 'all', 'has_contact', 'local_only'
  String _selectedSort = 'a_z'; // 'a_z', 'z_a', 'newest', 'oldest'
  int _displayedCount = 10;
  bool _isLoadingMore = false;

  static const Map<String, String> _sortOptions = {
    'a_z': 'Name A–Z',
    'z_a': 'Name Z–A',
    'newest': 'Recently Updated',
    'oldest': 'Oldest First',
  };

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<CustomerBloc>().add(LoadCustomers());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  void _loadMore() {
    if (_isLoadingMore) return;
    setState(() => _isLoadingMore = true);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _displayedCount += 10;
          _isLoadingMore = false;
        });
      }
    });
  }

  void _resetPaging() {
    setState(() {
      _displayedCount = 10;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textPrimary = context.textPrimaryColor;
    final textMuted = context.textMutedColor;
    final borderCol = context.borderColor;
    final surfaceSubtle = context.surfaceSubtle;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BlocBuilder<CustomerBloc, CustomerState>(
        builder: (context, state) {
          if (state is CustomerLoading || state is CustomerInitial) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state is CustomerLoaded) {
            final allCustomers = state.customers;
            final query = _searchController.text.trim().toLowerCase();

            // Filter
            var filtered = allCustomers.where((c) {
              if (query.isEmpty) return true;
              final nameMatch = c.name.toLowerCase().contains(query);
              final contactMatch =
                  (c.contactInfo ?? '').toLowerCase().contains(query);
              return nameMatch || contactMatch;
            }).toList();

            if (_selectedFilter == 'has_contact') {
              filtered = filtered
                  .where((c) =>
                      c.contactInfo != null && c.contactInfo!.trim().isNotEmpty)
                  .toList();
            } else if (_selectedFilter == 'local_only') {
              filtered = filtered.where((c) => c.syncPending).toList();
            }

            switch (_selectedSort) {
              case 'z_a':
                filtered.sort((a, b) =>
                    b.name.toLowerCase().compareTo(a.name.toLowerCase()));
                break;
              case 'newest':
                filtered.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
                break;
              case 'oldest':
                filtered.sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
                break;
              case 'a_z':
              default:
                filtered.sort((a, b) =>
                    a.name.toLowerCase().compareTo(b.name.toLowerCase()));
                break;
            }

            final isFiltered =
                query.isNotEmpty || _selectedFilter != 'all' || _selectedSort != 'a_z';

            if (filtered.isEmpty) {
              return Column(
                children: [
                  _buildSearchAndFilters(textPrimary, textMuted, surfaceSubtle, borderCol),
                  Expanded(
                    child: Center(
                      child: isFiltered
                          ? _EmptyState(
                              icon: Icons.search_off_rounded,
                              title: query.isNotEmpty
                                  ? 'No customers found for "$query"'
                                  : 'No customers found with selected filter',
                              subtitle:
                                  'Try checking your spelling or clear filters to view all customers',
                              action: OutlinedButton.icon(
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _selectedFilter = 'all';
                                    _selectedSort = 'a_z';
                                  });
                                  _resetPaging();
                                },
                                icon: const Icon(Icons.clear_all_rounded, size: 16),
                                label: const Text('Clear Filters'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                  side: const BorderSide(color: AppColors.primary),
                                ),
                              ),
                            )
                          : _EmptyState(
                              icon: Icons.business_outlined,
                              title: 'No customers found',
                              subtitle:
                                  'Add your first customer to start tracking sites & notes',
                              action: ElevatedButton.icon(
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const CustomerFormScreen()),
                                ),
                                icon: const Icon(Icons.add_rounded, size: 16),
                                label: const Text('Add Customer'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                    ),
                  ),
                ],
              );
            }

            final visibleCustomers = filtered.take(_displayedCount).toList();

            return Column(
              children: [
                _buildSearchAndFilters(textPrimary, textMuted, surfaceSubtle, borderCol),
                Expanded(
                  child: CustomScrollView(
                    controller: _scrollController,
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${filtered.length} Customer${filtered.length == 1 ? '' : 's'}${visibleCustomers.length < filtered.length ? ' (showing ${visibleCustomers.length})' : ''}',
                                style: GoogleFonts.outfit(
                                  fontSize: 13,
                                  color: textMuted,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                _sortOptions[_selectedSort] ?? '',
                                style: GoogleFonts.outfit(
                                  fontSize: 11,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                        sliver: SliverList.separated(
                          itemCount: visibleCustomers.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final customer = visibleCustomers[index];
                            return _CustomerCard(customer: customer);
                          },
                        ),
                      ),
                      if (_isLoadingMore)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Loading more customers...',
                                    style: GoogleFonts.outfit(
                                      fontSize: 12,
                                      color: textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      const SliverToBoxAdapter(
                        child: SizedBox(height: 80),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_customer_screen',
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CustomerFormScreen()),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded, size: 20),
        label: Text(
          'Add Customer',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
      ),
    );
  }

  Widget _buildSortMenu(Color textPrimary, Color textMuted,
      Color surfaceSubtle, Color borderCol) {
    return PopupMenuButton<String>(
      initialValue: _selectedSort,
      tooltip: 'Sort customers',
      onSelected: (val) {
        setState(() => _selectedSort = val);
        _resetPaging();
      },
      color: context.surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: borderCol),
      ),
      itemBuilder: (ctx) => _sortOptions.entries.map((entry) {
        final isSelected = entry.key == _selectedSort;
        return PopupMenuItem<String>(
          value: entry.key,
          child: Row(
            children: [
              Icon(
                isSelected ? Icons.check_rounded : Icons.radio_button_unchecked_rounded,
                size: 16,
                color: isSelected ? AppColors.primary : textMuted,
              ),
              const SizedBox(width: 8),
              Text(
                entry.value,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? AppColors.primary : textPrimary,
                ),
              ),
            ],
          ),
        );
      }).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: surfaceSubtle,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderCol, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.sort_rounded, size: 15, color: AppColors.primary),
            const SizedBox(width: 5),
            Text(
              _sortOptions[_selectedSort] ?? 'Sort',
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
            ),
            const SizedBox(width: 2),
            Icon(Icons.arrow_drop_down_rounded, size: 16, color: textMuted),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters(Color textPrimary, Color textMuted,
      Color surfaceSubtle, Color borderCol) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            style: GoogleFonts.outfit(color: textPrimary, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Search customers by name, phone, email...',
              prefixIcon:
                  Icon(Icons.search_rounded, size: 20, color: textMuted),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear_rounded, size: 18, color: textMuted),
                      onPressed: () {
                        _searchController.clear();
                        _resetPaging();
                        setState(() {});
                      },
                    )
                  : null,
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onChanged: (_) {
              _resetPaging();
              setState(() {});
            },
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildSortMenu(textPrimary, textMuted, surfaceSubtle, borderCol),
                const SizedBox(width: 6),
                _buildFilterChip('all', 'All Customers'),
                const SizedBox(width: 6),
                _buildFilterChip('has_contact', 'Has Contact Info'),
                const SizedBox(width: 6),
                _buildFilterChip('local_only', '🔄 Local Only'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedFilter = value);
        _resetPaging();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : context.surfaceSubtle,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : context.borderColor,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Colors.white : context.textPrimaryColor,
          ),
        ),
      ),
    );
  }
}

class _CustomerCard extends StatelessWidget {
  final dynamic customer;
  const _CustomerCard({required this.customer});

  @override
  Widget build(BuildContext context) {
    final cardBg = context.surfaceColor;
    final borderCol = context.borderColor;
    final textPrimary = context.textPrimaryColor;
    final textMuted = context.textMutedColor;

    final initials = customer.name.isNotEmpty
        ? customer.name
            .split(' ')
            .take(2)
            .map((w) => w.isEmpty ? '' : w[0].toUpperCase())
            .join()
        : 'C';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (_, anim, __) =>
                CustomerDetailScreen(customer: customer),
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
            transitionDuration: const Duration(milliseconds: 250),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: cardBg,
          border: Border.all(
            color: borderCol,
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.25),
                      AppColors.primaryDark.withValues(alpha: 0.15),
                    ],
                  ),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.name,
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      customer.contactInfo ?? 'No contact information recorded',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        color: textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (customer.syncPending)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.cloud_upload_outlined,
                      size: 13, color: AppColors.warning),
                ),
              Icon(
                Icons.chevron_right_rounded,
                color: textMuted.withValues(alpha: 0.5),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? action;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final surfaceSubtle = context.surfaceSubtle;
    final borderCol = context.borderColor;
    final textPrimary = context.textPrimaryColor;
    final textMuted = context.textMutedColor;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: surfaceSubtle,
                border: Border.all(
                  color: borderCol,
                  width: 1,
                ),
              ),
              child: Icon(icon, size: 36, color: textMuted),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: textMuted,
              ),
            ),
            if (action != null) ...[
              const SizedBox(height: 16),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
