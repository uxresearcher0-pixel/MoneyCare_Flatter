import java.util.Base64
import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    // Applies google-services.json (committed alongside this file) to generate
    // the Firebase config Firebase.initializeApp() picks up natively.
    id("com.google.gms.google-services")
}

// Release signing: reads from android/key.properties (local dev — the file
// is gitignored, never commit a real keystore or its passwords) or from
// RELEASE_KEYSTORE_BASE64 / RELEASE_STORE_PASSWORD / RELEASE_KEY_ALIAS /
// RELEASE_KEY_PASSWORD env vars (CI — set as GitHub Actions secrets). Falls
// back to debug signing when neither is present, so a from-scratch checkout
// or a CI run before secrets are configured still builds successfully —
// just not with a Play-submittable release signature.
val keyPropertiesFile = rootProject.file("key.properties")
val keyProperties = Properties()
if (keyPropertiesFile.exists()) {
    keyProperties.load(keyPropertiesFile.inputStream())
}

val releaseKeystoreBase64 = System.getenv("RELEASE_KEYSTORE_BASE64")
val hasCiSigning = !releaseKeystoreBase64.isNullOrBlank()
val hasLocalSigning = keyPropertiesFile.exists()

if (hasCiSigning) {
    // Materialize the keystore from the CI secret into a gitignored path.
    val decodedKeystore = layout.buildDirectory.file("release-signing/release.jks").get().asFile
    decodedKeystore.parentFile.mkdirs()
    // Imported explicitly (Base64, not fully-qualified java.util.Base64) —
    // the Android Gradle plugin injects a `java` extension property on
    // Project that shadows the `java` package name for fully-qualified
    // references in this script, breaking `java.util.X` lookups.
    decodedKeystore.writeBytes(Base64.getDecoder().decode(releaseKeystoreBase64))
}

android {
    namespace = "com.moneycare.money_care"
    // Pinned rather than inherited from flutter.compileSdkVersion: CI resolves
    // whatever public Flutter "stable" happens to be at build time, which may
    // default lower than what Google Play currently requires. Pinning removes
    // that drift as a submission risk. Bump this explicitly (and re-verify
    // against Play's current requirement) rather than letting it float.
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.moneycare.money_care"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        // Pinned to Google Play's current minimum target (Android 16 / API 36,
        // effective 31 Aug 2026) rather than inherited — see compileSdk comment.
        targetSdk = 36
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasCiSigning || hasLocalSigning) {
            create("release") {
                if (hasCiSigning) {
                    storeFile = layout.buildDirectory.file("release-signing/release.jks").get().asFile
                    storePassword = System.getenv("RELEASE_STORE_PASSWORD")
                    keyAlias = System.getenv("RELEASE_KEY_ALIAS")
                    keyPassword = System.getenv("RELEASE_KEY_PASSWORD")
                } else {
                    storeFile = file(keyProperties.getProperty("storeFile"))
                    storePassword = keyProperties.getProperty("storePassword")
                    keyAlias = keyProperties.getProperty("keyAlias")
                    keyPassword = keyProperties.getProperty("keyPassword")
                }
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (hasCiSigning || hasLocalSigning) {
                signingConfigs.getByName("release")
            } else {
                // No real keystore available (fresh checkout, or CI before
                // secrets are configured) — falls back to the debug key so
                // `flutter build apk/appbundle --release` still succeeds.
                // This build is NOT submittable to Google Play as-is.
                signingConfigs.getByName("debug")
            }
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
