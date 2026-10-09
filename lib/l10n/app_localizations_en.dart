// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'News App';

  @override
  String get home => 'Home';

  @override
  String get favorites => 'Favorites';

  @override
  String get history => 'Reading History';

  @override
  String get profile => 'Profile';

  @override
  String get settings => 'Settings';

  @override
  String get searchNews => 'Search news...';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get arabic => 'Arabic';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get notifications => 'Notifications';

  @override
  String get readingMode => 'Reading Mode';

  @override
  String get logout => 'Logout';

  @override
  String get cancel => 'Cancel';

  @override
  String get retry => 'Retry';

  @override
  String get noNewsFound => 'No news found.';

  @override
  String get categories => 'Categories';

  @override
  String get general => 'General';

  @override
  String get business => 'Business';

  @override
  String get technology => 'Technology';

  @override
  String get sports => 'Sports';

  @override
  String get health => 'Health';

  @override
  String get science => 'Science';

  @override
  String get entertainment => 'Entertainment';

  @override
  String get clear => 'Clear';

  @override
  String searchResultsFor(String query) {
    return 'Results for \"$query\"';
  }

  @override
  String get unableToLoadNews => 'Unable to load news';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get trySearchingElse => 'Try searching for something else.';

  @override
  String get unexpectedError => 'Something went wrong. Please try again.';

  @override
  String get confirmLogout => 'Are you sure you want to log out?';

  @override
  String get logoutFailed => 'Logout failed. Please try again.';

  @override
  String get login => 'Login';

  @override
  String get welcomeBack => 'Welcome Back!';

  @override
  String get loginSubtitle => 'Login to continue using News App.';

  @override
  String get email => 'Email';

  @override
  String get enterYourEmail => 'Enter your email';

  @override
  String get password => 'Password';

  @override
  String get enterYourPassword => 'Enter your password';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get createAccount => 'Create Account';

  @override
  String get noAccount => 'Don\'t have an account?';

  @override
  String get loginSuccessful => 'Login successful!';

  @override
  String get incorrectCredentials => 'Email or password is incorrect.';

  @override
  String get enterValidEmail => 'Please enter a valid email address.';

  @override
  String get accountDisabled => 'This account has been disabled.';

  @override
  String get checkInternet => 'Check your internet connection.';

  @override
  String get tooManyAttempts => 'Too many attempts. Please try again later.';

  @override
  String get somethingWentWrong => 'Something went wrong. Please try again.';

  @override
  String get enterEmailFirst => 'Enter your email first.';

  @override
  String get passwordResetSent => 'Password reset email sent. Check your inbox.';

  @override
  String get passwordResetFailed => 'Unable to send password reset email.';

  @override
  String get enterEmailError => 'Please enter your email.';

  @override
  String get enterPasswordError => 'Please enter your password.';

  @override
  String get clearHistory => 'Clear History';

  @override
  String get confirmClearHistory => 'Are you sure you want to delete all reading history?';

  @override
  String get historyCleared => 'Reading history cleared';

  @override
  String get unableToLoadHistory => 'Could not load reading history';

  @override
  String get noHistoryYet => 'No reading history yet';

  @override
  String get historyDescription => 'Articles you open will appear here.';

  @override
  String get invalidArticleLink => 'Invalid article link';

  @override
  String get couldNotOpenArticle => 'Could not open this article';

  @override
  String get removeFromHistory => 'Remove from history';

  @override
  String get noFavoritesYet => 'No Favorites Yet';

  @override
  String get favoritesDescription => 'Save the news you like by tapping the heart icon, and you will find them here.';

  @override
  String get tapHeartToSave => 'Tap the heart icon on any news to save it';

  @override
  String get unableToLoadFavorites => 'Unable to Load Favorites';

  @override
  String get favoritesLoadError => 'Something went wrong while loading your saved articles. Please try again.';

  @override
  String get addedToFavorites => 'Added to favorites';

  @override
  String get removedFromFavorites => 'Removed from favorites';

  @override
  String get unknownSource => 'Unknown source';

  @override
  String get imageUnavailable => 'Image unavailable';

  @override
  String get untitled => 'Untitled';

  @override
  String get pleaseLoginToViewProfile => 'Please log in to view your profile';

  @override
  String get myProfile => 'My Profile';

  @override
  String get failedToLoadProfile => 'Failed to load profile data';

  @override
  String get user => 'User';

  @override
  String get accountInformation => 'Account Information';

  @override
  String get fullName => 'Full Name';

  @override
  String get emailAddress => 'Email Address';

  @override
  String get chooseAppLanguage => 'Choose app language';

  @override
  String get darkThemeEnabled => 'Dark theme enabled';

  @override
  String get lightThemeEnabled => 'Light theme enabled';

  @override
  String get createYourAccount => 'Create your account';

  @override
  String get signUpSubtitle => 'Sign up to continue using News App';

  @override
  String get name => 'Name';

  @override
  String get enterYourName => 'Enter your name';

  @override
  String get pleaseEnterName => 'Please enter your name';

  @override
  String get nameMinLength => 'Name must be at least 3 characters';

  @override
  String get pleaseEnterEmail => 'Please enter your email';

  @override
  String get pleaseEnterValidEmail => 'Please enter a valid email address';

  @override
  String get enterPassword => 'Enter your password';

  @override
  String get pleaseEnterPassword => 'Please enter your password';

  @override
  String get passwordMinLength => 'Password must be at least 6 characters';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get confirmYourPassword => 'Confirm your password';

  @override
  String get pleaseConfirmPassword => 'Please confirm your password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get accountCreatedSuccessfully => 'Account created and data saved successfully';

  @override
  String get emailAlreadyRegistered => 'This email is already registered';

  @override
  String get passwordTooWeak => 'Password is too weak';

  @override
  String get accountCreatedButSaveFailed => 'Account created, but saving user data failed';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get noNewsInfoToShare => 'No news information available to share';

  @override
  String get sharingFailed => 'Sharing failed';

  @override
  String get newsDetails => 'News Details';

  @override
  String get shareNews => 'Share news';

  @override
  String get removeFromFavorites => 'Remove from favorites';

  @override
  String get addToFavorites => 'Add to favorites';

  @override
  String get noImage => 'No Image';

  @override
  String get description => 'Description';

  @override
  String get content => 'Content';

  @override
  String get openFullArticle => 'Open Full Article';
}
