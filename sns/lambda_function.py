import boto3
import os

REGION = os.environ.get("AWS_REGION", "eu-west-1")
CUSTOMER = os.environ["CUSTOMER"]
ENV = os.environ["ENV"]
SNS_TOPIC_ARN_INFRA = os.environ.get("SNS_TOPIC_ARN_INFRA")
SNS_TOPIC_ARN_PERFORMANCE = os.environ.get("SNS_TOPIC_ARN_PERFORMANCE")
SNS_TOPIC_ARN_SUPPORT = os.environ.get("SNS_TOPIC_ARN_SUPPORT")
SNS_TOPIC_ARN_TIER1 = os.environ.get("SNS_TOPIC_ARN_TIER1")
SNS_TOPIC_ARN_LEADS = os.environ.get("SNS_TOPIC_ARN_LEADS")

cw = boto3.client("cloudwatch", region_name=REGION)
ec2 = boto3.client("ec2", region_name=REGION)
rds = boto3.client("rds", region_name=REGION)
efs = boto3.client("efs", region_name=REGION)
elbv2 = boto3.client("elbv2", region_name=REGION)
acm = boto3.client("acm", region_name=REGION)


def get_tag(tags, key, default):
    for t in tags or []:
        if t["Key"] == key:
            return t["Value"]
    return default


def get_sns_topics():
    topics = [
        SNS_TOPIC_ARN_INFRA,
        SNS_TOPIC_ARN_PERFORMANCE,
        SNS_TOPIC_ARN_SUPPORT,
        SNS_TOPIC_ARN_TIER1,
        SNS_TOPIC_ARN_LEADS
    ]
    return [t for t in topics if t][:5]


def log_alarm(name):
    print(f"CREATED/UPDATED → {name}")


def get_ec2_instances():
    instances = []
    paginator = ec2.get_paginator("describe_instances")
    for page in paginator.paginate():
        for r in page["Reservations"]:
            for i in r["Instances"]:
                instances.append({
                    "id": i["InstanceId"],
                    "name": get_tag(i.get("Tags"), "Name", i["InstanceId"])
                })
    return instances


def create_ec2_alarm(inst, metric, threshold, severity, unit, sns_topics):
    alarm_name = f"{CUSTOMER}_{severity}_{ENV}_EC2_{metric}_ABOVE_{threshold}{unit}_{inst['name']}"
    METRIC_MAP = {
        "CPU": ("AWS/EC2", "CPUUtilization"),
        "MEM": ("CWAgent", "MemoryUtilization"),
        "DiskReadOps": ("AWS/EC2", "DiskReadOps"),
        "DiskWriteOps": ("AWS/EC2", "DiskWriteOps"),
        "DiskReadBytes": ("AWS/EC2", "DiskReadBytes"),
        "DiskWriteBytes": ("AWS/EC2", "DiskWriteBytes"),
        "NetworkIn": ("AWS/EC2", "NetworkIn"),
        "NetworkOut": ("AWS/EC2", "NetworkOut"),
        "SwapUsage": ("CWAgent", "SwapUsage"),
        "DiskSpaceUtilization": ("CWAgent", "DiskSpaceUtilization"),
        "DiskInodesUtilization": ("CWAgent", "DiskInodesUtilization"),
        "StatusCheckFailed": ("AWS/EC2", "StatusCheckFailed")
    }
    namespace, metric_name = METRIC_MAP[metric]
    cw.put_metric_alarm(
        AlarmName=alarm_name,
        AlarmDescription=f"EC2 {inst['name']} {metric} above {threshold}{unit}",
        Namespace=namespace,
        MetricName=metric_name,
        Statistic="Average",
        Period=60,
        EvaluationPeriods=2,
        Threshold=threshold,
        ComparisonOperator="GreaterThanThreshold",
        Dimensions=[{"Name": "InstanceId", "Value": inst["id"]}],
        AlarmActions=sns_topics,
        OKActions=sns_topics,
        TreatMissingData="notBreaching"
    )
    log_alarm(alarm_name)


def create_ec2_status_check(inst, sns_topics):
    alarm_name = f"{CUSTOMER}_CRT_{ENV}_EC2_STATUSCHECK_FAILED_{inst['name']}"
    cw.put_metric_alarm(
        AlarmName=alarm_name,
        Namespace="AWS/EC2",
        MetricName="StatusCheckFailed",
        Statistic="Maximum",
        Period=60,
        EvaluationPeriods=2,
        Threshold=1,
        ComparisonOperator="GreaterThanOrEqualToThreshold",
        Dimensions=[{"Name": "InstanceId", "Value": inst["id"]}],
        AlarmActions=sns_topics,
        OKActions=sns_topics,
        TreatMissingData="notBreaching"
    )
    log_alarm(alarm_name)


