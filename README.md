# Introduction

[![PR Quality Check](https://github.com/microsoft/kalypso/actions/workflows/pr.yaml/badge.svg)](https://github.com/microsoft/kalypso/actions/workflows/pr.yaml)

Kalypso provides a composable reference architecture of the workload management in a multi-cluster and multi-tenant environment with GitOps.

This is an umbrella repository that contains requirements, use cases, high level architecture and design decisions. The overall solution is composable so that every single component is handled in [its own repository](#referenced-repositories).

## Motivation

There is an organization developing cloud-native applications. Any application needs a compute to work on. For cloud native a compute is a K8s cluster. An organization may have a single cluster or, which is more common, there are multiple clusters. So they have to decide what applications should work on what clusters, or in other words, schedule them. The result of this decision or scheduling is a model of their cluster fleet, the desired state of the world if you will. Having that in place, they need somehow to deliver applications to the assigned clusters so they will turn the desired state into the reality or in other words reconcile it.

Every single application goes through a certain software development lifecycle, that promotes it to the production environment. E.g. an application is built, deployed to Dev environment, tested and promoted to Stage environment, tested and finally delivered to production. So the application requires and targets different K8s resources to support its SDLC. Furthermore, the applications normally expects on the clusters some platform services like Prometheus and Fluentbit and infra configurations like networking policy.

Depending on the application, the variety of the cluster types where the application is deployed in its lifecycle may be very diverse. The very same application with different configurations may be hosted on a managed cluster in the cloud, a connected cluster on prem, a fleet of clusters on semi-connected edge devices on a factory lines or military drones, an air-gapped cluster on a starship. Besides that, clusters involved in the early lifecycle stages such as Dev and QA are normally managed by the developer, but the actual production clusters and reconciling to them may be managed by the organization's customers. In the latter case the developer may be only responsible for promoting and scheduling the application across different rings.  

The scenarios described above can be handled manually with a handful of scripts and pipelines in a small organization operating a single application and a few clusters. In enterprise organizations this is a real challenge. They operate at scale, producing hundreds of applications targeting hundreds of cluster types that are backed up by thousands of physical clusters. It would be fair to say, that handling that manually with scripts is simply not feasible. It requires a scalable automated solution with the following capabilities:

- Separation of concerns on scheduling and reconciling
- Promotion of the fleet state through a chain of environments
- Sophisticated, extensible and replaceable scheduler
- Flexibility to use different reconcilers for different cluster types depending in their nature and connectivity

### Existing projects

It's worth mentioning that there is a variety of existing projects targeting to address some of the described challenges. Most of them are built on the *Hub/Spoke* concept where there is a *Hub* cluster that controls workload placement across connected *Spoke* clusters. Examples of such tools are [Kubefed](https://github.com/kubernetes-sigs/kubefed), [Karmada](https://karmada.io/), [KubeVela](https://kubevela.io/), [OCM](https://open-cluster-management.io/), [Azure Kubernetes Fleet](https://learn.microsoft.com/en-us/azure/kubernetes-fleet/overview), [Rancher Fleet](https://fleet.rancher.io) etc. By definition, solutions like that expect a connection between *Hub* and *Spoke* clusters, at least an occasional one. They commonly provide monolithic functionality meaning they implement both workload scheduling and reconciling to the spoke clusters, so that scheduling and reconciling are tightly coupled to each other.

Historically, most of such tools have been designed to federate applications across multiple clusters. They are supposed to provide scalability, availability and security capabilities for a single application instance by breaking through Kubernetes limit of 5k nodes and placing an application across multiple regions and security zones. A solution like that is a perfect fit for a group or a fleet of connected clusters of the same or similar type with simple workload placement, based on labels and cluster performance metrics. From the perspective of this project, a cluster fleet like that is considered as a single deployment target, as a cluster of clusters with its own mechanics to load and balance the underlying compute.

## Roles

### Platform Team

Platform team takes care of the cluster fleet that hosts applications produced by app teams.

*Key responsibilities*:

- Define staging environments (Dev, QA, UAT, Prod)
- Define cluster types in the fleet (group of clusters sharing the same configurations) and their distribution across environments
- Provision New clusters (CAPI/Crossplane/Bicep/Terraform/…)
- Manage infrastructure configurations and platform services (e.g. RBAC, Istio, Service Accounts, Prometheus, Flux, etc.) across cluster types
- Schedule applications on cluster types

### Application Team

Application team is responsible for their core application logic and providing the Kubernetes manifests that define how to deploy that application and its dependencies. They are responsible for owning their CI pipeline that creates container images, Kubernetes manifests and any validation steps required prior to rollout (e.g., testing, linting). The application team may have limited knowledge of the clusters that they are deploying to, and primarily need to understand the success of their application rollout as defined by the success of the pipeline stages. The application team is not aware of the structure of the entire fleet, global configurations and what other teams do.

*Key responsibilities*:

- Run full SDLC of their applications: develop, build, deploy, test, promote, release, support, bugfix, etc.
- Maintain and contribute to source and manifests repositories of their applications
- Define and configure application deployment targets
- Communicate to Platform Team requesting desired infrastructure for successful SDLC

### Application Operators

Application Operators work with the applications on the clusters on the edge. They are normally in charge of application instances working on a single or a small group of clusters. They may perform some local configurations for the specific clusters and applications instances. This role is out of scope of this project.

## High Level Flow

![kalypso-high-level](./docs/images/kalypso-highlevel.png)

## Primary Use Cases

- [Platform team onboards a workload](./docs/use-cases/platform-team-onboards-workload.md)
- [Platform team defines a cluster type](./docs/images/under-construction.png)
- [Platform team provides a configuration value for a cluster type](./docs/images/under-construction.png)
- [Platform team schedules an application on cluster types](./docs/images/under-construction.png)
- [Application team defines application deployment targets](./docs/images/under-construction.png)
- [Application team provides a configuration value for a deployment target](./docs/images/under-construction.png)
- [Application team updates the application](./docs/images/under-construction.png)
- [Platform team defines service deployment targets](./docs/images/under-construction.png)
- [Platform team provides a configuration value for a service deployment target](./docs/images/under-construction.png)
- [Platform team updates a platform service](./docs/images/under-construction.png)

## Design Details

![kalypso-detailed](./docs/images/kalypso-detailed.png)

<!--
### Separation of Concerns

Platform team has a very limited knowledge about the applications and therefore is not involved in the application configuration and deployment. Platform team 
-->

## Referenced Repositories

|Repository|Description|
|--------|----------|
|[Application Source](https://github.com/microsoft/kalypso-app-src)|Contains a sample application source code including Docker files, manifest templates and CI/CD workflows|
|[Application GitOps](./docs/images/under-construction.png)|Contains final sample application manifests to de be deployed to the deployment targets|
|[Services Source](./docs/images/under-construction.png)|Contains high level manifest templates of sample dial-tone platform services and CI/CD workflows|
|[Services GitOps](./docs/images/under-construction.png)|Contains final manifests of sample dial-tone platform services to be deployed across clusters fleet|
|[Control Plane](https://github.com/microsoft/kalypso-control-plane)|Contains a platform model including environments, cluster types, applications and services, mapping rules and configurations, Promotion Flow workflows|
|[Platform GitOps](https://github.com/microsoft/kalypso-gitops)|Contains final manifests representing the topology of the fleet - what cluster types are available, how they are distributed across environments and what is supposed to deployed where|
|[Kalypso Scheduler](./docs/images/under-construction.png)|Contains detailed design and source code of the scheduler operator, responsible for scheduling applications and services on cluster types and uploading the result to the GitOps repo|
|[Kalypso Observability Hub](./docs/images/under-construction.png)|Contains detailed design and source code of the deployment observability service|

## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit <https://cla.opensource.microsoft.com>.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft
trademarks or logos is subject to and must follow
[Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/en-us/legal/intellectualproperty/trademarks/usage/general).
Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship.
Any use of third-party trademarks or logos are subject to those third-party's policies.
