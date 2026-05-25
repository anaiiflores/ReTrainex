import 'package:flutter/material.dart';
import '../../../../core/strings/locale_manager.dart'; // Textos localizados
import '../../../../core/theme/app_colors.dart';        // Paleta de colores
import '../../models/user_model.dart';                  // Modelo con los datos del usuario
import '../../services/user_service.dart';              // Servicio que carga el usuario

/// Pantalla de perfil del usuario.
/// Muestra avatar, datos personales (edad/peso/altura), rutina asignada y fisioterapeuta.
/// Es `StatefulWidget` porque necesita cargar datos de forma asíncrona al montarse.
class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  bool _isLoading = false; // true mientras se espera la respuesta del servicio
  UserModel? _user;        // null hasta que llegan los datos; null también si falla la carga

  @override
  void initState() {
    super.initState();
    _loadUser(); // Inicia la carga en cuanto el widget se monta en el árbol
  }

  /// Llama al servicio y actualiza el estado con el usuario cargado.
  Future<void> _loadUser() async {
    setState(() => _isLoading = true); // Muestra el spinner de carga
    try {
      final user = await UserService().getUser(); // Espera al futuro (mock: 300 ms)
      setState(() => _user = user);               // Guarda el usuario y dispara rebuild
    } finally {
      // `finally` garantiza que el spinner se oculta aunque ocurra una excepción
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // true si la pantalla tiene ≥600 px de ancho (tablet / escritorio)
    final isWide = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,        // Sin sombra bajo la barra
        centerTitle: true,   // Título centrado
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 20), // Flecha de retroceso iOS-style
          onPressed: () => Navigator.of(context).pop(), // Vuelve a la pantalla anterior
        ),
        title: Text(
          LocaleManager.strings.settingsPersonalData, // "DATOS PERSONALES"
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      // Árbol de condiciones para decidir qué mostrar en el body
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary)) // Spinner mientras carga
          : _user == null
              ? const SizedBox.shrink() // Sin datos → sin espacio (no debería ocurrir normalmente)
              : _buildBody(isWide, _user!), // '!' seguro: ya verificamos _user != null
    );
  }

  // ── Body ─────────────────────────────────────────────────────────────────

  /// Construye el contenido principal con scroll adaptado al ancho de pantalla.
  Widget _buildBody(bool isWide, UserModel user) {
    final s = LocaleManager.strings; // Alias para abreviar accesos a strings
    return SingleChildScrollView(
      // Márgenes más amplios en pantallas anchas para no estirar el contenido
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 48 : 16, // Tablet: 48px; móvil: 16px
        vertical: isWide ? 36 : 20,
      ),
      child: Center(
        child: ConstrainedBox(
          // Limita el ancho máximo en tablet para evitar tarjetas demasiado anchas
          constraints:
              BoxConstraints(maxWidth: isWide ? 560.0 : double.infinity),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Alinea etiquetas de sección a la izquierda
            children: [
              _buildAvatarCard(user),         // Bloque superior con avatar y nombre
              const SizedBox(height: 20),
              _buildSectionLabel(Icons.person_rounded, s.settingsPersonalData), // "DATOS PERSONALES"
              const SizedBox(height: 10),
              _buildPersonalDataCard(user),   // Edad, peso y altura en filas con iconos
              if (user.routine != null) ...[  // Solo si el usuario tiene rutina asignada
                const SizedBox(height: 28),
                _buildSectionLabel(Icons.fitness_center_rounded,
                    s.userAssignedRoutine),   // "RUTINA ASIGNADA"
                const SizedBox(height: 10),
                _buildRoutineCard(user),      // Tarjeta con título, día y dificultad de la rutina
              ],
              if (user.physioName != null) ...[ // Solo si se conoce el fisio
                const SizedBox(height: 28),
                _buildSectionLabel(Icons.medical_services_rounded,
                    s.userPhysiotherapist),   // "FISIOTERAPEUTA"
                const SizedBox(height: 10),
                _buildPhysioCard('Dr. ${user.physioName!}'), // Prefijo "Dr." hardcodeado
              ],
              const SizedBox(height: 16), // Espacio inferior para evitar que el scroll quede justo
            ],
          ),
        ),
      ),
    );
  }

  // ── Avatar ────────────────────────────────────────────────────────────────

  /// Bloque con el avatar circular (imagen o inicial) y el nombre del usuario.
  Widget _buildAvatarCard(UserModel user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15), // Fondo azul muy transparente
              shape: BoxShape.circle,
              border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.4), width: 2), // Aro azul semitransparente
              // Si hay foto de perfil → la muestra como fondo del círculo
              image: user.profileImageUrl != null
                  ? DecorationImage(
                      image: NetworkImage(user.profileImageUrl!), // Carga la imagen desde la URL
                      fit: BoxFit.cover, // Rellena sin deformar
                    )
                  : null, // Sin imagen → no aplica DecorationImage
            ),
            // Si no hay foto → muestra la inicial del nombre en el centro
            child: user.profileImageUrl == null
                ? Center(
                    child: Text(
                      user.userName.isNotEmpty
                          ? user.userName[0].toUpperCase() // Primera letra en mayúscula
                          : '?',                           // Fallback si el nombre está vacío
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  )
                : null, // Si hay imagen, el child del círculo es null (la imagen lo cubre)
          ),
          const SizedBox(height: 14),
          Text(
            user.userName.toUpperCase(), // Nombre en mayúsculas
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5, // Espaciado estilo etiqueta técnica
            ),
          ),
          const SizedBox(height: 4),
          Text(
            LocaleManager.strings.settingsProfile.toUpperCase(), // "PERFIL"
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              letterSpacing: 2,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ── Datos personales ──────────────────────────────────────────────────────

  /// Tarjeta con tres filas: edad, peso y altura.
  /// Usa el widget privado `_DataRow` para mantener uniformidad visual.
  Widget _buildPersonalDataCard(UserModel user) {
    final s = LocaleManager.strings;
    final noData = s.userNotSpecified; // "No especificado" — reutilizado en las tres filas
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _DataRow(
            icon: Icons.cake_rounded,
            iconColor: AppColors.secondary,
            label: s.userAge,                                            // "EDAD"
            value: user.age != null ? '${user.age} ${s.userYears}' : noData, // "33 años" o "No especificado"
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 1, color: AppColors.border), // Separador entre filas
          ),
          _DataRow(
            icon: Icons.monitor_weight_rounded,
            iconColor: AppColors.primary,
            label: s.userWeight,                                          // "PESO"
            value: user.weight != null ? '${user.weight} kg' : noData,  // "62.5 kg"
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 1, color: AppColors.border),
          ),
          _DataRow(
            icon: Icons.height_rounded,
            iconColor: AppColors.secondary,
            label: s.userHeight,                                          // "ALTURA"
            value: user.height != null
                ? '${user.height!.toStringAsFixed(0)} cm'                // "164 cm" (sin decimales)
                : noData,
          ),
        ],
      ),
    );
  }

  // ── Fisioterapeuta ────────────────────────────────────────────────────────

  /// Tarjeta con el nombre del fisioterapeuta asignado.
  Widget _buildPhysioCard(String name) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.15), // Fondo verde claro
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.person_rounded,
                color: AppColors.secondary, size: 22), // Icono de persona en verde
          ),
          const SizedBox(width: 14),
          Text(
            name, // "Dr. Anaii Penev Gordo"
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ── Rutina ────────────────────────────────────────────────────────────────

  /// Tarjeta con el resumen de la rutina asignada (título, día, duración y dificultad).
  Widget _buildRoutineCard(UserModel user) {
    final routine = user.routine!; // '!' seguro: solo se llama cuando user.routine != null
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.route_rounded,
                color: AppColors.primary, size: 22), // Icono de ruta para representar rutina
          ),
          const SizedBox(width: 14),
          Expanded( // `Expanded` evita overflow si el título es largo
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  routine.title,  // "Fortalecimiento Escapular"
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${routine.day}  ·  ${routine.minutes} MIN  ·  ${routine.difficulty}',
                  // "MIÉRCOLES  ·  20 MIN  ·  MEDIA" — puntos medianos como separador visual
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Etiqueta de sección: icono + texto en gris, usada antes de cada bloque de datos.
  Widget _buildSectionLabel(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 16), // Icono pequeño en gris
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

// ── Data row ──────────────────────────────────────────────────────────────────

/// Fila de dato individual: icono de color + etiqueta + valor.
/// Clase privada (`_`) — solo se usa dentro de este archivo.
class _DataRow extends StatelessWidget {
  final IconData icon;       // Icono que identifica el tipo de dato
  final Color iconColor;     // Color del icono (varía por fila)
  final String label;        // Nombre del campo ("EDAD", "PESO", "ALTURA")
  final String value;        // Valor formateado ("33 años", "62.5 kg", "164 cm")

  const _DataRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), // Sangría y altura de cada fila
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 22), // Icono a la izquierda
          const SizedBox(width: 14),
          Expanded( // Label ocupa todo el espacio disponible, empujando el valor a la derecha
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value, // Valor alineado a la derecha de la fila
            style: const TextStyle(
              color: AppColors.textSecondary, // Gris — contrasta con el label blanco
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
