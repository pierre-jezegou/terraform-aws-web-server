# AWS complete infrastructure deploy with terraform
## Set up
1. Add `Name` tag = `lav-vpc` to vpc
2. Run the python script to get all the subnets (sould be improved with a `data` block in terraform)
3. Change the values in `terraform.tfvars` of:
   - `subnet_id` with the first subnet got from the pthjon script
   - `subnets` with the complete list

## Run terraform
```shell
terraform apply
```

