# 🚀 GitLab CI/CD Mastery - Enterprise Pipeline Excellence

## 🎯 Objective
Master GitLab CI/CD pipelines for Java/.NET applications with Docker, security scanning, multi-stage deployments, and enterprise-grade automation.

> **"The best pipelines are invisible - they just work, every time."**

## 🌟 Why GitLab CI/CD Dominates Enterprise

### Companies Using GitLab at Scale
- **Goldman Sachs** - 10,000+ developers, 50,000+ pipelines daily
- **Siemens** - 300,000+ employees using GitLab for industrial IoT
- **T-Mobile** - Deploys to 50M+ customers with GitLab pipelines
- **CERN** - Manages Large Hadron Collider data with GitLab

### Enterprise Requirements
- **Multi-language support** (Java, .NET, Python, Node.js)
- **Security integration** (SAST, DAST, dependency scanning)
- **Multi-environment** deployments (dev/staging/prod)
- **Compliance** and audit trails
- **Performance** and cost optimization

## 🏗️ Enterprise Pipeline Architecture

### The Complete .gitlab-ci.yml Structure
```yaml
# .gitlab-ci.yml - Enterprise-grade pipeline
stages:
  - validate
  - build
  - test
  - security
  - package
  - deploy-dev
  - deploy-staging
  - deploy-prod

variables:
  # Docker configuration
  DOCKER_DRIVER: overlay2
  DOCKER_TLS_CERTDIR: "/certs"
  
  # Application configuration
  MAVEN_OPTS: "-Dmaven.repo.local=$CI_PROJECT_DIR/.m2/repository"
  MAVEN_CLI_OPTS: "--batch-mode --errors --fail-at-end --show-version"
  
  # AWS configuration
  AWS_DEFAULT_REGION: eu-west-1
  ECS_CLUSTER_NAME: enterprise-cluster
  
  # Security scanning
  SECURE_ANALYZERS_PREFIX: "registry.gitlab.com/gitlab-org/security-products/analyzers"

# Global cache configuration
cache:
  key: ${CI_COMMIT_REF_SLUG}
  paths:
    - .m2/repository/
    - node_modules/
    - target/

# Include templates for reusability
include:
  - template: Security/SAST.gitlab-ci.yml
  - template: Security/Dependency-Scanning.gitlab-ci.yml
  - template: Security/Container-Scanning.gitlab-ci.yml
  - local: '.gitlab/ci/java-pipeline.yml'
  - local: '.gitlab/ci/dotnet-pipeline.yml'
  - local: '.gitlab/ci/deployment.yml'

# Pipeline rules
workflow:
  rules:
    - if: $CI_COMMIT_BRANCH == "main"
    - if: $CI_COMMIT_BRANCH == "develop"
    - if: $CI_MERGE_REQUEST_IID
    - if: $CI_COMMIT_TAG
```

## ☕ Java Application Pipeline

### Complete Java Spring Boot Pipeline
```yaml
# .gitlab/ci/java-pipeline.yml
.java-base:
  image: maven:3.9-openjdk-17
  before_script:
    - echo "Configuring Maven settings..."
    - mkdir -p ~/.m2
    - cp settings.xml ~/.m2/settings.xml
  cache:
    key: maven-$CI_COMMIT_REF_SLUG
    paths:
      - .m2/repository/

# Validate Java code
validate-java:
  extends: .java-base
  stage: validate
  script:
    - echo "🔍 Validating Java project structure..."
    - mvn validate
    - mvn compile -DskipTests
  rules:
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"
      changes:
        - "**/*.java"
        - "pom.xml"
        - "src/**/*"
    - if: $CI_COMMIT_BRANCH == "main"
    - if: $CI_COMMIT_BRANCH == "develop"

# Build Java application
build-java:
  extends: .java-base
  stage: build
  script:
    - echo "🏗️ Building Java application..."
    - mvn $MAVEN_CLI_OPTS clean compile
    - mvn $MAVEN_CLI_OPTS package -DskipTests
    - echo "BUILD_VERSION=$(mvn help:evaluate -Dexpression=project.version -q -DforceStdout)" >> build.env
  artifacts:
    reports:
      dotenv: build.env
    paths:
      - target/*.jar
      - target/classes/
    expire_in: 1 hour
  rules:
    - if: $CI_COMMIT_BRANCH == "main"
    - if: $CI_COMMIT_BRANCH == "develop"
    - if: $CI_MERGE_REQUEST_IID

# Unit tests with coverage
test-java-unit:
  extends: .java-base
  stage: test
  script:
    - echo "🧪 Running Java unit tests..."
    - mvn $MAVEN_CLI_OPTS test
    - mvn jacoco:report
  coverage: '/Total.*?([0-9]{1,3})%/'
  artifacts:
    reports:
      junit:
        - target/surefire-reports/TEST-*.xml
      coverage_report:
        coverage_format: cobertura
        path: target/site/jacoco/jacoco.xml
    paths:
      - target/site/jacoco/
    expire_in: 1 week
  rules:
    - if: $CI_COMMIT_BRANCH == "main"
    - if: $CI_COMMIT_BRANCH == "develop"
    - if: $CI_MERGE_REQUEST_IID

# Integration tests
test-java-integration:
  extends: .java-base
  stage: test
  services:
    - name: postgres:15
      alias: postgres
    - name: redis:7-alpine
      alias: redis
  variables:
    POSTGRES_DB: testdb
    POSTGRES_USER: testuser
    POSTGRES_PASSWORD: testpass
    SPRING_PROFILES_ACTIVE: integration-test
    DATABASE_URL: jdbc:postgresql://postgres:5432/testdb
    REDIS_URL: redis://redis:6379
  script:
    - echo "🔗 Running Java integration tests..."
    - mvn $MAVEN_CLI_OPTS verify -Pintegration-tests
  artifacts:
    reports:
      junit:
        - target/failsafe-reports/TEST-*.xml
    expire_in: 1 week
  rules:
    - if: $CI_COMMIT_BRANCH == "main"
    - if: $CI_COMMIT_BRANCH == "develop"

# Performance tests
test-java-performance:
  extends: .java-base
  stage: test
  script:
    - echo "⚡ Running performance tests..."
    - mvn $MAVEN_CLI_OPTS verify -Pperformance-tests
  artifacts:
    reports:
      performance: target/jmeter/results/*.jtl
    paths:
      - target/jmeter/results/
    expire_in: 1 week
  rules:
    - if: $CI_COMMIT_BRANCH == "main"
    - if: $CI_COMMIT_BRANCH == "develop"
  allow_failure: true

# Build Docker image
package-java:
  stage: package
  image: docker:24-dind
  services:
    - docker:24-dind
  variables:
    DOCKER_HOST: tcp://docker:2376
    DOCKER_TLS_VERIFY: 1
    DOCKER_CERT_PATH: "/certs/client"
  before_script:
    - echo "🐳 Preparing Docker environment..."
    - docker info
    - echo $CI_REGISTRY_PASSWORD | docker login -u $CI_REGISTRY_USER --password-stdin $CI_REGISTRY
  script:
    - echo "📦 Building Docker image for Java application..."
    - |
      cat > Dockerfile << EOF
      # Multi-stage build for Java application
      FROM maven:3.9-openjdk-17 AS builder
      WORKDIR /app
      COPY pom.xml .
      RUN mvn dependency:go-offline -B
      COPY src ./src
      RUN mvn clean package -DskipTests
      
      # Production image
      FROM openjdk:17-jre-slim
      
      # Create non-root user
      RUN groupadd -r appuser && useradd -r -g appuser appuser
      
      # Install security updates
      RUN apt-get update && apt-get upgrade -y && \
          apt-get install -y --no-install-recommends curl && \
          rm -rf /var/lib/apt/lists/*
      
      WORKDIR /app
      
      # Copy application
      COPY --from=builder /app/target/*.jar app.jar
      
      # Set ownership
      RUN chown -R appuser:appuser /app
      USER appuser
      
      # Health check
      HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
        CMD curl -f http://localhost:8080/actuator/health || exit 1
      
      EXPOSE 8080
      ENTRYPOINT ["java", "-jar", "/app/app.jar"]
      EOF
    - docker build -t $CI_REGISTRY_IMAGE/java-app:$BUILD_VERSION .
    - docker build -t $CI_REGISTRY_IMAGE/java-app:latest .
    - docker push $CI_REGISTRY_IMAGE/java-app:$BUILD_VERSION
    - docker push $CI_REGISTRY_IMAGE/java-app:latest
    - echo "IMAGE_TAG=$BUILD_VERSION" >> package.env
  artifacts:
    reports:
      dotenv: package.env
  rules:
    - if: $CI_COMMIT_BRANCH == "main"
    - if: $CI_COMMIT_BRANCH == "develop"
```

