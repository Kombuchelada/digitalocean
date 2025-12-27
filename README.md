# Terraform and Ansible for my DigitalOcean

This project provisions a DigitalOcean droplet and a block storage volume with Terraform, then configures the server filesystem layout using Ansible to prepare for running services (like nginx proxy manager) via Docker.

## Overview
- Terraform creates resources in DigitalOcean (droplet, DNS, volume, attachment).
- Ansible mounts the volume at `/mnt/docker-data` and creates folders for Docker and service data.
- Environment variables are loaded via `.env` (optionally auto-loaded with `direnv`).

Project layout:
- Terraform files in [terraform](terraform)
- Ansible files in [ansible](ansible)
- Env templates: [.env.example](.env.example), optional loader: [.envrc](.envrc)

## Prerequisites

Install tools:
```bash
brew install terraform ansible direnv
```
Enable direnv (zsh):
```bash
echo 'eval "$(direnv hook zsh)"' >> ~/.zshrc
source ~/.zshrc
```

## Setup Environment
1) Create `.env` from the template and fill values:
```bash
cp .env.example .env
# edit .env: set DO_PAT, SSH_KEY_PATH, ANSIBLE_HOST, etc.
```
2) Auto-load env vars when entering the repo:
```bash
# in repo root
printf "set -a\nsource .env\nset +a\n" > .envrc
direnv allow
```
3) Verify env:
```bash
echo $TF_VAR_do_token
echo $TF_VAR_pvt_key
echo $TF_VAR_domain
```

Notes:
- Terraform reads variables from env as `TF_VAR_<name>`.
- Ansible inventory in [ansible/inventory.yaml](ansible/inventory.yaml) reads `ANSIBLE_HOST` and `ANSIBLE_PRIVATE_KEY_FILE` from env.

## Terraform: Provision Infrastructure
Run from [terraform](terraform):
```bash
cd terraform
terraform init
terraform plan
terraform apply
```
Variables used:
- `var.do_token` from `TF_VAR_do_token`
- `var.pvt_key` from `TF_VAR_pvt_key`
- `var.domain` from `TF_VAR_domain`

Key resources:
- Droplet: [www-1.tf](terraform/www-1.tf)
- DNS domain: [domain_root.tf](terraform/domain_root.tf)
- Volume + attachment: [volume.tf](terraform/volume.tf)

## Ansible: Configure Mount + Folders
Run from [ansible](ansible):
```bash
cd ansible
ansible-playbook site.yml
```
What it does:
- Unmounts legacy `/mnt/docker_data_volume` if present.
- Mounts the DO volume at `/mnt/docker-data` using by-id path.
- Creates directories:
  - `/mnt/docker-data/docker`
  - `/mnt/docker-data/services/npm/{data,letsencrypt}`

Inventory:
- Static YAML inventory at [ansible/inventory.yaml](ansible/inventory.yaml) using env vars.

## Resizing the Volume
To grow storage without data loss:
1) Resize volume in DigitalOcean UI or `doctl`.
2) On droplet, grow the filesystem (ext4 supports online resize):
```bash
sudo resize2fs /dev/disk/by-id/scsi-0DO_Volume_docker-data-volume
```
3) Update Terraform `size` in [volume.tf](terraform/volume.tf) to match the new GB value and run `terraform apply` to sync state.

## Security & Git Hygiene
- Never commit secrets or state files.
- Already ignored in [.gitignore](.gitignore): `.env`, `.envrc`, `.terraform/`, `*.tfstate`, `*.tfvars`.
- Commit `.tf` files, `.terraform.lock.hcl`, and Ansible playbooks.

## Troubleshooting
- Dynamic inventory plugin `digitalocean.cloud.droplet` is deprecated in Ansible 13; this project uses static YAML inventory.
- If Ansible can’t connect, verify `ANSIBLE_HOST` resolves and `ANSIBLE_PRIVATE_KEY_FILE` points to your SSH key.
- Check mounts with:
```bash
lsblk -f
findmnt /mnt/docker-data
```

## Next Steps
- Deploy Docker and nginx proxy manager with bind mounts under `/mnt/docker-data/services/npm/`.
- Optionally move Docker root to `/mnt/docker-data/docker` for more root disk headroom.

## TODO: GitHub Actions Setup
- Terraform workflow:
  - Add `.github/workflows/terraform.yml` to run `terraform fmt -check`, `terraform init`, `terraform plan`.
  - Store `DO_PAT` as a GitHub Actions secret; pass to workflow as `TF_VAR_do_token`.
  - Use a remote backend for state (Terraform Cloud or DO Spaces) to avoid storing `terraform.tfstate`.
- Ansible workflow:
  - Use a deploy job with `ansible-playbook` via `ssh` to the droplet or a self-hosted runner.
  - Inject `ANSIBLE_HOST` and `ANSIBLE_PRIVATE_KEY` via GitHub secrets; consider short-lived deploy keys.
- Linting & checks:
  - Add `tflint` and `terraform validate` steps.
  - Add `ansible-lint` for playbooks.
- Pre-commit hooks:
  - Configure `.pre-commit-config.yaml` for Terraform fmt/validate and YAML formatting.
- Environment management:
  - Avoid secrets in `.env.example`; document required envs in README only.
