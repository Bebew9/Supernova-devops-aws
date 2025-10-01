resource "aws_lambda_function" "api" {
  filename      = "../app/lambda_function.zip"
  function_name = "devops-test-lambda"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.12"
  source_code_hash = filebase64sha256("../app/lambda_function.zip")
  environment {
    variables = { TABLE_NAME = aws_dynamodb_table.items.name }
  }
}
