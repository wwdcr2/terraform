provider "aws" {
    region = "us-east-1"
}

module "webserver_cluster" {
  source = "../../../modules/services/webserver-cluster"

  cluster_name = "webservers-prod"
  db_remote_state_bucket = "tf-start-prod"
  db_remote_state_key = "prod/data-stores/mysql/terrform.tfstate"
  
  instance_type = "t2.micro"
  min_size = 2
  max_size = 10
}

resource "aws_autoscaling_schedule" "scale_out_during_business_hours"{
    scheduled_action_name = "scale-out-during-business-housrs"
    min_size = 2
    max_size = 10
    desired_capacity = 3
    recurrence = "0 9 * * *"

    aws_autoscaling_group_name = module.webserver_cluster.asg_name
}

resource "aws_autoscaling_schedule" "scale_in_at_night"{
    scheduled_action_name = "scale-in-at-night"
    min_size = 2
    max_size = 10
    desired_capacity = 2
    recurrence = "0 17 * * *"

    aws_autoscaling_group_name = module.webserver_cluster.asg_name
}

output "asg_name" {
    value = aws_autoscaling_group.example.name
}
