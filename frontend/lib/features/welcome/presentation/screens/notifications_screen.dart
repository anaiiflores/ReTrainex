import 'package:flutter/material.dart';
import '../../../../core/strings/locale_manager.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/loading_widget.dart';       // Spinner de carga
import '../../../../shared/widgets/error_message_widget.dart'; // Error con retry
import '../../models/notification_model.dart';
import '../../services/notification_service.dart';

/// Pantalla de lista de notificaciones del usuario.
/// Divide las notificaciones en dos secciones: no leídas y anteriores.
/// `StatefulWidget` porque gestiona la carga asíncrona y el marcado como leída.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _isLoading = false;
  String? _errorMessage;
  List<NotificationModel> _notifications = []; // Lista completa (leídas + no leídas)

  final NotificationService _service = NotificationService();

  @override
  void initState() {
    super.initState();
    _load(); // Carga las notificaciones al montar la pantalla
  }

  /// Carga la lista de notificaciones desde el servicio.
  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final result = await _service.getNotifications();
      setState(() => _notifications = result);
    } catch (_) {
      setState(() => _errorMessage = LocaleManager.strings.errorLoadingNotifications);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Marca la notificación con [id] como leída localmente y en el servicio.
  /// Actualiza la lista en lugar de recargar toda la pantalla para evitar parpadeos.
  Future<void> _markAsRead(String id) async {
    await _service.markAsRead(id); // Persiste en el backend (mock: 200 ms de delay)
    setState(() {
      // Reconstruye la lista sustituyendo solo la notificación modificada
      _notifications = _notifications.map((n) {
        return n.id == id
            ? NotificationModel(
                // Copia todos los campos excepto isRead que pasa a true
                id: n.id,
                type: n.type,
                title: n.title,
                body: n.body,
                createdAt: n.createdAt,
                isRead: true,           // ← único campo que cambia
                hasAction: n.hasAction,
                actionLabel: n.actionLabel,
              )
            : n; // El resto de notificaciones no cambian
      }).toList();
    });
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Cuenta las no leídas para el badge del AppBar
    final unreadCount = _notifications.where((n) => !n.isRead).length;
    final isWide = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(unreadCount),
      body: _buildBody(isWide),
    );
  }

  /// AppBar con el título, flecha de retroceso y badge con el número de no leídas.
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
      title: Text(
        LocaleManager.strings.notifications, // "NOTIFICACIONES"
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: [
        // Badge circular solo si hay notificaciones sin leer
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
                '$unreadCount', // Número de notificaciones pendientes
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
      ],
      // Línea separadora bajo el AppBar
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1, color: AppColors.border),
      ),
    );
  }

  /// Body: spinner / error / lista vacía / lista dividida en secciones.
  Widget _buildBody(bool isWide) {
    if (_isLoading) {
      return LoadingWidget(message: LocaleManager.strings.loading);
    }
    if (_errorMessage != null) {
      return ErrorMessageWidget(
        message: _errorMessage!,
        onRetry: _load,
      );
    }
    if (_notifications.isEmpty) {
      return Center(
        child: Text(
          LocaleManager.strings.noNotifications, // "No tienes notificaciones"
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 16),
        ),
      );
    }

    // Separa en dos listas para mostrarlas en secciones distintas
    final unread = _notifications.where((n) => !n.isRead).toList(); // No leídas
    final read = _notifications.where((n) => n.isRead).toList();    // Ya leídas

    return Center(
      child: ConstrainedBox(
        constraints:
            BoxConstraints(maxWidth: isWide ? 680.0 : double.infinity), // Limita el ancho en tablet
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            // Sección "NUEVAS" — solo si hay notificaciones sin leer
            if (unread.isNotEmpty) ...[
              _SectionHeader(
                  label: LocaleManager.strings.newNotifications(unread.length)), // "NUEVAS (2)"
              // Genera una tarjeta por cada notificación no leída
              ...unread.map((n) => _NotificationCard(
                    notification: n,
                    onTap: () => _markAsRead(n.id), // Al pulsar → marcar como leída
                    onAction: n.hasAction ? () {} : null, // Botón de acción (ej. abrir cuestionario)
                  )),
            ],
            // Sección "ANTERIORES" — solo si hay notificaciones ya leídas
            if (read.isNotEmpty) ...[
              _SectionHeader(label: LocaleManager.strings.previousNotifications), // "ANTERIORES"
              ...read.map((n) => _NotificationCard(
                    notification: n,
                    onTap: null,   // Las leídas no disparan acción al pulsar
                    onAction: null,
                  )),
            ],
            const SizedBox(height: 16), // Espacio inferior
          ],
        ),
      ),
    );
  }
}

