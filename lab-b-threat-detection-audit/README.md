# Lab B - Watchtower (STANDALONE)
Deploys: VPC, KMS, Aurora PostgreSQL, Kinesis Stream for Activity Streams, GuardDuty RDS Protection, CloudWatch Logs, EventBridge -> SNS Alerts, S3 bucket for Security Lake export
Deploy: terraform init && terraform apply -var="db_password=StrongP@ss123!" -var="soc_email=you@email.com"
Then: aws rds start-activity-stream --resource-arn <cluster-arn-from-output> --mode async --kms-key-id <kms-key-from-output>
Attack Sim: psql -> SELECT * FROM customers; -> check SNS email + CloudWatch + GuardDuty
Independent: YES - no Lab A needed.