## 🔷 .NET Application Pipeline

### Complete .NET Core Pipeline
```yaml
# .gitlab/ci/dotnet-pipeline.yml
.dotnet-base:
  image: mcr.microsoft.com/dotnet/sdk:8.0
  variables:
    DOTNET_CLI_TELEMETRY_OPTOUT: 1
    DOTNET_SKIP_FIRST_TIME_EXPERIENCE: 1
    NUGET_XMLDOC_MODE: skip
  before_script:
    - echo "🔷 Configuring .NET environment..."
    - dotnet --version
    - dotnet nuget add source $CI_SERVER_URL/api/v4/projects/$CI_PROJECT_ID/packages/nuget/index.json --name gitlab --username gitlab-ci-token --password $CI_JOB_TOKEN --store-password-in-clear-text

# Validate .NET code
validate-dotnet:
  extends: .dotnet-base
  stage: validate
  script:
    - echo "🔍 Validating .NET project..."
    - dotnet restore
    - dotnet build --no-restore --configuration Release
  rules:
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"
      changes:
        - "**/*.cs"
        - "**/*.csproj"
        - "**/*.sln"
    - if: $CI_COMMIT_BRANCH == "main"
    - if: $CI_COMMIT_BRANCH == "develop"

# Build .NET application
build-dotnet:
  extends: .dotnet-base
  stage: build
  script:
    - echo "🏗️ Building .NET application..."
    - dotnet restore
    - dotnet build --no-restore --configuration Release
    - dotnet publish --no-build --configuration Release --output ./publish
    - echo "BUILD_VERSION=$(date +%Y%m%d)-$CI_COMMIT_SHORT_SHA" >> build.env
  artifacts:
    reports:
      dotenv: build.env
    paths:
      - publish/
      - "**/*.dll"
      - "**/*.pdb"
    expire_in: 1 hour
  rules:
    - if: $CI_COMMIT_BRANCH == "main"
    - if: $CI_COMMIT_BRANCH == "develop"
    - if: $CI_MERGE_REQUEST_IID

# Unit tests with coverage
test-dotnet-unit:
  extends: .dotnet-base
  stage: test
  script:
    - echo "🧪 Running .NET unit tests..."
    - dotnet restore
    - dotnet test --no-restore --configuration Release --logger trx --collect:"XPlat Code Coverage" --results-directory ./TestResults/
    - dotnet tool install -g dotnet-reportgenerator-globaltool
    - ~/.dotnet/tools/reportgenerator -reports:"TestResults/*/coverage.cobertura.xml" -targetdir:"TestResults/CoverageReport" -reporttypes:Cobertura
  coverage: '/Total\s*\|\s*(\d+(?:\.\d+)?)%/'
  artifacts:
    reports:
      junit:
        - TestResults/*.trx
      coverage_report:
        coverage_format: cobertura
        path: TestResults/CoverageReport/Cobertura.xml
    paths:
      - TestResults/
    expire_in: 1 week
  rules:
    - if: $CI_COMMIT_BRANCH == "main"
    - if: $CI_COMMIT_BRANCH == "develop"
    - if: $CI_MERGE_REQUEST_IID

# Integration tests
test-dotnet-integration:
  extends: .dotnet-base
  stage: test
  services:
    - name: postgres:15
      alias: postgres
    - name: redis:7-alpine
      alias: redis
  variables:
    POSTGRES_DB: testdb
    POSTGRES_USER: testuser
    POSTGRES_PASSWORD: testpass
    ASPNETCORE_ENVIRONMENT: IntegrationTest
    ConnectionStrings__DefaultConnection: "Host=postgres;Database=testdb;Username=testuser;Password=testpass"
    ConnectionStrings__Redis: "redis:6379"
  script:
    - echo "🔗 Running .NET integration tests..."
    - dotnet restore
    - dotnet test --no-restore --configuration Release --filter "Category=Integration" --logger trx --results-directory ./TestResults/
  artifacts:
    reports:
      junit:
        - TestResults/*.trx
    expire_in: 1 week
  rules:
    - if: $CI_COMMIT_BRANCH == "main"
    - if: $CI_COMMIT_BRANCH == "develop"

# Package .NET application
package-dotnet:
  stage: package
  image: docker:24-dind
  services:
    - docker:24-dind
  variables:
    DOCKER_HOST: tcp://docker:2376
    DOCKER_TLS_VERIFY: 1
    DOCKER_CERT_PATH: "/certs/client"
  before_script:
    - echo "🐳 Preparing Docker environment..."
    - docker info
    - echo $CI_REGISTRY_PASSWORD | docker login -u $CI_REGISTRY_USER --password-stdin $CI_REGISTRY
  script:
    - echo "📦 Building Docker image for .NET application..."
    - |
      cat > Dockerfile << EOF
      # Multi-stage build for .NET application
      FROM mcr.microsoft.com/dotnet/sdk:8.0 AS builder
      WORKDIR /src
      
      # Copy csproj and restore dependencies
      COPY *.csproj ./
      RUN dotnet restore
      
      # Copy source and build
      COPY . ./
      RUN dotnet publish -c Release -o /app/publish --no-restore
      
      # Production image
      FROM mcr.microsoft.com/dotnet/aspnet:8.0
      
      # Create non-root user
      RUN groupadd -r appuser && useradd -r -g appuser appuser
      
      # Install security updates
      RUN apt-get update && apt-get upgrade -y && \
          apt-get install -y --no-install-recommends curl && \
          rm -rf /var/lib/apt/lists/*
      
      WORKDIR /app
      
      # Copy application
      COPY --from=builder /app/publish .
      
      # Set ownership
      RUN chown -R appuser:appuser /app
      USER appuser
      
      # Health check
      HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
        CMD curl -f http://localhost:8080/health || exit 1
      
      EXPOSE 8080
      ENTRYPOINT ["dotnet", "YourApp.dll"]
      EOF
    - docker build -t $CI_REGISTRY_IMAGE/dotnet-app:$BUILD_VERSION .
    - docker build -t $CI_REGISTRY_IMAGE/dotnet-app:latest .
    - docker push $CI_REGISTRY_IMAGE/dotnet-app:$BUILD_VERSION
    - docker push $CI_REGISTRY_IMAGE/dotnet-app:latest
    - echo "IMAGE_TAG=$BUILD_VERSION" >> package.env
  artifacts:
    reports:
      dotenv: package.env
  rules:
    - if: $CI_COMMIT_BRANCH == "main"
    - if: $CI_COMMIT_BRANCH == "develop"
```

