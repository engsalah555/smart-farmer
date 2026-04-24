import com.android.build.gradle.BaseExtension
import org.gradle.api.tasks.compile.JavaCompile

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val project = this
    
    // Set build directory
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)

    // Force plugins to depend on :app evaluation
    if (project.name != "app") {
        project.evaluationDependsOn(":app")
    }

    // Configure compilation tasks lazily for all projects
    tasks.withType<JavaCompile>().configureEach {
        sourceCompatibility = JavaVersion.VERSION_21.toString()
        targetCompatibility = JavaVersion.VERSION_21.toString()
    }
    
    tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
        compilerOptions {
            jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_21)
        }
    }

    // Configure Android extension for plugins only (app is already configured)
    if (project.name != "app" && !project.state.executed) {
        project.afterEvaluate {
            if (project.hasProperty("android")) {
                try {
                    project.extensions.configure<BaseExtension>("android") {
                        // Force compileSdk to 36 for modern plugin compatibility
                        compileSdkVersion(36)
                        
                        compileOptions {
                            sourceCompatibility = JavaVersion.VERSION_21
                            targetCompatibility = JavaVersion.VERSION_21
                        }
                    }
                } catch (e: Exception) {
                    // Ignore if finalized
                }
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
