import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/booking_viewmodel.dart';

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthViewModel>(context, listen: false);
      final bookingVM =
          Provider.of<BookingViewModel>(context, listen: false);
      if (auth.currentUser != null) {
        bookingVM.fetchCourts();
        final ownedCourtIds = auth.currentUser!.ownedCourts;
        if (ownedCourtIds.isNotEmpty) {
          bookingVM.fetchBookingsByCourts(ownedCourtIds);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthViewModel>(context);
    final bookingVM = Provider.of<BookingViewModel>(context);
    final user = auth.currentUser;
    final ownedCourtIds = user?.ownedCourts ?? [];

    final ownerBookings = bookingVM.allBookings
        .where((b) => ownedCourtIds.contains(b.courtId))
        .toList();
    final totalRevenue = ownerBookings
        .where((b) => b.status == 'confirmed' || b.status == 'completed')
        .fold<double>(0, (sum, b) => sum + b.price);

    final pendingCount =
        ownerBookings.where((b) => b.status == 'pending').length;
    final confirmedCount =
        ownerBookings.where((b) => b.status == 'confirmed').length;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Quản lý sân'),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          final auth = Provider.of<AuthViewModel>(context, listen: false);
          final bookingVM =
              Provider.of<BookingViewModel>(context, listen: false);
          if (auth.currentUser != null) {
            bookingVM.fetchCourts();
            final ownedCourtIds = auth.currentUser!.ownedCourts;
            if (ownedCourtIds.isNotEmpty) {
              bookingVM.fetchBookingsByCourts(ownedCourtIds);
            }
          }
        },
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Xin chào, ${user?.name ?? ''}!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Đây là trang quản lý dành cho chủ sân.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    icon: Icons.sports_tennis,
                    value: '${ownedCourtIds.length}',
                    label: 'Sân đang quản lý',
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    icon: Icons.pending,
                    value: '$pendingCount',
                    label: 'Chờ xác nhận',
                    color: AppTheme.warningColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    icon: Icons.check_circle,
                    value: '$confirmedCount',
                    label: 'Đã xác nhận',
                    color: AppTheme.successColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    icon: Icons.payments,
                    value: '${totalRevenue.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')} VNĐ',
                    label: 'Tổng doanh thu',
                    color: AppTheme.secondaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              'Quản lý nhanh',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildMenuCard(
              context,
              icon: Icons.list_alt,
              title: 'Danh sách sân',
              subtitle: 'Xem và quản lý sân của bạn',
              color: AppTheme.primaryColor,
              onTap: () {
                Navigator.pushNamed(context, '/owner/courts');
              },
            ),
            const SizedBox(height: 12),
            _buildMenuCard(
              context,
              icon: Icons.calendar_month,
              title: 'Lịch đặt sân',
              subtitle: 'Xem lịch đặt theo ngày',
              color: AppTheme.secondaryColor,
              onTap: () {
                Navigator.pushNamed(context, '/owner/calendar');
              },
            ),
            const SizedBox(height: 12),
            _buildMenuCard(
              context,
              icon: Icons.confirmation_number,
              title: 'Xác nhận đặt sân',
              subtitle: '$pendingCount đơn đang chờ',
              color: AppTheme.warningColor,
              badge: pendingCount > 0 ? pendingCount : null,
              onTap: () {
                Navigator.pushNamed(context, '/owner/calendar');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    int? badge,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.errorColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$badge',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppTheme.textLight,
            ),
          ],
        ),
      ),
    );
  }
}
