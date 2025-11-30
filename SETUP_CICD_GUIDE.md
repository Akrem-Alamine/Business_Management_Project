# CI/CD Pipeline Setup Guide

This guide provides step-by-step instructions to clone the Business Management Project and set up the complete CI/CD pipeline on a new Windows PC.

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Project Setup](#project-setup)
3. [Java Setup](#java-setup)
4. [Maven Configuration](#maven-configuration)
5. [Git Configuration](#git-configuration)
6. [Jenkins Installation](#jenkins-installation)
7. [SonarQube Installation](#sonarqube-installation)
8. [Pipeline Configuration](#pipeline-configuration)
9. [Running the Pipeline](#running-the-pipeline)
10. [Troubleshooting](#troubleshooting)

---

## Prerequisites

### Required Software
- Windows 10 or later
- Git (https://git-scm.com/download/win)
- Administrator access to install software

### Recommended System Resources
- RAM: 8GB minimum (16GB for smooth operation)
- Disk Space: 15GB minimum (5GB for project, 3GB for Jenkins, 2GB for SonarQube, 5GB buffer)
- Network: Internet connection for downloading dependencies

---

## Project Setup

### Step 1: Create Working Directory
```powershell
# Open PowerShell as Administrator
mkdir C:\DevProjects
cd C:\DevProjects
```

### Step 2: Clone the Repository
```powershell
git clone https://github.com/Akrem-Alamine/Business_Management_Project.git
cd Business_Management_Project
```

### Step 3: Verify Project Structure
```powershell
# List project structure
dir
# You should see: src/, target/, pom.xml, Jenkinsfile, etc.
```

---

## Java Setup

### Step 1: Download Java 25 (for Jenkins & Maven)
1. Visit: https://www.oracle.com/java/technologies/downloads/#java25
2. Download: **Windows x64 Installer** (jdk-25_windows-x64_bin.exe)
3. Run installer with Administrator rights
4. Install to: `C:\Program Files\Java\jdk-25`
5. Complete the installation

### Step 2: Download Java 21 (for SonarQube)
1. Visit: https://www.oracle.com/java/technologies/javase/jdk21-archive-downloads.html
2. Download: **Windows x64 Installer** (jdk-21_windows-x64_bin.exe)
3. Run installer with Administrator rights
4. Install to: `C:\Program Files\Java\jdk-21`
5. Complete the installation

### Step 3: Set JAVA_HOME Environment Variable
```powershell
# Open PowerShell as Administrator
[Environment]::SetEnvironmentVariable("JAVA_HOME", "C:\Program Files\Java\jdk-25", "User")

# Verify installation
java -version
# Output should show: "java version 25.0.1"
```

### Step 4: Verify Java Installation
```powershell
# Check Java 25 (for Jenkins)
java -version

# Check Java 21 (for SonarQube)
"C:\Program Files\Java\jdk-21\bin\java.exe" -version
```

---

## Maven Configuration

### Step 1: Download Maven
1. Visit: https://maven.apache.org/download.cgi
2. Download: **Binary zip archive** (apache-maven-3.9.4-bin.zip)
3. Extract to: `C:\apache-maven-3.9.4`

### Step 2: Set M2_HOME Environment Variable
```powershell
# Open PowerShell as Administrator
[Environment]::SetEnvironmentVariable("M2_HOME", "C:\apache-maven-3.9.4", "User")

# Add Maven to PATH
$path = [Environment]::GetEnvironmentVariable("PATH", "User")
[Environment]::SetEnvironmentVariable("PATH", "$path;C:\apache-maven-3.9.4\bin", "User")

# Verify installation
mvn --version
# Output should show Maven 3.9.4
```

### Step 3: Verify Maven Wrapper
```powershell
cd C:\DevProjects\Business_Management_Project

# Test Maven wrapper (downloads Maven if needed)
.\mvnw --version
```

---

## Git Configuration

### Step 1: Download & Install Git
1. Visit: https://git-scm.com/download/win
2. Download: **64-bit Git for Windows**
3. Run installer and select default options
4. Complete installation

### Step 2: Configure Git
```powershell
# Set global user configuration
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Verify configuration
git config --global --list
```

### Step 3: Verify Repository Clone
```powershell
cd C:\DevProjects\Business_Management_Project
git status
# Should show: "On branch master, Your branch is up to date..."
```

---

## Jenkins Installation

### Step 1: Download Jenkins
1. Visit: https://www.jenkins.io/download/
2. Download: **Windows installer (.msi)** (Generic Java package)
3. Version: Latest LTS

### Step 2: Install Jenkins
1. Run the installer as Administrator
2. Choose Installation Directory: `C:\Program Files\Jenkins`
3. Select "Run service as LocalSystem" or create a service account
4. Port Configuration: **Use port 8081** (or available port)
5. Complete installation

### Step 3: Access Jenkins Web Interface
```powershell
# Open browser
# Jenkins URL: http://localhost:8081

# On first access, retrieve initial admin password:
# PowerShell as Administrator:
Get-Content "C:\Program Files\Jenkins\secrets\initialAdminPassword"
```

### Step 4: Jenkins Setup Wizard
1. Enter the admin password from above
2. Click "Install suggested plugins"
3. Create first admin user
4. Confirm instance configuration
5. Finish setup

### Step 5: Configure Jenkins Environment
1. Go to: **Manage Jenkins** → **Configure System**
2. Scroll to **Environment variables**
3. Add three variables:
   - Name: `JAVA_HOME` | Value: `C:\Program Files\Java\jdk-25`
   - Name: `M2_HOME` | Value: `C:\apache-maven-3.9.4`
   - Name: `PATH` | Value: `C:\Program Files\Java\jdk-25\bin;C:\apache-maven-3.9.4\bin;C:\Program Files\Git\cmd;%PATH%`
4. Click **Save**

---

## SonarQube Installation

### Step 1: Download SonarQube
1. Visit: https://www.sonarqube.org/downloads/
2. Download: **Community Edition** (Windows 64-bit ZIP)
3. Latest version (25.x or higher)

### Step 2: Extract SonarQube
```powershell
# Assuming you have sonarqube-25.11.0.114957.zip
Expand-Archive -Path sonarqube-25.11.0.114957.zip -DestinationPath C:\
# Extracted to: C:\sonarqube-25.11.0.114957
```

### Step 3: Create SonarQube Startup Script (Java 21)
```powershell
# Create batch file for SonarQube with Java 21
$scriptContent = @'
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

$scriptContent | Set-Content "C:\sonarqube-25.11.0.114957\bin\windows-x86-64\StartSonarJava21.bat" -Encoding ASCII
```

### Step 4: Start SonarQube
```powershell
# Run the startup script
cmd /c "C:\sonarqube-25.11.0.114957\bin\windows-x86-64\StartSonarJava21.bat"

# Wait 30-60 seconds for SonarQube to start
# Open browser: http://localhost:9000
# Login with: admin / admin (default)
```

### Step 5: Generate SonarQube Token
1. Go to: http://localhost:9000
2. Login with admin/admin
3. Go to: **Administration** → **Users** → **Tokens**
4. Click **Generate Tokens**
5. Name: `Jenkins_Token`
6. Type: **Global Analysis Token**
7. Copy the token (example: `sqa_f91ba8837d3fe097b578d79f16c8794469e3bb95`)
8. **Save this token - you'll need it for the pipeline**

---

## Pipeline Configuration

### Step 1: Verify Jenkinsfile
```powershell
cd C:\DevProjects\Business_Management_Project
cat Jenkinsfile
# Should contain 5 stages: Git Checkout, Build, SonarQube Analysis, Test, Nexus Deploy
```

### Step 2: Update SonarQube Token in Jenkinsfile
```groovy
# In Jenkinsfile, find the SonarQube Analysis stage and replace the token:
-Dsonar.token=YOUR_TOKEN_HERE

# Replace YOUR_TOKEN_HERE with the token generated in Step 5 above
```

### Step 3: Create Jenkins Pipeline Job
1. Go to Jenkins: http://localhost:8081
2. Click **+ New Item**
3. Job name: `BusinessProject_Pipeline`
4. Select: **Pipeline**
5. Click **OK**

### Step 4: Configure Pipeline
1. Under **Definition**, select: **Pipeline script from SCM**
2. SCM: Select **Git**
3. Repository URL: `https://github.com/Akrem-Alamine/Business_Management_Project.git`
4. Branch: `*/master`
5. Script Path: `Jenkinsfile`
6. Click **Save**

### Step 5: Commit Token Update (if changed)
```powershell
cd C:\DevProjects\Business_Management_Project

# Only if you updated the token in Jenkinsfile:
git add Jenkinsfile
git commit -m "feat: update SonarQube token for new environment"
git push origin master
```

---

## Running the Pipeline

### Step 1: Start All Services
```powershell
# Terminal 1: Start SonarQube (keep running)
cmd /c "C:\sonarqube-25.11.0.114957\bin\windows-x86-64\StartSonarJava21.bat"

# Terminal 2: Verify Jenkins is running
# http://localhost:8081 (should be accessible)
```

### Step 2: Trigger Pipeline Build
1. Go to: http://localhost:8081
2. Click on **BusinessProject_Pipeline**
3. Click **Build Now**
4. Wait for pipeline to complete (2-5 minutes)

### Step 3: Monitor Pipeline Execution
1. Click on the build number (e.g., **#1**)
2. Click **Console Output** to see real-time logs
3. Stages should execute in order:
   - ✅ Git Checkout
   - ✅ Build (Maven compile)
   - ✅ SonarQube Analysis
   - ✅ Test (ProductServiceTest)
   - ✅ Nexus Deploy (package artifacts)

### Step 4: View Test Results
```powershell
# Check test output in console
# Look for: "Tests run: 1, Failures: 0, Errors: 0"
```

### Step 5: View SonarQube Analysis
1. Go to: http://localhost:9000
2. Navigate to project: **BusinessManagementProject**
3. Review code quality metrics and issues

---

## Testing the Pipeline

### Local Test (Before Pipeline)
```powershell
cd C:\DevProjects\Business_Management_Project

# Run Maven test
.\mvnw test -Dtest=ProductServiceTest

# Expected output:
# [INFO] Tests run: 1, Failures: 0, Errors: 0, Skipped: 0
```

### Pipeline Test
1. Trigger build via Jenkins UI
2. Monitor all 5 stages in Console Output
3. Verify success message at end

### Verify Each Component

**Test Git Connection:**
```powershell
git remote -v
# Should show: https://github.com/Akrem-Alamine/Business_Management_Project.git
```

**Test Maven:**
```powershell
.\mvnw clean compile -DskipTests
# Should complete successfully without errors
```

**Test Java:**
```powershell
java -version
# Should show Java 25
```

**Test SonarQube:**
```powershell
# Open browser: http://localhost:9000
# Should show login page
```

**Test Jenkins:**
```powershell
# Open browser: http://localhost:8081
# Should show Jenkins dashboard
```

---

## Troubleshooting

### Jenkins Issues

**Problem: Jenkins won't start**
```powershell
# Check Jenkins service
Get-Service Jenkins
# Start service manually
Start-Service Jenkins
```

**Problem: Port 8081 already in use**
```powershell
# Find process using port 8081
netstat -ano | findstr :8081
# Kill process
taskkill /PID <PID> /F
```

**Problem: Maven wrapper error**
```powershell
# Delete corrupted wrapper
Remove-Item .mvn\wrapper\maven-wrapper.jar -Force

# Re-run (wrapper will re-download)
.\mvnw --version
```

### SonarQube Issues

**Problem: SonarQube won't start**
- Verify Java 21 is installed
- Check logs: `C:\sonarqube-25.11.0.114957\logs\sonar.log`
- Try restarting with administrator rights

**Problem: SonarQube authentication fails**
```powershell
# Verify token in Jenkinsfile
# Token format: sqa_xxxxxxxxxxxxx (starts with sqa_)
# Check if token is expired (regenerate if needed)
```

**Problem: Port 9000 already in use**
```powershell
# Find process using port 9000
netstat -ano | findstr :9000
# Kill process
taskkill /PID <PID> /F
```

### Pipeline Execution Issues

**Problem: Git checkout fails**
```powershell
# Verify git is installed
git --version
# Verify repository URL is accessible
git ls-remote https://github.com/Akrem-Alamine/Business_Management_Project.git
```

**Problem: Build fails with "mvnw not found"**
```powershell
# Verify Maven wrapper exists
ls .mvn\wrapper\maven-wrapper.jar
# If missing, git checkout may have failed
```

**Problem: Test fails**
```powershell
# Run locally to debug
.\mvnw test -Dtest=ProductServiceTest
# Check output for specific error
```

**Problem: SonarQube analysis hangs**
```powershell
# Check if SonarQube server is running
# http://localhost:9000 should be accessible
# Check SonarQube logs for errors
```

---

## Environment Variables Summary

| Variable | Value | Purpose |
|----------|-------|---------|
| JAVA_HOME | C:\Program Files\Java\jdk-25 | Maven & Jenkins Java |
| M2_HOME | C:\apache-maven-3.9.4 | Maven installation |
| PATH | (includes bin directories) | Executable paths |

## Ports Used

| Service | Port | URL |
|---------|------|-----|
| Jenkins | 8081 | http://localhost:8081 |
| SonarQube | 9000 | http://localhost:9000 |

## Useful Commands

```powershell
# Check all Java installations
dir "C:\Program Files\Java"

# List Jenkins jobs
curl http://localhost:8081/api/json

# View SonarQube projects
curl http://localhost:9000/api/projects/search

# Clear Maven cache
Remove-Item $env:USERPROFILE\.m2\repository -Recurse -Force
```

---

## Support & Resources

- Jenkins Documentation: https://www.jenkins.io/doc/
- SonarQube Documentation: https://docs.sonarqube.org/
- Maven Documentation: https://maven.apache.org/guides/
- Git Documentation: https://git-scm.com/doc
- Project Repository: https://github.com/Akrem-Alamine/Business_Management_Project

---

## Completion Checklist

- [ ] Java 25 installed and JAVA_HOME set
- [ ] Java 21 installed for SonarQube
- [ ] Maven 3.9.4 downloaded and M2_HOME set
- [ ] Git installed and configured
- [ ] Project cloned to C:\DevProjects\Business_Management_Project
- [ ] Jenkins installed and running on port 8081
- [ ] SonarQube installed and running on port 9000
- [ ] SonarQube token generated
- [ ] Jenkinsfile updated with SonarQube token
- [ ] Jenkins pipeline job created
- [ ] Pipeline successfully executed all 5 stages
- [ ] Test passed in pipeline console
- [ ] SonarQube analysis results visible

---

**Last Updated:** December 1, 2025
**Project Version:** 0.0.1-SNAPSHOT
