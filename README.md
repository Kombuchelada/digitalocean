# DigitalOcean Infra with Terraform + Ansible + GitHub Actions

This project provisions a DigitalOcean droplet, DNS records, and a block storage volume with Terraform, then configures the server filesystem layout with Ansible. A GitHub Actions workflow automates planning/applying and configuration.

## Overview
- Terraform creates resources in DigitalOcean (droplet, DNS, volume, attachment).
- Ansible mounts the volume at `/mnt/docker-data` and creates folders for Docker and service data.
- Environment variables are loaded via `.env` (optionally auto-loaded with `direnv`).

Project layout:
- Terraform files in [terraform](terraform)
- Ansible files in [ansible](ansible)
- CI workflow: [.github/workflows/infra.yml](.github/workflows/infra.yml)

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
ansible-galaxy collection install -r requirements.yml
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

## CI Setup (GitHub Actions)

The workflow in [.github/workflows/infra.yml](.github/workflows/infra.yml) will:
- Run `terraform init`/`plan` on PRs and pushes
- Auto-apply on `main` (push or dispatch)
- Pass the droplet IP to Ansible and run the playbook

### Required GitHub Secrets and Variables

- Secret DIGITALOCEAN_ACCESS_TOKEN: a DigitalOcean PAT with write access
- Secret SSH_PRIVATE_KEY: private key matching your DO account SSH key (used by provisioner and Ansible)
- Secret TF_API_TOKEN: Terraform Cloud API token (for remote backend auth)
- Secret DOMAIN: the root domain to manage (e.g. `example.com`)

Add these in your repository settings:
1. Settings → Secrets and variables → Actions → New repository secret: DIGITALOCEAN_ACCESS_TOKEN
2. New repository secret: SSH_PRIVATE_KEY
3. New repository secret: TF_API_TOKEN
4. New repository secret: DOMAIN

Optional: protect apply with an environment (Settings → Environments). Then set `environment: production` on the apply step and require approvals.

### First Run

Trigger a run on `main` after secrets are set:

```bash
gh workflow run "Infrastructure CI" -r main
```

Or push to `main` to auto-apply.

## Remote State (Terraform Cloud)

This project is set up to use Terraform Cloud for state storage and locking. Configure your organization and workspace in [terraform/backend.tf](terraform/backend.tf):

- Set `organization` to your Terraform Cloud org name.
- Set `workspaces.name` to your desired workspace (e.g., `tf-sample-prod`).

Then migrate local state to Terraform Cloud (interactive):

```bash
cd terraform
# Ensure you're logged into Terraform Cloud (or rely on TF_API_TOKEN in CI)
terraform login

# Run init and accept the migration prompt when asked
terraform init
```

Note: `-migrate-state` is not used with Terraform Cloud. Migration is performed via interactive prompts during `terraform init`.

The CI workflow authenticates to Terraform Cloud using the `TF_API_TOKEN` secret via the `hashicorp/setup-terraform` action. No manual login is needed in CI.
