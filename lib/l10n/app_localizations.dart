import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Expense Tracker'**
  String get appName;

  /// No description provided for @drawerTitle.
  ///
  /// In en, this message translates to:
  /// **'💰 Expense Tracker'**
  String get drawerTitle;

  /// No description provided for @drawerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your personal finance easily'**
  String get drawerSubtitle;

  /// No description provided for @drawerHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get drawerHome;

  /// No description provided for @drawerCharts.
  ///
  /// In en, this message translates to:
  /// **'Charts'**
  String get drawerCharts;

  /// No description provided for @drawerCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get drawerCategories;

  /// No description provided for @drawerSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get drawerSettings;

  /// No description provided for @emptyExpenses.
  ///
  /// In en, this message translates to:
  /// **'No expenses added yet'**
  String get emptyExpenses;

  /// No description provided for @emptyExpensesHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the + button below to add your first expense'**
  String get emptyExpensesHint;

  /// No description provided for @homeAddExpense.
  ///
  /// In en, this message translates to:
  /// **'Add Expense'**
  String get homeAddExpense;

  /// No description provided for @sortDateDesc.
  ///
  /// In en, this message translates to:
  /// **'Date (Newer > Older)'**
  String get sortDateDesc;

  /// No description provided for @sortDateAsc.
  ///
  /// In en, this message translates to:
  /// **'Date (Older > Newer)'**
  String get sortDateAsc;

  /// No description provided for @sortAmountDesc.
  ///
  /// In en, this message translates to:
  /// **'Amount (High > Low)'**
  String get sortAmountDesc;

  /// No description provided for @sortAmountAsc.
  ///
  /// In en, this message translates to:
  /// **'Amount (Low > High)'**
  String get sortAmountAsc;

  /// No description provided for @addExpenseTitle.
  ///
  /// In en, this message translates to:
  /// **'New Expense'**
  String get addExpenseTitle;

  /// No description provided for @amountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amountLabel;

  /// No description provided for @amountRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter an amount'**
  String get amountRequired;

  /// No description provided for @noCategories.
  ///
  /// In en, this message translates to:
  /// **'No categories found. Please add a category first.'**
  String get noCategories;

  /// No description provided for @categoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryLabel;

  /// No description provided for @noteLabel.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get noteLabel;

  /// No description provided for @notePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'e.g. Lunch'**
  String get notePlaceholder;

  /// No description provided for @buttonAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get buttonAdd;

  /// No description provided for @buttonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get buttonCancel;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @chartNoData.
  ///
  /// In en, this message translates to:
  /// **'No data available for this currency'**
  String get chartNoData;

  /// No description provided for @chartTitle.
  ///
  /// In en, this message translates to:
  /// **'Charts'**
  String get chartTitle;

  /// No description provided for @filterLast7Days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 Days'**
  String get filterLast7Days;

  /// No description provided for @filterThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get filterThisWeek;

  /// No description provided for @filterThisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get filterThisMonth;

  /// No description provided for @filterPrevMonth.
  ///
  /// In en, this message translates to:
  /// **'Previous Month'**
  String get filterPrevMonth;

  /// No description provided for @categoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categoryTitle;

  /// No description provided for @categoryAddButton.
  ///
  /// In en, this message translates to:
  /// **'Add Category'**
  String get categoryAddButton;

  /// No description provided for @categoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No categories yet'**
  String get categoryEmpty;

  /// No description provided for @expenseAdded.
  ///
  /// In en, this message translates to:
  /// **'Added'**
  String get expenseAdded;

  /// No description provided for @chartNoDataForPeriod.
  ///
  /// In en, this message translates to:
  /// **'No expenses for this period'**
  String get chartNoDataForPeriod;

  /// No description provided for @categoryAddDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Add New Category'**
  String get categoryAddDialogTitle;

  /// No description provided for @categoryNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Category Name'**
  String get categoryNameLabel;

  /// No description provided for @totalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get totalLabel;

  /// No description provided for @settingsClearDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete All Data'**
  String get settingsClearDataTitle;

  /// No description provided for @settingsClearDataMessage.
  ///
  /// In en, this message translates to:
  /// **'All expenses will be permanently deleted. Are you sure?'**
  String get settingsClearDataMessage;

  /// No description provided for @settingsConfirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Yes, delete'**
  String get settingsConfirmDelete;

  /// No description provided for @settingsDataCleared.
  ///
  /// In en, this message translates to:
  /// **'All data has been deleted'**
  String get settingsDataCleared;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsThemeTitle.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsThemeTitle;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsThemeSystem;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsClearDataListTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete all data'**
  String get settingsClearDataListTitle;

  /// No description provided for @settingsClearDataListSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Permanently deletes all expenses'**
  String get settingsClearDataListSubtitle;

  /// No description provided for @sortTooltip.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sortTooltip;

  /// No description provided for @categoryDeleted.
  ///
  /// In en, this message translates to:
  /// **'Category deleted'**
  String get categoryDeleted;

  /// No description provided for @categoryEditDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Category'**
  String get categoryEditDialogTitle;

  /// No description provided for @buttonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get buttonSave;

  /// No description provided for @settingsCurrencyTitle.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get settingsCurrencyTitle;

  /// No description provided for @categorySelectIcon.
  ///
  /// In en, this message translates to:
  /// **'Select Icon'**
  String get categorySelectIcon;

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Expense Tracker'**
  String get appTitle;

  /// No description provided for @drawerReport.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get drawerReport;

  /// No description provided for @reportTitle.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get reportTitle;

  /// No description provided for @selectDateRange.
  ///
  /// In en, this message translates to:
  /// **'Select Date Range'**
  String get selectDateRange;

  /// No description provided for @selectDateRangeHint.
  ///
  /// In en, this message translates to:
  /// **'Please select a date range'**
  String get selectDateRangeHint;

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @amountCannotBeZero.
  ///
  /// In en, this message translates to:
  /// **'Amount cannot be zero'**
  String get amountCannotBeZero;

  /// No description provided for @categoryRequired.
  ///
  /// In en, this message translates to:
  /// **'You must select a category.'**
  String get categoryRequired;

  /// No description provided for @selectCategoryPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Select category'**
  String get selectCategoryPlaceholder;

  /// No description provided for @categoryNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Category name cannot be empty'**
  String get categoryNameRequired;

  /// No description provided for @editExpenseTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Expense'**
  String get editExpenseTitle;

  /// No description provided for @expenseUpdated.
  ///
  /// In en, this message translates to:
  /// **'Expense updated'**
  String get expenseUpdated;

  /// No description provided for @buttonSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get buttonSaveChanges;

  /// No description provided for @buttonUpdate.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get buttonUpdate;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'tr': return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
