# Janky Vault Cluster

This terraform project creates a vault cluster with internal storage using Raft.
By default it will spin up the cluster in your default VPC, which saves costs.
Pretty much any other choice (e.g. spinning it up in private subnets, or your
own VPC) is untested.

Optionally, you can create a network load balancer and point a route 53 record at
it using the Route 53 zone of your choice.  

The `vault operator init` sequence is unimplemented until I decide what to do with
the resulting keys and tokens.  To initialize a vault, ssh into a vault node as
`ec2-user` and run:

```
sudo su - 
vault operator init
```

Be sure to keep your root token and unseal keys!

The chief reason this project exists is to toy with the auto-unseal feature and
the AWS secrets engine.  Everything is in "experimental" stage right now and you
may use this project at your own peril.
