// plugins {
//     id("com.android.application")
//     id("com.google.gms.google-services")
//     id("dev.flutter.flutter-gradle-plugin")
// }

// android {
//     namespace = "com.aytech.easyride"
    
//     // Bumped to 37 to resolve permission_handler requirements
//     compileSdk = 37
//     ndkVersion = flutter.ndkVersion

//     compileOptions {
//         // ✅ 1. Enable Core Library Desugaring flag
//         isCoreLibraryDesugaringEnabled = true
        
//         sourceCompatibility = JavaVersion.VERSION_17
//         targetCompatibility = JavaVersion.VERSION_17
//     }

//     defaultConfig {
//         applicationId = "com.aytech.easyride"
//         minSdk = flutter.minSdkVersion
//         targetSdk = flutter.targetSdkVersion
//         versionCode = flutter.versionCode
//         versionName = flutter.versionName
//     }

//     buildTypes {
//         release {
//             signingConfig = signingConfigs.getByName("debug")
//         }
//     }
// }

// kotlin {
//     compilerOptions {
//         jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
//     }
// }

// flutter {
//     source = "../.."
// }

// // ✅ 2. Inject the desugaring engine dependency required by flutter_local_notifications
// dependencies {
//     coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.3")
// }

plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.aytech.easyride"
    
    compileSdk = 37
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.aytech.easyride"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        manifestPlaceholders["mapsApiKey"] = "YAIzaSyDiVFbR5x5ApuMzqy2QJeeIoPjsD1vKwtY"
    }

    buildTypes {
        release {
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

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.3")
}
