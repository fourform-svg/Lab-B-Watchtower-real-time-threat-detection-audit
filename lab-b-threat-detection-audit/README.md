# Lab B - Watchtower 
Deploys: VPC, KMS, Aurora PostgreSQL, Kinesis Stream for Activity Streams, GuardDuty RDS Protection, CloudWatch Logs, EventBridge -> SNS Alerts, S3 bucket for Security Lake export
Deploy: terraform init && terraform apply -var="db_password=StrongP@ss123!" -var="soc_email=you@email.com"
Then: aws rds start-activity-stream --resource-arn <cluster-arn-from-output> --mode async --kms-key-id <kms-key-from-output>
Attack Sim: psql -> SELECT * FROM customers; -> check SNS email + CloudWatch + GuardDuty
Independent: YES - no Lab A needed.

Problem: E-commerce company suspects an insider is exfiltrating data. Need real-time audit of every SQL statement and automated alerts for suspicious patterns (e.g., SELECT * on the customers table at 2 AM, login from a new IP).