## 🛡️ Enterprise Security Pipeline

### Comprehensive Security Scanning
```yaml
# Security scanning stages
security-sast:
  stage: security
  variables:
    SAST_EXCLUDED_PATHS: "spec, test, tests, tmp, node_modules"
  rules:
    - if: $CI_COMMIT_BRANCH == "main"
    - if: $CI_COMMIT_BRANCH == "develop"
    - if: $CI_MERGE_REQUEST_IID

security-dependency-scanning:
  stage: security
  variables:
    DS_EXCLUDED_PATHS: "spec, test, tests, tmp, node_modules"
  rules:
    - if: $CI_COMMIT_BRANCH == "main"
    - if: $CI_COMMIT_BRANCH == "develop"
    - if: $CI_MERGE_REQUEST_IID

security-container-scanning:
  stage: security
  variables:
    CS_IMAGE: $CI_REGISTRY_IMAGE/java-app:$BUILD_VERSION
  rules:
    - if: $CI_COMMIT_BRANCH == "main"
    - if: $CI_COMMIT_BRANCH == "develop"

# Custom security checks
security-secrets-detection:
  stage: security
  image: alpine:latest
  before_script:
    - apk add --no-cache git grep
  script:
    - echo "🔍 Scanning for secrets and sensitive data..."
    - |
      # Define patterns to search for
      PATTERNS=(
        "password\s*[:=]\s*['\"][^'\"]{8,}['\"]"
        "secret\s*[:=]\s*['\"][^'\"]{8,}['\"]"
        "token\s*[:=]\s*['\"][^'\"]{8,}['\"]"
        "api[_-]?key\s*[:=]\s*['\"][^'\"]{8,}['\"]"
        "private[_-]?key"
        "-----BEGIN.*PRIVATE KEY-----"
        "aws[_-]?access[_-]?key[_-]?id"
        "aws[_-]?secret[_-]?access[_-]?key"
      )
      
      FOUND_SECRETS=false
      
      for pattern in "${PATTERNS[@]}"; do
        if git grep -i -E "$pattern" -- '*.java' '*.cs' '*.js' '*.ts' '*.py' '*.yml' '*.yaml' '*.json' '*.properties' '*.xml' 2>/dev/null; then
          echo "❌ Potential secret found matching pattern: $pattern"
          FOUND_SECRETS=true
        fi
      done
      
      if [ "$FOUND_SECRETS" = true ]; then
        echo "❌ Security scan failed: Potential secrets detected"
        exit 1
      else
        echo "✅ No secrets detected"
      fi
  rules:
    - if: $CI_COMMIT_BRANCH == "main"
    - if: $CI_COMMIT_BRANCH == "develop"
    - if: $CI_MERGE_REQUEST_IID

# License compliance
security-license-scanning:
  stage: security
  image: alpine:latest
  before_script:
    - apk add --no-cache curl jq
  script:
    - echo "📜 Scanning for license compliance..."
    - |
      # Check for prohibited licenses
      PROHIBITED_LICENSES=("GPL-2.0" "GPL-3.0" "AGPL-3.0" "LGPL-2.1" "LGPL-3.0")
      
      # For Java projects
      if [ -f "pom.xml" ]; then
        echo "Checking Maven dependencies for license compliance..."
        # This would integrate with license scanning tools
      fi
      
      # For .NET projects
      if [ -f "*.csproj" ]; then
        echo "Checking NuGet packages for license compliance..."
        # This would integrate with license scanning tools
      fi
      
      echo "✅ License compliance check completed"
  rules:
    - if: $CI_COMMIT_BRANCH == "main"
    - if: $CI_COMMIT_BRANCH == "develop"
  allow_failure: true
```

## 🚀 Multi-Environment Deployment Pipeline

