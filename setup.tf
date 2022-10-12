locals {
  envs = { for tuple in regexall("(.*)=(.*)", file(".env")) : tuple[0] => sensitive(tuple[1]) }
}

terraform {
  required_providers {
    port-labs = {
      source  = "port-labs/port-labs"
      version = "~> 0.5.0"
    }
  }
}

provider "port-labs" {
  client_id = local.envs["PORT_CLIENT_ID"]
  secret    = local.envs["PORT_CLIENT_SECRET"]
}

// defining blueprint
resource "port-labs_blueprint" "Rank" {
  title      = "Rank"
  icon       = "Permission"
  identifier = "Rank"
  properties {
    identifier = "description"
    title      = "Description"
    type       = "string"
  }
  properties {
    identifier = "priorty"
    title      = "Priorty"
    type       = "number"
  }
  properties {
    identifier = "level"
    type       = "string"
    title      = "Level"
    enum = [
      "Level 1",
      "Level 2",
      "Level 3",
      "Level 4",
      "Level 5",
    ]
    enum_colors = {
      "Level 1" = "red",
      "Level 2" = "orange",
      "Level 3" = "yellow",
      "Level 4" = "blue",
      "Level 5" = "green",
    }
  }
}

resource "port-labs_blueprint" "Check" {
  title      = "Check"
  icon       = "DevopsTool"
  identifier = "Check"
  properties {
    identifier = "description"
    type       = "string"
    title      = "Description"
  }
  properties {
    identifier = "category"
    type       = "string"
    title      = "Category"
    enum = [
      "Service Ownership",
      "Security",
      "Reliability",
      "Observability",
      "Quality",
      "Documentation",
    ]
    enum_colors = {
      "Service Ownership" = "orange",
      "Security"          = "green",
      "Reliability"       = "purple",
      "Observability"     = "red",
      "Quality"           = "yellow",
      "Documentation"     = "blue",
    }
  }
  mirror_properties {
    identifier = "maturity"
    title      = "Maturity"
    path       = "rank.level"
  }

  mirror_properties {
    identifier = "priorty"
    title      = "Priorty"
    path       = "rank.priorty"
  }

  relations {
    required   = true
    title      = port-labs_blueprint.Rank.title
    target     = port-labs_blueprint.Rank.identifier
    identifier = "rank"
  }

  depends_on = [
    port-labs_blueprint.Rank,
  ]
}

resource "port-labs_blueprint" "Service" {
  title      = "Service"
  icon       = "Service"
  identifier = "Service"
  properties {
    identifier = "repo"
    type       = "string"
    format     = "url"
    title      = "Repository"
  }
  mirror_properties {
    identifier = "maturity"
    title      = "Maturity"
    path       = "rank.level"
  }
  relations {
    title      = port-labs_blueprint.Rank.title
    identifier = "rank"
    target     = port-labs_blueprint.Rank.identifier
  }

  depends_on = [
    port-labs_blueprint.Rank,
  ]
}

resource "port-labs_blueprint" "CheckRun" {
  title      = "Check Run"
  icon       = "Deployment"
  identifier = "CheckRun"
  properties {
    identifier = "status"
    type       = "string"
    title      = "StatusDescription"
    enum = [
      "success",
      "failure",
    ]
    enum_colors = {
      "success" = "green",
      "failure" = "red",
    }
  }
  properties {
    identifier = "buildId"
    type       = "string"
    title      = "Build Id"
  }
  properties {
    identifier = "url"
    type       = "string"
    format     = "url"
    title      = "Job URL"
  }

  relations {
    title      = port-labs_blueprint.Check.title
    identifier = "check"
    target     = port-labs_blueprint.Check.identifier
    required   = true
  }

  relations {
    required   = true
    identifier = "service"
    title      = port-labs_blueprint.Service.title
    target     = port-labs_blueprint.Service.identifier
  }

  depends_on = [
    port-labs_blueprint.Service,
    port-labs_blueprint.Check
  ]
}

// Defining ranks
resource "port-labs_entity" "Level1" {
  blueprint  = port-labs_blueprint.Rank.identifier
  title      = "Level 1"
  identifier = "Level1"
  properties {
    name  = "description"
    value = "Process unpredictable and poortly reactive"
  }

  properties {
    name  = "priorty"
    value = 1
  }

  properties {
    name  = "level"
    value = "Level 1"
  }
}
resource "port-labs_entity" "Level2" {
  blueprint  = port-labs_blueprint.Rank.identifier
  title      = "Level 2"
  identifier = "Level2"
  properties {
    name  = "description"
    value = "Process characterized for projects and is often react"
  }

  properties {
    name  = "priorty"
    value = 2
  }

  properties {
    name  = "level"
    value = "Level 2"
  }
}

