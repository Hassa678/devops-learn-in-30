from diagrams import Diagram, Cluster, Edge
from diagrams.aws.compute import ECS
from diagrams.aws.network import VPC
from diagrams.aws.devtools import Codebuild, Codepipeline
from diagrams.aws.storage import S3
from diagrams.aws.database import Dynamodb
from diagrams.onprem.vcs import Github
from diagrams.aws.general import General

graph_attr = {
    "fontsize": "12",
    "bgcolor": "white",
    "splines": "ortho"
}

with Diagram("DevOps Learn in 30 – AWS Infrastructure & CI/CD", show=True, graph_attr=graph_attr):

    github = Github("GitHub Repo")

    with Cluster("GitHub Actions Workflow"):
        build = Codebuild("Build Job\n- ECR Only\n- Docker push")
        deploy = Codepipeline("Deploy Job\n- Full Terraform\n- ECS")

    github >> Edge(label="push to main") >> [build, deploy]

    ecr = General("Amazon ECR\nDocker Image")
    build >> ecr

    with Cluster("Terraform Backend"):
        s3 = S3("S3 Bucket\nState File")
        dynamo = Dynamodb("DynamoDB\nState Locking")

    deploy >> [s3, dynamo]

    with Cluster("VPC Infrastructure"):
        vpc = VPC("Main VPC")
        subnet = General("Subnet")
        sg = General("Security Group")
        igw = General("Internet Gateway")
        rt = General("Route Table")

    vpc >> subnet >> sg
    vpc >> [igw, rt]

    with Cluster("ECS Fargate"):
        ecs_cluster = ECS("ECS Cluster")
        task_def = General("Task Definition")
        service = ECS("ECS Service\n(Fargate)")

    deploy >> [vpc, ecs_cluster]
    ecs_cluster >> task_def >> service
    service >> Edge(label="runs image") >> ecr
