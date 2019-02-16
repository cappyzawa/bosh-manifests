#!/bin/bash

bosh deploy -d concourse concourse-deployment/cluster/concourse.yml \
     -l concourse-deployment/versions.yml \
     -o concourse-deployment/cluster/operations/static-web.yml \
     -o concourse-deployment/cluster/operations/basic-auth.yml \
     -o concourse-deployment/cluster/operations/external-postgres.yml \
     -o ops-files/concourse-emtpy-certs-path.yml \
     -o ops-files/use-specific-stemcell.yml \
     -o ops-files/concourse-teams.yml \
     -o ops-files/concourse-variables.yml \
     -o prometheus-boshrelease/manifests/operators/concourse/enable-prometheus-metrics.yml \
     -o <(cat <<EOF
- type: replace
  path: /releases/name=concourse/url
  value: https://192-168-11-108.sslip.io:9000/public/concourse-4.2.3.tgz
- type: replace
  path: /releases/name=concourse/version
  value: 4.2.3
- type: replace
  path: /releases/name=concourse/sha1
  value: 0e726361c87aa4225f1a78109cb0b7dfecd1dacd
- type: replace
  path: /releases/name=garden-runc/url
  value: https://bosh.io/d/github.com/cloudfoundry/garden-runc-release?v=1.18.2
- type: replace
  path: /releases/name=garden-runc/version
  value: 1.18.2
- type: replace
  path: /releases/name=garden-runc/sha1
  value: f761349dfe829fb2e17ab53eb058267209275038
EOF) \
     -v stemcell_version="97" \
     -v web_ip=10.244.1.120 \
     -v external_url=https://concourse.ik.am:14161 \
     -v network_name=default \
     -v web_vm_type=default \
     -v db_vm_type=default \
     -v db_persistent_disk_type=default \
     -v worker_vm_type=default \
     -v deployment_name=concourse \
     -v postgres_host=192.168.220.40 \
     -v postgres_port=5432 \
     -v postgres_role=atc \
     -v credhub_url=https://10.244.1.100:8844 \
     -v credhub-ip=10.244.1.100 \
     -v uaa-url=https://192.168.50.6:8443 \
     --var-file uaa-tls.ca=<(bosh int bosh-lite-creds.yml --path /uaa_ssl/ca) \
     --var-file uaa-jwt.public_key=<(bosh int bosh-lite-creds.yml --path /uaa_jwt_signing_key/public_key) \
     -v credhub_client_id=director_to_credhub \
     -v credhub_client_secret=`bosh int bosh-lite-creds.yml --path /uaa_clients_director_to_credhub` \
     -v vault_url=https://10.244.0.98:8200 \
     --var-file vault_cert.ca=<(credhub get -n /bosh-lite/vault/concourse-tls -j | jq -r .value.ca) \
     --var-file vault_cert.certificate=<(credhub get -n /bosh-lite/vault/concourse-tls -j | jq -r .value.certificate) \
     --var-file vault_cert.private_key=<(credhub get -n /bosh-lite/vault/concourse-tls -j | jq -r .value.private_key) \
     --no-redact

#     -o concourse-deployment/cluster/operations/vault-tls-cert-auth.yml \
# -o ops-files/concourse-credhub.yml \
# -o ops-files/concourse-credhub-external-postgres.yml \
# -o ops-files/concourse-variables.yml \
