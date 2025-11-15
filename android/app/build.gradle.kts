plugins {
    id("com.android.application")
    
    // =================================================================
    // INI DIA PERBAIKANNYA! (Hapus 'version "1.9.22"')
    // =================================================================
    id("kotlin-android") // <-- Gak ada 'version' lagi, dia bakal ngikutin root

    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.cashwise"
    compileSdk = flutter.compileSdkVersion
    
    // Fix NDK (Ini masih kita butuhin)
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.cashwise"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}