resource "port-labs_entity" "Level3" {
  blueprint  = port-labs_blueprint.Rank.identifier
  title      = "Level 3"
  identifier = "Level3"
  properties {
    name  = "description"
    value = "Process characterized for the organization and is proactive"
  }

  properties {
    name  = "priorty"
    value = 3
  }

  properties {
    name  = "level"
    value = "Level 3"
  }
}

resource "port-labs_entity" "Level4" {
  blueprint  = port-labs_blueprint.Rank.identifier
  title      = "Level 4"
  identifier = "Level4"
  properties {
    name  = "description"
    value = "Process easured and controlled by the organization"
  }

  properties {
    name  = "priorty"
    value = 4
  }

  properties {
    name  = "level"
    value = "Level 4"
  }
}

resource "port-labs_entity" "Level5" {
  blueprint  = port-labs_blueprint.Rank.identifier
  title      = "Level 5"
  identifier = "Level5"
  properties {
    name  = "description"
    value = "Focus on contiunous process imporevements"
  }

  properties {
    name  = "priorty"
    value = 5
  }

  properties {
    name  = "level"
    value = "Level 5"
  }
}



// Defining checks
resource "port-labs_entity" "readme-check" {
  title      = "Readme Check"
  identifier = "readme"
  blueprint  = port-labs_blueprint.Check.identifier
  properties {
    name  = "description"
    value = "Check if the repository has a README.md file"
  }
  properties {
    name  = "category"
    value = "Documentation"
  }
  relations {
    identifier = port-labs_entity.Level1.identifier
    name       = "rank"
  }
  depends_on = [
    port-labs_entity.Level1,
  ]
}

resource "port-labs_entity" "snyk-check" {
  title      = "Snyk Check"
  identifier = "snyk"
  blueprint  = port-labs_blueprint.Check.identifier
  properties {
    name  = "description"
    value = "Check if the repository have snyk vulnerabilities"
  }
  properties {
    name  = "category"
    value = "Security"
  }
  relations {
    identifier = port-labs_entity.Level3.identifier
    name       = "rank"
  }
  depends_on = [
    port-labs_entity.Level3,
  ]
}

resource "port-labs_entity" "pager-check" {
  title      = "Pager Check"
  identifier = "pager"
  blueprint  = port-labs_blueprint.Check.identifier
  properties {
    name  = "description"
    value = "Check if the repository have pagerduty defined"
  }
  properties {
    name  = "category"
    value = "Service Ownership"
  }
  relations {
    identifier = port-labs_entity.Level3.identifier
    name       = "rank"
  }
  depends_on = [
    port-labs_entity.Level2,
  ]
}

resource "port-labs_entity" "pager-team-check" {
  title      = "Pager Team Check"
  identifier = "pager-team"
  blueprint  = port-labs_blueprint.Check.identifier
  properties {
    name  = "description"
    value = "Check if the repository have pagerduty team defined"
  }
  properties {
    name  = "category"
    value = "Service Ownership"
  }
  relations {
    identifier = port-labs_entity.Level2.identifier
    name       = "rank"
  }
  depends_on = [
    port-labs_entity.Level2,
  ]
}

resource "port-labs_entity" "sentry-check" {
  title      = "Sentry Check"
  identifier = "sentry"
  blueprint  = port-labs_blueprint.Check.identifier
  properties {
    name  = "description"
    value = "Check if the repository have sentry installed"
  }
  properties {
    name  = "category"
    value = "Observability"
  }
  relations {
    identifier = port-labs_entity.Level5.identifier
    name       = "rank"
  }
  depends_on = [
    port-labs_entity.Level5,
  ]
}

resource "port-labs_entity" "linked-issues-check" {
  title      = "Linked Issues Check"
  identifier = "linked-issues"
  blueprint  = port-labs_blueprint.Check.identifier
  properties {
    name  = "description"
    value = "Check if the repository have open GitHub issues"
  }
  properties {
    name  = "category"
    value = "Quality"
  }
  relations {
    name       = "rank"
    identifier = port-labs_entity.Level4.identifier
  }
  depends_on = [
    port-labs_entity.Level5,
  ]
}
resource "port-labs_entity" "repository-service" {
  title      = "port-service-maturity-example" // Put here the repository name of the service
  identifier = "port-service-maturity-example" // Put here the repository name of the service
  blueprint  = port-labs_blueprint.Service.identifier

  properties {
    name  = "repo"
    value = "https://github.com/port-labs/port-service-maturity-example"
  }

  depends_on = [
    port-labs_blueprint.Service,
  ]
}
