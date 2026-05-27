import 'app_strings.dart'; // Importa el contrato abstracto que esta clase debe cumplir

/// Implementación española de todos los textos de la app.
///
/// Cada método / getter lleva @override para indicar que implementa
/// una declaración de AppStrings. El compilador avisa si falta alguna.
///
/// 'const AppStringsEs()' permite que LocaleManager devuelva
/// una instancia constante (creada en tiempo de compilación, coste cero).
class AppStringsEs implements AppStrings {
  const AppStringsEs();

  // ── Nav ───────────────────────────────────────────────────────────────────
  @override
  String get navHome => 'INICIO';       // Pestaña 0 de la barra inferior
  @override
  String get navRoutines => 'MIS RUTINAS'; // Pestaña 1
  @override
  String get navProgress => 'MI PROGRESO'; // Pestaña 2
  @override
  String get navSettings => 'AJUSTES';     // Pestaña 3

  // ── General ───────────────────────────────────────────────────────────────
  @override
  String get appName => 'RETRAINEX'; // Nombre visible de la app (mayúsculas)
  @override
  String get loading => 'Cargando...'; // Spinner genérico
  @override
  String get errorLoadingInfo => 'No se pudo cargar la información'; // Error genérico
  @override
  String get errorLoadingNotifications =>
      'No se pudieron cargar las notificaciones'; // Error específico de notificaciones

  // ── Dashboard ─────────────────────────────────────────────────────────────
  @override
  String greeting(String name) => '¡Hola, $name!'; // Saludo dinámico con el nombre del paciente
  @override
  String get treatmentCompleted => 'TRATAMIENTO COMPLETADO'; // Debajo del anillo de progreso
  @override
  String get nextSession => 'PRÓXIMA SESIÓN'; // Cabecera tarjeta siguiente sesión
  @override
  String get date => 'FECHA'; // Columna fecha en tarjeta sesión
  @override
  String get hour => 'HORA';  // Columna hora en tarjeta sesión
  @override
  String get viewDetails => 'VER DETALLES'; // Botón gradiente del dashboard
  @override
  String get reminder => 'RECORDATORIO'; // Etiqueta tarjeta de recordatorio
  @override
  String get seniorPhysiotherapist => 'FISIOTERAPEUTA SENIOR'; // Cargo bajo el nombre del fisio
  @override
  String get newAssignment => 'NUEVA ASIGNACIÓN'; // Badge estado newAssignment
  @override
  String get physiotherapyStartsToday => 'TU FISIOTERAPIA COMIENZA HOY'; // Subtítulo estado newAssignment
  @override
  String get currentAssignment => 'ASIGNACIÓN ACTUAL'; // Etiqueta dentro de tarjeta de asignación
  @override
  String get aboutToBegin => 'ESTÁS A PUNTO DE COMENZAR ESTA AVENTURA'; // Cuerpo estado vacío (none)
  @override
  String get noNotificationsYet =>
      'NO HAS RECIBIDO NINGUNA NOTIFICACIÓN DE MOMENTO'; // Texto en estado vacío

  // ── Notifications ─────────────────────────────────────────────────────────
  @override
  String get notifications => 'Notificaciones'; // Título AppBar
  @override
  String get noNotifications => 'No tienes notificaciones'; // Estado vacío
  @override
  String newNotifications(int count) => 'NUEVAS ($count)'; // Cabecera sección no leídas
  @override
  String get previousNotifications => 'ANTERIORES'; // Cabecera sección leídas
  @override
  String get open => 'Abrir →'; // Enlace de acción por defecto

  // ── Schedule ──────────────────────────────────────────────────────────────
  @override
  String get planYourSuccess => 'Planifica tu éxito'; // Título
  @override
  String get configureRoutine => 'Configura tu rutina de hoy'; // Subtítulo
  @override
  String get selectDays => 'SELECCIONA LOS DÍAS'; // Etiqueta selector
  @override
  String get activityTime => 'HORA DE LA ACTIVIDAD'; // Etiqueta time picker
  @override
  String get start => 'EMPEZAR'; // Botón principal
  // Abreviaturas de 3 letras para el selector de días del calendario
  @override
  String get monday => 'LUN';
  @override
  String get tuesday => 'MAR';
  @override
  String get wednesday => 'MIÉ';
  @override
  String get thursday => 'JUE';
  @override
  String get friday => 'VIE';
  @override
  String get saturday => 'SÁB';
  @override
  String get sunday => 'DOM';

