# Application Onboarding Checklist

This document contains a list of of tasks and best practices that should be done or incorporated with the application in order to onboard the app to the fleet.

* Yaml best practices
  * The application deployment yaml should specify resource limits.
  * The application resources should be deployed to their own namespace (i.e. not the default namespace).
    * Flux requires a namespace for all resources - even if it's "default"
* Docker image
  * Any Docker images from Docker Hub should be signed and from a trusted, known vendor.
  * "latest" tag should be avoided if possible.
  * Use multi-stage Docker build process to reduce image size
  * Do not run Docker images as root
  * Do not publish Docker images to Docker Hub "free" due to rate limiting
* App versioning
  * Implement app versioning and tag the images accordingly
    * Tag with major.minor.build and major.minor where possible
  * Follow [semver](https://semver.org/) standards where possible
* Identify any unique app dependencies that are not built in with the cluster.
  * This will likely require additional set up work by the platform team.
  * The sooner this can be identified the better.
* Identify any app secrets that should be stored as a k8s secret.
* CI/CD
  * Create a CI/CD pipeline for the application.
  * Do not push image to public DockerHub.
  * Incorporate testing into the pipeline.
  * Have separate CI and CD pipelines where possible
    * This is required if the platform or SRE team are responsible for the deployment to the cluster
* Unit Testing
* Linter (program language specific)
* Healthz/Readyz endpoint for monitoring and probes
  * Add a "deep" health check to verify application health
    * Cache this result for 60 seconds to avoid DDOS target
* Monitoring
  * Logging: Application outputs structured logs (i.e. json) to standard out
  * Metrics: Application is updated to create and emit custom prometheus metrics at the /metrics endpoint (as desired/needed)
    * [Prometheus metric types](https://prometheus.io/docs/concepts/metric_types/)
