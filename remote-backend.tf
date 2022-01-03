terraform {
  backend "remote" {
    organization = "rjackson-biz"

    workspaces {
      name = "simpletest"
    }
  }
}
