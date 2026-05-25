/// Contrato (interfaz) de todos los textos de la app.
///
/// Cada sección agrupa las claves de una funcionalidad.
/// Para añadir una nueva pantalla o widget:
///   1. Declara aquí las claves necesarias (get o método con parámetros).
///   2. Implementa el valor en AppStringsEs y AppStringsEn.
///
/// Convenio:
///   - 'String get xxx'   → texto sin parámetros (getter)
///   - 'String xxx(T p)'  → texto con datos en tiempo de ejecución (método)
///   - `` `List<String>` get `` → listas de etiquetas (días, meses, etc.)
abstract class AppStrings {
  // ── Nav ───────────────────────────────────────────────────────────────────
  // Etiquetas de la barra de navegación inferior
  String get navHome;      // "INICIO" / "HOME"
  String get navRoutines;  // "MIS RUTINAS" / "MY ROUTINES"
  String get navProgress;  // "MI PROGRESO" / "MY PROGRESS"
  String get navSettings;  // "AJUSTES" / "SETTINGS"

  // ── General ───────────────────────────────────────────────────────────────
  // Textos reutilizables en varios contextos
  String get appName;                    // Nombre de la app: "RETRAINEX"
  String get loading;                    // Indicador genérico de carga
  String get errorLoadingInfo;           // Error genérico al cargar datos
  String get errorLoadingNotifications;  // Error específico de notificaciones

  // ── Dashboard ─────────────────────────────────────────────────────────────
  // Textos de la pantalla principal (welcome_ini_screen)
  String greeting(String name);         // Saludo personalizado con el nombre del paciente
  String get treatmentCompleted;        // Etiqueta bajo el anillo de progreso
  String get nextSession;               // Cabecera de la tarjeta de próxima sesión
  String get date;                      // Etiqueta de columna "FECHA"
  String get hour;                      // Etiqueta de columna "HORA"
  String get viewDetails;               // Botón "VER DETALLES"
  String get reminder;                  // Etiqueta de tarjeta de recordatorio
  String get seniorPhysiotherapist;     // Subtítulo del nombre del fisio
  String get newAssignment;             // Badge "NUEVA ASIGNACIÓN"
  String get physiotherapyStartsToday;  // Subtítulo estado newAssignment
  String get currentAssignment;         // Etiqueta dentro de la tarjeta de asignación
  String get aboutToBegin;              // Subtítulo en estado vacío (none)
  String get noNotificationsYet;        // Cuerpo del estado vacío

  // ── Notifications ─────────────────────────────────────────────────────────
  String get notifications;                // Título AppBar de notificaciones
  String get noNotifications;             // Estado vacío de notificaciones
  String newNotifications(int count);      // Cabecera sección no leídas con contador
  String get previousNotifications;        // Cabecera sección leídas
  String get open;                         // Texto del enlace de acción por defecto

  // ── Schedule ──────────────────────────────────────────────────────────────
  // Pantalla de planificación de horario
  String get planYourSuccess;   // Título principal
  String get configureRoutine;  // Subtítulo
  String get selectDays;        // Etiqueta selector de días
  String get activityTime;      // Etiqueta selector de hora
  String get start;             // Botón "EMPEZAR"
  // Abreviaturas de días de la semana para el selector compacto
  String get monday;
  String get tuesday;
  String get wednesday;
  String get thursday;
  String get friday;
  String get saturday;
  String get sunday;

  // ── Progress / Calendar ───────────────────────────────────────────────────
  String get noSessionsScheduled;     // Texto cuando el día seleccionado no tiene sesión
  List<String> get monthNames;        // 12 nombres de mes (enero…diciembre / January…December)
  List<String> get weekDayShort;      // 7 iniciales de día (L,M,X,J,V,S,D / M,T,W,T,F,S,S)
  List<String> get weekDayMedium;     // 7 abreviaturas de día (LUN…DOM / MON…SUN)

  // ── Form ──────────────────────────────────────────────────────────────────
  // Mismo contenido que Schedule pero usado en el formulario interno de Settings
  String get formPlanTitle;
  String get formPlanSubtitle;
  String get formSelectDays;
  String get formActivityTime;
  String get formStart;

