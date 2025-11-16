// android/build.gradle.kts (ROOT)

import org.gradle.api.tasks.Delete

plugins {
    id("com.android.application") version "8.7.0" apply false
    id("org.jetbrains.kotlin.android") apply false
}

// Repositori buat semua module
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Task clean standar
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
