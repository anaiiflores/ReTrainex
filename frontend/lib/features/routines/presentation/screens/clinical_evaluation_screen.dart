import 'package:flutter/material.dart';
import '../../../../core/strings/app_strings.dart'; // AppStrings — tipo del parámetro `s`
import '../../../../core/strings/locale_manager.dart'; // LocaleManager.strings — textos localizados
import '../../../../core/theme/app_colors.dart'; // Paleta de colores

/// Pantalla de evaluación clínica del dolor.
/// Se abre cuando el paciente omite un ejercicio por "dolor" (SkipReason.pain).
/// El fisioterapeuta recibirá la evaluación para tomar acción.
/// Devuelve `true` si el formulario fue enviado, `false` si fue cancelado.
class ClinicalEvaluationScreen extends StatefulWidget {
  /// Nombre del ejercicio que causó el dolor — se muestra en el header.
  final String exerciseName;

  const ClinicalEvaluationScreen({super.key, required this.exerciseName});

  @override
  State<ClinicalEvaluationScreen> createState() =>
      _ClinicalEvaluationScreenState();
}

class _ClinicalEvaluationScreenState extends State<ClinicalEvaluationScreen> {
  // ── Estado de los selectores ──────────────────────────────────────────────
  int?
      _painLevel; // Nivel de dolor seleccionado (0, 2, 5, 8 o 10); null = sin selección
  int? _painTypeIndex; // Índice del tipo de dolor (0-3); null = sin selección
  int?
      _timingIndex; // Índice de cuándo empezó el dolor (0-2); null = sin selección
  int?
      _sleepLevel; // Nivel de impacto en el sueño (0, 2, 5, 8 o 10); null = sin selección
  double _preciseIntensity = 0.0; // Intensidad precisa con el slider (0.0–10.0)
  final TextEditingController _notesController =
      TextEditingController(); // Notas adicionales

  @override
  void dispose() {
    _notesController.dispose(); // Libera el controlador al destruir el widget
    super.dispose();
  }

  /// El formulario solo es válido si el usuario ha seleccionado los 4 campos obligatorios.
  /// El slider y las notas son opcionales.
  bool get _canSubmit =>
      _painLevel != null && // Escala de dolor seleccionada
      _painTypeIndex != null && // Tipo de dolor seleccionado
      _timingIndex != null && // Momento de inicio seleccionado
      _sleepLevel != null; // Impacto en el sueño seleccionado

