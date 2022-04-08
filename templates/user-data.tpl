#!/bin/bash

########################################
# Gather info from meta-data / tags
########################################
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

MY_IP=$(curl -s -H "X-aws-ec2-metadata-token: $${TOKEN}" \
  http://169.254.169.254/latest/meta-data/local-ipv4)

VAULT_CLUSTER_ID=$(curl -s -H "X-aws-ec2-metadata-token: $${TOKEN}" \
  http://169.254.169.254/latest/meta-data/tags/instance/vault:cluster-id)

VAULT_CLUSTER_FQDN=$(curl -s -H "X-aws-ec2-metadata-token: $${TOKEN}" \
  http://169.254.169.254/latest/meta-data/tags/instance/vault:cluster-fqdn)

VAULT_NODE_ID=$(curl -s -H "X-aws-ec2-metadata-token: $${TOKEN}" \
  http://169.254.169.254/latest/meta-data/tags/instance/vault:node-id)

VAULT_MASTER_NODE_ID=$(curl -s -H "X-aws-ec2-metadata-token: $${TOKEN}" \
  http://169.254.169.254/latest/meta-data/tags/instance/vault:master-node-id)

VAULT_KMS_KEY_ID=$(curl -s -H "X-aws-ec2-metadata-token: $${TOKEN}" \
  http://169.254.169.254/latest/meta-data/tags/instance/vault:kms-key-id)

AWS_AZ=$(curl -s -H "X-aws-ec2-metadata-token: $${TOKEN}" \
  http://169.254.169.254/latest/meta-data/placement/availability-zone)

# Chop the last character off of the AZ in which the instance was placed
AWS_REGION=$${AWS_AZ:0:$[$${#AWS_AZ} - 1]}

replica_region=${replica_region}
replica_region=$${replica_region:=us-west-2}

function create_or_update_secret() {
  region=$1
  aws secretsmanager create-secret \
   --name /vault/init/$${VAULT_CLUSTER_FQDN} \
   --secret-string "'$(cat $${TEMPDIR}/$${VAULT_CLUSTER_FQDN}-init.json)'" \
   --region $region || :
  if [ $? -eq 255 ]; then
    hash=$(echo $RANDOM | md5sum)
    aws secretsmanager put-secret-value \
     --client-request-token $hash \
     --secret-string "'$(cat $${TEMPDIR}/$${VAULT_CLUSTER_FQDN}-init.json)'" \
     --secret-id /vault/init/$${VAULT_CLUSTER_FQDN} \
     --region $region
  fi
}

########################################
# Install packages
########################################
yum install -y yum-utils
yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
yum -y install vault
yum -y update

mkdir -p 0700 /var/lib/vault/data
chown -R vault:vault /var/lib/vault/data

########################################
# Configure vault
########################################
cat > /etc/vault.d/vault.hcl <<EOF
ui                                  = true
disable_mlock                       = true
cluster_addr                        = "http://$${MY_IP}:8201"
cluster_name                        = "$${VAULT_CLUSTER_ID}"
api_addr                            = "http://$${MY_IP}:8200"
enable_response_header_hostname     = true
enable_response_header_raft_node_id = true


storage "raft" {
  path         = "/var/lib/vault/data"
  node_id      = "$${VAULT_NODE_ID}"
  retry_join {
    auto_join           = "provider=aws region=$${AWS_REGION} tag_key=vault:cluster-id tag_value=$${VAULT_CLUSTER_ID}"
    leader_ca_cert_file = "/opt/vault/tls/ca.crt"
  }
}

listener "tcp" {
  address                            = "0.0.0.0:8200"
  cluster_address                    = "0.0.0.0:8201"
  tls_cert_file                      = "/opt/vault/tls/tls.crt"
  tls_key_file                       = "/opt/vault/tls/tls.key"
  tls_require_and_verify_client_cert = false
}

seal "awskms" {
  region     = "$${AWS_REGION}"
  kms_key_id = "$${VAULT_KMS_KEY_ID}"
}
EOF

rm -f /opt/vault/tls/tls.crt /opt/vault/tls/tls.key

cat > /tmp/ca.crt <<EOF
${ca_crt}
EOF

cat > /tmp/ca.key <<EOF
${ca_key}
EOF

cat >> /etc/vault.d/vault.env <<EOF
VAULT_CACERT=/opt/vault/tls/ca.crt
VAULT_CLIENT_CERT=/opt/vault/tls/client.crt
VAULT_CLIENT_KEY=/opt/vault/tls/client.key
EOF

########################################
# Configure TLS
########################################
base64 -d /tmp/ca.crt > /opt/vault/tls/ca.crt
base64 -d /tmp/ca.key > /opt/vault/tls/ca.key

cat > /tmp/openssl-san.cnf <<EOF
[req]
default_bits = 4096
distinguished_name = req_distinguished_name
req_extensions = req_ext
x509_extensions = v3_req
prompt = no

[req_distinguished_name]
countryName = ${tls_cert_country_name}
stateOrProvinceName = ${tls_cert_state_province_name}
localityName = ${tls_cert_locality_name}
organizationName = $${VAULT_CLUSTER_ID}
commonName = $${VAULT_CLUSTER_FQDN}

[req_ext]
subjectAltName = @alt_names

[v3_req]
subjectAltName = @alt_names

[alt_names]
IP.1 = $${MY_IP}
IP.2 = 127.0.0.1
EOF

# Server cert
openssl req \
  -out /opt/vault/tls/tls.req \
  -new \
  -keyout /opt/vault/tls/tls.key \
  -newkey rsa:2048 \
  -config /tmp/openssl-san.cnf \
  -nodes \
  -sha256 \
  -subj $${VAULT_CLUSTER_FQDN} \
  -days 1095 # 3 years

openssl x509 \
  -req \
  -CA /opt/vault/tls/ca.crt \
  -CAkey /opt/vault/tls/ca.key \
  -in /opt/vault/tls/tls.req \
  -out /tmp/tls.crt \
  -days 1095 \
  -CAserial /opt/vault/tls/ca.srl \
  -CAcreateserial \
  -extfile /tmp/openssl-san.cnf \
  -extensions v3_req

# client cert
openssl req \
  -out /opt/vault/tls/client.req \
  -new \
  -keyout /opt/vault/tls/client.key \
  -newkey rsa:2048 \
  -config /tmp/openssl-san.cnf \
  -nodes \
  -sha256 \
  -subj $${VAULT_NODE_ID}.$${VAULT_CLUSTER_FQDN} \
  -days 1095 # 3 years

openssl x509 \
  -req \
  -CA /opt/vault/tls/ca.crt \
  -CAkey /opt/vault/tls/ca.key \
  -in /opt/vault/tls/client.req \
  -out /tmp/client.crt \
  -days 1095 \
  -CAserial /opt/vault/tls/ca.srl \
  -CAcreateserial \
  -extfile /tmp/openssl-san.cnf \
  -extensions v3_req

cat /tmp/tls.crt /opt/vault/tls/ca.crt > /opt/vault/tls/tls.crt
cat /tmp/client.crt /opt/vault/tls/ca.crt > /opt/vault/tls/client.crt

chown -R vault:vault /opt/vault/tls
chmod go-rwx /opt/vault/tls/*

rm -f /tmp/ca.crt /tmp/ca.key /tmp/openssl-san.cnf /tmp/tls.crt \
 /tmp/client.crt /opt/vault/tls/ca.key /opt/vault/tls/*.req \
 /opt/vault/tls/ca.srl

########################################
# Make life easier for admins
########################################
echo "export VAULT_CAPATH=/opt/vault/tls/ca.crt" >> /etc/profile.d/vault.sh \
 && chmod 755 /etc/profile.d/vault.sh

########################################
# Start services
########################################
systemctl enable vault
systemctl start vault

########################################
# Initialize vault
########################################
sleep 20 
if ( ! vault operator init -status ); then
  if [ "$${VAULT_NODE_ID}" == "$${VAULT_MASTER_NODE_ID}" ]; then
    TEMPDIR=$(mktemp -d)
    for i in $(seq 60); do 
      VAULT_CAPATH=/opt/vault/tls/ca.crt vault operator init -format=json \
       > $${TEMPDIR}/$${VAULT_CLUSTER_FQDN}-init.json \
       && break
       sleep 5
    done

    if [ $? -eq 0 ]; then
      create_or_update_secret $AWS_REGION \
      && create_or_update_secret $replica_region \
      && rm -rf $${TEMPDIR}
    fi
  fi
fi
