# Rol para que Lambda se ejecute en AWS
resource "aws_iam_role" "lambda_exec" {
  name = "lambda-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

# Permiso básico: permite que Lambda escriba logs en CloudWatch
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Permiso adicional: acceso a DynamoDB solo a la tabla
resource "aws_iam_role_policy" "lambda_dynamo" {
  name = "lambda-dynamo-access"
  role = aws_iam_role.lambda_exec.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "dynamodb:PutItem",
        "dynamodb:GetItem"
      ]
      Resource = aws_dynamodb_table.items.arn
    }]
  })
}

# Rol para GitHub Actions (OIDC seguro)
resource "aws_iam_role" "github_deploy" {
  name = "github-deploy-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          "token.actions.githubusercontent.com:sub" = "repo:${var.github_repo}:ref:refs/heads/main"
        }
      }
    }]
  })
}

# Política de deploy con permisos restringidos (least-privilege)
resource "aws_iam_role_policy" "deploy_policy" {
  name = "deploy-policy"
  role = aws_iam_role.github_deploy.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # Lambda
      {
        Effect = "Allow"
        Action = [
          "lambda:CreateFunction",
          "lambda:UpdateFunctionCode",
          "lambda:AddPermission"
        ]
        Resource = aws_lambda_function.api.arn
      },
      # API Gateway
      {
        Effect = "Allow"
        Action = [
          "apigateway:GET",
          "apigateway:POST",
          "apigateway:PUT",
          "apigateway:DELETE"
        ]
        Resource = aws_apigatewayv2_api.http_api.execution_arn
      },
      # PassRole solo al rol de Lambda
      {
        Effect = "Allow"
        Action = ["iam:PassRole"]
        Resource = aws_iam_role.lambda_exec.arn
      },
      # DynamoDB
      {
        Effect = "Allow"
        Action = [
          "dynamodb:CreateTable",
          "dynamodb:DescribeTable",
          "dynamodb:PutItem",
          "dynamodb:GetItem"
        ]
        Resource = [
          aws_dynamodb_table.items.arn,
          "${aws_dynamodb_table.items.arn}/*"
        ]
      },
      # Logs (opcional)
      {
        Effect = "Allow"
        Action = ["logs:DescribeLogGroups"]
        Resource = "*"
      }
    ]
  })
}