  // ── Settings ──────────────────────────────────────────────────────────────
  String get settingsNotifications;       // Cabecera sección Notificaciones
  String get settingsProfile;             // Cabecera sección Perfil
  String get settingsSchedule;            // Ítem Horario (no implementado aún)
  String get settingsFaq;                 // Ítem Preguntas frecuentes
  String get settingsPersonalData;        // Ítem Datos personales
  String get settingsPersonalDataSub;     // Subtítulo Datos personales
  String get settingsAccessibility;       // Ítem Accesibilidad (no implementado)
  String get settingsAccessibilitySub;    // Subtítulo Accesibilidad
  String get settingsLanguage;            // Ítem Idioma
  String get settingsLanguageValue;       // Valor actual: "Español" / "English"
  String get settingsVersion;             // "Versión 1.0.0"
  String get settingsCopyright;           // Pie de versión
  String get remindersEnabled;            // Snackbar al activar recordatorios
  String get reminders;                   // Etiqueta del toggle de recordatorios
  String get remindersSubtitle;           // Subtítulo del toggle
  String get faqTitle;                    // Título del bottom sheet de FAQ
  // 4 preguntas frecuentes con sus respuestas
  String get faq1Question;
  String get faq1Answer;
  String get faq2Question;
  String get faq2Answer;
  String get faq3Question;
  String get faq3Answer;
  String get faq4Question;
  String get faq4Answer;

  // ── Notification mock data ───────────────────────────────────────────────
  // Contenido de las notificaciones de ejemplo (se mueven aquí para poder localizarlas)
  String get notifActionOpen;            // Etiqueta del botón de acción
  String get notifMsgTitle;             // Título notif mensaje del Dr.
  String get notifMsgBody;              // Cuerpo notif mensaje del Dr.
  String get notifQuestionnaireTitle;   // Título notif cuestionario
  String get notifQuestionnaireBody;    // Cuerpo notif cuestionario
  String get notifReminderTitle;        // Título notif recordatorio
  String get notifReminderBody;         // Cuerpo notif recordatorio
  String get notifSessionCompleteTitle; // Título notif sesión completada
  String get notifSessionCompleteBody;  // Cuerpo notif sesión completada

  // ── Workout complete ──────────────────────────────────────────────────────
  String get sessionCompleteAppBar;  // Título de la AppBar en pantalla de fin
  String get excellent;              // Encabezado de celebración "¡EXCELENTE!"
  String get dayCompleted;           // Subtítulo "DÍA COMPLETADO"
  String get statDuration;           // Etiqueta estadística duración
  String get statExercises;          // Etiqueta estadística ejercicios
  String get congratsMessage;        // Mensaje de felicitaciones
  String streakDays(int days);       // "RACHA DE X DÍAS" — recibe el número
  String get onFire;                 // Mensaje motivacional de racha
  String get newAchievement;         // Etiqueta de nuevo logro
  String get goHome;                 // Botón volver al inicio

  // ── Skip reason sheet ────────────────────────────────────────────────────
  String get skipQuestion;   // Pregunta principal del bottom sheet de omisión
  String get skipDontKnow;   // Opción 1: no sé hacerlo
  String get skipCantNow;    // Opción 2: no puedo ahora
  String get skipPain;       // Opción 3: me duele → dispara evaluación clínica

  // ── Routine status ───────────────────────────────────────────────────────
  String get statusCompleted;  // Badge "COMPLETADO" / verde
  String get statusToday;      // Badge "HOY" / azul
  String get statusUpcoming;   // Badge "PRÓXIMO" / gris

  // ── Weekly progress card ─────────────────────────────────────────────────
  String get weeklyProgress;                          // Etiqueta cabecera
  String get progressStart;                           // Mensaje si no hay sesiones completadas
  String get progressDone;                            // Mensaje si todas completadas
  String get progressOnTrack;                         // Mensaje si hay progreso parcial
  String progressSessions(int completed, int total);  // "X de Y sesiones completadas"

