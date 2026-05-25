import 'app_strings.dart'; // Importa el contrato abstracto que esta clase debe cumplir

/// Implementación inglesa de todos los textos de la app.
/// Estructura idéntica a AppStringsEs — mismas secciones, distinto idioma.
/// Ver AppStringsEs para comentarios sobre el propósito de cada clave.
class AppStringsEn implements AppStrings {
  const AppStringsEn();

  // ── Nav ───────────────────────────────────────────────────────────────────
  @override
  String get navHome => 'HOME';
  @override
  String get navRoutines => 'MY ROUTINES';
  @override
  String get navProgress => 'MY PROGRESS';
  @override
  String get navSettings => 'SETTINGS';

  // ── General ───────────────────────────────────────────────────────────────
  @override
  String get appName => 'RETRAINEX';
  @override
  String get loading => 'Loading...';
  @override
  String get errorLoadingInfo => 'Could not load information';
  @override
  String get errorLoadingNotifications => 'Could not load notifications';

  // ── Dashboard ─────────────────────────────────────────────────────────────
  @override
  String greeting(String name) => 'Hello, $name!';
  @override
  String get treatmentCompleted => 'TREATMENT COMPLETED';
  @override
  String get nextSession => 'NEXT SESSION';
  @override
  String get date => 'DATE';
  @override
  String get hour => 'TIME';
  @override
  String get viewDetails => 'VIEW DETAILS';
  @override
  String get reminder => 'REMINDER';
  @override
  String get seniorPhysiotherapist => 'SENIOR PHYSIOTHERAPIST';
  @override
  String get newAssignment => 'NEW ASSIGNMENT';
  @override
  String get physiotherapyStartsToday => 'YOUR PHYSIOTHERAPY STARTS TODAY';
  @override
  String get currentAssignment => 'CURRENT ASSIGNMENT';
  @override
  String get aboutToBegin => 'YOU ARE ABOUT TO START THIS JOURNEY';
  @override
  String get noNotificationsYet =>
      'YOU HAVE NOT RECEIVED ANY NOTIFICATIONS YET';

  // ── Notifications ─────────────────────────────────────────────────────────
  @override
  String get notifications => 'Notifications';
  @override
  String get noNotifications => 'You have no notifications';
  @override
  String newNotifications(int count) => 'NEW ($count)';
  @override
  String get previousNotifications => 'PREVIOUS';
  @override
  String get open => 'Open →';

  // ── Schedule ──────────────────────────────────────────────────────────────
  @override
  String get planYourSuccess => 'Plan your success';
  @override
  String get configureRoutine => 'Set up your routine for today';
  @override
  String get selectDays => 'SELECT DAYS';
  @override
  String get activityTime => 'ACTIVITY TIME';
  @override
  String get start => 'START';
  @override
  String get monday => 'MON';
  @override
  String get tuesday => 'TUE';
  @override
  String get wednesday => 'WED';
  @override
  String get thursday => 'THU';
  @override
  String get friday => 'FRI';
  @override
  String get saturday => 'SAT';
  @override
  String get sunday => 'SUN';

  // ── Progress / Calendar ───────────────────────────────────────────────────
  @override
  String get noSessionsScheduled => 'No sessions scheduled';
  @override
  List<String> get monthNames => [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December',
      ];
  @override
  List<String> get weekDayShort => ['M', 'T', 'W', 'T', 'F', 'S', 'S']; // Iniciales en inglés
  @override
  List<String> get weekDayMedium =>
      ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

  // ── Form ──────────────────────────────────────────────────────────────────
  @override
  String get formPlanTitle => 'Plan your success';
  @override
  String get formPlanSubtitle => 'Set up your routine';
  @override
  String get formSelectDays => 'Select the days';
  @override
  String get formActivityTime => 'Activity time';
  @override
  String get formStart => 'START';

