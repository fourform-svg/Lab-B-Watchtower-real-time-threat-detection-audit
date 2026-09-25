# Lab B - Watchtower  - Real-Time Threat Detection & Audit

Deploys: VPC, KMS, Aurora PostgreSQL, Kinesis Stream for Activity Streams, GuardDuty RDS Protection, CloudWatch Logs, EventBridge -> SNS Alerts, S3 bucket for Security Lake export
Deploy: terraform init && terraform apply -var="db_password=StrongP@ss123!" -var="soc_email=you@email.com"
Then: aws rds start-activity-stream --resource-arn <cluster-arn-from-output> --mode async --kms-key-id <kms-key-from-output>
Attack Sim: psql -> SELECT * FROM customers; -> check SNS email + CloudWatch + GuardDuty
Independent: YES - no Lab A needed.

PROBLEM: E-commerce company suspects an insider is exfiltrating data. Need real-time audit of every SQL statement and automated alerts for suspicious patterns (e.g., SELECT * on the customers table at 2 AM, login from a new IP).


Design & Plan:

    Enable Database Activity Streams (DAS) on Aurora - Kinesis encrypted with KMS.
    Enable GuardDuty RDS Protection - detects anomalous logins, brute force.
    CloudTrail for the management plane (who modified RDS).
    Flow: DAS -> Kinesis Data Stream -> Kinesis Firehose -> S3 (Security Lake OCSF format) + CloudWatch Logs.
    EventBridge Rules:
    Rule 1: GuardDuty finding severity >7 -> Lambda -> SNS to SOC email.
    Rule 2: DAS event where type=READ and table=customers and rowCount>1000 -> SNS.
    Analytics: Security Lake + OpenSearch dashboard forensics.

Execution Steps:

    Deploy Lab A stack first (secure base).
    Enable aws rds start-activity-stream --mode async --kms-key-id xxx
    Create Kinesis -> Firehose -> Security Lake custom source.
    Lambda alert_handler.py: parses GuardDuty JSON, enriches with user identity, sends to SNS.
    Simulate attack: SELECT * FROM customers; from an unapproved IP, show alert in <2 mins.

 Screenshot of SNS email alert, OpenSearch query | where table = "customers", and Cost analysis attached.

Output /Solution: Built real-time database auditing with Database Activity Streams, GuardDuty RDS Protection, and Security Lake, enabling automated anomaly detection and SOC alerting with < 2 min MTTD.
