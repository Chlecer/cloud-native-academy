# 🔧 AWS Enterprise Architecture - The Foundation

## 🎯 Objective
Master AWS services that power enterprise applications: ECS, EKS, S3, IAM, CloudWatch, and Lambda.

> **"In enterprise DevOps, AWS is not just a cloud provider - it's your infrastructure foundation."**

## 🌟 Why These AWS Services Matter

### Enterprise Requirements
- **High Availability:** 99.99% uptime for business-critical applications
- **Global Scale:** Multi-region deployments for worldwide users
- **Security:** Enterprise-grade access control and compliance
- **Observability:** Real-time monitoring and alerting
- **Cost Optimization:** Efficient resource utilization

## 🚀 AWS ECS - Container Orchestration for Enterprise

### What is ECS?
**Simple explanation:** ECS is AWS's managed container service - like Kubernetes but simpler and AWS-native.

**Enterprise use cases:**
- **Java applications:** Spring Boot microservices
- **.NET applications:** ASP.NET Core APIs
- **Web applications:** React/Angular SPAs
- **Background services:** Data processing, ETL jobs

### Production ECS Setup

```hcl
# ecs-cluster.tf
resource "aws_ecs_cluster" "main" {
  name = "enterprise-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Environment = var.environment
    Team        = "devops"
  }
}

# ECS Service for Java application
resource "aws_ecs_service" "java_app" {
  name            = "java-microservice"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.java_app.arn
  desired_count   = 3

  deployment_configuration {
    maximum_percent         = 200
    minimum_healthy_percent = 100
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.java_app.arn
    container_name   = "java-app"
    container_port   = 8080
  }

  depends_on = [aws_lb_listener.main]
}

# Task definition for Java Spring Boot app
resource "aws_ecs_task_definition" "java_app" {
  family                   = "java-microservice"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 1024
  memory                   = 2048
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn           = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name  = "java-app"
      image = "your-registry/java-microservice:latest"
      
      portMappings = [
        {
          containerPort = 8080
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "SPRING_PROFILES_ACTIVE"
          value = var.environment
        },
        {
          name  = "AWS_REGION"
          value = var.aws_region
        }
      ]

      secrets = [
        {
          name      = "DATABASE_PASSWORD"
          valueFrom = aws_ssm_parameter.db_password.arn
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.java_app.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }

      healthCheck = {
        command = [
          "CMD-SHELL",
          "curl -f http://localhost:8080/actuator/health || exit 1"
        ]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }
    }
  ])
}
```

### ECS with Application Load Balancer

```hcl
# Application Load Balancer
resource "aws_lb" "main" {
  name               = "enterprise-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets           = var.public_subnet_ids

  enable_deletion_protection = true

  tags = {
    Environment = var.environment
  }
}

# Target group for Java application
resource "aws_lb_target_group" "java_app" {
  name     = "java-app-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/actuator/health"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  tags = {
    Environment = var.environment
  }
}

# ALB Listener
resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = var.ssl_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.java_app.arn
  }
}
```

## ☸️ AWS EKS - Kubernetes for Enterprise

### When to Use EKS vs ECS
```
Use EKS when:
✅ Complex microservices architecture
✅ Need Kubernetes ecosystem tools
✅ Multi-cloud strategy
✅ Advanced networking requirements

Use ECS when:
✅ AWS-native applications
✅ Simpler container orchestration
✅ Cost optimization priority
✅ Less operational overhead
```

### Production EKS Cluster

```hcl
# EKS Cluster
resource "aws_eks_cluster" "main" {
  name     = "enterprise-eks"
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = "1.28"

  vpc_config {
    subnet_ids              = concat(var.private_subnet_ids, var.public_subnet_ids)
    endpoint_private_access = true
    endpoint_public_access  = true
    public_access_cidrs     = ["0.0.0.0/0"]
  }

  encryption_config {
    provider {
      key_arn = aws_kms_key.eks.arn
    }
    resources = ["secrets"]
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_AmazonEKSClusterPolicy,
  ]

  tags = {
    Environment = var.environment
  }
}

# EKS Node Group
resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "enterprise-nodes"
  node_role_arn   = aws_iam_role.eks_node_group_role.arn
  subnet_ids      = var.private_subnet_ids

  scaling_config {
    desired_size = 3
    max_size     = 10
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  instance_types = ["t3.large"]
  capacity_type  = "ON_DEMAND"

  remote_access {
    ec2_ssh_key = var.key_pair_name
    source_security_group_ids = [aws_security_group.eks_nodes.id]
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_node_group_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks_node_group_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.eks_node_group_AmazonEC2ContainerRegistryReadOnly,
  ]

  tags = {
    Environment = var.environment
  }
}
```

## 🗄️ AWS S3 - Global Content Delivery

### Enterprise S3 Configuration

```hcl
# S3 bucket for application assets
resource "aws_s3_bucket" "app_assets" {
  bucket = "enterprise-app-assets-${random_id.bucket_suffix.hex}"

  tags = {
    Environment = var.environment
    Purpose     = "application-assets"
  }
}

# S3 bucket versioning
resource "aws_s3_bucket_versioning" "app_assets" {
  bucket = aws_s3_bucket.app_assets.id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 bucket encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "app_assets" {
  bucket = aws_s3_bucket.app_assets.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.s3.arn
      sse_algorithm     = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

# S3 bucket public access block
resource "aws_s3_bucket_public_access_block" "app_assets" {
  bucket = aws_s3_bucket.app_assets.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# CloudFront distribution for global delivery
resource "aws_cloudfront_distribution" "app_assets" {
  origin {
    domain_name = aws_s3_bucket.app_assets.bucket_regional_domain_name
    origin_id   = "S3-${aws_s3_bucket.app_assets.id}"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.app_assets.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${aws_s3_bucket.app_assets.id}"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Environment = var.environment
  }
}
```

