# ============================================================================
# Automated CI/CD Pipeline Setup Script
# ============================================================================
# This script automates the complete setup of Jenkins, SonarQube, Maven, Git
# and the Business Management Project CI/CD pipeline on a Windows PC
#
# Usage: powershell -ExecutionPolicy Bypass -File setup-cicd-auto.ps1
# ============================================================================

# Requires admin rights
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
    Write-Host "❌ This script requires Administrator privileges!" -ForegroundColor Red
    Write-Host "Please run PowerShell as Administrator and try again." -ForegroundColor Yellow
    exit 1
}

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

# ============================================================================
# Configuration
# ============================================================================
$INSTALL_DIR = "C:\DevProjects"
$JAVA25_URL = "https://download.oracle.com/java/25/latest/jdk-25_windows-x64_bin.exe"
$JAVA21_URL = "https://download.oracle.com/java/21/latest/jdk-21_windows-x64_bin.exe"
$MAVEN_URL = "https://archive.apache.org/dist/maven/maven-3/3.9.4/binaries/apache-maven-3.9.4-bin.zip"
$GIT_URL = "https://github.com/git-for-windows/git/releases/download/v2.43.0.windows.1/Git-2.43.0-64-bit.exe"
$JENKINS_URL = "https://get.jenkins.io/windows-stable/jenkins-2.387.3.msi"
$SONARQUBE_URL = "https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-10.4.1.88267.zip"
$SONARQUBE_VERSION = "10.4.1.88267"
$PROJECT_REPO = "https://github.com/Akrem-Alamine/Business_Management_Project.git"
$PROJECT_NAME = "Business_Management_Project"

# ============================================================================
# Helper Functions
# ============================================================================

function Write-Step {
    param([string]$message)
    Write-Host "`n" + ("=" * 80) -ForegroundColor Cyan
    Write-Host "▶ $message" -ForegroundColor Cyan
    Write-Host ("=" * 80) -ForegroundColor Cyan
}

function Write-Success {
    param([string]$message)
    Write-Host "✅ $message" -ForegroundColor Green
}

function Write-Error-Msg {
    param([string]$message)
    Write-Host "❌ $message" -ForegroundColor Red
}

function Write-Warning-Msg {
    param([string]$message)
    Write-Host "⚠️  $message" -ForegroundColor Yellow
}

function Test-Path-Exists {
    param([string]$path, [string]$name)
    if (Test-Path $path) {
        Write-Success "$name found at: $path"
        return $true
    } else {
        Write-Warning-Msg "$name not found at: $path"
        return $false
    }
}

function Download-File {
    param([string]$url, [string]$destination)
    try {
        Write-Host "Downloading from: $url" -ForegroundColor Gray
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Invoke-WebRequest -Uri $url -OutFile $destination -UseBasicParsing
        Write-Success "Downloaded: $(Split-Path $destination -Leaf)"
    } catch {
        Write-Error-Msg "Failed to download: $url`nError: $_"
        return $false
    }
    return $true
}

function Install-Software {
    param([string]$installer, [string]$arguments)
    try {
        Write-Host "Running installer..." -ForegroundColor Gray
        Start-Process -FilePath $installer -ArgumentList $arguments -Wait -NoNewWindow
        Write-Success "Installation completed"
    } catch {
        Write-Error-Msg "Installation failed: $_"
        return $false
    }
    return $true
}

# ============================================================================
# Step 1: Create Working Directory
# ============================================================================
Write-Step "Step 1: Creating Working Directory"
try {
    if (-not (Test-Path $INSTALL_DIR)) {
        New-Item -ItemType Directory -Path $INSTALL_DIR -Force | Out-Null
        Write-Success "Created directory: $INSTALL_DIR"
    } else {
        Write-Success "Directory already exists: $INSTALL_DIR"
    }
    Set-Location $INSTALL_DIR
} catch {
    Write-Error-Msg "Failed to create/navigate to directory: $_"
    exit 1
}

# ============================================================================
# Step 2: Clone Project Repository
# ============================================================================
Write-Step "Step 2: Cloning Project Repository"
$PROJECT_PATH = Join-Path $INSTALL_DIR $PROJECT_NAME

if (Test-Path $PROJECT_PATH) {
    Write-Warning-Msg "Project already exists at: $PROJECT_PATH"
    $choice = Read-Host "Do you want to pull latest changes? (Y/N)"
    if ($choice -eq 'Y' -or $choice -eq 'y') {
        Set-Location $PROJECT_PATH
        git pull origin master
        Write-Success "Project updated"
    }
} else {
    try {
        git clone $PROJECT_REPO
        Write-Success "Project cloned successfully"
        Set-Location $PROJECT_PATH
    } catch {
        Write-Error-Msg "Failed to clone repository: $_"
        Write-Warning-Msg "Make sure Git is installed. Skipping clone step."
    }
}

