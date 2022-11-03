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
  title       = "Rank"
  description = "a rank is a collection of properties that defines what a rank is a Check is connected to it to define how important the Check is, while the Service is connected to it to define the service maturity"
  icon        = "Permission"
  identifier  = "Rank"
  properties {
    identifier  = "description"
    title       = "Description"
    description = "An explanation of how service in this Rank is supposed to look like"
    icon        = "Docs"
    type        = "string"
  }
  properties {
    identifier  = "priority"
    title       = "Priority"
    description = "The importance of the Rank 1 - 5"
    type        = "number"
  }
  properties {
    identifier  = "level"
    type        = "string"
    description = "The level of the Rank (Level 1, Level 2 etc...)"
    title       = "Level"
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
  title       = "Check"
  icon        = "DevopsTool"
  identifier  = "Check"
  description = "a check is the definition of the Check responsibility"
  properties {
    identifier  = "description"
    type        = "string"
    icon        = "Docs"
    title       = "Description"
    description = "a small description of the check and its purpose"
  }
  properties {
    identifier  = "category"
    type        = "string"
    title       = "Category"
    description = "in which domain the check applies to (Service Ownership, security, reliability etc..)"
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
    identifier = "level"
    title      = "Level"
    path       = "rank.level"
  }

  mirror_properties {
    identifier = "priority"
    title      = "Priority"
    path       = "rank.priority"
  }

  relations {
    required   = true
    title      = port-labs_blueprint.Rank.title
    target     = port-labs_blueprint.Rank.identifier
    identifier = "rank"
  }
}

resource "port-labs_blueprint" "Service" {
  title       = "Service"
  icon        = "Service"
  identifier  = "Service"
  description = "Service is the object that we would like to estimate its maturity i.e Payment Service, Order Service etc"
  properties {
    identifier  = "repo"
    type        = "string"
    format      = "url"
    title       = "Repository"
    description = "the URL of the git repository"
    icon        = "Git"
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
}

resource "port-labs_blueprint" "CheckRun" {
  title       = "Check Run"
  icon        = "Deployment"
  identifier  = "CheckRun"
  description = "a check run is the actual Job Run of the Check definition on a specific Service"
  properties {
    identifier  = "status"
    type        = "string"
    title       = "Status"
    description = "check run result failure or success"
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
    identifier  = "buildId"
    type        = "string"
    title       = "Build Id"
    description = "an identifier to the buildId of the check run to identify multiple check runs of the same build"
  }
  properties {
    identifier  = "url"
    type        = "string"
    format      = "url"
    title       = "Job URL"
    icon        = "Github"
    description = "a link to the Job URL of the actual GitHub run"
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
    name  = "priority"
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
    name  = "priority"
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
    name  = "priority"
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
    name  = "priority"
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
    name  = "priority"
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
    value = "Is README.md file exists within the repository?"
  }
  properties {
    name  = "category"
    value = "Documentation"
  }
  relations {
    identifier = port-labs_entity.Level1.identifier
    name       = "rank"
  }
}

resource "port-labs_entity" "codewoners-check" {
  title      = "CODEOWNERS Check"
  identifier = "codeowners"
  blueprint  = port-labs_blueprint.Check.identifier
  properties {
    name  = "description"
    value = "Is CODEOWNERS file exists within the repository?"
  }
  properties {
    name  = "category"
    value = "Service Ownership"
  }
  relations {
    identifier = port-labs_entity.Level3.identifier
    name       = "rank"
  }
}


resource "port-labs_entity" "snyk-check" {
  title      = "Snyk Check"
  identifier = "snyk"
  blueprint  = port-labs_blueprint.Check.identifier
  properties {
    name  = "description"
    value = "Does the service pass all of the snyk vulnerability scans?"
  }
  properties {
    name  = "category"
    value = "Security"
  }
  relations {
    identifier = port-labs_entity.Level3.identifier
    name       = "rank"
  }
}

resource "port-labs_entity" "pager-check" {
  title      = "Pager Check"
  identifier = "pager"
  blueprint  = port-labs_blueprint.Check.identifier
  properties {
    name  = "description"
    value = "Is pagerduty contain the service?"
  }
  properties {
    name  = "category"
    value = "Service Ownership"
  }
  relations {
    identifier = port-labs_entity.Level3.identifier
    name       = "rank"
  }
}

resource "port-labs_entity" "fast-api-version-check" {
  title      = "FastApi version Check"
  identifier = "fast-api-version"
  blueprint  = port-labs_blueprint.Check.identifier
  properties {
    name  = "description"
    value = "Is fastApi version equals 0.85.2"
  }
  properties {
    name  = "category"
    value = "Quality"
  }
  relations {
    name       = "rank"
    identifier = port-labs_entity.Level2.identifier
  }
}

resource "port-labs_entity" "docs-check" {
  title      = "API Docs Check"
  identifier = "api-docs"
  blueprint  = port-labs_blueprint.Check.identifier
  properties {
    name  = "description"
    value = "Is Redoc available?"
  }
  properties {
    name  = "category"
    value = "Documentation"
  }
  relations {
    name       = "rank"
    identifier = port-labs_entity.Level4.identifier
  }
}


resource "port-labs_entity" "pager-team-check" {
  title      = "Pager Team Check"
  identifier = "pager-team"
  blueprint  = port-labs_blueprint.Check.identifier
  properties {
    name  = "description"
    value = "Is the service within pagerduty has a team owner?"
  }
  properties {
    name  = "category"
    value = "Service Ownership"
  }
  relations {
    identifier = port-labs_entity.Level2.identifier
    name       = "rank"
  }
}

resource "port-labs_entity" "sentry-check" {
  title      = "Sentry Check"
  identifier = "sentry"
  blueprint  = port-labs_blueprint.Check.identifier
  properties {
    name  = "description"
    value = "Is sentry installed on the service?"
  }
  properties {
    name  = "category"
    value = "Observability"
  }
  relations {
    identifier = port-labs_entity.Level5.identifier
    name       = "rank"
  }
}

resource "port-labs_entity" "linked-issues-check" {
  title      = "Linked Issues Check"
  identifier = "linked-issues"
  blueprint  = port-labs_blueprint.Check.identifier
  properties {
    name  = "description"
    value = "Does the service have linked GitHub issues?"
  }
  properties {
    name  = "category"
    value = "Quality"
  }
  relations {
    name       = "rank"
    identifier = port-labs_entity.Level4.identifier
  }
}
resource "port-labs_entity" "repository-service" {
  title      = "port-service-maturity-example" // Put here the repository name of the service
  identifier = "port-service-maturity-example" // Put here the repository name of the service
  blueprint  = port-labs_blueprint.Service.identifier

  properties {
    name  = "repo"
    value = "https://github.com/port-labs/port-service-maturity-example"
  }
}

