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

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @charts.
  ///
  /// In en, this message translates to:
  /// **'Charts'**
  String get charts;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @addExpense.
  ///
  /// In en, this message translates to:
  /// **'New Expense'**
  String get addExpense;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount (₺)'**
  String get amount;

  /// No description provided for @amountRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter an amount'**
  String get amountRequired;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @noCategories.
  ///
  /// In en, this message translates to:
  /// **'No categories found. Please add a category first.'**
  String get noCategories;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get note;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get deleted;

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

  /// No description provided for @newCategory.
  ///
  /// In en, this message translates to:
  /// **'Add New Category'**
  String get newCategory;

  /// No description provided for @categoryName.
  ///
  /// In en, this message translates to:
  /// **'Category Name'**
  String get categoryName;

  /// No description provided for @addCategory.
  ///
  /// In en, this message translates to:
  /// **'Add Category'**
  String get addCategory;

  /// No description provided for @categoryDeleted.
  ///
  /// In en, this message translates to:
  /// **'Category deleted'**
  String get categoryDeleted;

  /// No description provided for @weekSpend.
  ///
  /// In en, this message translates to:
  /// **'Weekly Spending'**
  String get weekSpend;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No expense data available'**
  String get noData;

  /// No description provided for @noDataPeriod.
  ///
  /// In en, this message translates to:
  /// **'No expenses found for this period'**
  String get noDataPeriod;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// No description provided for @last7Days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 Days'**
  String get last7Days;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// No description provided for @prevMonth.
  ///
  /// In en, this message translates to:
  /// **'Previous Month'**
  String get prevMonth;

  /// No description provided for @resetAll.
  ///
  /// In en, this message translates to:
  /// **'Reset All Data'**
  String get resetAll;

  /// No description provided for @resetConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Delete all data?'**
  String get resetConfirmation;

  /// No description provided for @food.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get food;

  /// No description provided for @transport.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get transport;

  /// No description provided for @bill.
  ///
  /// In en, this message translates to:
  /// **'Bill'**
  String get bill;

  /// No description provided for @market.
  ///
  /// In en, this message translates to:
  /// **'Groceries'**
  String get market;

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