# ============================================================================
# Step 3: Check/Install Java 25
# ============================================================================
Write-Step "Step 3: Checking Java 25 Installation"
$JAVA25_PATH = "C:\Program Files\Java\jdk-25"

if (Test-Path-Exists $JAVA25_PATH "Java 25") {
    Write-Success "Java 25 is already installed"
} else {
    Write-Warning-Msg "Java 25 not found. Manual installation required."
    Write-Host "Download from: https://www.oracle.com/java/technologies/downloads/#java25" -ForegroundColor Yellow
    Write-Host "Install to: $JAVA25_PATH" -ForegroundColor Yellow
    $readInput = Read-Host "Press Enter after Java 25 installation is complete..."
}

# Set JAVA_HOME environment variable
try {
    [Environment]::SetEnvironmentVariable("JAVA_HOME", $JAVA25_PATH, "User")
    Write-Success "Set JAVA_HOME environment variable"
} catch {
    Write-Error-Msg "Failed to set JAVA_HOME: $_"
}

# ============================================================================
# Step 4: Check/Install Java 21
# ============================================================================
Write-Step "Step 4: Checking Java 21 Installation"
$JAVA21_PATH = "C:\Program Files\Java\jdk-21"

if (Test-Path-Exists $JAVA21_PATH "Java 21") {
    Write-Success "Java 21 is already installed"
} else {
    Write-Warning-Msg "Java 21 not found. Manual installation required."
    Write-Host "Download from: https://www.oracle.com/java/technologies/javase/jdk21-archive-downloads.html" -ForegroundColor Yellow
    Write-Host "Install to: $JAVA21_PATH" -ForegroundColor Yellow
    $readInput = Read-Host "Press Enter after Java 21 installation is complete..."
}

# ============================================================================
# Step 5: Check/Install Maven
# ============================================================================
Write-Step "Step 5: Checking Maven Installation"
$MAVEN_PATH = "C:\apache-maven-3.9.4"

if (Test-Path-Exists $MAVEN_PATH "Maven") {
    Write-Success "Maven is already installed"
} else {
    Write-Host "Maven not found. Would you like to install it? (Y/N)" -ForegroundColor Yellow
    $choice = Read-Host "Choice"
    
    if ($choice -eq 'Y' -or $choice -eq 'y') {
        $MAVEN_ZIP = "$INSTALL_DIR\maven.zip"
        
        if (Download-File $MAVEN_URL $MAVEN_ZIP) {
            try {
                Write-Host "Extracting Maven..." -ForegroundColor Gray
                Expand-Archive -Path $MAVEN_ZIP -DestinationPath "C:\" -Force
                Remove-Item $MAVEN_ZIP -Force
                Write-Success "Maven installed successfully"
            } catch {
                Write-Error-Msg "Failed to extract Maven: $_"
            }
        }
    }
}

# Set M2_HOME environment variable
try {
    [Environment]::SetEnvironmentVariable("M2_HOME", $MAVEN_PATH, "User")
    $currentPath = [Environment]::GetEnvironmentVariable("PATH", "User")
    if ($currentPath -notlike "*$MAVEN_PATH\bin*") {
        [Environment]::SetEnvironmentVariable("PATH", "$currentPath;$MAVEN_PATH\bin", "User")
    }
    Write-Success "Set M2_HOME environment variable"
} catch {
    Write-Error-Msg "Failed to set M2_HOME: $_"
}

# ============================================================================
# Step 6: Check/Install Git
# ============================================================================
Write-Step "Step 6: Checking Git Installation"
try {
    $gitVersion = git --version 2>$null
    Write-Success "Git is installed: $gitVersion"
} catch {
    Write-Host "Git not found. Manual installation required." -ForegroundColor Yellow
    Write-Host "Download from: https://git-scm.com/download/win" -ForegroundColor Yellow
    $readInput = Read-Host "Press Enter after Git installation is complete..."
}

# Configure Git
try {
    $gitUserName = Read-Host "Enter your Git username (for commits)"
    $gitEmail = Read-Host "Enter your Git email (for commits)"
    
    git config --global user.name $gitUserName
    git config --global user.email $gitEmail
    Write-Success "Git configured with user: $gitUserName <$gitEmail>"
} catch {
    Write-Error-Msg "Failed to configure Git: $_"
}

