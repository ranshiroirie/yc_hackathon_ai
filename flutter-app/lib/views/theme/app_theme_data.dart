import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum AppColor {
  background(Color(0xFFF2F3EE)),
  backgroundSubtleWarm(Color(0xFFF8F5F3)),
  white(Colors.white),
  primary(Color(0xFFE35E49)), //rgba(227, 94, 73, 1)
  primaryHover(Color(0xFFDB3B1A)),
  primaryPressed(Color(0xFFDB3B1A)),
  containerBg(Color(0xFFF8F5F3)),
  containerBgAlt(Color(0xFFF6F8F3)),
  textDefault(Color(0xE5000000)),
  textSecondary(Color(0x80000000)),
  textIconTertiary(Color(0x4D000000)),
  danger(Color(0xFFE51045)),
  strokeDefault(Color(0x1F000000)),
  bgDisabled(Color(0x0D000000)),
  gray8(Color(0xFFEAEAE7)),
  gray16(Color(0xFFE1E1DA)),
  gray20(Color(0xFFCACABE)),
  gray24(Color(0xFFB4B4AB)),
  gray40(Color(0xFF8E8F87)),
  gray60(Color(0xFF65665F)),
  mapWarmGray(Color(0xFFC8C4AA)),
  black(Color(0xFF1C3111)), //Black: rgba(28, 49, 17, 1)
  bgBeige(Color(0xFFF2F3EE)), //BG Beige: rgba(242, 243, 238, 1)
  bgGreen(Color(0xFFBEC6AF)), //BG Green: rgba(190, 198, 175, 1)
  bgBlue(Color(0xFFBED1D7)), //BG Blue: rgba(190, 209, 215, 1)
  bgLightBlue(Color(0xFFCED6D8)), // BG Light Blue
  fgBeige(Color(0xFFFAFBF9)), //FG Beige: rgba(242, 243, 238, 1)
  bgLightGreen(Color(0xFFD2D6CC)), // BG Light Green
  shadow(Color.fromRGBO(72, 74, 13, 0.08)),
  shadowSM(Color.fromRGBO(0, 0, 0, 0.04)),
  shadowMD(Color.fromRGBO(0, 0, 0, 0.08)),
  shadowLG(Color.fromRGBO(0, 0, 0, 0.12)),

  // マーカー関連のカラー
  markerCurrent(Color(0xFFE35E49)), // 現在地マーカーの色（primaryに近いが少し調整）
  markerCurrentPulse(Color(0x80E35E49)), // 現在地マーカーのパルス色（透明度50%）
  markerBorder(Colors.white); // マーカーの境界線色

  final Color color;
  const AppColor(this.color);
}

final appColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: AppColor.primary.color,
  onPrimary: AppColor.white.color,
  secondary: AppColor.primary.color,
  onSecondary: AppColor.white.color,
  surface: AppColor.bgBeige.color,
  onSurface: AppColor.black.color,
  surfaceContainer: AppColor.bgBeige.color,
  error: AppColor.danger.color,
  onError: AppColor.white.color,
  outline: AppColor.strokeDefault.color,
);

