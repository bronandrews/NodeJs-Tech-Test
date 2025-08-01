## Considerations

The following are just some considerations when implemented in a real-world scenario.

<p>-- git repo is currently public, ideally this would be private</p>

<p>-- EKS cluster is running on public subnets in this instance, they should be private and accessed through correct network routing and connectivity</p>

<p>-- Jenkins job using the pipeline needs to be create manually, this could be detailed in a .groovy file and kept in source control</p>

<p>-- Maintenance required on ECR repo - lifecycle policy to control and manage retention</p>

<p>-- Security is always a consideration - only users that <i>need</i> access to each component, should have access. Achieved via strict IAM roles and permissions.</p>
