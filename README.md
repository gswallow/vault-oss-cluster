# Janky Vault Cluster

This terraform project creates a vault cluster with internal storage using Raft.
By default it will spin up the cluster in your default VPC, which saves costs.
Pretty much any other choice (e.g. spinning it up in private subnets, or your
own VPC) is untested.

Optionally, you can create a network load balancer and point a route 53 record at
it using the Route 53 zone of your choice.  

Root tokens will be stored in AWS Secrets Manager, in a primary and secondary AWS
region, under the "/vault/init/cluster-name" secret parameter. CLI commands can
be run by setting the `VAULT_TOKEN` environment variable on one of the nodes. The
`VAULT_CAPATH` environment variable should be set for you (per 
`/etc/profile.d/vault.sh`).  For security reasons, the vault instances have the
ability to create and update parameters in AWS Secrets Manager, but not to 
retrieve the values.

The chief reason this project exists is to toy with the auto-unseal feature and
the AWS secrets engine.  Everything is in "experimental" stage right now and you
may use this project at your own peril.

### CA Certs
Mac users: you can import the CA cert to your system keychain using Keychain
Access.  This will allow you to trust the CA cert, and actually visit the vault
cluster you've stood up.
