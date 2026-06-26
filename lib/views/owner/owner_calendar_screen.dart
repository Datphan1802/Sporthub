import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/booking_viewmodel.dart';
import '../../services/firestore_service.dart';

class OwnerCalendarScreen extends StatefulWidget {
  const OwnerCalendarScreen({super.key});

  @override
  State<OwnerCalendarScreen> createState() => _OwnerCalendarScreenState();
}

class _OwnerCalendarScreenState extends State<OwnerCalendarScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  DateTime _selectedDate = DateTime.now();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  void _loadBookings() {
    final auth = Provider.of<AuthViewModel>(context, listen: false);
    if (auth.currentUser != null) {
      Provider.of<BookingViewModel>(context, listen: false)
          .fetchMyBookings(auth.currentUser!.uid);
    }
  }

  Future<void> _confirmBooking(String bookingId) async {
    setState(() => _isProcessing = true);
    try {
      await _firestoreService.confirmBooking(bookingId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã xác nhận đặt sân'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _cancelBooking(String bookingId) async {
    setState(() => _isProcessing = true);
    try {
      await _firestoreService.cancelBooking(bookingId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã hủy đặt sân'),
            backgroundColor: AppTheme.warningColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthViewModel>(context);
    final bookingVM = Provider.of<BookingViewModel>(context);
    final ownedCourtIds = auth.currentUser?.ownedCourts ?? [];

    final dayBookings = bookingVM.myBookings.where((b) {
      return ownedCourtIds.contains(b.courtId) &&
          b.date.year == _selectedDate.year &&
          b.date.month == _selectedDate.month &&
          b.date.day == _selectedDate.day;
    }).toList();

    dayBookings.sort((a, b) => a.timeSlot.compareTo(b.timeSlot));

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Lịch đặt sân'),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    setState(() {
                      _selectedDate = _selectedDate.subtract(
                          const Duration(days: 1));
                    });
                  },
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime.now()
                            .subtract(const Duration(days: 365)),
                        lastDate:
                            DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setState(() => _selectedDate = picked);
                      }
                    },
                    child: Text(
                      DateFormat('EEEE, d MMMM yyyy', 'vi').format(_selectedDate),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    setState(() {
                      _selectedDate =
                          _selectedDate.add(const Duration(days: 1));
                    });
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  '${dayBookings.length} đơn đặt',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {
                    setState(() => _selectedDate = DateTime.now());
                  },
                  icon: const Icon(Icons.today, size: 16),
                  label: const Text('Hôm nay'),
                ),
              ],
            ),
          ),
          Expanded(
            child: dayBookings.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_available,
                          size: 64,
                          color: AppTheme.textLight.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Không có đơn đặt nào',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: dayBookings.length,
                    itemBuilder: (context, index) {
                      final booking = dayBookings[index];
                      return _buildBookingItem(booking);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingItem(dynamic booking) {
    Color statusColor;
    String statusLabel;
    switch (booking.status) {
      case 'pending':
        statusColor = AppTheme.warningColor;
        statusLabel = 'Chờ xác nhận';
        break;
      case 'confirmed':
        statusColor = AppTheme.successColor;
        statusLabel = 'Đã xác nhận';
        break;
      case 'cancelled':
        statusColor = AppTheme.errorColor;
        statusLabel = 'Đã hủy';
        break;
      case 'completed':
        statusColor = AppTheme.infoColor;
        statusLabel = 'Hoàn thành';
        break;
      default:
        statusColor = AppTheme.textSecondary;
        statusLabel = booking.status;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.2),
          width: 1,
        ),
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
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  booking.timeSlot,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  booking.courtName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${booking.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')} VNĐ',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              if (booking.status == 'pending')
                Row(
                  children: [
                    TextButton(
                      onPressed: _isProcessing
                          ? null
                          : () => _cancelBooking(booking.id),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.errorColor,
                      ),
                      child: const Text('Từ chối'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _isProcessing
                          ? null
                          : () => _confirmBooking(booking.id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.successColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                      ),
                      child: const Text('Xác nhận'),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}
