.PHONY: plan apply destroy
plan:
	cd infra && terraform init && terraform plan
apply:
	cd infra && terraform apply -auto-approve
destroy:
	cd infra && terraform destroy -auto-approve
