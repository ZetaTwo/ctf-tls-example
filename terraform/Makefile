default: apply

init:
	terraform init

plan:
	terraform plan -var-file="secret.tfvars"

fmt:
	terraform fmt

apply:
	terraform apply -var-file="secret.tfvars"

.PHONY: default init plan fmt apply
