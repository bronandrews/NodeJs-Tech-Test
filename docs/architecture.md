## Considerations

The following are considerations when implements in a real-world scenario.

<p>git repo is currently public, ideally this would be private</p>

<p>EKS cluster is running on public subnets in this instance, they would be private using correct network routing and connectivity</p>

<p>Jenkins job using the pipeline needs to be create manually, this should be declared in a .groovy file and kept in source control</p>

<p>Maintenance required on ECR repo - lifecycle policy to control and manage retention</p>

<p>Security is always a consideration - only users that need access to each component should have access. This is acheieved via IAM roles and permissions.</p>