def create_rds_alarm(db, metric, threshold, severity, comparison, unit, sns_topics):
    alarm_name = f"{CUSTOMER}_{severity}_{ENV}_RDS_{metric}_ABOVE_{threshold}{unit}_{db['DBInstanceIdentifier']}"
    metric_name = "CPUUtilization" if metric == "CPU" else "FreeableMemory"
    cw.put_metric_alarm(
        AlarmName=alarm_name,
        AlarmDescription=f"RDS {db['DBInstanceIdentifier']} {metric} threshold breached",
        Namespace="AWS/RDS",
        MetricName=metric_name,
        Statistic="Average",
        Period=60,
        EvaluationPeriods=2,
        Threshold=threshold,
        ComparisonOperator=comparison,
        Dimensions=[{"Name": "DBInstanceIdentifier", "Value": db["DBInstanceIdentifier"]}],
        AlarmActions=sns_topics,
        OKActions=sns_topics,
        TreatMissingData="notBreaching"
    )
    log_alarm(alarm_name)


def create_rds_swap_low_alarm(db, gb, severity, sns_topics):
    threshold_bytes = gb * 1024 * 1024 * 1024
    alarm_name = f"{CUSTOMER}_{severity}_{ENV}_RDS_SWAP_BELOW_{gb}GB_{db['DBInstanceIdentifier']}"
    cw.put_metric_alarm(
        AlarmName=alarm_name,
        AlarmDescription=f"RDS swap below {gb}GB",
        Namespace="AWS/RDS",
        MetricName="SwapUsage",
        Statistic="Average",
        Period=60,
        EvaluationPeriods=2,
        Threshold=threshold_bytes,
        ComparisonOperator="LessThanThreshold",
        Dimensions=[{"Name": "DBInstanceIdentifier", "Value": db["DBInstanceIdentifier"]}],
        AlarmActions=sns_topics,
        OKActions=sns_topics,
        TreatMissingData="notBreaching"
    )
    log_alarm(alarm_name)


def get_efs_name(fs_id):
    tags = efs.describe_tags(FileSystemId=fs_id)["Tags"]
    for t in tags:
        if t["Key"] == "Name":
            return t["Value"]
    return fs_id


def create_efs_alarm(fs, threshold, severity, sns_topics):
    fs_name = get_efs_name(fs["FileSystemId"])
    alarm_name = f"{CUSTOMER}_{severity}_EFS_IOP_ABOVE_{threshold}%_{fs_name}"
    cw.put_metric_alarm(
        AlarmName=alarm_name,
        AlarmDescription=f"EFS {fs_name} IOP above {threshold}%",
        Namespace="AWS/EFS",
        MetricName="PercentIOLimit",
        Statistic="Average",
        Period=300,
        EvaluationPeriods=2,
        Threshold=threshold,
        ComparisonOperator="GreaterThanThreshold",
        Dimensions=[{"Name": "FileSystemId", "Value": fs["FileSystemId"]}],
        AlarmActions=sns_topics,
        OKActions=sns_topics,
        TreatMissingData="notBreaching"
    )
    log_alarm(alarm_name)


def get_load_balancers():
    lbs = []
    paginator = elbv2.get_paginator("describe_load_balancers")
    for page in paginator.paginate():
        lbs.extend(page["LoadBalancers"])
    return lbs


def create_elb_alarm(lb, metric, threshold, severity, comparison, unit, statistic, sns_topics):
    lb_name = lb["LoadBalancerName"]
    lb_arn_suffix = lb["LoadBalancerArn"].split("loadbalancer/")[1]
    METRIC_MAP = {
        "HealthyHostCount": "HealthyHostCount",
        "UnHealthyHostCount": "UnHealthyHostCount",
        "HTTPCode_ELB_5XX_Count": "HTTPCode_ELB_5XX_Count",
        "HTTPCode_ELB_4XX_Count": "HTTPCode_ELB_4XX_Count",
        "TargetResponseTime": "TargetResponseTime",
        "ActiveConnectionCount": "ActiveConnectionCount"
    }
    alarm_name = f"{CUSTOMER}_{severity}_{ENV}_ELB_{metric}_{lb_name}"
    cw.put_metric_alarm(
        AlarmName=alarm_name,
        Namespace="AWS/ApplicationELB",
        MetricName=METRIC_MAP[metric],
        Statistic=statistic,
        Period=60,
        EvaluationPeriods=2,
        Threshold=threshold,
        ComparisonOperator=comparison,
        Dimensions=[{"Name": "LoadBalancer", "Value": lb_arn_suffix}],
        AlarmActions=sns_topics,
        OKActions=sns_topics,
        TreatMissingData="notBreaching"
    )
    log_alarm(alarm_name)


