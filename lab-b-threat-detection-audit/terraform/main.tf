
provider "aws" { region = var.region }
resource "aws_vpc" "main" { cidr_block = "10.1.0.0/16" tags={Name="lab-b-vpc"} }
resource "aws_subnet" "private_a" { vpc_id=aws_vpc.main.id cidr_block="10.1.2.0/24" availability_zone="${var.region}a" }
resource "aws_subnet" "private_b" { vpc_id=aws_vpc.main.id cidr_block="10.1.3.0/24" availability_zone="${var.region}b" }
resource "aws_kms_key" "rds" { description="Lab B CMK" enable_key_rotation=true }
resource "aws_kms_alias" "rds" { name="alias/rds/lab-b-secure" target_key_id=aws_kms_key.rds.id }
resource "aws_security_group" "db" { vpc_id=aws_vpc.main.id name="lab-b-db-sg" ingress { from_port=5432 to_port=5432 protocol="tcp" cidr_blocks=["10.1.0.0/16"] } egress { from_port=0 to_port=0 protocol="-1" cidr_blocks=["0.0.0.0/0"] } }
resource "aws_db_subnet_group" "main" { name="lab-b-subnet-group" subnet_ids=[aws_subnet.private_a.id, aws_subnet.private_b.id] }
resource "aws_rds_cluster" "aurora" { cluster_identifier="lab-b-aurora" engine="aurora-postgresql" engine_version="15.4" master_username="dbadmin" master_password=var.db_password database_name="labbdb" db_subnet_group_name=aws_db_subnet_group.main.name vpc_security_group_ids=[aws_security_group.db.id] storage_encrypted=true kms_key_id=aws_kms_key.rds.id skip_final_snapshot=true enabled_cloudwatch_logs_exports=["postgresql"] }
resource "aws_rds_cluster_instance" "inst" { count=1 identifier="lab-b-aurora-0" cluster_identifier=aws_rds_cluster.aurora.id instance_class="db.t3.medium" engine=aws_rds_cluster.aurora.engine publicly_accessible=false performance_insights_enabled=true }

resource "aws_kinesis_stream" "das" { name="lab-b-activity-stream" shard_count=1 encryption_type="KMS" kms_key_id=aws_kms_key.rds.id }
resource "aws_s3_bucket" "security_lake" { bucket="lab-b-security-lake-${random_id.s.hex}" }
resource "random_id" "s" { byte_length=4 }
resource "aws_cloudwatch_log_group" "rds_audit" { name="/aws/rds/cluster/lab-b-aurora/audit" retention_in_days=7 }
resource "aws_guardduty_detector" "main" { enable=true }
resource "aws_guardduty_detector_feature" "rds_login" { detector_id=aws_guardduty_detector.main.id name="RDS_LOGIN_EVENTS" status="ENABLED" }
resource "aws_sns_topic" "soc_alerts" { name="lab-b-soc-alerts" }
resource "aws_sns_topic_subscription" "email" { topic_arn=aws_sns_topic.soc_alerts.arn protocol="email" endpoint=var.soc_email }
resource "aws_cloudwatch_event_rule" "guardduty" { name="lab-b-guardduty-finding" event_pattern=jsonencode({source=["aws.guardduty"], detail={resourceType=["RDSDB"]}}) }
resource "aws_cloudwatch_event_target" "sns" { rule=aws_cloudwatch_event_rule.guardduty.name arn=aws_sns_topic.soc_alerts.arn }
resource "aws_iam_role" "eventbridge_sns" { name="lab-b-eventbridge-sns-role" assume_role_policy=jsonencode({Version="2012-10-17", Statement=[{Effect="Allow", Principal={Service="events.amazonaws.com"}, Action="sts:AssumeRole"}]}) }

output "cluster_arn" { value=aws_rds_cluster.aurora.arn }
output "kms_key_id" { value=aws_kms_key.rds.id }
output "kinesis_stream_name" { value=aws_kinesis_stream.das.name }