  // ── Settings ──────────────────────────────────────────────────────────────
  @override
  String get settingsNotifications => 'Notifications';
  @override
  String get settingsProfile => 'Profile';
  @override
  String get settingsSchedule => 'Schedule';
  @override
  String get settingsFaq => 'FAQ';
  @override
  String get settingsPersonalData => 'Personal data';
  @override
  String get settingsPersonalDataSub => 'Name, age, weight';
  @override
  String get settingsAccessibility => 'Accessibility';
  @override
  String get settingsAccessibilitySub => 'Text size, contrast';
  @override
  String get settingsLanguage => 'Language';
  @override
  String get settingsLanguageValue => 'English'; // Valor actual cuando el idioma es inglés
  @override
  String get settingsVersion => 'Version 1.0.0';
  @override
  String get settingsCopyright => '© 2026 ReTrainex. All rights reserved.';
  @override
  String get remindersEnabled => 'Reminders enabled!';
  @override
  String get reminders => 'Reminders';
  @override
  String get remindersSubtitle => 'Receive alerts for your exercises';
  @override
  String get faqTitle => 'FREQUENTLY ASKED QUESTIONS';
  @override
  String get faq1Question => 'Can I skip exercises?';
  @override
  String get faq1Answer =>
      'Yes, you can skip any exercise. However, we recommend talking to your physiotherapist before doing so frequently.';
  @override
  String get faq2Question => 'What if it hurts?';
  @override
  String get faq2Answer =>
      'Stop the exercise immediately and contact your physiotherapist. Never force a movement that causes sharp pain.';
  @override
  String get faq3Question => 'How often should I do the sessions?';
  @override
  String get faq3Answer =>
      'Your physiotherapist has designed a specific plan for you. Follow the assigned days for best results.';
  @override
  String get faq4Question => 'How do I change my reminder schedule?';
  @override
  String get faq4Answer =>
      'Go to Settings → Notifications → Schedule and select your preferred time.';

  // ── Skip reason sheet ────────────────────────────────────────────────────
  @override
  String get skipQuestion => 'WHY ARE YOU SKIPPING THIS EXERCISE?';
  @override
  String get skipDontKnow => 'I don\'t know how to do it'; // Escape de comilla simple con \'
  @override
  String get skipCantNow => 'I can\'t do it right now';
  @override
  String get skipPain => 'It hurts';

  // ── Routine status ───────────────────────────────────────────────────────
  @override
  String get statusCompleted => 'COMPLETED';
  @override
  String get statusToday => 'TODAY';
  @override
  String get statusUpcoming => 'UPCOMING';

  // ── Weekly progress card ─────────────────────────────────────────────────
  @override
  String get weeklyProgress => 'WEEKLY PROGRESS';
  @override
  String get progressStart => 'START TODAY';
  @override
  String get progressDone => 'YOU DID IT!';
  @override
  String get progressOnTrack => 'YOU\'RE ON TRACK';
  @override
  String progressSessions(int completed, int total) =>
      '$completed of $total sessions completed';

  // ── Today's session ──────────────────────────────────────────────────────
  @override
  String get todaySession => 'TODAY\'S SESSION';
  @override
  String get sessionCompleted => 'SESSION COMPLETED';
  @override
  String get noSessionToday => 'No session scheduled today';

  // ── Exercise subtitles ────────────────────────────────────────────────────
  @override
  String exerciseSubtitleSeries(int series, int reps) =>
      '$series SETS  x  $reps REPS'; // "SETS" en inglés en lugar de "SERIES"
  @override
  String exerciseSubtitleMinutes(int minutes) => '$minutes MINUTES';

  // ── Workout preparation ───────────────────────────────────────────────────
  @override
  String get prepAppBar => 'WORKOUT IN PROGRESS';
  @override
  String get prepExit => 'Exit';
  @override
  String get prepGetReady => 'GET READY';
  @override
  String get prepSkip => 'Skip preparation';

  // ── Register ──────────────────────────────────────────────────────────────
  @override
  String get registerTitle => 'Register';
  @override
  String get registerPlaceholder => 'Registration screen';

  // ── Settings dev ──────────────────────────────────────────────────────────
  @override
  String get settingsDevTestTitle => 'Form test';
  @override
  String get settingsDevTestSub => 'Day selector test';

  // ── Video area ────────────────────────────────────────────────────────────
  @override
  String get videoComingSoon => 'VIDEO COMING SOON';

  // ── Error widget ──────────────────────────────────────────────────────────
  @override
  String get errorRetry => 'Retry';

