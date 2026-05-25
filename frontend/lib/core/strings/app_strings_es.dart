import 'app_strings.dart';

class AppStringsEs implements AppStrings {
  const AppStringsEs();

  @override
  String get navHome => 'INICIO';
  @override
  String get navRoutines => 'MIS RUTINAS';
  @override
  String get navProgress => 'MI PROGRESO';
  @override
  String get navSettings => 'AJUSTES';

  @override
  String get appName => 'RETRAINEX';
  @override
  String get loading => 'Cargando...';
  @override
  String get errorLoadingInfo => 'No se pudo cargar la información';
  @override
  String get errorLoadingNotifications =>
      'No se pudieron cargar las notificaciones';

  @override
  String greeting(String name) => '¡Hola, $name!';
  @override
  String get treatmentCompleted => 'TRATAMIENTO COMPLETADO';
  @override
  String get nextSession => 'PRÓXIMA SESIÓN';
  @override
  String get date => 'FECHA';
  @override
  String get hour => 'HORA';
  @override
  String get viewDetails => 'VER DETALLES';
  @override
  String get reminder => 'RECORDATORIO';
  @override
  String get seniorPhysiotherapist => 'FISIOTERAPEUTA SENIOR';
  @override
  String get newAssignment => 'NUEVA ASIGNACIÓN';
  @override
  String get physiotherapyStartsToday => 'TU FISIOTERAPIA COMIENZA HOY';
  @override
  String get currentAssignment => 'ASIGNACIÓN ACTUAL';
  @override
  String get aboutToBegin => 'ESTÁS A PUNTO DE COMENZAR ESTA AVENTURA';
  @override
  String get noNotificationsYet =>
      'NO HAS RECIBIDO NINGUNA NOTIFICACIÓN DE MOMENTO';

  @override
  String get notifications => 'Notificaciones';
  @override
  String get noNotifications => 'No tienes notificaciones';
  @override
  String newNotifications(int count) => 'NUEVAS ($count)';
  @override
  String get previousNotifications => 'ANTERIORES';
  @override
  String get open => 'Abrir →';

  @override
  String get planYourSuccess => 'Planifica tu éxito';
  @override
  String get configureRoutine => 'Configura tu rutina de hoy';
  @override
  String get selectDays => 'SELECCIONA LOS DÍAS';
  @override
  String get activityTime => 'HORA DE LA ACTIVIDAD';
  @override
  String get start => 'EMPEZAR';
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

  @override
  String get noSessionsScheduled => 'Sin sesiones programadas';
  @override
  List<String> get monthNames => [
        'Enero',
        'Febrero',
        'Marzo',
        'Abril',
        'Mayo',
        'Junio',
        'Julio',
        'Agosto',
        'Septiembre',
        'Octubre',
        'Noviembre',
        'Diciembre',
      ];
  @override
  List<String> get weekDayShort => ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
  @override
  List<String> get weekDayMedium =>
      ['LUN', 'MAR', 'MIÉ', 'JUE', 'VIE', 'SÁB', 'DOM'];

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
  String get settingsPersonalDataSub => 'Nombre, edad, peso';
  @override
  String get settingsAccessibility => 'Accesibilidad';
  @override
  String get settingsAccessibilitySub => 'Tamaño de texto, contraste';
  @override
  String get settingsLanguage => 'Idioma';
  @override
  String get settingsLanguageValue => 'Español';
  @override
  String get settingsVersion => 'Versión 1.0.0';
  @override
  String get settingsCopyright =>
      '© 2026 ReTrainex. Todos los derechos reservados.';
  @override
  String get remindersEnabled => '¡Recordatorios activados!';
  @override
  String get reminders => 'Recordatorios';
  @override
  String get remindersSubtitle => 'Recibe alertas para tus ejercicios';
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

  @override
  String get skipQuestion => '¿POR QUÉ OMITES EL EJERCICIO?';
  @override
  String get skipDontKnow => 'No sé hacer el ejercicio';
  @override
  String get skipCantNow => 'No puedo hacerlo ahora';
  @override
  String get skipPain => 'Me duele';

  @override
  String get statusCompleted => 'COMPLETADO';
  @override
  String get statusToday => 'HOY';
  @override
  String get statusUpcoming => 'PRÓXIMO';

  @override
  String get weeklyProgress => 'PROGRESO SEMANAL';
  @override
  String get progressStart => 'EMPIEZA HOY';
  @override
  String get progressDone => '¡LO LOGRASTE!';
  @override
  String get progressOnTrack => 'VAS POR BUEN CAMINO';
  @override
  String progressSessions(int completed, int total) =>
      '$completed de $total sesiones completadas';

  @override
  String get todaySession => 'SESIÓN DE HOY';
  @override
  String get sessionCompleted => 'SESIÓN COMPLETADA';
  @override
  String get noSessionToday => 'Sin sesión programada hoy';

  @override
  String exerciseSubtitleSeries(int series, int reps) =>
      '$series SERIES  x  $reps REPS';
  @override
  String exerciseSubtitleMinutes(int minutes) => '$minutes MINUTOS';
  @override
  String get prepAppBar => 'ENTRENAMIENTO EN CURSO';
  @override
  String get prepExit => 'Salir';
  @override
  String get prepGetReady => 'PREPÁRATE';
  @override
  String get prepSkip => 'Omitir preparación';

  @override
  String get registerTitle => 'Registro';
  @override
  String get registerPlaceholder => 'Pantalla de registro';

  @override
  String get settingsDevTestTitle => 'Test de formulario';
  @override
  String get settingsDevTestSub => 'Test del selector de días';

  @override
  String get videoComingSoon => 'VÍDEO PRÓXIMAMENTE';