  /// Envía la evaluación al fisioterapeuta.
  /// Muestra un SnackBar verde de confirmación y cierra la pantalla tras 1 s.
  Future<void> _submit() async {
    // Ejemplo: await clinicalService.submitEvaluation(ClinicalEvaluation(...));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(milliseconds: 1000),
        backgroundColor:
            const Color.fromARGB(255, 30, 168, 40), // Verde claro de fondo
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
        ),
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded,
                color: Color(0xFF69F0AE), // Verde claro — icono de éxito
                size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                LocaleManager.strings.clinicalSubmitSuccess,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    // Espera a que el SnackBar sea visible antes de cerrar la pantalla.
    // `mounted` evita usar el context si el widget fue destruido durante la espera.
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    Navigator.of(context)
        .pop(true); // `true` indica que el formulario fue enviado
  }

  @override
  Widget build(BuildContext context) {
    final s = LocaleManager.strings; // Alias corto para los textos localizados

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(s), // AppBar rojo con botón de cancelar
      body: SafeArea(
        child: Column(
          children: [
            // La mayor parte del contenido es scrollable
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(
                        s), // Tarjeta roja con el ejercicio y aviso al fisio
                    const SizedBox(height: 28),
                    // Sección 1: escala de emoticonos del dolor (0–10)
                    _buildSection(
                      label: s.clinicalHowDoYouFeel, // "¿CÓMO TE SIENTES?"
                      sublabel: s.clinicalPainScaleHint, // Pista de la escala
                      child: _buildPainScale(),
                    ),
                    const SizedBox(height: 24),
                    // Sección 2: slider de intensidad precisa (0.0–10.0)
                    _buildPreciseIntensitySection(s),
                    const SizedBox(height: 24),
                    // Sección 3: cuadrícula 2×2 de tipos de dolor
                    _buildSection(
                      label: s.clinicalHowIsThePain, // "¿CÓMO ES EL DOLOR?"
                      child: _buildPainTypeGrid(
                          s.clinicalPainTypes), // Lista de 4 tipos
                    ),
                    const SizedBox(height: 24),
                    // Sección 4: fila de 3 opciones de frecuencia/momento
                    _buildSection(
                      label: s.clinicalWhenDidItStart, // "¿CUÁNDO EMPEZÓ?"
                      child: _buildFrequencyOptions(
                          s.clinicalFrequencyOptions), // Lista de 3 opciones
                    ),
                    const SizedBox(height: 24),
                    // Sección 5: escala numérica del impacto en el sueño
                    _buildSection(
                      label:
                          s.clinicalHowAffectsSleep, // "¿CÓMO AFECTA TU SUEÑO?"
                      sublabel: s.clinicalSleepHint,
                      child: _buildNumberScale(
                          _sleepLevel, (v) => setState(() => _sleepLevel = v)),
                    ),
                    const SizedBox(height: 24),
                    _buildNotesField(s), // Campo de texto libre opcional
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            _buildActions(
                s), // Botones "ENVIAR" y "CANCELAR" fijos en la parte inferior
          ],
        ),
      ),
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────────────

  /// AppBar rojo — el color alerta visualmente que se trata de una situación de dolor.
  /// El botón de retroceso devuelve `false` (cancelación sin enviar).
  PreferredSizeWidget _buildAppBar(AppStrings s) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: Colors.white, size: 20),
        onPressed: () =>
            Navigator.of(context).pop(false), // Cancela y devuelve false
      ),
      centerTitle: true,
      title: Text(
        s.clinicalEvalTitle, // "EVALUACIÓN CLÍNICA"
        style: const TextStyle(
          color: Colors.redAccent, // Rojo — señal de alerta médica
          fontSize: 13,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  /// Tarjeta de alerta roja con el nombre del ejercicio y el aviso de que el fisio será notificado.
  Widget _buildHeader(AppStrings s) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.redAccent.withValues(alpha: 0.08), // Fondo rojo muy suave
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: Colors.redAccent
                .withValues(alpha: 0.3)), // Borde rojo semitransparente
      ),
      child: Row(
        children: [
          // Icono de servicios médicos en contenedor rojo
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.redAccent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.medical_services_rounded,
                color: Colors.redAccent, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.clinicalPainReported, // "DOLOR REPORTADO"
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  widget.exerciseName
                      .toUpperCase(), // Nombre del ejercicio en mayúsculas
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  s.clinicalPhysioWillReceive, // "Tu fisio recibirá esta información"
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Section wrapper ───────────────────────────────────────────────────────

  /// Contenedor de sección reutilizable: muestra el `label` azul, el `sublabel` gris
  /// opcional y a continuación el widget de contenido (`child`).
  Widget _buildSection({
    required String label, // Título de la sección en azul
    String? sublabel, // Descripción opcional en gris
    required Widget child, // Control de selección (escala, cuadrícula, etc.)
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label, // Título de la sección en azul
          style: const TextStyle(
            color: AppColors.primary, // Azul — jerarquía de sección
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        if (sublabel != null) ...[
          const SizedBox(height: 3),
          Text(
            sublabel, // Pista adicional en gris
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
        const SizedBox(height: 12),
        child, // Control de selección que varía por sección
      ],
    );
  }

  // ── Pain scale ────────────────────────────────────────────────────────────

  // Cinco puntos de la escala de dolor — 0, 2, 5, 8, 10 (no todos los enteros)
  // para que los botones quepan en la fila sin overflow.
  static const List<int> _painLevels = [0, 2, 5, 8, 10];

  // Iconos de emoticonos para cada nivel — de muy satisfecho a muy insatisfecho.
  static const Map<int, IconData> _painIcons = {
    0: Icons.sentiment_very_satisfied_rounded, // Sin dolor
    2: Icons.sentiment_satisfied_rounded, // Dolor leve
    5: Icons.sentiment_neutral_rounded, // Dolor moderado
    8: Icons.sentiment_dissatisfied_rounded, // Dolor intenso
    10: Icons.sentiment_very_dissatisfied_rounded, // Dolor muy intenso
  };

  // Colores semafóricos para cada nivel de dolor.
  static const Map<int, Color> _painColors = {
    0: Color(0xFF00BFA5), // Verde azulado — sin dolor
    2: Color(0xFF42A5F5), // Azul — dolor leve
    5: Color(0xFF7E57C2), // Violeta — dolor moderado
    8: Color(0xFFFF7043), // Naranja rojizo — dolor intenso
    10: Color(0xFFF44336), // Rojo — dolor muy intenso
  };

  /// Fila de 5 botones animados para seleccionar el nivel de dolor.
  /// El seleccionado muestra un halo de color y el icono más grande.
  Widget _buildPainScale() {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween, // Distribuye uniformemente
      children: _painLevels.map((i) {
        final selected =
            _painLevel == i; // Verdadero si este nivel está seleccionado
        final color =
            _painColors[i]!; // Color del nivel (nunca null gracias al `!`)
        return GestureDetector(
          onTap: () =>
              setState(() => _painLevel = i), // Actualiza el nivel seleccionado
          child: AnimatedContainer(
            duration: const Duration(
                milliseconds: 150), // Animación suave al seleccionar
            width: 58,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              // Fondo de color suave cuando está seleccionado, oscuro cuando no
              color:
                  selected ? color.withValues(alpha: 0.15) : AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected
                    ? color
                    : AppColors.border, // Borde de color o gris
                width: selected ? 1.5 : 1, // Borde más grueso al seleccionar
              ),
              // Halo de color solo cuando está seleccionado
              boxShadow: selected
                  ? [
                      BoxShadow(
                          color: color.withValues(alpha: 0.35),
                          blurRadius: 10,
                          spreadRadius: 1)
                    ]
                  : [], // Sin sombra cuando no está seleccionado
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _painIcons[i], // Emoticono correspondiente al nivel
                  color: selected
                      ? color
                      : AppColors.textSecondary, // Color temático o gris
                  size: selected ? 34 : 28, // Más grande al seleccionar
                ),
                const SizedBox(height: 5),
                Text(
                  '$i', // Número del nivel (0, 2, 5, 8 o 10)
                  style: TextStyle(
                    color: selected ? color : AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Pain type grid ────────────────────────────────────────────────────────

  // Iconos para los 4 tipos de dolor: punzante, pulsátil, opresivo, eléctrico.
  static const List<IconData> _painTypeIcons = [
    Icons.push_pin_rounded, // Punzante — como un alfiler
    Icons.waves_rounded, // Pulsátil — ondas
    Icons.compress_rounded, // Opresivo — compresión
    Icons.bolt_rounded, // Eléctrico — rayo
  ];

  /// Cuadrícula 2×2 de tarjetas de tipo de dolor.
  /// Recibe los labels desde LocaleManager para que sean traducibles.
  Widget _buildPainTypeGrid(List<String> labels) {
    return Column(
      children: [
        // Primera fila: tipos 0 y 1
        Row(children: [
          _PainTypeCard(
              icon: _painTypeIcons[0],
              label: labels[0], // "Punzante"
              selected: _painTypeIndex == 0,
              onTap: () => setState(() => _painTypeIndex = 0)),
          const SizedBox(width: 10),
          _PainTypeCard(
              icon: _painTypeIcons[1],
              label: labels[1], // "Pulsátil"
              selected: _painTypeIndex == 1,
              onTap: () => setState(() => _painTypeIndex = 1)),
        ]),
        const SizedBox(height: 10),
        // Segunda fila: tipos 2 y 3
        Row(children: [
          _PainTypeCard(
              icon: _painTypeIcons[2],
              label: labels[2], // "Opresivo"
              selected: _painTypeIndex == 2,
              onTap: () => setState(() => _painTypeIndex = 2)),
          const SizedBox(width: 10),
          _PainTypeCard(
              icon: _painTypeIcons[3],
              label: labels[3], // "Eléctrico"
              selected: _painTypeIndex == 3,
              onTap: () => setState(() => _painTypeIndex = 3)),
        ]),
      ],
    );
  }

  // ── Frequency options ─────────────────────────────────────────────────────

  // Iconos para las 3 opciones de frecuencia/momento del dolor.
  static const List<IconData> _frequencyIcons = [
    Icons.brightness_low_rounded, // Poco frecuente / reciente
    Icons.sync_rounded, // Recurrente / cíclico
    Icons.all_inclusive_rounded, // Constante / siempre
  ];

  /// Fila de 3 tarjetas para indicar cuándo empezó el dolor.
  /// Construida con un bucle en lugar de inline para simplicidad.
  Widget _buildFrequencyOptions(List<String> labels) {
    final items = <Widget>[]; // Lista mutable de widgets para el Row
    for (int i = 0; i < labels.length; i++) {
      if (i > 0)
        items.add(const SizedBox(width: 10)); // Separador entre tarjetas
      items.add(_PainTypeCard(
        icon: _frequencyIcons[i],
        label: labels[i], // "Ahora", "Recurrente", "Siempre"
        selected: _timingIndex == i,
        onTap: () => setState(
            () => _timingIndex = i), // Actualiza el índice de frecuencia
      ));
    }
    return Row(children: items); // Row con las 3 tarjetas
  }

  // ── Number scale (shared) ─────────────────────────────────────────────────

  // Los mismos 5 niveles que la escala de dolor — reutiliza también `_painColors`.
  static const List<int> _scaleLevels = [0, 2, 5, 8, 10];

  /// Escala numérica genérica reutilizable (usada para el impacto en el sueño).
  /// Misma apariencia que `_buildPainScale` pero con número en el centro en vez de emoticono.
  /// Acepta el valor actual y un callback para actualizarlo — patrón `ValueChanged<int>`.
  Widget _buildNumberScale(int? selected, ValueChanged<int> onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: _scaleLevels.map((i) {
        final isSelected =
            selected == i; // Verdadero si este nivel está seleccionado
        final color = _painColors[i]!; // Color semafórico del nivel
        return GestureDetector(
          onTap: () =>
              onChanged(i), // Llama al callback con el valor seleccionado
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 58,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: isSelected
                  ? color.withValues(alpha: 0.15)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? color : AppColors.border,
                width: isSelected ? 1.5 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                          color: color.withValues(alpha: 0.35),
                          blurRadius: 10,
                          spreadRadius: 1)
                    ]
                  : [],
            ),
            child: Center(
              child: Text(
                '$i', // Número del nivel sin emoticono
                style: TextStyle(
                  color: isSelected ? color : AppColors.textSecondary,
                  fontSize: isSelected ? 22 : 18, // Más grande al seleccionar
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w500,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Precise intensity ─────────────────────────────────────────────────────

  /// Sección del slider de intensidad precisa.
  /// Muestra el valor actual con `AnimatedSwitcher` para animar el cambio de número.
  /// El color del slider y del número cambia según la intensidad (verde / naranja / rojo).
  Widget _buildPreciseIntensitySection(AppStrings s) {
    final formatted = _preciseIntensity.toStringAsFixed(1); // Ej: "7.3"
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              s.clinicalPreciseIntensity.toUpperCase(), // "INTENSIDAD PRECISA"
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(width: 10),
            // AnimatedSwitcher anima la transición entre valores del número
            // `ValueKey(formatted)` fuerza la reconstrucción cuando el texto cambia
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              child: Text(
                formatted,
                key: ValueKey(
                    formatted), // Clave única para cada valor formateado
                style: TextStyle(
                  color:
                      _intensityColor(_preciseIntensity), // Verde/naranja/rojo
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // `SliderTheme` personaliza los colores del slider según la intensidad actual
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor:
                _intensityColor(_preciseIntensity), // Pista activa (izquierda)
            inactiveTrackColor: AppColors.border, // Pista inactiva (derecha)
            thumbColor: _intensityColor(_preciseIntensity), // Manija del slider
            overlayColor: _intensityColor(_preciseIntensity)
                .withValues(alpha: 0.2), // Halo al pulsar
            trackHeight: 4, // Grosor de la pista
            thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 8), // Manija circular de 8 px
            overlayShape: const RoundSliderOverlayShape(
                overlayRadius: 18), // Halo de 18 px
          ),
          child: Slider(
            value: _preciseIntensity,
            min: 0,
            max: 10,
            divisions: 100, // 100 divisiones → precisión de 0.1
            onChanged: (v) => setState(() => _preciseIntensity = v),
          ),
        ),
        // Etiquetas de los extremos del slider (0 y 10)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('0',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 11)),
              Text('10',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 11)),
            ],
          ),
        ),
      ],
    );
  }

  /// Devuelve el color semafórico para el slider según la intensidad.
  /// 0–3 → verde (leve), 3–6 → naranja (moderado), >6 → rojo (severo).
  Color _intensityColor(double value) {
    if (value <= 3) return const Color(0xFF00BFA5); // Verde azulado — leve
    if (value <= 6) return const Color(0xFFFF7043); // Naranja rojizo — moderado
    return const Color(0xFFF44336); // Rojo — severo
  }

  // ── Notes field ──────────────────────────────────────────────────────────

  /// Campo de texto libre para notas adicionales (opcional).
  /// Permite al paciente describir con sus propias palabras dónde o cómo duele.
  Widget _buildNotesField(AppStrings s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          s.clinicalAdditionalNotes.toUpperCase(), // "NOTAS ADICIONALES"
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller:
              _notesController, // Controla el texto para poder leerlo al enviar
          minLines: 2, // Altura mínima de 2 líneas
          maxLines:
              5, // Se expande hasta 5 líneas antes de hacer scroll interno
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: s.clinicalNotesHint, // "Describe dónde duele..."
            hintStyle: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
            filled: true,
            fillColor: AppColors.surface, // Fondo oscuro del campo
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            // Borde estático sin foco
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            // Borde sin foco explícito (misma apariencia que `border`)
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            // Borde azul más grueso cuando el campo tiene el foco
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  /// Barra de acciones fija en la parte inferior con dos botones:
  ///  - "ENVIAR AL FISIO": habilitado solo si `_canSubmit` es verdadero.
  ///  - "CANCELAR": siempre habilitado, devuelve `false`.
  Widget _buildActions(AppStrings s) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      color: AppColors.background,
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed:
                  _canSubmit ? _submit : null, // Deshabilitado si faltan campos
              icon: const Icon(Icons.send_rounded, size: 18),
              label: Text(
                s.clinicalSendToPhysio, // "ENVIAR AL FISIO"
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary, // Azul cuando activo
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                    AppColors.border, // Gris cuando deshabilitado
                disabledForegroundColor:
                    AppColors.textSecondary, // Texto gris cuando deshabilitado
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () =>
                  Navigator.of(context).pop(false), // Cancela y devuelve false
              icon: const Icon(Icons.close_rounded, size: 18),
              label: Text(
                s.clinicalCancel, // "CANCELAR"
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.redAccent, // Rojo — acción de cancelación
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Pain type card ────────────────────────────────────────────────────────────

/// Tarjeta seleccionable con icono y etiqueta.
/// Usada tanto para los tipos de dolor (cuadrícula 2×2) como para las opciones de frecuencia (fila de 3).
/// `Expanded` hace que la tarjeta ocupe la fracción del Row que le corresponde.
class _PainTypeCard extends StatelessWidget {
  final IconData icon; // Icono que representa la opción
  final String label; // Texto descriptivo de la opción
  final bool selected; // Si está seleccionada actualmente
  final VoidCallback
      onTap; // Acción al pulsar (actualiza el índice en el padre)

  const _PainTypeCard({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      // `Expanded` dentro del Row divide el espacio equitativamente entre las tarjetas
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(
              milliseconds:
                  150), // Transición suave al seleccionar/deseleccionar
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            // Fondo azul suave cuando seleccionado, oscuro cuando no
            color: selected
                ? AppColors.primary.withValues(alpha: 0.12)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? AppColors.primary
                  : AppColors.border, // Borde azul o gris
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // El contenido determina la altura
            children: [
              Icon(
                icon,
                color: selected
                    ? AppColors.primary
                    : AppColors.textSecondary, // Azul o gris
                size:
                    32, // Tamaño fijo (no cambia al seleccionar, a diferencia de la escala de dolor)
              ),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign:
                    TextAlign.center, // Centra el texto para etiquetas largas
                style: TextStyle(
                  color: selected ? Colors.white : AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