  // ── Workout controls ─────────────────────────────────────────────────────
  @override
  String get controlsSkipExercise => 'SKIP EXERCISE';
  @override
  String get controlsNextExercise => 'Next exercise';
  @override
  String get controlsResume => 'Resume';
  @override
  String get controlsPause => 'Pause';

  // ── Exercise screen labels ────────────────────────────────────────────────
  @override
  String get exerciseCurrentLabel => 'CURRENT EXERCISE';
  @override
  String get exerciseVideoHd => 'HD VIDEO';
  @override
  String get exerciseFrontal => 'FRONT';
  @override
  String get exerciseDetails => 'DETAILS';
  @override
  String get exerciseNoLimit => 'NO LIMIT';
  @override
  String get exerciseRhythmLabel => 'RHYTHM';
  @override
  String get exerciseProgressLabel => 'PROGRESS';

  // ── Routine detail ───────────────────────────────────────────────────────
  @override
  String get routineDetailTitle => 'SESSION DETAILS';
  @override
  String get routineActiveProtocol => 'ACTIVE_PROTOCOL';
  @override
  String get routineSysLog => 'SYS_LOG: MISSION_OBJECTIVE';
  @override
  String get routineExerciseList => 'EXE_LIST';
  @override
  String routineItems(int count) => '// ${count.toString().padLeft(2, '0')} ITEMS';
  @override
  String get loadingSession => 'Loading session...';
  @override
  String get errorLoadingSession => 'Could not load session details';
  @override
  String get startSession => 'START';

  // ── Clinical evaluation ───────────────────────────────────────────────────
  @override
  String get clinicalEvalTitle => 'CLINICAL EVALUATION';
  @override
  String get clinicalPainReported => 'PAIN REPORTED';
  @override
  String get clinicalPhysioWillReceive =>
      'Your physiotherapist will receive this information.';
  @override
  String get clinicalHowDoYouFeel => 'HOW ARE YOU FEELING TODAY?';
  @override
  String get clinicalPainScaleHint => '0 = no pain  ·  10 = maximum pain';
  @override
  String get clinicalHowIsThePain => 'PAIN TYPE';
  @override
  String get clinicalWhenDidItStart => 'HOW OFTEN DOES IT APPEAR?';
  @override
  String get clinicalSendToPhysio => 'SEND';
  @override
  String get clinicalCancel => 'CANCEL';
  @override
  List<String> get clinicalPainTypes =>
      ['Stabbing', 'Dull', 'Oppressive', 'Electric'];
  @override
  List<String> get clinicalTimingLabels =>
      ['Before the exercise', 'At the start', 'During', 'After finishing'];
  @override
  String get clinicalPreciseIntensity => 'Precise intensity';
  @override
  List<String> get clinicalFrequencyOptions =>
      ['Occasional', 'Intermittent', 'Constant'];
  @override
  String get clinicalHowAffectsSleep => 'HOW DOES IT AFFECT YOUR SLEEP?';
  @override
  String get clinicalSleepHint => '0 = little  ·  10 = a lot';
  @override
  String get clinicalAdditionalNotes => 'Additional notes (optional)';
  @override
  String get clinicalNotesHint => 'Write any other details here...';

  // ── User / Profile ────────────────────────────────────────────────────────
  @override
  String get userAssignedRoutine => 'Assigned routine';
  @override
  String get userPhysiotherapist => 'Physiotherapist';
  @override
  String get userNotSpecified => 'Not specified';
  @override
  String get userAge => 'Age';
  @override
  String get userYears => 'years';
  @override
  String get userWeight => 'Weight';
  @override
  String get userHeight => 'Height';

  // ── Workout rest ─────────────────────────────────────────────────────────
  @override
  String get restAppBar => 'RECOVERY PHASE';
  @override
  String get restSessionLabel => 'RETRAINEX SESSION';
  @override
  String get restTitle => 'REST\nTIME'; // '\n' fuerza salto de línea en el título
  @override
  String get restSeconds => 'SECONDS';
  @override
  String get restAddTime => '+20 seconds';
  @override
  String get restSkip => 'Skip rest';
  @override
  String get restStopSession => 'Stop session';
  @override
  String get restNextExercise => 'NEXT EXERCISE';