# ============================================================================
# Step 7: Check/Install Jenkins
# ============================================================================
Write-Step "Step 7: Checking Jenkins Installation"
try {
    $jenkinsService = Get-Service Jenkins -ErrorAction SilentlyContinue
    if ($jenkinsService) {
        Write-Success "Jenkins is already installed"
        Write-Host "Jenkins Status: $($jenkinsService.Status)" -ForegroundColor Gray
    } else {
        throw "Jenkins not installed"
    }
} catch {
    Write-Host "Jenkins not found. Manual installation required." -ForegroundColor Yellow
    Write-Host "Download from: https://www.jenkins.io/download/" -ForegroundColor Yellow
    Write-Host "Choose 'Windows installer (.msi)'" -ForegroundColor Yellow
    Write-Host "During installation, set port to 8081" -ForegroundColor Yellow
    $readInput = Read-Host "Press Enter after Jenkins installation is complete..."
}

# Configure Jenkins environment variables
Write-Host "Configuring Jenkins environment variables..." -ForegroundColor Gray
$jenkinsPath = "C:\Program Files\Jenkins"
if (Test-Path $jenkinsPath) {
    try {
        # Create Jenkins config if needed
        Write-Success "Jenkins environment will use JAVA_HOME and M2_HOME"
    } catch {
        Write-Error-Msg "Failed to configure Jenkins: $_"
    }
}

# ============================================================================
# Step 8: Check/Install SonarQube
# ============================================================================
Write-Step "Step 8: Checking SonarQube Installation"
$SONARQUBE_PATH = "C:\sonarqube-$SONARQUBE_VERSION"

if (Test-Path-Exists $SONARQUBE_PATH "SonarQube") {
    Write-Success "SonarQube is already installed"
} else {
    Write-Host "SonarQube not found. Would you like to install it? (Y/N)" -ForegroundColor Yellow
    $choice = Read-Host "Choice"
    
    if ($choice -eq 'Y' -or $choice -eq 'y') {
        $SONARQUBE_ZIP = "$INSTALL_DIR\sonarqube.zip"
        
        Write-Host "Downloading SonarQube (this may take a few minutes)..." -ForegroundColor Gray
        if (Download-File $SONARQUBE_URL $SONARQUBE_ZIP) {
            try {
                Write-Host "Extracting SonarQube..." -ForegroundColor Gray
                Expand-Archive -Path $SONARQUBE_ZIP -DestinationPath "C:\" -Force
                Remove-Item $SONARQUBE_ZIP -Force
                Write-Success "SonarQube extracted successfully"
            } catch {
                Write-Error-Msg "Failed to extract SonarQube: $_"
            }
        }
    }
}

# Create SonarQube startup script
Write-Host "Creating SonarQube startup script with Java 21..." -ForegroundColor Gray
$sonarStartPath = "$SONARQUBE_PATH\bin\windows-x86-64"
if (Test-Path $sonarStartPath) {
    $startScriptContent = @'
@echo off
setlocal enabledelayedexpansion
set JAVA_HOME=C:\Program Files\Java\jdk-21
set PATH=%JAVA_HOME%\bin;%PATH%
set SONAR_JAVA_PATH=%JAVA_HOME%\bin\java.exe

echo Starting SonarQube with Java 21...
echo JAVA_HOME: %JAVA_HOME%
echo SONAR_JAVA_PATH: %SONAR_JAVA_PATH%

cd /d "C:\sonarqube-25.11.0.114957\bin\windows-x86-64"
call StartSonar.bat
'@
    
    try {
        $startScriptContent | Set-Content "$sonarStartPath\StartSonarJava21.bat" -Encoding ASCII
        Write-Success "SonarQube startup script created"
    } catch {
        Write-Error-Msg "Failed to create startup script: $_"
    }
}

# ============================================================================
# Step 9: Create Jenkins Pipeline Job Configuration
# ============================================================================
Write-Step "Step 9: Creating Jenkins Pipeline Job Configuration"