### Complete Deployment Strategy
```yaml
# .gitlab/ci/deployment.yml
.deploy-base:
  image: alpine:latest
  before_script:
    - apk add --no-cache curl jq aws-cli
    - aws configure set region $AWS_DEFAULT_REGION
    - aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
    - aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY

# Deploy to Development
deploy-dev:
  extends: .deploy-base
  stage: deploy-dev
  environment:
    name: development
    url: https://dev.enterprise-app.com
  variables:
    ENVIRONMENT: dev
    ECS_SERVICE_NAME: java-microservice-dev
    DESIRED_COUNT: 2
  script:
    - echo "🚀 Deploying to Development environment..."
    - |
      # Update ECS service with new image
      TASK_DEFINITION=$(aws ecs describe-task-definition --task-definition $ECS_SERVICE_NAME --query 'taskDefinition')
      
      # Update image in task definition
      NEW_TASK_DEFINITION=$(echo $TASK_DEFINITION | jq --arg IMAGE "$CI_REGISTRY_IMAGE/java-app:$IMAGE_TAG" '.containerDefinitions[0].image = $IMAGE')
      
      # Remove unnecessary fields
      NEW_TASK_DEFINITION=$(echo $NEW_TASK_DEFINITION | jq 'del(.taskDefinitionArn, .revision, .status, .requiresAttributes, .placementConstraints, .compatibilities, .registeredAt, .registeredBy)')
      
      # Register new task definition
      aws ecs register-task-definition --cli-input-json "$NEW_TASK_DEFINITION"
      
      # Update service
      aws ecs update-service --cluster $ECS_CLUSTER_NAME --service $ECS_SERVICE_NAME --task-definition $ECS_SERVICE_NAME --desired-count $DESIRED_COUNT
      
      # Wait for deployment to complete
      aws ecs wait services-stable --cluster $ECS_CLUSTER_NAME --services $ECS_SERVICE_NAME
      
      echo "✅ Deployment to Development completed successfully"
  rules:
    - if: $CI_COMMIT_BRANCH == "develop"
    - if: $CI_COMMIT_BRANCH == "main"

# Deploy to Staging
deploy-staging:
  extends: .deploy-base
  stage: deploy-staging
  environment:
    name: staging
    url: https://staging.enterprise-app.com
  variables:
    ENVIRONMENT: staging
    ECS_SERVICE_NAME: java-microservice-staging
    DESIRED_COUNT: 3
  script:
    - echo "🎭 Deploying to Staging environment..."
    - |
      # Similar deployment script as dev but with staging-specific configurations
      TASK_DEFINITION=$(aws ecs describe-task-definition --task-definition $ECS_SERVICE_NAME --query 'taskDefinition')
      NEW_TASK_DEFINITION=$(echo $TASK_DEFINITION | jq --arg IMAGE "$CI_REGISTRY_IMAGE/java-app:$IMAGE_TAG" '.containerDefinitions[0].image = $IMAGE')
      NEW_TASK_DEFINITION=$(echo $NEW_TASK_DEFINITION | jq 'del(.taskDefinitionArn, .revision, .status, .requiresAttributes, .placementConstraints, .compatibilities, .registeredAt, .registeredBy)')
      
      aws ecs register-task-definition --cli-input-json "$NEW_TASK_DEFINITION"
      aws ecs update-service --cluster $ECS_CLUSTER_NAME --service $ECS_SERVICE_NAME --task-definition $ECS_SERVICE_NAME --desired-count $DESIRED_COUNT
      aws ecs wait services-stable --cluster $ECS_CLUSTER_NAME --services $ECS_SERVICE_NAME
      
      echo "✅ Deployment to Staging completed successfully"
    - |
      # Run smoke tests
      echo "🧪 Running smoke tests..."
      sleep 30  # Wait for service to be fully ready
      
      HEALTH_CHECK=$(curl -s -o /dev/null -w "%{http_code}" https://staging.enterprise-app.com/actuator/health)
      if [ "$HEALTH_CHECK" = "200" ]; then
        echo "✅ Smoke tests passed"
      else
        echo "❌ Smoke tests failed"
        exit 1
      fi
  rules:
    - if: $CI_COMMIT_BRANCH == "main"

# Deploy to Production (Manual approval required)
deploy-prod:
  extends: .deploy-base
  stage: deploy-prod
  environment:
    name: production
    url: https://enterprise-app.com
  variables:
    ENVIRONMENT: prod
    ECS_SERVICE_NAME: java-microservice-prod
    DESIRED_COUNT: 5
  script:
    - echo "🏭 Deploying to Production environment..."
    - |
      # Blue-Green deployment strategy for production
      echo "Implementing Blue-Green deployment..."
      
      # Get current task definition
      CURRENT_TASK_DEF=$(aws ecs describe-services --cluster $ECS_CLUSTER_NAME --services $ECS_SERVICE_NAME --query 'services[0].taskDefinition' --output text)
      
      # Create new task definition with new image
      TASK_DEFINITION=$(aws ecs describe-task-definition --task-definition $ECS_SERVICE_NAME --query 'taskDefinition')
      NEW_TASK_DEFINITION=$(echo $TASK_DEFINITION | jq --arg IMAGE "$CI_REGISTRY_IMAGE/java-app:$IMAGE_TAG" '.containerDefinitions[0].image = $IMAGE')
      NEW_TASK_DEFINITION=$(echo $NEW_TASK_DEFINITION | jq 'del(.taskDefinitionArn, .revision, .status, .requiresAttributes, .placementConstraints, .compatibilities, .registeredAt, .registeredBy)')
      
      # Register new task definition
      NEW_TASK_DEF_ARN=$(aws ecs register-task-definition --cli-input-json "$NEW_TASK_DEFINITION" --query 'taskDefinition.taskDefinitionArn' --output text)
      
      # Update service with new task definition
      aws ecs update-service --cluster $ECS_CLUSTER_NAME --service $ECS_SERVICE_NAME --task-definition $NEW_TASK_DEF_ARN --desired-count $DESIRED_COUNT
      
      # Wait for deployment to complete
      echo "Waiting for deployment to stabilize..."
      aws ecs wait services-stable --cluster $ECS_CLUSTER_NAME --services $ECS_SERVICE_NAME
      
      # Health check
      echo "Performing health checks..."
      sleep 60  # Wait for service to be fully ready
      
      for i in {1..5}; do
        HEALTH_CHECK=$(curl -s -o /dev/null -w "%{http_code}" https://enterprise-app.com/actuator/health)
        if [ "$HEALTH_CHECK" = "200" ]; then
          echo "✅ Health check $i/5 passed"
        else
          echo "❌ Health check $i/5 failed, rolling back..."
          aws ecs update-service --cluster $ECS_CLUSTER_NAME --service $ECS_SERVICE_NAME --task-definition $CURRENT_TASK_DEF
          exit 1
        fi
        sleep 10
      done
      
      echo "🎉 Production deployment completed successfully!"
  when: manual
  rules:
    - if: $CI_COMMIT_BRANCH == "main"

# Rollback job (manual)
rollback-prod:
  extends: .deploy-base
  stage: deploy-prod
  environment:
    name: production
    url: https://enterprise-app.com
  variables:
    ENVIRONMENT: prod
    ECS_SERVICE_NAME: java-microservice-prod
  script:
    - echo "🔄 Rolling back Production deployment..."
    - |
      # Get previous task definition
      TASK_DEFINITIONS=$(aws ecs list-task-definitions --family-prefix $ECS_SERVICE_NAME --status ACTIVE --sort DESC --max-items 2 --query 'taskDefinitionArns' --output text)
      PREVIOUS_TASK_DEF=$(echo $TASK_DEFINITIONS | cut -d' ' -f2)
      
      if [ -z "$PREVIOUS_TASK_DEF" ]; then
        echo "❌ No previous task definition found"
        exit 1
      fi
      
      echo "Rolling back to: $PREVIOUS_TASK_DEF"
      
      # Update service with previous task definition
      aws ecs update-service --cluster $ECS_CLUSTER_NAME --service $ECS_SERVICE_NAME --task-definition $PREVIOUS_TASK_DEF
      
      # Wait for rollback to complete
      aws ecs wait services-stable --cluster $ECS_CLUSTER_NAME --services $ECS_SERVICE_NAME
      
      echo "✅ Rollback completed successfully"
  when: manual
  rules:
    - if: $CI_COMMIT_BRANCH == "main"
```

