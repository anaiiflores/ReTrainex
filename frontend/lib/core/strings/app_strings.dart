abstract class AppStrings {
  // ── Nav ───────────────────────────────────────────────────────────────────
  String get navHome;
  String get navRoutines;
  String get navProgress;
  String get navSettings;

  // ── General ───────────────────────────────────────────────────────────────
  String get appName;
  String get loading;
  String get errorLoadingInfo;
  String get errorLoadingNotifications;

  // ── Dashboard ─────────────────────────────────────────────────────────────
  String greeting(String name);
  String get treatmentCompleted;
  String get nextSession;
  String get date;
  String get hour;
  String get viewDetails;
  String get reminder;
  String get seniorPhysiotherapist;
  String get newAssignment;
  String get physiotherapyStartsToday;
  String get currentAssignment;
  String get aboutToBegin;
  String get noNotificationsYet;

  // ── Notifications ─────────────────────────────────────────────────────────
  String get notifications;
  String get noNotifications;
  String newNotifications(int count);
  String get previousNotifications;
  String get open;

  // ── Schedule ──────────────────────────────────────────────────────────────
  String get planYourSuccess;
  String get configureRoutine;
  String get selectDays;
  String get activityTime;
  String get start;
  String get monday;
  String get tuesday;
  String get wednesday;
  String get thursday;
  String get friday;
  String get saturday;
  String get sunday;

  // ── Progress / Calendar ───────────────────────────────────────────────────
  String get noSessionsScheduled;
  List<String> get monthNames;
  List<String> get weekDayShort;
  List<String> get weekDayMedium;

  // ── Form ──────────────────────────────────────────────────────────────────
  String get formPlanTitle;
  String get formPlanSubtitle;
  String get formSelectDays;
  String get formActivityTime;
  String get formStart;

  // ── Settings ──────────────────────────────────────────────────────────────
  String get settingsNotifications;
  String get settingsProfile;
  String get settingsSchedule;
  String get settingsFaq;
  String get settingsPersonalData;
  String get settingsPersonalDataSub;
  String get settingsAccessibility;
  String get settingsAccessibilitySub;
  String get settingsLanguage;
  String get settingsLanguageValue;
  String get settingsVersion;
  String get settingsCopyright;
  String get remindersEnabled;
  String get reminders;
  String get remindersSubtitle;
  String get faqTitle;
  String get faq1Question;
  String get faq1Answer;
  String get faq2Question;
  String get faq2Answer;
  String get faq3Question;
  String get faq3Answer;
  String get faq4Question;
  String get faq4Answer;

  // ── Notification mock data ───────────────────────────────────────────────
  String get notifActionOpen;
  String get notifMsgTitle;
  String get notifMsgBody;
  String get notifQuestionnaireTitle;
  String get notifQuestionnaireBody;
  String get notifReminderTitle;
  String get notifReminderBody;
  String get notifSessionCompleteTitle;
  String get notifSessionCompleteBody;

  // ── Workout complete ──────────────────────────────────────────────────────
  String get sessionCompleteAppBar;
  String get excellent;
  String get dayCompleted;
  String get statDuration;
  String get statExercises;
  String get congratsMessage;
  String streakDays(int days);
  String get onFire;
  String get newAchievement;
  String get goHome;

  // ── Skip reason sheet ────────────────────────────────────────────────────
  String get skipQuestion;
  String get skipDontKnow;
  String get skipCantNow;
  String get skipPain;

  // ── Routine status ───────────────────────────────────────────────────────
  String get statusCompleted;
  String get statusToday;
  String get statusUpcoming;

  // ── Weekly progress card ─────────────────────────────────────────────────
  String get weeklyProgress;
  String get progressStart;
  String get progressDone;
  String get progressOnTrack;
  String progressSessions(int completed, int total);

  // ── Today's session ──────────────────────────────────────────────────────
  String get todaySession;
  String get sessionCompleted;
  String get noSessionToday;

  // ── Workout preparation ───────────────────────────────────────────────────
  String get prepAppBar;
  String get prepExit;
  String get prepGetReady;
  String get prepSkip;

  // ── Register ──────────────────────────────────────────────────────────────
  String get registerTitle;
  String get registerPlaceholder;

  // ── Settings dev ──────────────────────────────────────────────────────────
  String get settingsDevTestTitle;
  String get settingsDevTestSub;

  // ── Video area ────────────────────────────────────────────────────────────
  String get videoComingSoon;

  // ── Error widget ──────────────────────────────────────────────────────────
  String get errorRetry;

  // ── Workout controls ─────────────────────────────────────────────────────
  String get controlsSkipExercise;
  String get controlsNextExercise;
  String get controlsResume;
  String get controlsPause;

  // ── Exercise ─────────────────────────────────────────────────────────────
  String exerciseSubtitleSeries(int series, int reps);
  String exerciseSubtitleMinutes(int minutes);
  String get exerciseCurrentLabel;
  String get exerciseVideoHd;
  String get exerciseFrontal;
  String get exerciseDetails;
  String get exerciseNoLimit;
  String get exerciseRhythmLabel;
  String get exerciseProgressLabel;

  // ── Routine detail ───────────────────────────────────────────────────────
  String get routineDetailTitle;
  String get routineActiveProtocol;
  String get routineSysLog;
  String get routineExerciseList;
  String routineItems(int count);
  String get loadingSession;
  String get errorLoadingSession;
  String get startSession;

  // ── User / Profile ────────────────────────────────────────────────────────
  String get userAssignedRoutine;
  String get userPhysiotherapist;
  String get userNotSpecified;
  String get userAge;
  String get userYears;
  String get userWeight;
  String get userHeight;

  // ── Workout rest ─────────────────────────────────────────────────────────
  String get restAppBar;
  String get restSessionLabel;
  String get restTitle;
  String get restSeconds;
  String get restAddTime;
  String get restSkip;
  String get restStopSession;
  String get restNextExercise;

  // ── Session paused (exercise detail) ─────────────────────────────────────
  String get sessionPausedTitle;
  String get sessionPausedBack;
  String get sessionPausedStart;
  String sessionPausedRhythm(String rhythm);
  String get sessionPausedSeries;
  String get sessionPausedReps;
  String get sessionPausedDescription;
  String get sessionPausedDescriptionText;
  String get sessionPausedTips;
  String get sessionPausedTipsText;

  // ── Login ─────────────────────────────────────────────────────────────────
  String get loginTitle;
  String get loginSubtitle;
  String get loginEmailHint;
  String get loginEmailRequired;
  String get loginEmailInvalid;
  String get loginPasswordLabel;
  String get loginPasswordRequired;
  String get loginPasswordTooShort;
  String get loginButton;
  String get loginNoAccount;
  String get loginSuccess;

  // ── Time ago ─────────────────────────────────────────────────────────────
  String timeAgoMinutes(int minutes);
  String timeAgoHours(int hours);
  String timeAgoDays(int days);

  // ── Routines list ─────────────────────────────────────────────────────────
  String get routineListLoading;
  String get routineListError;

  // ── Clinical evaluation ───────────────────────────────────────────────────
  String get clinicalEvalTitle;
  String get clinicalPainReported;
  String get clinicalPhysioWillReceive;
  String get clinicalHowDoYouFeel;
  String get clinicalPainScaleHint;
  String get clinicalHowIsThePain;
  String get clinicalWhenDidItStart;
  String get clinicalSendToPhysio;
  String get clinicalCancel;
  List<String> get clinicalPainTypes;
  List<String> get clinicalTimingLabels;
  String get clinicalPreciseIntensity;
  List<String> get clinicalFrequencyOptions;
  String get clinicalHowAffectsSleep;
  String get clinicalSleepHint;
  String get clinicalAdditionalNotes;
  String get clinicalNotesHint;
}
