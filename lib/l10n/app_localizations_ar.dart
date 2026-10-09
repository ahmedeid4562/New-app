// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'تطبيق الأخبار';

  @override
  String get home => 'الرئيسية';

  @override
  String get favorites => 'المفضلة';

  @override
  String get history => 'سجل القراءة';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get settings => 'الإعدادات';

  @override
  String get searchNews => 'ابحث عن الأخبار...';

  @override
  String get language => 'اللغة';

  @override
  String get english => 'الإنجليزية';

  @override
  String get arabic => 'العربية';

  @override
  String get darkMode => 'الوضع الداكن';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get readingMode => 'وضع القراءة';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get cancel => 'إلغاء';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get noNewsFound => 'لم يتم العثور على أخبار.';

  @override
  String get categories => 'التصنيفات';

  @override
  String get general => 'عام';

  @override
  String get business => 'أعمال';

  @override
  String get technology => 'التكنولوجيا';

  @override
  String get sports => 'الرياضة';

  @override
  String get health => 'الصحة';

  @override
  String get science => 'العلوم';

  @override
  String get entertainment => 'الترفيه';

  @override
  String get clear => 'مسح';

  @override
  String searchResultsFor(String query) {
    return 'نتائج البحث عن \"$query\"';
  }

  @override
  String get unableToLoadNews => 'تعذر تحميل الأخبار';

  @override
  String get tryAgain => 'حاول مرة أخرى';

  @override
  String get trySearchingElse => 'جرّب البحث عن شيء آخر.';

  @override
  String get unexpectedError => 'حدث خطأ. يُرجى المحاولة مرة أخرى.';

  @override
  String get confirmLogout => 'هل أنت متأكد أنك تريد تسجيل الخروج؟';

  @override
  String get logoutFailed => 'فشل تسجيل الخروج. حاول مرة أخرى.';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get welcomeBack => 'مرحبًا بعودتك!';

  @override
  String get loginSubtitle => 'سجّل الدخول لمتابعة استخدام تطبيق الأخبار.';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get enterYourEmail => 'أدخل بريدك الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get enterYourPassword => 'أدخل كلمة المرور';

  @override
  String get forgotPassword => 'هل نسيت كلمة المرور؟';

  @override
  String get createAccount => 'إنشاء حساب';

  @override
  String get noAccount => 'ليس لديك حساب؟';

  @override
  String get loginSuccessful => 'تم تسجيل الدخول بنجاح!';

  @override
  String get incorrectCredentials => 'البريد الإلكتروني أو كلمة المرور غير صحيحة.';

  @override
  String get enterValidEmail => 'يرجى إدخال بريد إلكتروني صحيح.';

  @override
  String get accountDisabled => 'تم تعطيل هذا الحساب.';

  @override
  String get checkInternet => 'تحقق من اتصالك بالإنترنت.';

  @override
  String get tooManyAttempts => 'محاولات كثيرة. حاول مرة أخرى لاحقًا.';

  @override
  String get somethingWentWrong => 'حدث خطأ. يرجى المحاولة مرة أخرى.';

  @override
  String get enterEmailFirst => 'أدخل بريدك الإلكتروني أولًا.';

  @override
  String get passwordResetSent => 'تم إرسال رابط إعادة تعيين كلمة المرور. تحقق من بريدك.';

  @override
  String get passwordResetFailed => 'تعذر إرسال رابط إعادة تعيين كلمة المرور.';

  @override
  String get enterEmailError => 'يرجى إدخال بريدك الإلكتروني.';

  @override
  String get enterPasswordError => 'يرجى إدخال كلمة المرور.';

  @override
  String get clearHistory => 'مسح سجل القراءة';

  @override
  String get confirmClearHistory => 'هل أنت متأكد أنك تريد حذف سجل القراءة بالكامل؟';

  @override
  String get historyCleared => 'تم مسح سجل القراءة';

  @override
  String get unableToLoadHistory => 'تعذر تحميل سجل القراءة';

  @override
  String get noHistoryYet => 'لا يوجد سجل قراءة حتى الآن';

  @override
  String get historyDescription => 'المقالات التي تفتحها ستظهر هنا.';

  @override
  String get invalidArticleLink => 'رابط المقال غير صالح';

  @override
  String get couldNotOpenArticle => 'تعذر فتح هذا المقال';

  @override
  String get removeFromHistory => 'حذف من سجل القراءة';

  @override
  String get noFavoritesYet => 'لا توجد أخبار في المفضلة حتى الآن';

  @override
  String get favoritesDescription => 'احفظ الأخبار التي تعجبك بالضغط على علامة القلب، وستجدها هنا.';

  @override
  String get tapHeartToSave => 'اضغط على علامة القلب لحفظ أي خبر';

  @override
  String get unableToLoadFavorites => 'تعذر تحميل المفضلة';

  @override
  String get favoritesLoadError => 'حدثت مشكلة أثناء تحميل الأخبار المحفوظة. حاول مرة أخرى.';

  @override
  String get addedToFavorites => 'تمت إضافة الخبر إلى المفضلة';

  @override
  String get removedFromFavorites => 'تم حذف الخبر من المفضلة';

  @override
  String get unknownSource => 'مصدر غير معروف';

  @override
  String get imageUnavailable => 'الصورة غير متاحة';

  @override
  String get untitled => 'بدون عنوان';

  @override
  String get pleaseLoginToViewProfile => 'يرجى تسجيل الدخول لعرض ملفك الشخصي';

  @override
  String get myProfile => 'ملفي الشخصي';

  @override
  String get failedToLoadProfile => 'تعذر تحميل بيانات الملف الشخصي';

  @override
  String get user => 'مستخدم';

  @override
  String get accountInformation => 'معلومات الحساب';

  @override
  String get fullName => 'الاسم بالكامل';

  @override
  String get emailAddress => 'البريد الإلكتروني';

  @override
  String get chooseAppLanguage => 'اختر لغة التطبيق';

  @override
  String get darkThemeEnabled => 'المظهر الداكن مفعّل';

  @override
  String get lightThemeEnabled => 'المظهر الفاتح مفعّل';

  @override
  String get createYourAccount => 'أنشئ حسابك';

  @override
  String get signUpSubtitle => 'أنشئ حسابًا لمتابعة استخدام تطبيق الأخبار';

  @override
  String get name => 'الاسم';

  @override
  String get enterYourName => 'أدخل اسمك';

  @override
  String get pleaseEnterName => 'يرجى إدخال اسمك';

  @override
  String get nameMinLength => 'يجب ألا يقل الاسم عن 3 أحرف';

  @override
  String get pleaseEnterEmail => 'يرجى إدخال بريدك الإلكتروني';

  @override
  String get pleaseEnterValidEmail => 'يرجى إدخال بريد إلكتروني صحيح';

  @override
  String get enterPassword => 'أدخل كلمة المرور';

  @override
  String get pleaseEnterPassword => 'يرجى إدخال كلمة المرور';

  @override
  String get passwordMinLength => 'يجب ألا تقل كلمة المرور عن 6 أحرف';

  @override
  String get confirmPassword => 'تأكيد كلمة المرور';

  @override
  String get confirmYourPassword => 'أعد إدخال كلمة المرور';

  @override
  String get pleaseConfirmPassword => 'يرجى تأكيد كلمة المرور';

  @override
  String get passwordsDoNotMatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get accountCreatedSuccessfully => 'تم إنشاء الحساب وحفظ البيانات بنجاح';

  @override
  String get emailAlreadyRegistered => 'هذا البريد الإلكتروني مسجل بالفعل';

  @override
  String get passwordTooWeak => 'كلمة المرور ضعيفة';

  @override
  String get accountCreatedButSaveFailed => 'تم إنشاء الحساب، لكن تعذر حفظ بيانات المستخدم';

  @override
  String get alreadyHaveAccount => 'لديك حساب بالفعل؟';

  @override
  String get noNewsInfoToShare => 'لا توجد معلومات عن الخبر لمشاركتها';

  @override
  String get sharingFailed => 'تعذرت مشاركة الخبر';

  @override
  String get newsDetails => 'تفاصيل الخبر';

  @override
  String get shareNews => 'مشاركة الخبر';

  @override
  String get removeFromFavorites => 'حذف من المفضلة';

  @override
  String get addToFavorites => 'إضافة إلى المفضلة';

  @override
  String get noImage => 'لا توجد صورة';

  @override
  String get description => 'الوصف';

  @override
  String get content => 'المحتوى';

  @override
  String get openFullArticle => 'قراءة المقال كاملًا';
}
