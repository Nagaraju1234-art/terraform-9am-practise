provider "aws" {
    region = "us-west-2"
  
}
# Upload the zip to S3   #first create bucket after that adding remaing code
resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "make-buckettt"
}

  
# Terraform can’t zip files by itself, so we use the archive_file data source.
# Zip lambda_function.py automatically
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda_function.py"
  output_path = "${path.module}/lambda_function.zip"
}
# Upload the zip to S3

  


resource "aws_s3_object" "lambda_code" {
  bucket = aws_s3_bucket.lambda_bucket.id
  key    = "lambda_function.zip"
  source = data.archive_file.lambda_zip.output_path
  etag   = filemd5(data.archive_file.lambda_zip.output_path)
}
# The etag ensures Terraform re-uploads the file if the code changes.
# IAM ROLE
resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_logging" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
# Lambda function from S3
resource "aws_lambda_function" "my_lambda" {
  function_name = "my_lambda_function"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.13"

  # Automatically fetch from S3
  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.lambda_code.key

  # This forces update when code changes
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  timeout     = 300
  memory_size = 128
}
