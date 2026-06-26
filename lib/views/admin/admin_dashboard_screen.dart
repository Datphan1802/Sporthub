import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../viewmodels/booking_viewmodel.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bookingVM =
          Provider.of<BookingViewModel>(context, listen: false);
      bookingVM.fetchCourts();
      bookingVM.fetchAllBookings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bookingVM = Provider.of<BookingViewModel>(context);
    final courts = bookingVM.courts;
    final bookings = bookingVM.allBookings;

    final totalRevenue = bookings
        .where((b) => b.status == 'confirmed' || b.status == 'completed')
        .fold<double>(0, (sum, b) => sum + b.price);
    final pendingBookings =
        bookings.where((b) => b.status == 'pending').length;
    final confirmedBookings =
        bookings.where((b) => b.status == 'confirmed').length;
    final completedBookings =
        bookings.where((b) => b.status == 'completed').length;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Quản trị'),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          final bookingVM =
              Provider.of<BookingViewModel>(context, listen: false);
          bookingVM.fetchCourts();
          bookingVM.fetchAllBookings();
        },
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Tổng quan hệ thống',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    icon: Icons.sports_tennis,
                    value: '${courts.length}',
                    label: 'Tổng sân',
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    icon: Icons.people,
                    value: '1',
                    label: 'Người dùng',
                    color: AppTheme.infoColor,
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
                    icon: Icons.pending,
                    value: '$pendingBookings',
                    label: 'Chờ xác nhận',
                    color: AppTheme.warningColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    icon: Icons.check_circle,
                    value: '$confirmedBookings',
                    label: 'Đã xác nhận',
                    color: AppTheme.successColor,
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
                    icon: Icons.done_all,
                    value: '$completedBookings',
                    label: 'Hoàn thành',
                    color: AppTheme.infoColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    icon: Icons.payments,
                    value:
                        '${totalRevenue.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')} VNĐ',
                    label: 'Tổng doanh thu',
                    color: AppTheme.secondaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              'Quản lý hệ thống',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildActionCard(
              context,
              icon: Icons.approval,
              title: 'Duyệt sân mới',
              subtitle: 'Phê duyệt sân thể thao mới tham gia',
              color: AppTheme.warningColor,
              onTap: () {
                Navigator.pushNamed(context, '/admin/approval');
              },
            ),
            const SizedBox(height: 12),
            _buildActionCard(
              context,
              icon: Icons.people_alt,
              title: 'Quản lý người dùng',
              subtitle: 'Xem và quản lý tài khoản người dùng',
              color: AppTheme.infoColor,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tính năng quản lý người dùng sắp ra mắt!'),
                    backgroundColor: AppTheme.infoColor,
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildActionCard(
              context,
              icon: Icons.analytics,
              title: 'Thống kê',
              subtitle: 'Xem báo cáo chi tiết hệ thống',
              color: AppTheme.secondaryColor,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tính năng thống kê sắp ra mắt!'),
                    backgroundColor: AppTheme.infoColor,
                  ),
                );
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

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
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
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
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
            const Icon(Icons.chevron_right, color: AppTheme.textLight),
          ],
        ),
      ),
    );
  }
}