## 🔐 AWS IAM - Enterprise Security

### IAM Roles and Policies

```hcl
# ECS Task Execution Role
resource "aws_iam_role" "ecs_execution_role" {
  name = "ecs-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

# Attach AWS managed policy
resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Custom policy for accessing SSM parameters
resource "aws_iam_role_policy" "ecs_ssm_policy" {
  name = "ecs-ssm-policy"
  role = aws_iam_role.ecs_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameters",
          "ssm:GetParameter",
          "ssm:GetParametersByPath"
        ]
        Resource = [
          "arn:aws:ssm:${var.aws_region}:${data.aws_caller_identity.current.account_id}:parameter/app/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt"
        ]
        Resource = [
          aws_kms_key.ssm.arn
        ]
      }
    ]
  })
}

# ECS Task Role (for application permissions)
resource "aws_iam_role" "ecs_task_role" {
  name = "ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

# Custom policy for application S3 access
resource "aws_iam_role_policy" "ecs_s3_policy" {
  name = "ecs-s3-policy"
  role = aws_iam_role.ecs_task_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = [
          "${aws_s3_bucket.app_assets.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.app_assets.arn
        ]
      }
    ]
  })
}
```

## 📊 AWS CloudWatch - Enterprise Monitoring

### CloudWatch Configuration

```hcl
# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "java_app" {
  name              = "/ecs/java-microservice"
  retention_in_days = 30

  tags = {
    Environment = var.environment
    Application = "java-microservice"
  }
}

# CloudWatch Alarms
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "java-app-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors ECS CPU utilization"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    ServiceName = aws_ecs_service.java_app.name
    ClusterName = aws_ecs_cluster.main.name
  }

  tags = {
    Environment = var.environment
  }
}

resource "aws_cloudwatch_metric_alarm" "high_memory" {
  alarm_name          = "java-app-high-memory"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = "85"
  alarm_description   = "This metric monitors ECS memory utilization"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    ServiceName = aws_ecs_service.java_app.name
    ClusterName = aws_ecs_cluster.main.name
  }

  tags = {
    Environment = var.environment
  }
}

# SNS Topic for alerts
resource "aws_sns_topic" "alerts" {
  name = "enterprise-alerts"

  tags = {
    Environment = var.environment
  }
}
```

## ⚡ AWS Lambda - Serverless Automation

### Lambda Functions for DevOps Automation

```python
# lambda/auto_scaling.py
import json
import boto3
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    """
    Auto-scaling function triggered by CloudWatch alarms
    """
    ecs_client = boto3.client('ecs')
    
    try:
        # Parse CloudWatch alarm
        message = json.loads(event['Records'][0]['Sns']['Message'])
        alarm_name = message['AlarmName']
        new_state = message['NewStateValue']
        
        if 'high-cpu' in alarm_name and new_state == 'ALARM':
            # Scale up ECS service
            response = ecs_client.update_service(
                cluster='enterprise-cluster',
                service='java-microservice',
                desiredCount=5
            )
            logger.info(f"Scaled up service: {response}")
            
        elif 'high-cpu' in alarm_name and new_state == 'OK':
            # Scale down ECS service
            response = ecs_client.update_service(
                cluster='enterprise-cluster',
                service='java-microservice',
                desiredCount=3
            )
            logger.info(f"Scaled down service: {response}")
            
        return {
            'statusCode': 200,
            'body': json.dumps('Auto-scaling completed successfully')
        }
        
    except Exception as e:
        logger.error(f"Error in auto-scaling: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps(f'Error: {str(e)}')
        }
```

```hcl
# Lambda function for auto-scaling
resource "aws_lambda_function" "auto_scaling" {
  filename         = "auto_scaling.zip"
  function_name    = "enterprise-auto-scaling"
  role            = aws_iam_role.lambda_role.arn
  handler         = "auto_scaling.lambda_handler"
  source_code_hash = data.archive_file.auto_scaling_zip.output_base64sha256
  runtime         = "python3.9"
  timeout         = 60

  environment {
    variables = {
      CLUSTER_NAME = aws_ecs_cluster.main.name
    }
  }

  tags = {
    Environment = var.environment
  }
}

# Lambda permission for SNS
resource "aws_lambda_permission" "allow_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.auto_scaling.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.alerts.arn
}

# SNS subscription to Lambda
resource "aws_sns_topic_subscription" "lambda" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.auto_scaling.arn
}
```

## 🎓 What You Mastered

### AWS Enterprise Skills
- ✅ **ECS/Fargate** - Managed container orchestration
- ✅ **EKS** - Enterprise Kubernetes service
- ✅ **S3 + CloudFront** - Global content delivery
- ✅ **IAM** - Enterprise security and access control
- ✅ **CloudWatch** - Comprehensive monitoring and alerting
- ✅ **Lambda** - Serverless automation and scaling

### Real-World Applications
- 🏢 **Java/.NET applications** on ECS with auto-scaling
- ☸️ **Kubernetes workloads** on EKS with enterprise security
- 🌍 **Global content delivery** with S3 and CloudFront
- 🔐 **Enterprise security** with IAM roles and policies
- 📊 **Production monitoring** with CloudWatch and SNS
- ⚡ **Automation** with Lambda functions

### Career Impact
- 💼 **AWS Solutions Architect:** $120k-$180k
- 💼 **Senior DevOps Engineer:** $110k-$170k
- 💼 **Cloud Infrastructure Engineer:** $100k-$160k

---

**Next:** [Terraform Enterprise Patterns](../02-terraform-enterprise/) - Infrastructure as Code mastery!