  // ── Progress / Calendar ───────────────────────────────────────────────────
  @override
  String get noSessionsScheduled => 'Sin sesiones programadas'; // En tarjeta de día seleccionado
  @override
  List<String> get monthNames => [ // 12 nombres de mes — índice 0=enero, 11=diciembre
        'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
        'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
      ];
  @override
  List<String> get weekDayShort => ['L', 'M', 'X', 'J', 'V', 'S', 'D']; // 1 letra por día (X=miércoles)
  @override
  List<String> get weekDayMedium =>
      ['LUN', 'MAR', 'MIÉ', 'JUE', 'VIE', 'SÁB', 'DOM']; // 3 letras por día

  // ── Form ──────────────────────────────────────────────────────────────────
  @override
  String get formPlanTitle => 'Planifica tu éxito';
  @override
  String get formPlanSubtitle => 'Configura tu rutina';
  @override
  String get formSelectDays => 'Selecciona los días';
  @override
  String get formActivityTime => 'Hora de la actividad';
  @override
  String get formStart => 'EMPEZAR';

  // ── Settings ──────────────────────────────────────────────────────────────
  @override
  String get settingsNotifications => 'Notificaciones';
  @override
  String get settingsProfile => 'Perfil';
  @override
  String get settingsSchedule => 'Horario';
  @override
  String get settingsFaq => 'Preguntas frecuentes';
  @override
  String get settingsPersonalData => 'Datos personales';
  @override
  String get settingsPersonalDataSub => 'Nombre, edad, peso'; // Subtítulo descriptivo
  @override
  String get settingsAccessibility => 'Accesibilidad';
  @override
  String get settingsAccessibilitySub => 'Tamaño de texto, contraste';
  @override
  String get settingsLanguage => 'Idioma';
  @override
  String get settingsLanguageValue => 'Español'; // Valor actual mostrado junto al ítem
  @override
  String get settingsVersion => 'Versión 1.0.0'; // En el footer de la pantalla
  @override
  String get settingsCopyright =>
      '© 2026 ReTrainex. Todos los derechos reservados.'; // Pie del footer
  @override
  String get remindersEnabled => '¡Recordatorios activados!'; // Snackbar al activar toggle
  @override
  String get reminders => 'Recordatorios';                  // Título del toggle
  @override
  String get remindersSubtitle => 'Recibe alertas para tus ejercicios'; // Subtítulo del toggle

  // FAQ — 4 preguntas frecuentes con respuestas largas
  @override
  String get faqTitle => 'PREGUNTAS FRECUENTES';
  @override
  String get faq1Question => '¿Puedo saltar ejercicios?';
  @override
  String get faq1Answer =>
      'Sí, puedes omitir cualquier ejercicio. Sin embargo, te recomendamos hablar con tu fisioterapeuta antes de hacerlo con frecuencia.';
  @override
  String get faq2Question => '¿Qué pasa si me duele?';
  @override
  String get faq2Answer =>
      'Para inmediatamente el ejercicio y contacta con tu fisioterapeuta. Nunca fuerces un movimiento que cause dolor agudo.';
  @override
  String get faq3Question => '¿Con qué frecuencia debo hacer las sesiones?';
  @override
  String get faq3Answer =>
      'Tu fisioterapeuta ha diseñado un plan específico para ti. Sigue los días asignados para mejores resultados.';
  @override
  String get faq4Question => '¿Cómo cambio mi horario de recordatorio?';
  @override
  String get faq4Answer =>
      'Ve a Ajustes → Notificaciones → Horario y selecciona la hora que prefieras.';

  // ── Skip reason sheet ────────────────────────────────────────────────────
  @override
  String get skipQuestion => '¿POR QUÉ OMITES EL EJERCICIO?'; // Pregunta principal
  @override
  String get skipDontKnow => 'No sé hacer el ejercicio'; // Opción 1
  @override
  String get skipCantNow => 'No puedo hacerlo ahora';    // Opción 2
  @override
  String get skipPain => 'Me duele';                     // Opción 3 → dispara evaluación clínica

  // ── Routine status ───────────────────────────────────────────────────────
  @override
  String get statusCompleted => 'COMPLETADO'; // Badge verde en RoutineCardWidget
  @override
  String get statusToday => 'HOY';            // Badge azul — la rutina de hoy
  @override
  String get statusUpcoming => 'PRÓXIMO';     // Badge gris — días futuros

