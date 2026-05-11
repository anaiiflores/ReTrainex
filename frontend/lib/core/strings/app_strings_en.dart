import 'app_strings.dart';

class AppStringsEn implements AppStrings {
  const AppStringsEn();

  @override String get navHome => 'HOME';
  @override String get navRoutines => 'MY ROUTINES';
  @override String get navProgress => 'MY PROGRESS';
  @override String get navSettings => 'SETTINGS';

  @override String get appName => 'RETRAINEX';
  @override String get loading => 'Loading...';
  @override String get errorLoadingInfo => 'Could not load information';
  @override String get errorLoadingNotifications => 'Could not load notifications';

  @override String greeting(String name) => 'HELLO, $name!';
  @override String get treatmentCompleted => 'TREATMENT COMPLETED';
  @override String get nextSession => 'NEXT SESSION';
  @override String get date => 'DATE';
  @override String get hour => 'TIME';
  @override String get viewDetails => 'VIEW DETAILS';
  @override String get reminder => 'REMINDER';
  @override String get seniorPhysiotherapist => 'SENIOR PHYSIOTHERAPIST';
  @override String get newAssignment => 'NEW ASSIGNMENT';
  @override String get physiotherapyStartsToday => 'YOUR PHYSIOTHERAPY STARTS TODAY';
  @override String get currentAssignment => 'CURRENT ASSIGNMENT';
  @override String get aboutToBegin => 'YOU ARE ABOUT TO START THIS JOURNEY';
  @override String get noNotificationsYet => 'YOU HAVE NOT RECEIVED ANY NOTIFICATIONS YET';

  @override String get notifications => 'Notifications';
  @override String get noNotifications => 'You have no notifications';
  @override String newNotifications(int count) => 'NEW ($count)';
  @override String get previousNotifications => 'PREVIOUS';
  @override String get open => 'Open →';

  @override String get planYourSuccess => 'Plan your success';
  @override String get configureRoutine => 'Set up your routine for today';
  @override String get selectDays => 'SELECT DAYS';
  @override String get activityTime => 'ACTIVITY TIME';
  @override String get start => 'START';
  @override String get monday => 'MON';
  @override String get tuesday => 'TUE';
  @override String get wednesday => 'WED';
  @override String get thursday => 'THU';
  @override String get friday => 'FRI';
  @override String get saturday => 'SAT';
  @override String get sunday => 'SUN';

  @override String get noSessionsScheduled => 'No sessions scheduled';
  @override List<String> get monthNames => [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];
  @override List<String> get weekDayShort => ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override String get settingsNotifications => 'Notifications';
  @override String get settingsProfile => 'Profile';
  @override String get settingsSchedule => 'Schedule';
  @override String get settingsFaq => 'FAQ';
  @override String get settingsPersonalData => 'Personal data';
  @override String get settingsPersonalDataSub => 'Name, age, weight';
  @override String get settingsAccessibility => 'Accessibility';
  @override String get settingsAccessibilitySub => 'Text size, contrast';
  @override String get settingsLanguage => 'Language';
  @override String get settingsLanguageValue => 'English';
  @override String get settingsVersion => 'Version 1.0.0';
  @override String get settingsCopyright => '© 2026 ReTrainex. All rights reserved.';
  @override String get remindersEnabled => 'Reminders enabled!';
  @override String get reminders => 'Reminders';
  @override String get remindersSubtitle => 'Receive alerts for your exercises';
  @override String get faqTitle => 'FREQUENTLY ASKED QUESTIONS';
  @override String get faq1Question => 'Can I skip exercises?';
  @override String get faq1Answer => 'Yes, you can skip any exercise. However, we recommend talking to your physiotherapist before doing so frequently.';
  @override String get faq2Question => 'What if it hurts?';
  @override String get faq2Answer => 'Stop the exercise immediately and contact your physiotherapist. Never force a movement that causes sharp pain.';
  @override String get faq3Question => 'How often should I do the sessions?';
  @override String get faq3Answer => 'Your physiotherapist has designed a specific plan for you. Follow the assigned days for best results.';
  @override String get faq4Question => 'How do I change my reminder schedule?';
  @override String get faq4Answer => 'Go to Settings → Notifications → Schedule and select your preferred time.';
}
