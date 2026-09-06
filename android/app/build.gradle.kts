import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// AdMob application ID (SOW §4.8 · TASKS 7.2). Gradle can't read Dart defines,
// so the native app ID is sourced from the project-root .env (git-ignored).
// `release` builds use it; `debug` builds always use Google's public test app
// ID so day-to-day development never touches the production AdMob app.
val admobTestAppId = "ca-app-pub-3940256099942544~3347511713"
val admobProdAppIdAndroid: String = run {
    val envFile = rootProject.file("../.env")
    if (!envFile.exists()) return@run admobTestAppId
    val props = Properties().apply { envFile.inputStream().use { load(it) } }
    props.getProperty("ADMOB_APP_ID_ANDROID")?.trim()?.takeIf { it.isNotEmpty() }
        ?: admobTestAppId
}

android {
    namespace = "com.softpitalservices.emi_calculator"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.softpitalservices.emicalculator"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        // Pinned to 24 (Android 7.0): SOW AC-10 minimum + google_mobile_ads 9.x
        // requires API 23+. Was flutter.minSdkVersion (21).
        minSdk = 24
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Safe default for the AndroidManifest placeholder (TASKS 7.1); each
        // build type overrides it below.
        manifestPlaceholders["admobAppId"] = admobTestAppId
    }

    buildTypes {
        debug {
            manifestPlaceholders["admobAppId"] = admobTestAppId
        }
        release {
            manifestPlaceholders["admobAppId"] = admobProdAppIdAndroid
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
