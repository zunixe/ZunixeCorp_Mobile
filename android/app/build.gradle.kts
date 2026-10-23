import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Kredensial upload key TIDAK di-commit. Salin key.properties.example →
// key.properties lalu isi. Tanpa file ini (mis. CI), build rilis memakai
// debug key agar pipeline tetap jalan — AAB hasilnya TIDAK boleh diunggah.
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
val hasReleaseKey = keystorePropertiesFile.exists()
if (hasReleaseKey) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}
// Build verifikasi di CI boleh memakai debug key; build rilis lokal tidak,
// supaya AAB debug tidak pernah tanpa sengaja diunggah ke Play.
val allowDebugSigning = System.getenv("ALLOW_DEBUG_SIGNING") == "true"

android {
    namespace = "com.zunixe.zunixe_store"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.zunixe.zunixe_store"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseKey) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            // Fallback debug hanya dipakai bila ALLOW_DEBUG_SIGNING=true.
            // Guard di bawah mencegah build rilis tanpa upload key.
            signingConfig = if (hasReleaseKey) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

// Gagalkan hanya build rilis tanpa upload key. Build debug/profile tetap jalan
// karena konfigurasi signing tidak boleh melempar saat fase konfigurasi.
gradle.taskGraph.whenReady {
    val releaseRequested =
        allTasks.any { it.name.contains("Release", ignoreCase = true) }
    if (releaseRequested && !hasReleaseKey && !allowDebugSigning) {
        throw GradleException(
            "android/key.properties tidak ditemukan. Buat upload keystore " +
                "(lihat android/key.properties.example) sebelum build rilis. " +
                "Untuk build verifikasi saja, set ALLOW_DEBUG_SIGNING=true."
        )
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