  @override
  String get errorRetry => 'Reintentar';

  @override
  String get controlsSkipExercise => 'OMITIR EJERCICIO';
  @override
  String get controlsNextExercise => 'Siguiente ejercicio';
  @override
  String get controlsResume => 'Continuar';
  @override
  String get controlsPause => 'Pausar';

  @override
  String get exerciseCurrentLabel => 'EJERCICIO ACTUAL';
  @override
  String get exerciseVideoHd => 'VIDEO HD';
  @override
  String get exerciseFrontal => 'FRONTAL';
  @override
  String get exerciseDetails => 'DETALLES';
  @override
  String get exerciseNoLimit => 'SIN LÍMITE';
  @override
  String get exerciseRhythmLabel => 'RITMO';
  @override
  String get exerciseProgressLabel => 'PROGRESO';

  @override
  String get routineDetailTitle => 'DETALLES DE SESIÓN';
  @override
  String get routineActiveProtocol => 'PROTOCOLO_ACTIVO';
  @override
  String get routineSysLog => 'SYS_LOG: OBJETIVO_MISIÓN';
  @override
  String get routineExerciseList => 'EJE_LISTA';
  @override
  String routineItems(int count) => '// ${count.toString().padLeft(2, '0')} ELEMENTOS';
  @override
  String get loadingSession => 'Cargando sesión...';
  @override
  String get errorLoadingSession => 'No se pudo cargar el detalle de la sesión';
  @override
  String get startSession => 'INICIAR';

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
      ['Punzante', 'Sordo', 'Opresivo', 'Eléctrico'];
  @override
  List<String> get clinicalTimingLabels =>
      ['Antes del ejercicio', 'Al empezar', 'Durante', 'Al terminar'];
  @override
  String get clinicalPreciseIntensity => 'Intensidad precisa';
  @override
  List<String> get clinicalFrequencyOptions =>
      ['Ocasional', 'Intermitente', 'Constante'];
  @override
  String get clinicalHowAffectsSleep => '¿CÓMO AFECTA A TU SUEÑO?';
  @override
  String get clinicalSleepHint => '0 = poco  ·  10 = mucho';
  @override
  String get clinicalAdditionalNotes => 'Notas adicionales (opcional)';
  @override
  String get clinicalNotesHint => 'Escribe aquí cualquier otro detalle...';

  @override
  String get userAssignedRoutine => 'Rutina asignada';
  @override
  String get userPhysiotherapist => 'Fisioterapeuta';
  @override
  String get userNotSpecified => 'No especificado';
  @override
  String get userAge => 'Edad';
  @override
  String get userYears => 'años';
  @override
  String get userWeight => 'Peso';
  @override
  String get userHeight => 'Altura';

  @override
  String get restAppBar => 'FASE DE RECUPERACIÓN';
  @override
  String get restSessionLabel => 'SESIÓN RETRAINEX';
  @override
  String get restTitle => 'TIEMPO DE\nDESCANSO';
  @override
  String get restSeconds => 'SEGUNDOS';
  @override
  String get restAddTime => '+20 segundos';
  @override
  String get restSkip => 'Omitir descanso';
  @override
  String get restStopSession => 'Detener sesión';
  @override
  String get restNextExercise => 'PRÓXIMO EJERCICIO';

  @override
  String get sessionPausedTitle => 'DETALLE DEL EJERCICIO';
  @override
  String get sessionPausedBack => 'VOLVER AL EJERCICIO';
  @override
  String get sessionPausedStart => 'INICIAR EJERCICIO';
  @override
  String sessionPausedRhythm(String rhythm) => 'RITMO ${rhythm.toUpperCase()}';
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

  @override
  String get loginTitle => 'Login';
  @override
  String get loginSubtitle => 'REHABILITACIÓN INTELIGENTE';
  @override
  String get loginEmailHint => 'ejemplo@email.com';
  @override
  String get loginEmailRequired => 'Introduce tu correo';
  @override
  String get loginEmailInvalid => 'Correo no válido';
  @override
  String get loginPasswordLabel => 'Contraseña';
  @override
  String get loginPasswordRequired => 'Introduce tu contraseña';
  @override
  String get loginPasswordTooShort => 'Debe tener al menos 6 caracteres';
  @override
  String get loginButton => 'Iniciar Sesión';
  @override
  String get loginNoAccount => '¿No tienes cuenta? Crear cuenta';
  @override
  String get loginSuccess => 'Login correcto (de momento simulado)';

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

  @override
  String get sessionCompleteAppBar => 'SESIÓN COMPLETADA';
  @override
  String get excellent => '¡EXCELENTE!';
  @override
  String get dayCompleted => 'DÍA COMPLETADO';
  @override
  String get statDuration => 'DURACIÓN';
  @override
  String get statExercises => 'EJERCICIOS';
  @override
  String get congratsMessage =>
      '¡Felicitaciones! Has completado tu sesión de hoy. Continúa así para alcanzar tus objetivos.';
  @override
  String streakDays(int days) => 'RACHA DE $days DÍAS';
  @override
  String get onFire => '¡Estás en llamas! No te detengas.';
  @override
  String get newAchievement => 'NUEVO LOGRO';
  @override
  String get goHome => 'VOLVER AL INICIO';

  @override
  String timeAgoMinutes(int minutes) => 'Hace $minutes minutos';
  @override
  String timeAgoHours(int hours) => 'Hace $hours horas';
  @override
  String timeAgoDays(int days) => 'Hace $days días';

  @override
  String get routineListLoading => 'Cargando rutinas...';
  @override
  String get routineListError => 'No se pudieron cargar las rutinas';
}
