terraform {
  cloud {
    organization = "bogs_snark"
    workspaces {
      name = "bogs_snark"
    }
  }
}
