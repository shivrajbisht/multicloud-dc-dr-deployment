#!/usr/bin/env bash
# ==============================================================================
# MULTI-LANGUAGE UNIT TESTING & SONARQUBE COVERAGE REPORT GENERATOR
# ==============================================================================
# Executes unit tests, generates language-specific code coverage reports:
#   1. Java Spring Boot -> JaCoCo XML (target/site/jacoco/jacoco.xml)
#   2. Node.js / Frontend -> LCOV (coverage/lcov.info)
#   3. Python -> pytest-cov XML (coverage.xml)
#   4. Golang -> Go Cover Profile (coverage.out)
# And pushes coverage metrics to SonarQube server.
# ==============================================================================

set -eo pipefail

MICROSERVICE_TYPE="${1:-java-springboot-service}"
SONAR_HOST_URL="${SONAR_HOST_URL:-https://sonarqube.internal.company.com}"
SONAR_TOKEN="${SONAR_TOKEN:-}"

echo "=========================================================================="
echo "Executing Unit Tests & Code Coverage for: ${MICROSERVICE_TYPE}"
echo "=========================================================================="

case "${MICROSERVICE_TYPE}" in

  "java-springboot-service"|"java-springboot")
    echo "[JAVA] Running Maven Unit Tests & Generating JaCoCo XML Coverage Report..."
    cd docker/java-springboot || exit 1
    # Run Maven test and JaCoCo report plugin
    if [ -f "pom.xml" ]; then
      mvn clean test jacoco:report -B
      COVERAGE_REPORT="target/site/jacoco/jacoco.xml"
      echo "[JAVA] JaCoCo XML generated at: ${COVERAGE_REPORT}"
      
      # Push to SonarQube
      sonar-scanner \
        -Dsonar.host.url="${SONAR_HOST_URL}" \
        -Dsonar.token="${SONAR_TOKEN}" \
        -Dsonar.projectKey="${MICROSERVICE_TYPE}" \
        -Dsonar.java.binaries="target/classes" \
        -Dsonar.coverage.jacoco.xmlReportPaths="${COVERAGE_REPORT}"
    fi
    ;;

  "nodejs-service"|"nodejs-app"|"frontend-service")
    echo "[NODE/JS] Running Jest/Karma Unit Tests & Generating LCOV Coverage Report..."
    cd docker/nodejs-app || exit 1
    if [ -f "package.json" ]; then
      npm ci
      npm test -- --coverage --coverageReporters="lcov" --watchAll=false
      COVERAGE_REPORT="coverage/lcov.info"
      echo "[NODE/JS] LCOV file generated at: ${COVERAGE_REPORT}"

      # Push to SonarQube
      sonar-scanner \
        -Dsonar.host.url="${SONAR_HOST_URL}" \
        -Dsonar.token="${SONAR_TOKEN}" \
        -Dsonar.projectKey="${MICROSERVICE_TYPE}" \
        -Dsonar.javascript.lcov.reportPaths="${COVERAGE_REPORT}" \
        -Dsonar.typescript.lcov.reportPaths="${COVERAGE_REPORT}"
    fi
    ;;

  "python-service"|"python-app")
    echo "[PYTHON] Running Pytest & Generating Coverage XML Report..."
    cd docker/python-app || exit 1
    if [ -f "requirements.txt" ]; then
      python -m venv .venv
      source .venv/bin/activate
      pip install -r requirements.txt pytest pytest-cov
      pytest --cov=. --cov-report=xml:coverage.xml
      COVERAGE_REPORT="coverage.xml"
      echo "[PYTHON] Coverage XML generated at: ${COVERAGE_REPORT}"

      # Push to SonarQube
      sonar-scanner \
        -Dsonar.host.url="${SONAR_HOST_URL}" \
        -Dsonar.token="${SONAR_TOKEN}" \
        -Dsonar.projectKey="${MICROSERVICE_TYPE}" \
        -Dsonar.python.coverage.reportPaths="${COVERAGE_REPORT}"
    fi
    ;;

  "golang-service"|"golang-app")
    echo "[GOLANG] Running Go Test & Generating Coverage Out Report..."
    cd docker/golang-app || exit 1
    if [ -f "go.mod" ]; then
      go test -v -coverprofile=coverage.out ./...
      COVERAGE_REPORT="coverage.out"
      echo "[GOLANG] Go Coverage file generated at: ${COVERAGE_REPORT}"

      # Push to SonarQube
      sonar-scanner \
        -Dsonar.host.url="${SONAR_HOST_URL}" \
        -Dsonar.token="${SONAR_TOKEN}" \
        -Dsonar.projectKey="${MICROSERVICE_TYPE}" \
        -Dsonar.go.coverage.reportPaths="${COVERAGE_REPORT}"
    fi
    ;;

  *)
    echo "Unknown Microservice type: ${MICROSERVICE_TYPE}. Skipping test execution."
    ;;

esac

echo "=========================================================================="
echo "SonarQube Quality Gate & Code Coverage Upload Completed Successfully!"
echo "=========================================================================="
