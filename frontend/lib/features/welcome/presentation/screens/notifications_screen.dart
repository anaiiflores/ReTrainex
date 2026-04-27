import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/error_message_widget.dart';
import '../../models/notification_model.dart';
import '../../services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _isLoading = false;
  String? _errorMessage;
  List<NotificationModel> _notifications = [];

  final NotificationService _service = NotificationService();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final result = await _service.getNotifications();
      setState(() => _notifications = result);
    } catch (_) {
      setState(() => _errorMessage = 'No se pudieron cargar las notificaciones');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _markAsRead(String id) async {
    await _service.markAsRead(id);
    setState(() {
      _notifications = _notifications.map((n) {
        return n.id == id
            ? NotificationModel(
                id: n.id,
                type: n.type,
                title: n.title,
                body: n.body,
                createdAt: n.createdAt,
                isRead: true,
                hasAction: n.hasAction,
                actionLabel: n.actionLabel,
              )
            : n;
      }).toList();
    });
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => !n.isRead).length;
    final isWide = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(unreadCount),
      body: _buildBody(isWide),
    );
  }

  PreferredSizeWidget _buildAppBar(int unreadCount) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: Colors.white, size: 20),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Text(
        'Notificaciones',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: [
        if (unreadCount > 0)
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '$unreadCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
      ],
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1, color: AppColors.border),
      ),
    );
  }

  Widget _buildBody(bool isWide) {
    if (_isLoading) {
      return const LoadingWidget(message: 'Cargando notificaciones...');
    }
    if (_errorMessage != null) {
      return ErrorMessageWidget(
        message: _errorMessage!,
        onRetry: _load,
      );
    }
    if (_notifications.isEmpty) {
      return const Center(
        child: Text(
          'No tienes notificaciones',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
        ),
      );
    }

    final unread = _notifications.where((n) => !n.isRead).toList();
    final read = _notifications.where((n) => n.isRead).toList();

    return Center(
      child: ConstrainedBox(
        constraints:
            BoxConstraints(maxWidth: isWide ? 680.0 : double.infinity),
        child: ListView(
          padding: EdgeInsets.symmetric(
            horizontal: isWide ? 0 : 0,
            vertical: 8,
          ),
          children: [
            if (unread.isNotEmpty) ...[
              _SectionHeader(
                  label: 'NUEVAS (${unread.length})'),
              ...unread.map((n) => _NotificationCard(
                    notification: n,
                    onTap: () => _markAsRead(n.id),
                    onAction: n.hasAction ? () {} : null,
                  )),
            ],
            if (read.isNotEmpty) ...[
              const _SectionHeader(label: 'ANTERIORES'),
              ...read.map((n) => _NotificationCard(
                    notification: n,
                    onTap: null,
                    onAction: null,
                  )),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ─── Icono y color por tipo ───────────────────────────────────────────────────

IconData _iconForType(NotificationType type) {
  switch (type) {
    case NotificationType.message:
      return Icons.chat_bubble_rounded;
    case NotificationType.questionnaire:
      return Icons.description_rounded;
    case NotificationType.reminder:
      return Icons.notifications_rounded;
    case NotificationType.sessionComplete:
      return Icons.calendar_today_rounded;
  }
}

Color _colorForType(NotificationType type) {
  switch (type) {
    case NotificationType.message:
      return AppColors.primary;
    case NotificationType.questionnaire:
      return Colors.orange;
    case NotificationType.reminder:
      return AppColors.secondary;
    case NotificationType.sessionComplete:
      return Colors.green;
  }
}

// ─── Widgets locales ──────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;
  final VoidCallback? onAction;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final color = _colorForType(notification.type);
    final isUnread = !notification.isRead;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isUnread
              ? const Color(0xFF0F1E38)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isUnread
                ? AppColors.primary.withValues(alpha: 0.25)
                : AppColors.border,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icono
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _iconForType(notification.type),
                  color: color,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              // Contenido
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.body,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          notification.timeAgoText,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        if (onAction != null) ...[
                          const Spacer(),
                          GestureDetector(
                            onTap: onAction,
                            child: Text(
                              '${notification.actionLabel ?? 'Abrir'} →',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // Punto no leído
              if (isUnread) ...[
                const SizedBox(width: 8),
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: CircleAvatar(
                    radius: 5,
                    backgroundColor: AppColors.primary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