  // ── Weekly progress card ─────────────────────────────────────────────────
  @override
  String get weeklyProgress => 'PROGRESO SEMANAL'; // Cabecera de ProgressCardWidget
  @override
  String get progressStart => 'EMPIEZA HOY';       // Mensaje si completadas == 0
  @override
  String get progressDone => '¡LO LOGRASTE!';      // Mensaje si completadas == total
  @override
  String get progressOnTrack => 'VAS POR BUEN CAMINO'; // Mensaje si hay progreso parcial
  @override
  String progressSessions(int completed, int total) =>
      '$completed de $total sesiones completadas'; // Texto debajo de la barra de progreso

  // ── Today's session ──────────────────────────────────────────────────────
  @override
  String get todaySession => 'SESIÓN DE HOY';           // Etiqueta en tarjeta de hoy
  @override
  String get sessionCompleted => 'SESIÓN COMPLETADA';   // Si ya se hizo
  @override
  String get noSessionToday => 'Sin sesión programada hoy'; // Si no hay rutina asignada hoy

  // ── Exercise subtitles ────────────────────────────────────────────────────
  @override
  String exerciseSubtitleSeries(int series, int reps) =>
      '$series SERIES  x  $reps REPS'; // En ExerciseCardWidget cuando es por repeticiones
  @override
  String exerciseSubtitleMinutes(int minutes) => '$minutes MINUTOS'; // Cuando es por tiempo

  // ── Workout preparation ───────────────────────────────────────────────────
  @override
  String get prepAppBar => 'ENTRENAMIENTO EN CURSO'; // Título AppBar cuenta atrás
  @override
  String get prepExit => 'Salir';                    // Tooltip del botón X
  @override
  String get prepGetReady => 'PREPÁRATE';            // Texto dentro del anillo
  @override
  String get prepSkip => 'Omitir preparación';       // Enlace para saltar la cuenta atrás

  // ── Register ──────────────────────────────────────────────────────────────
  @override
  String get registerTitle => 'Registro';
  @override
  String get registerPlaceholder => 'Pantalla de registro'; // Placeholder — pendiente de implementar

  // ── Settings dev ──────────────────────────────────────────────────────────
  @override
  String get settingsDevTestTitle => 'Test de formulario';    // Solo visible en Settings para devs
  @override
  String get settingsDevTestSub => 'Test del selector de días'; // Abre WeekDaySelector de prueba

  // ── Video area ────────────────────────────────────────────────────────────
  @override
  String get videoComingSoon => 'VÍDEO PRÓXIMAMENTE'; // Cuando videoUrl == null

  // ── Error widget ──────────────────────────────────────────────────────────
  @override
  String get errorRetry => 'Reintentar'; // Botón de reintento en ErrorMessageWidget

  // ── Workout controls ─────────────────────────────────────────────────────
  @override
  String get controlsSkipExercise => 'OMITIR EJERCICIO'; // Tooltip botón skip
  @override
  String get controlsNextExercise => 'Siguiente ejercicio'; // Tooltip en modo timeless
  @override
  String get controlsResume => 'Continuar'; // Tooltip botón play (cuando pausado)
  @override
  String get controlsPause => 'Pausar';     // Tooltip botón pause (cuando activo)

  // ── Exercise screen labels ────────────────────────────────────────────────
  @override
  String get exerciseCurrentLabel => 'EJERCICIO ACTUAL'; // Supertítulo en WorkoutExerciseScreen
  @override
  String get exerciseVideoHd => 'VIDEO HD';              // Tag en área de vídeo
  @override
  String get exerciseFrontal => 'FRONTAL';               // Tag ángulo por defecto
  @override
  String get exerciseDetails => 'DETALLES';              // Tag que abre SessionPausedScreen
  @override
  String get exerciseNoLimit => 'SIN LÍMITE';            // Texto bajo el símbolo ∞
  @override
  String get exerciseRhythmLabel => 'RITMO';             // Etiqueta tarjeta inferior izquierda
  @override
  String get exerciseProgressLabel => 'PROGRESO';        // Etiqueta tarjeta inferior derecha

  // ── Routine detail ───────────────────────────────────────────────────────
  @override
  String get routineDetailTitle => 'DETALLES DE SESIÓN';       // Título en el header
  @override
  String get routineActiveProtocol => 'PROTOCOLO_ACTIVO';      // Supertítulo estilo HUD
  @override
  String get routineSysLog => 'SYS_LOG: OBJETIVO_MISIÓN';      // Etiqueta verde en tarjeta descripción
  @override
  String get routineExerciseList => 'EJE_LISTA';                // Cabecera lista de ejercicios
  @override
  String routineItems(int count) => '// ${count.toString().padLeft(2, '0')} ELEMENTOS'; // "// 04 ELEMENTOS" — padLeft rellena con ceros a la izquierda
  @override
  String get loadingSession => 'Cargando sesión...';
  @override
  String get errorLoadingSession => 'No se pudo cargar el detalle de la sesión';
  @override
  String get startSession => 'INICIAR'; // Botón principal de inicio de sesión