  // ── Today's session ──────────────────────────────────────────────────────
  String get todaySession;      // Etiqueta en tarjeta de sesión del día
  String get sessionCompleted;  // Etiqueta si la sesión ya se completó
  String get noSessionToday;    // Texto cuando no hay sesión programada hoy

  // ── Workout preparation ───────────────────────────────────────────────────
  String get prepAppBar;   // Título AppBar pantalla de preparación
  String get prepExit;     // Tooltip del botón de cerrar (X)
  String get prepGetReady; // Texto dentro del anillo de cuenta atrás
  String get prepSkip;     // Enlace para omitir la preparación

  // ── Register ──────────────────────────────────────────────────────────────
  String get registerTitle;        // Título AppBar de la pantalla de registro
  String get registerPlaceholder;  // Placeholder — pantalla pendiente de implementar

  // ── Settings dev ──────────────────────────────────────────────────────────
  String get settingsDevTestTitle;  // Título del ítem de prueba de desarrollador
  String get settingsDevTestSub;    // Subtítulo del ítem de prueba

  // ── Video area ────────────────────────────────────────────────────────────
  String get videoComingSoon;  // Texto cuando no hay URL de vídeo disponible

  // ── Error widget ──────────────────────────────────────────────────────────
  String get errorRetry;  // Texto del botón "Reintentar"

  // ── Workout controls ─────────────────────────────────────────────────────
  String get controlsSkipExercise;  // Tooltip botón omitir ejercicio
  String get controlsNextExercise;  // Tooltip botón siguiente ejercicio (modo timeless)
  String get controlsResume;        // Tooltip botón reanudar
  String get controlsPause;         // Tooltip botón pausar

  // ── Exercise ─────────────────────────────────────────────────────────────
  String exerciseSubtitleSeries(int series, int reps);  // "X SERIES x Y REPS"
  String exerciseSubtitleMinutes(int minutes);          // "X MINUTOS"
  String get exerciseCurrentLabel;   // "EJERCICIO ACTUAL"
  String get exerciseVideoHd;        // Tag "VIDEO HD"
  String get exerciseFrontal;        // Tag de ángulo por defecto "FRONTAL"
  String get exerciseDetails;        // Tag interactivo "DETALLES"
  String get exerciseNoLimit;        // Texto dentro del anillo cuando no hay temporizador ("∞")
  String get exerciseRhythmLabel;    // Etiqueta tarjeta "RITMO"
  String get exerciseProgressLabel;  // Etiqueta tarjeta "PROGRESO"

  // ── Routine detail ───────────────────────────────────────────────────────
  String get routineDetailTitle;     // Título del header de la pantalla de detalle
  String get routineActiveProtocol;  // Supertítulo tipo "PROTOCOLO_ACTIVO"
  String get routineSysLog;          // Etiqueta verde "SYS_LOG: OBJETIVO_MISIÓN"
  String get routineExerciseList;    // Cabecera de la lista de ejercicios
  String routineItems(int count);    // "// 04 ELEMENTOS" — formato HUD
  String get loadingSession;         // Mensaje de carga de sesión
  String get errorLoadingSession;    // Mensaje de error al cargar sesión
  String get startSession;           // Botón "INICIAR"

  // ── User / Profile ────────────────────────────────────────────────────────
  String get userAssignedRoutine;  // Etiqueta sección rutina asignada
  String get userPhysiotherapist;  // Etiqueta sección fisioterapeuta
  String get userNotSpecified;     // Valor cuando un campo es null
  String get userAge;              // Etiqueta campo edad
  String get userYears;            // Unidad "años" / "years"
  String get userWeight;           // Etiqueta campo peso
  String get userHeight;           // Etiqueta campo altura