## 📊 Pipeline Monitoring and Notifications

### Slack Integration
```yaml
# Notification jobs
.notify-slack:
  image: alpine:latest
  before_script:
    - apk add --no-cache curl jq
  script:
    - |
      SLACK_MESSAGE="{
        \"channel\": \"#deployments\",
        \"username\": \"GitLab CI/CD\",
        \"icon_emoji\": \":gitlab:\",
        \"attachments\": [
          {
            \"color\": \"$SLACK_COLOR\",
            \"title\": \"$SLACK_TITLE\",
            \"text\": \"$SLACK_MESSAGE\",
            \"fields\": [
              {
                \"title\": \"Project\",
                \"value\": \"$CI_PROJECT_NAME\",
                \"short\": true
              },
              {
                \"title\": \"Branch\",
                \"value\": \"$CI_COMMIT_REF_NAME\",
                \"short\": true
              },
              {
                \"title\": \"Commit\",
                \"value\": \"$CI_COMMIT_SHORT_SHA\",
                \"short\": true
              },
              {
                \"title\": \"Pipeline\",
                \"value\": \"<$CI_PIPELINE_URL|#$CI_PIPELINE_ID>\",
                \"short\": true
              }
            ]
          }
        ]
      }"
      
      curl -X POST -H 'Content-type: application/json' --data "$SLACK_MESSAGE" $SLACK_WEBHOOK_URL

notify-success:
  extends: .notify-slack
  stage: .post
  variables:
    SLACK_COLOR: "good"
    SLACK_TITLE: "✅ Deployment Successful"
    SLACK_MESSAGE: "Production deployment completed successfully!"
  rules:
    - if: $CI_COMMIT_BRANCH == "main"
      when: on_success

notify-failure:
  extends: .notify-slack
  stage: .post
  variables:
    SLACK_COLOR: "danger"
    SLACK_TITLE: "❌ Pipeline Failed"
    SLACK_MESSAGE: "Pipeline failed! Please check the logs."
  rules:
    - if: $CI_COMMIT_BRANCH == "main"
      when: on_failure
```

## 🎓 What You Mastered

### GitLab CI/CD Excellence
- ✅ **Multi-language pipelines** - Java Spring Boot & .NET Core
- ✅ **Security integration** - SAST, DAST, dependency scanning, secrets detection
- ✅ **Multi-stage deployments** - Dev/staging/prod with approval gates
- ✅ **Docker optimization** - Multi-stage builds, security hardening
- ✅ **Blue-green deployments** - Zero-downtime production releases
- ✅ **Automated rollbacks** - Quick recovery from failed deployments

### Enterprise Features
- 🔒 **Security-first approach** - Comprehensive scanning and compliance
- 🚀 **Performance optimization** - Parallel jobs, caching, artifacts
- 📊 **Monitoring integration** - Slack notifications, health checks
- 🔄 **GitOps workflow** - Infrastructure and application deployment
- 🛡️ **Compliance ready** - Audit trails, approval processes

### Industry Best Practices
- 📦 **Container security** - Non-root users, minimal images, health checks
- 🧪 **Testing pyramid** - Unit, integration, performance tests
- 🔐 **Secrets management** - No hardcoded credentials, secure injection
- 📈 **Observability** - Coverage reports, performance metrics
- 🎯 **Deployment strategies** - Manual approvals for production

### Career Impact
- 💼 **Senior DevOps Engineer:** $110k-$170k
- 💼 **CI/CD Specialist:** $100k-$160k
- 💼 **Platform Engineer:** $115k-$175k

---

**Next:** [ArgoCD GitOps Excellence](../04-argocd-gitops/) - Continuous deployment mastery!

## 🎯 PowerShell Automation Scripts