  // ── Clinical evaluation ───────────────────────────────────────────────────
  @override
  String get clinicalEvalTitle => 'EVALUACIÓN CLÍNICA';
  @override
  String get clinicalPainReported => 'DOLOR REPORTADO';
  @override
  String get clinicalPhysioWillReceive =>
      'Tu fisioterapeuta recibirá esta información.';
  @override
  String get clinicalHowDoYouFeel => '¿CÓMO TE SIENTES HOY?';
  @override
  String get clinicalPainScaleHint => '0 = sin dolor  ·  10 = dolor máximo';
  @override
  String get clinicalHowIsThePain => 'TIPO DE DOLOR';
  @override
  String get clinicalWhenDidItStart => '¿CON QUÉ FRECUENCIA APARECE?';
  @override
  String get clinicalSendToPhysio => 'ENVIAR';
  @override
  String get clinicalCancel => 'CANCELAR';
  @override
  List<String> get clinicalPainTypes =>
      ['Punzante', 'Sordo', 'Opresivo', 'Eléctrico']; // 4 tipos de dolor seleccionables
  @override
  List<String> get clinicalTimingLabels =>
      ['Antes del ejercicio', 'Al empezar', 'Durante', 'Al terminar']; // Cuándo aparece el dolor
  @override
  String get clinicalPreciseIntensity => 'Intensidad precisa'; // Etiqueta del slider continuo
  @override
  List<String> get clinicalFrequencyOptions =>
      ['Ocasional', 'Intermitente', 'Constante']; // Con qué frecuencia aparece
  @override
  String get clinicalHowAffectsSleep => '¿CÓMO AFECTA A TU SUEÑO?';
  @override
  String get clinicalSleepHint => '0 = poco  ·  10 = mucho';
  @override
  String get clinicalAdditionalNotes => 'Notas adicionales (opcional)';
  @override
  String get clinicalNotesHint => 'Escribe aquí cualquier otro detalle...';
  @override
  String get clinicalSubmitSuccess => 'Evaluación enviada al fisioterapeuta';

  // ── User / Profile ────────────────────────────────────────────────────────
  @override
  String get userAssignedRoutine => 'Rutina asignada';
  @override
  String get userPhysiotherapist => 'Fisioterapeuta';
  @override
  String get userNotSpecified => 'No especificado'; // Cuando el campo es null en el modelo
  @override
  String get userAge => 'Edad';
  @override
  String get userYears => 'años'; // Unidad que sigue al número de edad
  @override
  String get userWeight => 'Peso';
  @override
  String get userHeight => 'Altura';

  // ── Workout rest ─────────────────────────────────────────────────────────
  @override
  String get restAppBar => 'FASE DE RECUPERACIÓN';    // Título AppBar descanso
  @override
  String get restSessionLabel => 'SESIÓN RETRAINEX';  // Supertítulo
  @override
  String get restTitle => 'TIEMPO DE\nDESCANSO';      // '\n' fuerza salto de línea en el título
  @override
  String get restSeconds => 'SEGUNDOS';               // Unidad dentro del anillo
  @override
  String get restAddTime => '+20 segundos';           // Botón de añadir tiempo
  @override
  String get restSkip => 'Omitir descanso';           // Enlace omitir
  @override
  String get restStopSession => 'Detener sesión';     // Tooltip del botón de parada
  @override
  String get restNextExercise => 'PRÓXIMO EJERCICIO'; // Etiqueta en tarjeta de siguiente ej.

