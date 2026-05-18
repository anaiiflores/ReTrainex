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
}
