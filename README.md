# Islami - Comprehensive Islamic Application

A beautifully designed, feature-rich Islamic Flutter application built with a modern clean-architecture approach. The app features an elegant dark and gold aesthetic intended to provide a premium user experience.

![App Layout](assets/logo.png "Islami App")

## 🌟 Key Features

* **Beautiful UI/UX:** A stunning dark theme accented with gold elements, modern typography (Amiri for Arabic), and elegant decorative UI corners.
* **Splash & Onboarding:** Welcoming user flow with animated splash screens and an educational onboarding carousel.
* **Holy Quran Experience:**
  * **Full Surah Index:** Browse all 114 Surahs categorized securely from dedicated API endpoints (`mp3quran.net/api/v3` and `api.alquran.cloud/v1`).
  * **Dynamic Surah Detail View:** Read Arabic verses seamlessly. Each Ayah is correctly enumerated and displayed with beautiful borders.
  * **Most Recently Read:** The app keeps track of the Surahs you’ve recently opened using local storage (`shared_preferences`) so you can quickly jump back to reading.
  * **Search Functionality:** Find specific Surahs quickly by English or Arabic name.
* **Bottom Navigation Bar:** Effortlessly switch between Core features. *(Additional tabs coming soon)*.

## 🚀 Architecture

The application aggressively follows a **Feature-First Architecture** inside the `lib/` directory:

* `core/` - Reusable App Theming (`colors_manager.dart`) and components.
* `features/quran/` - Complete Data (Models, Repositories), Presentation (Cubit State Management), and UI Layers isolated for the Holy Quran.
* `features/onboarding/` - Isolated flow for app introduction.
* `features/splash/` - Isolated flow for app initialization.
* `features/main_layout/` - Global navigational shell.

### State Management

* **Flutter Bloc / Cubit**: Used effectively to isolate API loading states from the UI rendering context (e.g. `QuranCubit`, `SurahDetailCubit`).

## 🛠️ Upcoming Features

* **Hadith Compilation:** Prophetic traditions.
* **Digital Tasbih:** Simple interaction for remembering Allah.
* **Holy Quran Radio:** Free dedicated live streams.
* **Reading Stats:** Personal insights into reading habits.