final appThemeData = ThemeData(
  useMaterial3: true,
  colorScheme: appColorScheme,
  splashColor: Colors.transparent,
  highlightColor: Colors.transparent,
  scaffoldBackgroundColor: AppColor.bgBeige.color,
  appBarTheme: AppBarTheme(
    backgroundColor: appColorScheme.surface,
    foregroundColor: appColorScheme.onSurface,
    elevation: 0,
    centerTitle: false,
    scrolledUnderElevation: 0.0,
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: appColorScheme.surface,
    selectedItemColor: appColorScheme.primary,
    unselectedItemColor: appColorScheme.onSurface,
    showSelectedLabels: true,
    showUnselectedLabels: true,
    type: BottomNavigationBarType.fixed,
    elevation: 0,
  ),
  textButtonTheme: TextButtonThemeData(
    style: ButtonStyle(
      elevation: WidgetStateProperty.all(0),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      backgroundColor: WidgetStateProperty.resolveWith(
        (states) {
          if (states.contains(WidgetState.disabled)) {
            return AppColor.bgDisabled.color;
          } else if (states.contains(WidgetState.hovered)) {
            return AppColor.primaryHover.color;
          } else if (states.contains(WidgetState.pressed)) {
            return AppColor.primaryPressed.color;
          }
          return AppColor.primary.color;
        },
      ),
      foregroundColor: WidgetStateProperty.all(AppColor.white.color),
      textStyle: WidgetStateProperty.all(
        TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      padding: WidgetStateProperty.all(
        EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      minimumSize: WidgetStateProperty.all(const Size(0, 48)),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.xl.value),
      borderSide: BorderSide(
        color: AppColor.strokeDefault.color,
        width: 1.0,
      ),
    ),
    hintStyle: AppTextStyleNew.body02.value(
      color: AppColor.textSecondary.color,
    ),
    contentPadding: EdgeInsets.symmetric(
      vertical: Space.x3s.value,
      horizontal: Space.defaultt.value,
    ),
    floatingLabelBehavior: FloatingLabelBehavior.always,
    floatingLabelAlignment: FloatingLabelAlignment.start,
  ),
);

enum Space {
  x4s(2),
  x3s(4),
  xs(8),
  sm(10),
  defaultt(12),
  md(16),
  lg(20),
  xl(24),
  x2l(32),
  x3l(40),
  x6l(64),
  x7l(72);

  final double value;
  const Space(this.value);
}

const appDefaultPadding = EdgeInsets.all(12);

enum AppRadius {
  lg(4),
  xl(8),
  xxl(12),
  xxxl(16);

  final double value;
  const AppRadius(this.value);
}

enum AppTextStyleNew {
  heading01,
  heading01Serif,
  heading01SerifItalic,
  heading01SefifJa,
  heading02,
  heading02Serif,
  heading03,
  heading03Serif,
  heading04,
  heading04Serif,
  body01,
  body01Bold,
  body02,
  body02Bold,
  body02Underline,
  caption01,
  caption02,
  mapText;

  TextStyle value({
    required Color color,
  }) {
    switch (this) {
      case AppTextStyleNew.heading01:
        return GoogleFonts.dmSans(
          fontSize: 32,
          fontWeight: FontWeight.w600, // Semibold
          height: 1.3,
          letterSpacing: 0,
          color: color,
        );
      case AppTextStyleNew.heading01Serif:
        return GoogleFonts.castoro(
          fontSize: 32,
          fontWeight: FontWeight.w400, // Regular
          height: 1.3,
          letterSpacing: 0,
          color: color,
        );
      case AppTextStyleNew.heading01SerifItalic:
        return GoogleFonts.castoro(
          fontSize: 32,
          fontStyle: FontStyle.italic,
          height: 1.3,
          letterSpacing: 0,
          color: color,
        );
      case AppTextStyleNew.heading01SefifJa:
        return GoogleFonts.zenOldMincho(
          fontSize: 32,
          fontWeight: FontWeight.w600, // Semibold
          height: 1.3,
          letterSpacing: -2,
          color: color,
        );
      case AppTextStyleNew.heading02:
        return GoogleFonts.dmSans(
          fontSize: 28,
          fontWeight: FontWeight.w600, // Semibold
          height: 1.3,
          letterSpacing: 0,
          color: color,
        );
      case AppTextStyleNew.heading02Serif:
        return GoogleFonts.castoro(
          fontSize: 28,
          fontWeight: FontWeight.w400, // Regular
          height: 1.2,
          letterSpacing: 0,
          color: color,
        );
      case AppTextStyleNew.heading03:
        return GoogleFonts.dmSans(
          fontSize: 24,
          fontWeight: FontWeight.w600, // Semibold
          height: 1.3,
          letterSpacing: 0,
          color: color,
        );
      case AppTextStyleNew.heading03Serif:
        return GoogleFonts.castoro(
          fontSize: 24,
          fontWeight: FontWeight.w400, // Regular
          height: 1.3,
          letterSpacing: 0,
          color: color,
        );
      case AppTextStyleNew.heading04:
        return GoogleFonts.dmSans(
          fontSize: 20,
          fontWeight: FontWeight.w600, // Semibold
          height: 1.3,
          letterSpacing: 0,
          color: color,
        );
      case AppTextStyleNew.heading04Serif:
        return GoogleFonts.castoro(
          fontSize: 20,
          fontWeight: FontWeight.w400, // Regular
          height: 1.3,
          letterSpacing: 0,
          color: color,
        );
      case AppTextStyleNew.body01:
        return GoogleFonts.dmSans(
          fontSize: 16,
          fontWeight: FontWeight.w400, // Regular
          height: 1.4,
          letterSpacing: 0,
          color: color,
        );
      case AppTextStyleNew.body01Bold:
        return GoogleFonts.dmSans(
          fontSize: 16,
          fontWeight: FontWeight.w600, // Semibold
          height: 1.4,
          letterSpacing: 0,
          color: color,
        );
      case AppTextStyleNew.body02:
        return GoogleFonts.dmSans(
          fontSize: 14,
          fontWeight: FontWeight.w400, // Regular
          height: 1.4,
          letterSpacing: 0,
          color: color,
        );
      case AppTextStyleNew.body02Bold:
        return GoogleFonts.dmSans(
          fontSize: 14,
          fontWeight: FontWeight.w600, // Semibold
          height: 1.4,
          letterSpacing: 0,
          color: color,
        );
      case AppTextStyleNew.body02Underline:
        return GoogleFonts.dmSans(
          fontSize: 14,
          fontWeight: FontWeight.w400, // Regular
          height: 1.4,
          decoration: TextDecoration.underline,
          letterSpacing: 0,
          color: color,
        );
      case AppTextStyleNew.caption01:
        return GoogleFonts.dmSans(
          fontSize: 12,
          fontWeight: FontWeight.w400, // Regular
          height: 1.3,
          letterSpacing: 0,
          color: color,
        );
      case AppTextStyleNew.caption02:
        return GoogleFonts.dmSans(
          fontSize: 11,
          fontWeight: FontWeight.w400, // Regular
          height: 1.3,
          letterSpacing: 0,
          color: color,
        );
      case AppTextStyleNew.mapText:
        return GoogleFonts.barlow(
          fontSize: 12,
          fontWeight: FontWeight.w600, // Semibold
          height: 1.2,
          letterSpacing: 0,
          color: color,
        );
    }
  }
}

enum AppBoxShadow {
  shadowSM,
  shadowMD,
  shadowLG,
  shadowCardElevated,
  shadowPinMini; // x:8, y:8, blur:16, #000 8%

  BoxShadow get value {
    switch (this) {
      case AppBoxShadow.shadowSM:
        return BoxShadow(
          color: AppColor.shadowSM.color,
          blurRadius: 12,
          offset: Offset(0, 1),
        );
      case AppBoxShadow.shadowMD:
        return BoxShadow(
          color: AppColor.shadowMD.color,
          blurRadius: 16,
          offset: Offset(0, 1),
        );
      case AppBoxShadow.shadowLG:
        return BoxShadow(
          color: AppColor.shadowLG.color,
          blurRadius: 20,
          offset: Offset(0, 1),
        );
      case AppBoxShadow.shadowCardElevated:
        return BoxShadow(
          color: AppColor.shadowMD.color, // #000000 @ 8%
          blurRadius: 16,
          offset: Offset(8, 8),
        );
      case AppBoxShadow.shadowPinMini:
        return BoxShadow(
          color: AppColor.shadowLG.color,
          blurRadius: 4,
          offset: Offset(0, 1),
        );
    }
  }
}