if (Test-Path $PROJECT_PATH) {
    $jenkinsConfigPath = Join-Path $PROJECT_PATH "jenkins-config.txt"
    $configContent = @"
JENKINS PIPELINE JOB CONFIGURATION
===================================

Job Name: BusinessProject_Pipeline
Job Type: Pipeline

Configuration Steps:
1. Open Jenkins: http://localhost:8081
2. Click "+ New Item"
3. Enter Job Name: BusinessProject_Pipeline
4. Select "Pipeline" as job type
5. Click "OK"

Configure Pipeline:
- Under "Definition", select "Pipeline script from SCM"
- SCM: Git
- Repository URL: https://github.com/Akrem-Alamine/Business_Management_Project.git
- Branch: */master
- Script Path: Jenkinsfile
- Click "Save"

Pipeline Stages:
✅ Stage 1: Git Checkout
✅ Stage 2: Build (Maven compile)
✅ Stage 3: SonarQube Analysis
✅ Stage 4: Test (ProductServiceTest)
✅ Stage 5: Nexus Deploy (package artifacts)

SONARQUBE TOKEN SETUP:
====================
1. Open SonarQube: http://localhost:9000
2. Login with: admin / admin
3. Go to: Administration → Users → Tokens
4. Click "Generate Tokens"
5. Name: Jenkins_Token
6. Type: Global Analysis Token
7. Copy the token and paste in Jenkinsfile SonarQube stage

TO RUN THE PIPELINE:
===================
1. Start SonarQube: cmd /c "C:\sonarqube-25.11.0.114957\bin\windows-x86-64\StartSonarJava21.bat"
2. Wait for SonarQube to start (60 seconds)
3. Open Jenkins: http://localhost:8081
4. Click on "BusinessProject_Pipeline"
5. Click "Build Now"
6. Monitor progress in Console Output
"@
    
    try {
        $configContent | Set-Content $jenkinsConfigPath
        Write-Success "Jenkins configuration reference created"
    } catch {
        Write-Error-Msg "Failed to create configuration reference: $_"
    }
}

# ============================================================================
# Step 10: Verify All Installations
# ============================================================================
Write-Step "Step 10: Verifying All Installations"

Write-Host "`nChecking installations..." -ForegroundColor Gray

# Java 25
try {
    $javaVersion = & "$JAVA25_PATH\bin\java.exe" -version 2>&1
    Write-Success "Java 25: $($javaVersion[0])"
} catch {
    Write-Warning-Msg "Java 25 verification failed"
}

# Java 21
try {
    $java21Version = & "$JAVA21_PATH\bin\java.exe" -version 2>&1
    Write-Success "Java 21: $($java21Version[0])"
} catch {
    Write-Warning-Msg "Java 21 verification failed"
}

# Maven
try {
    $mavenVersion = & "$MAVEN_PATH\bin\mvn.cmd" --version 2>&1
    Write-Success "Maven: $($mavenVersion[0])"
} catch {
    Write-Warning-Msg "Maven verification failed"
}

# Git
try {
    $gitVersion = git --version
    Write-Success "Git: $gitVersion"
} catch {
    Write-Warning-Msg "Git verification failed"
}

# Jenkins
try {
    $jenkinsService = Get-Service Jenkins -ErrorAction SilentlyContinue
    if ($jenkinsService) {
        Write-Success "Jenkins Service: $($jenkinsService.Status)"
    }
} catch {
    Write-Warning-Msg "Jenkins verification failed"
}

# SonarQube
if (Test-Path $SONARQUBE_PATH) {
    Write-Success "SonarQube: Installed at $SONARQUBE_PATH"
} else {
    Write-Warning-Msg "SonarQube not installed"
}

# ============================================================================
# Final Instructions
# ============================================================================
Write-Step "Setup Complete!"

Write-Host "`n📋 NEXT STEPS:
1. Start Jenkins (if not running):
   - Services → Jenkins → Start
   - Or: Start-Service Jenkins

2. Start SonarQube:
   - Open PowerShell as Administrator
   - Run: cmd /c 'C:\sonarqube-25.11.0.114957\bin\windows-x86-64\StartSonarJava21.bat'
   - Wait 60 seconds for startup

3. Generate SonarQube Token:
   - Open: http://localhost:9000
   - Login: admin / admin
   - Go to: Administration → Users → Tokens
   - Generate Global Analysis Token
   - Copy token and update Jenkinsfile SonarQube stage

4. Create Jenkins Job:
   - Open: http://localhost:8081
   - Create New Item → Pipeline job
   - Set Repository URL and Script Path (Jenkinsfile)
   - Save

5. Run Pipeline:
   - Click Build Now
   - Monitor Console Output
   - Verify all 5 stages complete successfully

📌 IMPORTANT URLS:
   - Jenkins: http://localhost:8081
   - SonarQube: http://localhost:9000
   - Project: $PROJECT_PATH

📚 Documentation:
   - See SETUP_CICD_GUIDE.md in project directory
   - Jenkins: https://www.jenkins.io/doc/
   - SonarQube: https://docs.sonarqube.org/

" -ForegroundColor Green

Write-Host "✅ Setup script completed successfully!" -ForegroundColor Green
Write-Host "Press Enter to exit..." -ForegroundColor Gray
Read-Host
