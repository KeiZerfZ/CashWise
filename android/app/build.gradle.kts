// android/app/build.gradle.kts

import org.jetbrains.kotlin.gradle.tasks.KotlinCompile
import org.jetbrains.kotlin.gradle.dsl.JvmTarget

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.cashwise"
    compileSdk = flutter.compileSdkVersion

    ndkVersion = "27.0.12077973"

    defaultConfig {
        applicationId = "com.example.cashwise"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        getByName("release") {
            // Masih pakai debug keystore, aman buat dev
            signingConfig = signingConfigs.getByName("debug")

            // Kalau mau, bisa matiin minify sementara:
            // isMinifyEnabled = false
        }
    }

    // Java compile target 1.8 (iya, di-warning, tapi masih jalan)
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }
}

flutter {
    source = "../.."
}

// Kotlin compile target 1.8, pakai compilerOptions DSL
tasks.withType<KotlinCompile>().configureEach {
    compilerOptions {
        jvmTarget.set(JvmTarget.JVM_1_8)
    }
}

// ======================================================
// DEPENDENCIES
// ======================================================
dependencies {
    // Tambah OkHttp, ini yang hilang dan bikin R8 teriak
    implementation("com.squareup.okhttp3:okhttp:4.12.0")
}
