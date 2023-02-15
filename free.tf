provider "aws" {
	access_key = 
	secret_key = 
	region     = "us-east-1"
}

data "archive_file" "lambda-dummy" {
  type        = "zip"
  output_path = "${path.module}/dummy.zip"

  source {
    content  = "dummy"
    filename = "dummy.txt"
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_lambda_function" "lambda" {
  filename      = data.archive_file.lambda-dummy.output_path
  function_name = "uploader"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "index.App"

  source_code_hash = data.archive_file.lambda-dummy.output_base64sha256

  runtime = "java11"

  environment {
    variables = {
      foo = "bar"
    }
  }
}