import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/booking_viewmodel.dart';
import '../../widgets/booking_card.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadBookings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadBookings() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authViewModel =
          Provider.of<AuthViewModel>(context, listen: false);
      if (authViewModel.currentUser != null) {
        Provider.of<BookingViewModel>(context, listen: false)
            .fetchMyBookings(authViewModel.currentUser!.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Lịch đặt sân'),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppTheme.textPrimary),
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.primaryColor,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          tabs: const [
            Tab(text: 'Sắp tới'),
            Tab(text: 'Hoàn thành'),
            Tab(text: 'Đã hủy'),
          ],
        ),
      ),
      body: Consumer<BookingViewModel>(
        builder: (context, bookingViewModel, child) {
          if (bookingViewModel.myBookings.isEmpty) {
            return _buildEmptyState();
          }

          final upcoming = bookingViewModel.myBookings
              .where((b) =>
                  b.status.toLowerCase() == 'pending' ||
                  b.status.toLowerCase() == 'confirmed')
              .toList();
          final completed = bookingViewModel.myBookings
              .where((b) => b.status.toLowerCase() == 'completed')
              .toList();
          final cancelled = bookingViewModel.myBookings
              .where((b) => b.status.toLowerCase() == 'cancelled')
              .toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildBookingList(upcoming, 'upcoming'),
              _buildBookingList(completed, 'completed'),
              _buildBookingList(cancelled, 'cancelled'),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.calendar_today_outlined,
                size: 48,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Chưa có lịch đặt',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Bạn chưa đặt sân nào.\nHãy tìm và đặt sân yêu thích!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
            ),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.explore),
              label: const Text('Tìm sân ngay'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryColor,
                side: const BorderSide(color: AppTheme.primaryColor),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingList(List bookings, String type) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getEmptyIcon(type),
              size: 48,
              color: AppTheme.textLight.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              _getEmptyMessage(type),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        _loadBookings();
      },
      color: AppTheme.primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];
          return BookingCard(
            booking: booking,
            onCancel: booking.status.toLowerCase() == 'pending' ||
                    booking.status.toLowerCase() == 'confirmed'
                ? () => _showCancelDialog(booking)
                : null,
          );
        },
      ),
    );
  }

  IconData _getEmptyIcon(String type) {
    switch (type) {
      case 'upcoming':
        return Icons.calendar_today_outlined;
      case 'completed':
        return Icons.check_circle_outline;
      case 'cancelled':
        return Icons.cancel_outlined;
      default:
        return Icons.inbox_outlined;
    }
  }

  String _getEmptyMessage(String type) {
    switch (type) {
      case 'upcoming':
        return 'Không có lịch đặt sắp tới';
      case 'completed':
        return 'Không có lịch đã hoàn thành';
      case 'cancelled':
        return 'Không có lịch đã hủy';
      default:
        return 'Không có lịch đặt';
    }
  }

  void _showLogoutDialog(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc muốn đăng xuất không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              authViewModel.logout();
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(dynamic booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hủy đặt sân'),
        content: Text(
          'Bạn có chắc muốn hủy đặt sân tại ${booking.courtName} không?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Giữ'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _cancelBooking(booking.id);
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: const Text('Hủy đặt'),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelBooking(String bookingId) async {
    try {
      final bookingViewModel =
          Provider.of<BookingViewModel>(context, listen: false);
      final ok = await bookingViewModel.cancelBooking(bookingId);

      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  ok ? Icons.check_circle : Icons.error_outline,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    ok
                        ? 'Đã hủy đặt sân thành công'
                        : 'Không thể hủy đặt sân. Vui lòng thử lại.',
                  ),
                ),
              ],
            ),
            backgroundColor: ok ? AppTheme.successColor : AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white, size: 20),
                SizedBox(width: 10),
                Text('Không thể hủy đặt sân. Vui lòng thử lại.'),
              ],
            ),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }
}
