# Supernova DevOps Challenge ✨

> _“Done with curiosity, not copy-paste.”_

## 🎯 What this is
- IaC with Terraform  
- Serverless API: Lambda + DynamoDB  
- CI/CD using GitHub Actions + OIDC (no secrets in the repo)


## 🔐 Why it’s built this way
- **OIDC, not access keys** – no static credentials anywhere  
- **Separate IAM roles** – one for Lambda, one for deploy (least privilege)  
- **Idempotent /items endpoint** – uses DynamoDB’s `ConditionExpression` to block duplicates  
- **0€ cost** – all services are within AWS Free Tier (PAY_PER_REQUEST DynamoDB, Lambda, API Gateway)

## 🛠️ Cómo probar
```bash
make plan    # vista previa
make apply   # despliegue
make destroy # limpieza  
