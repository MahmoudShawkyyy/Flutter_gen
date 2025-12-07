// Top-level build file for all subprojects / modules.

buildscript {
    repositories {
        google()       // ✅ REQUIRED for Firebase & Google dependencies
        mavenCentral()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.7.0")
        classpath("com.google.gms:google-services:4.4.2") // ✅ Google Services plugin
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Optional: custom build output directory
val newBuildDir: Directory =
    rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