  // ── Session paused ────────────────────────────────────────────────────────
  @override
  String get sessionPausedTitle => 'DETALLE DEL EJERCICIO';
  @override
  String get sessionPausedBack => 'VOLVER AL EJERCICIO'; // Botón cuando fromWorkout == true
  @override
  String get sessionPausedStart => 'INICIAR EJERCICIO';  // Botón cuando fromWorkout == false
  @override
  String sessionPausedRhythm(String rhythm) => 'RITMO ${rhythm.toUpperCase()}'; // "RITMO LENTO" — toUpperCase normaliza el valor del backend
  @override
  String get sessionPausedSeries => 'SERIES';
  @override
  String get sessionPausedReps => 'REPS';
  @override
  String get sessionPausedDescription => 'DESCRIPCIÓN';
  @override
  String get sessionPausedDescriptionText =>
      'Realiza el movimiento de forma lenta y controlada. Mantén la postura correcta durante toda la ejecución para maximizar los beneficios y evitar lesiones.';
  @override
  String get sessionPausedTips => 'CONSEJOS';
  @override
  String get sessionPausedTipsText =>
      'Si notas dolor agudo, detente de inmediato. Respira de forma continua durante el ejercicio y consulta con tu fisioterapeuta ante cualquier duda.';

  // ── Login ─────────────────────────────────────────────────────────────────
  @override
  String get loginTitle => 'Login';
  @override
  String get loginSubtitle => 'REHABILITACIÓN INTELIGENTE';
  @override
  String get loginEmailHint => 'ejemplo@email.com';            // Placeholder del campo
  @override
  String get loginEmailRequired => 'Introduce tu correo';      // Validador: vacío
  @override
  String get loginEmailInvalid => 'Correo no válido';          // Validador: sin '@'
  @override
  String get loginPasswordLabel => 'Contraseña';
  @override
  String get loginPasswordRequired => 'Introduce tu contraseña'; // Validador: vacío
  @override
  String get loginPasswordTooShort => 'Debe tener al menos 6 caracteres'; // Validador: length < 6
  @override
  String get loginButton => 'Iniciar Sesión';
  @override
  String get loginNoAccount => '¿No tienes cuenta? Crear cuenta'; // Enlace a /register
  @override
  String get loginSuccess => 'Login correcto (de momento simulado)'; // Snackbar — sin backend real aún

  // ── Notification mock data ───────────────────────────────────────────────
  @override
  String get notifActionOpen => 'Abrir';
  @override
  String get notifMsgTitle => 'Mensaje del Dr. Pérez';
  @override
  String get notifMsgBody =>
      'Hola María, he revisado tu progreso y se ve excelente. Sigue así con la constancia.';
  @override
  String get notifQuestionnaireTitle => 'Cuestionario WOMAC pendiente';
  @override
  String get notifQuestionnaireBody =>
      'Por favor, completa el cuestionario de evaluación semanal para que tu fisioterapeuta pueda hacer seguimiento.';
  @override
  String get notifReminderTitle => 'Recordatorio de sesión';
  @override
  String get notifReminderBody =>
      'Tu sesión de hoy comienza en 30 minutos. ¡Prepárate!';
  @override
  String get notifSessionCompleteTitle => 'Sesión completada';
  @override
  String get notifSessionCompleteBody =>
      '¡Felicitaciones! Completaste tu sesión del Lunes. Llevas 5 días de racha.';

  // ── Workout complete ──────────────────────────────────────────────────────
  @override
  String get sessionCompleteAppBar => 'SESIÓN COMPLETADA';
  @override
  String get excellent => '¡EXCELENTE!';
  @override
  String get dayCompleted => 'DÍA COMPLETADO';
  @override
  String get statDuration => 'DURACIÓN';   // Etiqueta estadística tiempo
  @override
  String get statExercises => 'EJERCICIOS'; // Etiqueta estadística número de ejercicios
  @override
  String get congratsMessage =>
      '¡Felicitaciones! Has completado tu sesión de hoy. Continúa así para alcanzar tus objetivos.';
  @override
  String streakDays(int days) => 'RACHA DE $days DÍAS'; // Interpolación del número de días
  @override
  String get onFire => '¡Estás en llamas! No te detengas.';
  @override
  String get newAchievement => 'NUEVO LOGRO';
  @override
  String get goHome => 'VOLVER AL INICIO'; // Botón que hace popUntil(isFirst)

  // ── Time ago ─────────────────────────────────────────────────────────────
  @override
  String timeAgoMinutes(int minutes) => 'Hace $minutes minutos'; // Ej: "Hace 12 minutos"
  @override
  String timeAgoHours(int hours) => 'Hace $hours horas';         // Ej: "Hace 2 horas"
  @override
  String timeAgoDays(int days) => 'Hace $days días';             // Ej: "Hace 3 días"

  // ── Routines list ─────────────────────────────────────────────────────────
  @override
  String get routineListLoading => 'Cargando rutinas...';
  @override
  String get routineListError => 'No se pudieron cargar las rutinas';
}
