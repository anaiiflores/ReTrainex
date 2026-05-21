import 'app_strings.dart';

class AppStringsEn implements AppStrings {
  const AppStringsEn();

  @override
  String get navHome => 'HOME';
  @override
  String get navRoutines => 'MY ROUTINES';
  @override
  String get navProgress => 'MY PROGRESS';
  @override
  String get navSettings => 'SETTINGS';

  @override
  String get appName => 'RETRAINEX';
  @override
  String get loading => 'Loading...';
  @override
  String get errorLoadingInfo => 'Could not load information';
  @override
  String get errorLoadingNotifications => 'Could not load notifications';

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

  @override
  String get noSessionsScheduled => 'No sessions scheduled';
  @override
  List<String> get monthNames => [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
      ];
  @override
  List<String> get weekDayShort => ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  @override
  List<String> get weekDayMedium =>
      ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

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
  String get settingsLanguageValue => 'English';
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

  @override
  String exerciseSubtitleSeries(int series, int reps) =>
      '$series SETS  x  $reps REPS';
  @override
  String exerciseSubtitleMinutes(int minutes) => '$minutes MINUTES';

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
}
