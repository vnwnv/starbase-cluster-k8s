# Infrastructure Setup with Terraform

This directory contains Terraform configurations to set up the infrastructure for the Starbase Cluster K8s project. Below are the key files and their purposes:

## Getting Started

1. **Install Terraform**: Ensure you have Terraform installed on your system. You can download it from [Terraform's official website](https://www.terraform.io/downloads.html).

2. **Initialize Terraform**: Run the following command to initialize Terraform in this directory:

   ```bash
   cd infra
   terraform init
   ```

3. **Apply the Configuration**: Apply the Terraform configuration to create the infrastructure:

   ```bash
   terraform apply
   ```

   Review the plan and confirm the changes before applying.

4. **Destroy the Infrastructure**: To destroy the infrastructure, run:

   ```bash
   terraform destroy
   ```

   Review the plan and confirm the changes before destroying.

## Variables

You can customize the infrastructure setup by copying and modifying the variables in `vars/tfvars.example` and rename it to `*.auto.tfvars` file. You need put your file in same directory of `main.tf`.

Do not delete variable in an object! if you do not use that variable, you can make it to empty like `""`.

## Templates

Template files in the `templates` directory are used to generate configuration files dynamically during the Terraform execution.

The incentory will auto generated by terraform with name `incentory.gen`