def create_acm_alarm(cert_arn, cert_name, threshold_days, severity, sns_topics):
    alarm_name = f"{CUSTOMER}_{severity}_{ENV}_ACM_EXPIRY_{cert_name}"
    cw.put_metric_alarm(
        AlarmName=alarm_name,
        Namespace="AWS/CertificateManager",
        MetricName="DaysToExpiry",
        Statistic="Minimum",
        Period=86400,
        EvaluationPeriods=1,
        Threshold=threshold_days,
        ComparisonOperator="LessThanOrEqualToThreshold",
        Dimensions=[{"Name": "CertificateArn", "Value": cert_arn}],
        AlarmActions=sns_topics,
        OKActions=sns_topics,
        TreatMissingData="notBreaching"
    )
    log_alarm(alarm_name)


def lambda_handler(event, context):
    sns_topics = get_sns_topics()
    if not sns_topics:
        raise ValueError("SNS topic ARNs not configured")

    ec2_count = rds_count = swap_count = efs_count = elb_count = acm_count = 0

    try:
        for inst in get_ec2_instances():
            metrics = ["CPU", "CPU", "MEM", "MEM", "DiskReadOps", "DiskWriteOps", "NetworkIn", "NetworkOut",
                       "SwapUsage", "DiskSpaceUtilization", "DiskInodesUtilization"]
            thresholds = [70, 90, 80, 90, 3000, 3000, 100000000, 100000000, 1024, 80, 80]
            severity = ["WRN", "CRT", "WRN", "CRT", "WRN", "WRN", "WRN", "WRN", "WRN", "WRN", "WRN"]
            unit = ["%", "%", "%", "%", "IOPS", "IOPS", "B", "B", "MB", "%", "%"]
            for i, m in enumerate(metrics):
                create_ec2_alarm(inst, m, thresholds[i], severity[i], unit[i], sns_topics)
                ec2_count += 1
            create_ec2_status_check(inst, sns_topics)
            ec2_count += 1

        for db in rds.describe_db_instances()["DBInstances"]:
            create_rds_alarm(db, "CPU", 70, "WRN", "GreaterThanThreshold", "%", sns_topics)
            rds_count += 1
            create_rds_alarm(db, "CPU", 90, "CRT", "GreaterThanThreshold", "%", sns_topics)
            rds_count += 1
            create_rds_alarm(db, "MEM", 80, "WRN", "LessThanThreshold", "%", sns_topics)
            rds_count += 1
            create_rds_alarm(db, "MEM", 90, "CRT", "LessThanThreshold", "%", sns_topics)
            rds_count += 1
            create_rds_swap_low_alarm(db, 5, "WRN", sns_topics)
            swap_count += 1
            create_rds_swap_low_alarm(db, 3, "CRT", sns_topics)
            swap_count += 1

        for fs in efs.describe_file_systems()["FileSystems"]:
            create_efs_alarm(fs, 40, "WRN", sns_topics)
            efs_count += 1
            create_efs_alarm(fs, 60, "CRT", sns_topics)
            efs_count += 1

        for lb in get_load_balancers():
            create_elb_alarm(lb, "HealthyHostCount", 1, "CRT", "LessThanThreshold", "", "Minimum", sns_topics)
            elb_count += 1
            create_elb_alarm(lb, "UnHealthyHostCount", 1, "WRN", "GreaterThanOrEqualToThreshold", "", "Maximum", sns_topics)
            elb_count += 1

        for cert in acm.list_certificates(CertificateStatuses=["ISSUED"])["CertificateSummaryList"]:
            create_acm_alarm(cert["CertificateArn"], cert["DomainName"], 30, "CRT", sns_topics)
            acm_count += 1

    except Exception as e:
        print(f"ERROR: {str(e)}")
        raise

    total = ec2_count + rds_count + swap_count + efs_count + elb_count + acm_count

    print(f"SUMMARY → EC2:{ec2_count} RDS:{rds_count} SWAP:{swap_count} EFS:{efs_count} ELB:{elb_count} ACM:{acm_count} TOTAL:{total}")

    return {
        "statusCode": 200,
        "status": "SUCCESS",
        "ec2": ec2_count,
        "rds": rds_count,
        "swap": swap_count,
        "efs": efs_count,
        "elb": elb_count,
        "acm": acm_count,
        "total": total
    }