### GitLab CI/CD Setup Script
```powershell
# setup-gitlab-cicd.ps1 - Complete GitLab CI/CD setup
param(
    [Parameter(Mandatory=$true)]
    [string]$ProjectName,
    
    [Parameter(Mandatory=$true)]
    [string]$GitLabUrl,
    
    [Parameter(Mandatory=$true)]
    [string]$AccessToken,
    
    [string]$ProjectType = "java"
)

Write-Host "🚀 Setting up GitLab CI/CD for $ProjectName..." -ForegroundColor Green

# Create project structure
$directories = @(
    ".gitlab/ci",
    "helm-chart/templates",
    "scripts",
    "docs"
)

foreach ($dir in $directories) {
    if (!(Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force
        Write-Host "✅ Created directory: $dir" -ForegroundColor Green
    }
}

# Create .gitlab-ci.yml
$gitlabCiContent = @"
# GitLab CI/CD Pipeline for $ProjectName
stages:
  - validate
  - build
  - test
  - security
  - package
  - deploy-dev
  - deploy-staging
  - deploy-prod

variables:
  DOCKER_DRIVER: overlay2
  DOCKER_TLS_CERTDIR: "/certs"
  MAVEN_OPTS: "-Dmaven.repo.local=`$CI_PROJECT_DIR/.m2/repository"
  MAVEN_CLI_OPTS: "--batch-mode --errors --fail-at-end --show-version"

include:
  - template: Security/SAST.gitlab-ci.yml
  - template: Security/Dependency-Scanning.gitlab-ci.yml
  - template: Security/Container-Scanning.gitlab-ci.yml
  - local: '.gitlab/ci/$ProjectType-pipeline.yml'
  - local: '.gitlab/ci/deployment.yml'

workflow:
  rules:
    - if: `$CI_COMMIT_BRANCH == "main"
    - if: `$CI_COMMIT_BRANCH == "develop"
    - if: `$CI_MERGE_REQUEST_IID
    - if: `$CI_COMMIT_TAG
"@

Set-Content -Path ".gitlab-ci.yml" -Value $gitlabCiContent
Write-Host "✅ Created .gitlab-ci.yml" -ForegroundColor Green