  // ── Workout rest ─────────────────────────────────────────────────────────
  String get restAppBar;         // Título AppBar pantalla de descanso
  String get restSessionLabel;   // Supertítulo "SESIÓN RETRAINEX"
  String get restTitle;          // Título principal "TIEMPO DE\nDESCANSO"
  String get restSeconds;        // Unidad dentro del anillo "SEGUNDOS"
  String get restAddTime;        // Botón "+20 segundos"
  String get restSkip;           // Enlace omitir descanso
  String get restStopSession;    // Botón detener sesión
  String get restNextExercise;   // Etiqueta tarjeta siguiente ejercicio

  // ── Session paused (exercise detail) ─────────────────────────────────────
  String get sessionPausedTitle;            // Título AppBar "DETALLE DEL EJERCICIO"
  String get sessionPausedBack;             // Botón volver al ejercicio activo
  String get sessionPausedStart;            // Botón iniciar ejercicio (desde lista)
  String sessionPausedRhythm(String rhythm); // "RITMO LENTO" — con el valor del fisio
  String get sessionPausedSeries;           // Etiqueta stat "SERIES"
  String get sessionPausedReps;             // Etiqueta stat "REPS"
  String get sessionPausedDescription;      // Cabecera tarjeta descripción
  String get sessionPausedDescriptionText;  // Texto fijo de descripción genérica
  String get sessionPausedTips;             // Cabecera tarjeta consejos
  String get sessionPausedTipsText;         // Texto fijo de consejos

  // ── Login ─────────────────────────────────────────────────────────────────
  String get loginTitle;            // Título AppBar login
  String get loginSubtitle;         // Subtítulo debajo del logo
  String get loginEmailHint;        // Placeholder del campo email
  String get loginEmailRequired;    // Validación: campo vacío
  String get loginEmailInvalid;     // Validación: formato incorrecto
  String get loginPasswordLabel;    // Etiqueta campo contraseña
  String get loginPasswordRequired; // Validación: campo vacío
  String get loginPasswordTooShort; // Validación: menos de 6 caracteres
  String get loginButton;           // Texto del botón de envío
  String get loginNoAccount;        // Enlace a registro
  String get loginSuccess;          // Snackbar de éxito (simulado)

  // ── Time ago ─────────────────────────────────────────────────────────────
  // Utilizados en NotificationModel.timeAgoText
  String timeAgoMinutes(int minutes); // "Hace X minutos" / "X minutes ago"
  String timeAgoHours(int hours);     // "Hace X horas"   / "X hours ago"
  String timeAgoDays(int days);       // "Hace X días"    / "X days ago"

  // ── Routines list ─────────────────────────────────────────────────────────
  String get routineListLoading;  // Mensaje de carga en la lista semanal
  String get routineListError;    // Error al cargar la lista semanal

  // ── Clinical evaluation ───────────────────────────────────────────────────
  // Pantalla de evaluación de dolor (cuando el paciente omite por dolor)
  String get clinicalEvalTitle;           // Título AppBar "EVALUACIÓN CLÍNICA"
  String get clinicalPainReported;        // Badge rojo "DOLOR REPORTADO"
  String get clinicalPhysioWillReceive;   // Subtítulo informativo
  String get clinicalHowDoYouFeel;        // Sección 1: escala de dolor
  String get clinicalPainScaleHint;       // Hint escala "0 = sin dolor · 10 = máximo"
  String get clinicalHowIsThePain;        // Sección 2: tipo de dolor
  String get clinicalWhenDidItStart;      // Sección 3: frecuencia
  String get clinicalSendToPhysio;        // Botón enviar
  String get clinicalCancel;              // Botón cancelar
  List<String> get clinicalPainTypes;     // ["Punzante","Sordo","Opresivo","Eléctrico"]
  List<String> get clinicalTimingLabels;  // ["Antes","Al empezar","Durante","Al terminar"]
  String get clinicalPreciseIntensity;    // Etiqueta del slider continuo
  List<String> get clinicalFrequencyOptions; // ["Ocasional","Intermitente","Constante"]
  String get clinicalHowAffectsSleep;     // Sección 4: impacto en el sueño
  String get clinicalSleepHint;           // Hint escala sueño
  String get clinicalAdditionalNotes;     // Sección 5: notas libres
  String get clinicalNotesHint;           // Placeholder del campo de texto libre
}