  // ── Session paused ────────────────────────────────────────────────────────
  @override
  String get sessionPausedTitle => 'EXERCISE DETAIL';
  @override
  String get sessionPausedBack => 'BACK TO EXERCISE';
  @override
  String get sessionPausedStart => 'START EXERCISE';
  @override
  String sessionPausedRhythm(String rhythm) => 'RHYTHM ${rhythm.toUpperCase()}';
  @override
  String get sessionPausedSeries => 'SETS'; // "SETS" en inglés en lugar de "SERIES"
  @override
  String get sessionPausedReps => 'REPS';
  @override
  String get sessionPausedDescription => 'DESCRIPTION';
  @override
  String get sessionPausedDescriptionText =>
      'Perform the movement slowly and in a controlled manner. Maintain correct posture throughout the exercise to maximise benefits and prevent injury.';
  @override
  String get sessionPausedTips => 'TIPS';
  @override
  String get sessionPausedTipsText =>
      'If you notice sharp pain, stop immediately. Breathe continuously during the exercise and consult your physiotherapist with any questions.';

  // ── Login ─────────────────────────────────────────────────────────────────
  @override
  String get loginTitle => 'Login';
  @override
  String get loginSubtitle => 'INTELLIGENT REHABILITATION';
  @override
  String get loginEmailHint => 'example@email.com';
  @override
  String get loginEmailRequired => 'Enter your email';
  @override
  String get loginEmailInvalid => 'Invalid email';
  @override
  String get loginPasswordLabel => 'Password';
  @override
  String get loginPasswordRequired => 'Enter your password';
  @override
  String get loginPasswordTooShort => 'Must be at least 6 characters';
  @override
  String get loginButton => 'Sign In';
  @override
  String get loginNoAccount => 'Don\'t have an account? Create one';
  @override
  String get loginSuccess => 'Login successful (simulated for now)';

  // ── Notification mock data ───────────────────────────────────────────────
  @override
  String get notifActionOpen => 'Open';
  @override
  String get notifMsgTitle => 'Message from Dr. Pérez';
  @override
  String get notifMsgBody =>
      'Hi María, I have reviewed your progress and it looks excellent. Keep up the consistency.';
  @override
  String get notifQuestionnaireTitle => 'Pending WOMAC questionnaire';
  @override
  String get notifQuestionnaireBody =>
      'Please complete the weekly assessment questionnaire so your physiotherapist can follow up.';
  @override
  String get notifReminderTitle => 'Session reminder';
  @override
  String get notifReminderBody =>
      'Your session today starts in 30 minutes. Get ready!';
  @override
  String get notifSessionCompleteTitle => 'Session completed';
  @override
  String get notifSessionCompleteBody =>
      'Congratulations! You completed your Monday session. You have a 5-day streak.';

  // ── Workout complete ──────────────────────────────────────────────────────
  @override
  String get sessionCompleteAppBar => 'SESSION COMPLETE';
  @override
  String get excellent => 'EXCELLENT!';
  @override
  String get dayCompleted => 'DAY COMPLETED';
  @override
  String get statDuration => 'DURATION';
  @override
  String get statExercises => 'EXERCISES';
  @override
  String get congratsMessage =>
      'Congratulations! You completed today\'s session. Keep it up to reach your goals.';
  @override
  String streakDays(int days) => '$days-DAY STREAK'; // "5-DAY STREAK" — orden distinto al español
  @override
  String get onFire => 'You\'re on fire! Don\'t stop.';
  @override
  String get newAchievement => 'NEW ACHIEVEMENT';
  @override
  String get goHome => 'GO HOME';

  // ── Time ago ─────────────────────────────────────────────────────────────
  @override
  String timeAgoMinutes(int minutes) => '$minutes minutes ago'; // Ej: "12 minutes ago"
  @override
  String timeAgoHours(int hours) => '$hours hours ago';
  @override
  String timeAgoDays(int days) => '$days days ago';

  // ── Routines list ─────────────────────────────────────────────────────────
  @override
  String get routineListLoading => 'Loading routines...';
  @override
  String get routineListError => 'Could not load routines';
}