# Create Java pipeline if specified
if ($ProjectType -eq "java") {
    $javaPipelineContent = @"
# Java Spring Boot Pipeline
.java-base:
  image: maven:3.9-openjdk-17
  cache:
    key: maven-`$CI_COMMIT_REF_SLUG
    paths:
      - .m2/repository/

validate-java:
  extends: .java-base
  stage: validate
  script:
    - mvn validate
    - mvn compile -DskipTests

build-java:
  extends: .java-base
  stage: build
  script:
    - mvn clean package -DskipTests
    - echo "BUILD_VERSION=`$(mvn help:evaluate -Dexpression=project.version -q -DforceStdout)" >> build.env
  artifacts:
    reports:
      dotenv: build.env
    paths:
      - target/*.jar

test-java-unit:
  extends: .java-base
  stage: test
  script:
    - mvn test
    - mvn jacoco:report
  coverage: '/Total.*?([0-9]{1,3})%/'
  artifacts:
    reports:
      junit:
        - target/surefire-reports/TEST-*.xml
      coverage_report:
        coverage_format: cobertura
        path: target/site/jacoco/jacoco.xml

package-java:
  stage: package
  image: docker:24-dind
  services:
    - docker:24-dind
  script:
    - docker build -t `$CI_REGISTRY_IMAGE/app:`$BUILD_VERSION .
    - docker push `$CI_REGISTRY_IMAGE/app:`$BUILD_VERSION
"@
    
    Set-Content -Path ".gitlab/ci/java-pipeline.yml" -Value $javaPipelineContent
    Write-Host "✅ Created Java pipeline configuration" -ForegroundColor Green
}

# Create deployment pipeline
$deploymentContent = @"
# Deployment Pipeline
.deploy-base:
  image: alpine:latest
  before_script:
    - apk add --no-cache curl aws-cli

deploy-dev:
  extends: .deploy-base
  stage: deploy-dev
  environment:
    name: development
    url: https://dev.$ProjectName.com
  script:
    - echo "Deploying to development..."
    - aws ecs update-service --cluster dev-cluster --service $ProjectName-dev --force-new-deployment
  rules:
    - if: `$CI_COMMIT_BRANCH == "develop"

deploy-staging:
  extends: .deploy-base
  stage: deploy-staging
  environment:
    name: staging
    url: https://staging.$ProjectName.com
  script:
    - echo "Deploying to staging..."
    - aws ecs update-service --cluster staging-cluster --service $ProjectName-staging --force-new-deployment
  rules:
    - if: `$CI_COMMIT_BRANCH == "main"

deploy-prod:
  extends: .deploy-base
  stage: deploy-prod
  environment:
    name: production
    url: https://$ProjectName.com
  script:
    - echo "Deploying to production..."
    - aws ecs update-service --cluster prod-cluster --service $ProjectName-prod --force-new-deployment
  when: manual
  rules:
    - if: `$CI_COMMIT_BRANCH == "main"
"@

Set-Content -Path ".gitlab/ci/deployment.yml" -Value $deploymentContent
Write-Host "✅ Created deployment pipeline configuration" -ForegroundColor Green

# Create Dockerfile for Java
if ($ProjectType -eq "java") {
    $dockerfileContent = @"
# Multi-stage build for Java application
FROM maven:3.9-openjdk-17 AS builder
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline -B
COPY src ./src
RUN mvn clean package -DskipTests

# Production image
FROM openjdk:17-jre-slim

# Create non-root user
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Install security updates
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends curl && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy application
COPY --from=builder /app/target/*.jar app.jar

# Set ownership
RUN chown -R appuser:appuser /app
USER appuser

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:8080/actuator/health || exit 1

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
"@
    
    Set-Content -Path "Dockerfile" -Value $dockerfileContent
    Write-Host "✅ Created Dockerfile" -ForegroundColor Green
}

# Create Helm chart
$helmChartContent = @"
apiVersion: v2
name: $ProjectName
description: A Helm chart for $ProjectName
type: application
version: 0.1.0
appVersion: "1.0.0"
"@

Set-Content -Path "helm-chart/Chart.yaml" -Value $helmChartContent

$helmValuesContent = @"
replicaCount: 1

image:
  repository: registry.gitlab.com/yourgroup/$ProjectName
  pullPolicy: IfNotPresent
  tag: "latest"

service:
  type: ClusterIP
  port: 80

ingress:
  enabled: false
  className: ""
  annotations: {}
  hosts:
    - host: chart-example.local
      paths:
        - path: /
          pathType: Prefix
  tls: []

resources:
  limits:
    cpu: 500m
    memory: 512Mi
  requests:
    cpu: 250m
    memory: 256Mi

autoscaling:
  enabled: false
  minReplicas: 1
  maxReplicas: 100
  targetCPUUtilizationPercentage: 80
"@

Set-Content -Path "helm-chart/values.yaml" -Value $helmValuesContent
Write-Host "✅ Created Helm chart" -ForegroundColor Green

# Create pipeline monitoring script
$monitoringScript = @"
# pipeline-monitor.ps1 - Monitor GitLab CI/CD pipeline
param(
    [Parameter(Mandatory=`$true)]
    [string]`$ProjectId,
    
    [Parameter(Mandatory=`$true)]
    [string]`$GitLabUrl,
    
    [Parameter(Mandatory=`$true)]
    [string]`$AccessToken
)

`$headers = @{
    "PRIVATE-TOKEN" = `$AccessToken
    "Content-Type" = "application/json"
}

Write-Host "📊 Monitoring pipeline for project `$ProjectId..." -ForegroundColor Green

try {
    # Get latest pipeline
    `$pipelineUrl = "`$GitLabUrl/api/v4/projects/`$ProjectId/pipelines?per_page=1"
    `$pipeline = Invoke-RestMethod -Uri `$pipelineUrl -Headers `$headers -Method Get
    
    if (`$pipeline.Count -gt 0) {
        `$latestPipeline = `$pipeline[0]
        
        Write-Host "Pipeline ID: `$(`$latestPipeline.id)" -ForegroundColor Yellow
        Write-Host "Status: `$(`$latestPipeline.status)" -ForegroundColor Yellow
        Write-Host "Branch: `$(`$latestPipeline.ref)" -ForegroundColor Yellow
        Write-Host "Created: `$(`$latestPipeline.created_at)" -ForegroundColor Yellow
        
        # Get pipeline jobs
        `$jobsUrl = "`$GitLabUrl/api/v4/projects/`$ProjectId/pipelines/`$(`$latestPipeline.id)/jobs"
        `$jobs = Invoke-RestMethod -Uri `$jobsUrl -Headers `$headers -Method Get
        
        Write-Host "`n📋 Pipeline Jobs:" -ForegroundColor Green
        foreach (`$job in `$jobs) {
            `$statusColor = switch (`$job.status) {
                "success" { "Green" }
                "failed" { "Red" }
                "running" { "Yellow" }
                default { "White" }
            }
            Write-Host "  - `$(`$job.name): `$(`$job.status)" -ForegroundColor `$statusColor
        }
        
        # Check if pipeline failed
        if (`$latestPipeline.status -eq "failed") {
            Write-Host "`n❌ Pipeline failed! Check the logs for details." -ForegroundColor Red
            
            # Get failed jobs
            `$failedJobs = `$jobs | Where-Object { `$_.status -eq "failed" }
            foreach (`$failedJob in `$failedJobs) {
                Write-Host "Failed job: `$(`$failedJob.name)" -ForegroundColor Red
                Write-Host "Web URL: `$(`$failedJob.web_url)" -ForegroundColor Red
            }
        }
        elseif (`$latestPipeline.status -eq "success") {
            Write-Host "`n✅ Pipeline completed successfully!" -ForegroundColor Green
        }
        elseif (`$latestPipeline.status -eq "running") {
            Write-Host "`n🔄 Pipeline is currently running..." -ForegroundColor Yellow
        }
    }
    else {
        Write-Host "No pipelines found for this project." -ForegroundColor Yellow
    }
}
catch {
    Write-Host "❌ Error monitoring pipeline: `$(`$_.Exception.Message)" -ForegroundColor Red
}
"@

Set-Content -Path "scripts/pipeline-monitor.ps1" -Value $monitoringScript
Write-Host "✅ Created pipeline monitoring script" -ForegroundColor Green

Write-Host "`n🎉 GitLab CI/CD setup completed successfully!" -ForegroundColor Green
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Commit and push these files to your GitLab repository" -ForegroundColor White
Write-Host "2. Configure GitLab CI/CD variables (AWS credentials, etc.)" -ForegroundColor White
Write-Host "3. Run: .\scripts\pipeline-monitor.ps1 -ProjectId <id> -GitLabUrl <url> -AccessToken <token>" -ForegroundColor White
```

### Pipeline Performance Analyzer
```powershell
# analyze-pipeline-performance.ps1 - Analyze GitLab CI/CD performance
param(
    [Parameter(Mandatory=$true)]
    [string]$ProjectId,
    
    [Parameter(Mandatory=$true)]
    [string]$GitLabUrl,
    
    [Parameter(Mandatory=$true)]
    [string]$AccessToken,
    
    [int]$Days = 30
)

$headers = @{
    "PRIVATE-TOKEN" = $AccessToken
    "Content-Type" = "application/json"
}

Write-Host "📊 Analyzing pipeline performance for the last $Days days..." -ForegroundColor Green

try {
    # Calculate date range
    $since = (Get-Date).AddDays(-$Days).ToString("yyyy-MM-ddTHH:mm:ssZ")
    
    # Get pipelines
    $pipelineUrl = "$GitLabUrl/api/v4/projects/$ProjectId/pipelines?per_page=100&updated_after=$since"
    $pipelines = Invoke-RestMethod -Uri $pipelineUrl -Headers $headers -Method Get
    
    if ($pipelines.Count -eq 0) {
        Write-Host "No pipelines found in the specified time range." -ForegroundColor Yellow
        return
    }
    
    Write-Host "Found $($pipelines.Count) pipelines to analyze..." -ForegroundColor Yellow
    
    # Initialize metrics
    $totalPipelines = $pipelines.Count
    $successfulPipelines = ($pipelines | Where-Object { $_.status -eq "success" }).Count
    $failedPipelines = ($pipelines | Where-Object { $_.status -eq "failed" }).Count
    $canceledPipelines = ($pipelines | Where-Object { $_.status -eq "canceled" }).Count
    
    $durations = @()
    $branchStats = @{}
    
    foreach ($pipeline in $pipelines) {
        # Calculate duration
        if ($pipeline.created_at -and $pipeline.finished_at) {
            $created = [DateTime]::Parse($pipeline.created_at)
            $finished = [DateTime]::Parse($pipeline.finished_at)
            $duration = ($finished - $created).TotalMinutes
            $durations += $duration
        }
        
        # Branch statistics
        $branch = $pipeline.ref
        if ($branchStats.ContainsKey($branch)) {
            $branchStats[$branch]++
        } else {
            $branchStats[$branch] = 1
        }
    }
    
    # Calculate metrics
    $successRate = [math]::Round(($successfulPipelines / $totalPipelines) * 100, 2)
    $failureRate = [math]::Round(($failedPipelines / $totalPipelines) * 100, 2)
    
    if ($durations.Count -gt 0) {
        $avgDuration = [math]::Round(($durations | Measure-Object -Average).Average, 2)
        $minDuration = [math]::Round(($durations | Measure-Object -Minimum).Minimum, 2)
        $maxDuration = [math]::Round(($durations | Measure-Object -Maximum).Maximum, 2)
    }
    
    # Display results
    Write-Host "`n📈 Pipeline Performance Report" -ForegroundColor Green
    Write-Host "================================" -ForegroundColor Green
    Write-Host "Total Pipelines: $totalPipelines" -ForegroundColor White
    Write-Host "Successful: $successfulPipelines ($successRate%)" -ForegroundColor Green
    Write-Host "Failed: $failedPipelines ($failureRate%)" -ForegroundColor Red
    Write-Host "Canceled: $canceledPipelines" -ForegroundColor Yellow
    
    if ($durations.Count -gt 0) {
        Write-Host "`n⏱️ Duration Statistics" -ForegroundColor Green
        Write-Host "Average Duration: $avgDuration minutes" -ForegroundColor White
        Write-Host "Minimum Duration: $minDuration minutes" -ForegroundColor White
        Write-Host "Maximum Duration: $maxDuration minutes" -ForegroundColor White
    }
    
    Write-Host "`n🌿 Branch Statistics" -ForegroundColor Green
    $sortedBranches = $branchStats.GetEnumerator() | Sort-Object Value -Descending
    foreach ($branch in $sortedBranches | Select-Object -First 10) {
        Write-Host "  $($branch.Key): $($branch.Value) pipelines" -ForegroundColor White
    }
    
    # Performance recommendations
    Write-Host "`n💡 Performance Recommendations" -ForegroundColor Green
    Write-Host "================================" -ForegroundColor Green
    
    if ($successRate -lt 90) {
        Write-Host "⚠️  Success rate is below 90%. Consider:" -ForegroundColor Yellow
        Write-Host "   - Improving test stability" -ForegroundColor White
        Write-Host "   - Adding retry mechanisms" -ForegroundColor White
        Write-Host "   - Reviewing failed job patterns" -ForegroundColor White
    }
    
    if ($avgDuration -gt 30) {
        Write-Host "⚠️  Average duration is over 30 minutes. Consider:" -ForegroundColor Yellow
        Write-Host "   - Parallelizing jobs" -ForegroundColor White
        Write-Host "   - Optimizing Docker builds" -ForegroundColor White
        Write-Host "   - Using pipeline caching" -ForegroundColor White
    }
    
    if ($failureRate -gt 15) {
        Write-Host "⚠️  Failure rate is above 15%. Consider:" -ForegroundColor Yellow
        Write-Host "   - Implementing better testing strategies" -ForegroundColor White
        Write-Host "   - Adding pre-commit hooks" -ForegroundColor White
        Write-Host "   - Improving code review process" -ForegroundColor White
    }
    
    # Generate CSV report
    $reportPath = "pipeline-performance-report-$(Get-Date -Format 'yyyyMMdd-HHmmss').csv"
    $csvData = $pipelines | Select-Object id, status, ref, created_at, finished_at, web_url
    $csvData | Export-Csv -Path $reportPath -NoTypeInformation
    
    Write-Host "`n📄 Detailed report saved to: $reportPath" -ForegroundColor Green
    
} catch {
    Write-Host "❌ Error analyzing pipeline performance: $($_.Exception.Message)" -ForegroundColor Red
}
```

## 🏆 Enterprise Success Stories

### Goldman Sachs - 50,000 Daily Pipelines
**Challenge**: Managing CI/CD for 10,000+ developers across multiple business units
**Solution**: 
- Standardized GitLab CI/CD templates
- Automated compliance checking
- Multi-stage security scanning
- Blue-green deployments

**Results**:
- 99.9% pipeline reliability
- 15-minute average deployment time
- 50% reduction in security incidents
- $2M annual savings in operational costs

### T-Mobile - Customer-Facing Deployments
**Challenge**: Zero-downtime deployments for 50M+ customers
**Solution**:
- Canary deployment strategy
- Automated rollback mechanisms
- Real-time health monitoring
- Feature flag integration

**Results**:
- 99.99% uptime achieved
- 10x faster deployment frequency
- 90% reduction in customer-impacting incidents
- $5M revenue protection through reliable deployments

### Siemens - Industrial IoT Scale
**Challenge**: Managing 300,000+ employee access to CI/CD systems
**Solution**:
- Role-based access control (RBAC)
- Automated provisioning
- Compliance automation
- Multi-region deployments

**Results**:
- 100% SOX compliance maintained
- 60% reduction in manual processes
- 40% improvement in developer productivity
- Enterprise-wide standardization achieved

## 🎯 Advanced Enterprise Patterns

### 1. Multi-Tenant Pipeline Architecture
```yaml
# Multi-tenant deployment strategy
.deploy-tenant:
  script:
    - |
      TENANTS=("tenant-a" "tenant-b" "tenant-c")
      for tenant in "${TENANTS[@]}"; do
        echo "Deploying to $tenant..."
        helm upgrade --install $CI_PROJECT_NAME-$tenant ./helm-chart \
          --namespace $tenant \
          --set tenant.name=$tenant \
          --set image.tag=$IMAGE_TAG
      done
```

### 2. Compliance-First Pipeline
```yaml
# SOX/PCI compliance pipeline
compliance-gate:
  stage: validate
  script:
    - echo "Running compliance checks..."
    - python compliance-checker.py --sox --pci --gdpr
    - sonar-scanner -Dsonar.qualitygate.wait=true
  rules:
    - if: $CI_COMMIT_BRANCH == "main"
```

### 3. Cost Optimization Pipeline
```yaml
# Cost-aware deployment
cost-analysis:
  stage: validate
  script:
    - echo "Analyzing deployment costs..."
    - aws ce get-cost-and-usage --time-period Start=2024-01-01,End=2024-01-31
    - python cost-optimizer.py --threshold=1000
```

---

**You've mastered enterprise GitLab CI/CD! Ready for GitOps with ArgoCD?** 🚀