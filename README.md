# Janky Vault Cluster

This terraform project creates a vault cluster with internal storage using Raft.
By default it will spin up the cluster in your default VPC, which saves costs.
Pretty much any other choice (e.g. spinning it up in private subnets, or your
own VPC) is untested.

The primary thing that is unimplemented as of this writing (initial commit)
is a network load balancer.  The `vault operator init` sequence is also
unimplemented until I decide what to do with the resulting keys and tokens.

The chief reason this project exists is to toy with the auto-unseal feature and
the AWS secrets engine.  Everything is in "experimental" stage right now.
