data "archive_file" "main_lambda_archive" {
  type = "zip"
  source_dir  = "${path.module}/../src"
  output_path = "${path.module}/../src.zip"
}

resource "aws_s3_bucket" "main_lambda_bucket" {
    bucket = "main-lambda-bucket"

}

resource "aws_s3_object" "main" {
  bucket = aws_s3_bucket.main_lambda_bucket.bucket

  key    = "archive.zip"
  source = data.archive_file.main_lambda_archive.output_path

  etag = filemd5(data.archive_file.main_lambda_archive.output_path)
}