// ─── Funciones de ayuda para iconos y colores ─────────────────────────────────

/// Devuelve el icono correspondiente al tipo de notificación.
IconData _iconForType(NotificationType type) {
  switch (type) {
    case NotificationType.message:
      return Icons.chat_bubble_rounded;       // Burbuja de chat para mensajes del fisio
    case NotificationType.questionnaire:
      return Icons.description_rounded;       // Documento para cuestionarios
    case NotificationType.reminder:
      return Icons.notifications_rounded;     // Campana para recordatorios
    case NotificationType.sessionComplete:
      return Icons.calendar_today_rounded;    // Calendario para confirmación de sesión
  }
}

/// Devuelve el color de acento correspondiente al tipo de notificación.
Color _colorForType(NotificationType type) {
  switch (type) {
    case NotificationType.message:
      return AppColors.primary;   // Azul para mensajes del fisio
    case NotificationType.questionnaire:
      return Colors.orange;       // Naranja para cuestionarios pendientes
    case NotificationType.reminder:
      return AppColors.secondary; // Verde para recordatorios
    case NotificationType.sessionComplete:
      return Colors.green;        // Verde intenso para sesión completada
  }
}

// ─── Widgets locales ──────────────────────────────────────────────────────────

/// Cabecera de sección con el nombre del grupo ("NUEVAS", "ANTERIORES").
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

/// Tarjeta individual de notificación.
/// Tiene dos apariencias: no leída (fondo azul oscuro + punto) y leída (fondo gris).
class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;    // null → no reacciona al tap (notificaciones leídas)
  final VoidCallback? onAction; // null → no muestra el botón de acción

  const _NotificationCard({
    required this.notification,
    required this.onTap,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final color = _colorForType(notification.type); // Color del tipo de notificación
    final isUnread = !notification.isRead;

    return GestureDetector(
      onTap: onTap, // null → GestureDetector existe pero no dispara nada
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          // Fondo diferenciado: azul muy oscuro si no leída, gris si leída
          color: isUnread
              ? const Color(0xFF0F1E38) // Azul oscuro para no leídas
              : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isUnread
                ? AppColors.primary.withValues(alpha: 0.25) // Borde azul sutil para no leídas
                : AppColors.border,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start, // Alineación superior para contenido largo
            children: [
              // ── Icono del tipo ────────────────────────────────────────────
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15), // Fondo del color del tipo, muy transparente
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _iconForType(notification.type),
                  color: color,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              // ── Contenido textual ─────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title, // Título de la notificación
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.body, // Cuerpo del mensaje
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        height: 1.45, // Interlineado cómodo para mensajes largos
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          notification.timeAgoText, // "Hace 2 horas"
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        // Botón de acción al final de la fila (ej. "Abrir →")
                        if (onAction != null) ...[
                          const Spacer(), // Empuja el botón hacia la derecha
                          GestureDetector(
                            onTap: onAction,
                            child: Text(
                              '${notification.actionLabel ?? LocaleManager.strings.open} →',
                              // Etiqueta personalizada o "Abrir" por defecto
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
              // ── Punto indicador de no leída ───────────────────────────────
              if (isUnread) ...[
                const SizedBox(width: 8),
                const Padding(
                  padding: EdgeInsets.only(top: 2), // Alinea el punto con la primera línea de texto
                  child: CircleAvatar(
                    radius: 5,
                    backgroundColor: AppColors.primary, // Punto azul
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
