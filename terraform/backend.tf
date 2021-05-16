terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "tonyjoseph"
    workspaces {
      name = "cardano-node"
    }
  }
}