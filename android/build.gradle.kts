plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.named<Delete>("clean") {
    delete(rootProject.buildDir)
}

android {
    compileSdk = 33
    ndkVersion = "26.3.11579264" // Add this line

    defaultConfig {
        minSdk = 21
        targetSdk = 33
    }
}