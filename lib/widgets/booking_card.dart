import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/booking_model.dart';
import '../core/theme/app_theme.dart';

class BookingCard extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback? onTap;
  final VoidCallback? onCancel;

  const BookingCard({
    super.key,
    required this.booking,
    this.onTap,
    this.onCancel,
  });

  String _formatPrice(double price) {
    if (price >= 1000000) {
      return '${(price / 1000000).toStringAsFixed(1)} triệu VNĐ';
    }
    return '${price.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')} VNĐ';
  }

  Color get _statusColor {
    if (booking.isPending && booking.isPendingExpired) {
      return Colors.grey;
    }
    switch (booking.status.toLowerCase()) {
      case 'confirmed':
        return AppTheme.successColor;
      case 'pending':
        return AppTheme.warningColor;
      case 'cancelled':
        return AppTheme.errorColor;
      case 'completed':
        return AppTheme.infoColor;
      default:
        return AppTheme.textSecondary;
    }
  }

  IconData get _statusIcon {
    if (booking.isPending && booking.isPendingExpired) {
      return Icons.access_time;
    }
    switch (booking.status.toLowerCase()) {
      case 'confirmed':
        return Icons.check_circle;
      case 'pending':
        return Icons.schedule;
      case 'cancelled':
        return Icons.cancel;
      case 'completed':
        return Icons.done_all;
      default:
        return Icons.info;
    }
  }

  String get _statusLabel {
    if (booking.isPending && booking.isPendingExpired) {
      return 'HẾT HẠN';
    }
    switch (booking.status.toLowerCase()) {
      case 'confirmed':
        return 'ĐÃ XAC NHAN';
      case 'pending':
        return 'CHO THANH TOAN';
      case 'cancelled':
        return 'DA HUY';
      case 'completed':
        return 'HOAN THANH';
      default:
        return booking.status.toUpperCase();
    }
  }

  Duration? get _remainingTime {
    if (!booking.isPending || booking.pendingUntil == null) return null;
    final remaining = booking.pendingUntil!.difference(DateTime.now());
    if (remaining.isNegative) return Duration.zero;
    return remaining;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
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
          border: Border.all(
            color: _statusColor.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.sports_tennis,
                    color: _statusColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.courtName,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        booking.id.length >= 8
                            ? 'ID: ${booking.id.substring(0, 8)}...'
                            : 'ID: ${booking.id}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textLight,
                            ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(context),
              ],
            ),
            if (booking.isPending && !booking.isPendingExpired && _remainingTime != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.warningColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.warningColor.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.timer_outlined,
                      size: 16,
                      color: AppTheme.warningColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Còn ${_formatDuration(_remainingTime!)} để thanh toán',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.warningColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    context,
                    Icons.calendar_today,
                    DateFormat('EEEE, d MMM, yyyy', 'vi').format(booking.date),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    context,
                    Icons.access_time,
                    booking.timeSlot,
                  ),
                ),
                if (booking.price > 0)
                  Text(
                    _formatPrice(booking.price),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    context,
                    Icons.location_on_outlined,
                    booking.courtLocation,
                  ),
                ),
              ],
            ),
            if (booking.status.toLowerCase() == 'pending' ||
                booking.status.toLowerCase() == 'confirmed')
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: onCancel,
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.errorColor,
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Hủy đặt',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    if (d.inMinutes <= 0) return '0 phút';
    if (d.inMinutes < 60) return '${d.inMinutes} phút';
    final mins = d.inMinutes % 60;
    return '${d.inHours} giờ ${mins > 0 ? '$mins phút' : ''}';
  }

  Widget _buildStatusBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_statusIcon, size: 14, color: _statusColor),
          const SizedBox(width: 4),
          Text(
            _statusLabel,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: _statusColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
