#!/bin/bash

mkdir vrfrepos && cd vrfrepos

openssl s_client -showcerts -connect ccr-wg-vrf-vdu-01.wroclaw.nsn-rdnet.net:443 </dev/null 2>/dev/null|openssl x509 -outform PEM >ca_ccr-wg-vrf-vdu-01.crt

openssl s_client -showcerts -connect ccr-wg-vrf-vcu-01.wroclaw.nsn-rdnet.net:443 </dev/null 2>/dev/null|openssl x509 -outform PEM >ca_ccr-wg-vrf-vcu-01.crt

openssl s_client -showcerts -connect ccr-wl-vrf-vdu-01.wroclaw.nsn-rdnet.net:443 </dev/null 2>/dev/null|openssl x509 -outform PEM >ca_ccr-wl-vrf-vdu-01.crt

openssl s_client -showcerts -connect ccr-wl-vrf-vcu-01.wroclaw.nsn-rdnet.net:443 </dev/null 2>/dev/null|openssl x509 -outform PEM >ca_ccr-wl-vrf-vcu-01.crt

oc create configmap registry-vrf -n openshift-config \
--from-file=ccr-wg-vrf-vcu-01.wroclaw.nsn-rdnet.net..443=ca_ccr-wg-vrf-vcu-01.crt \
--from-file=ccr-wg-vrf-vdu-01.wroclaw.nsn-rdnet.net..443=ca_ccr-wg-vrf-vdu-01.crt \
--from-file=ccr-wl-vrf-vcu-01.wroclaw.nsn-rdnet.net..443=ca_ccr-wl-vrf-vcu-01.crt \
--from-file=ccr-wl-vrf-vdu-01.wroclaw.nsn-rdnet.net..443=ca_ccr-wl-vrf-vdu-01.crt

oc patch image.config.openshift.io/cluster --patch '{"spec":{"additionalTrustedCA":{"name":"registry-vrf"}}}' --type=merge

oc get secret/pull-secret -n openshift-config --template='{{index .data ".dockerconfigjson" | base64decode}}' > global_pull_secret

oc registry login --registry="ccr-wg-vrf-vdu-01.wroclaw.nsn-rdnet.net:443" --auth-basic='robot$vrf:zS8IxZm4R6H8Heu2NWFmd8wQMCRDv3b9' --to=global_pull_secret
oc registry login --registry="ccr-wg-vrf-vcu-01.wroclaw.nsn-rdnet.net:443" --auth-basic='robot$vrf:oeMnGLawBTTPPC20EZqH0YCEqZKLqu0U' --to=global_pull_secret
oc registry login --registry="ccr-wl-vrf-vdu-01.wroclaw.nsn-rdnet.net:443" --auth-basic='robot$vrf:m7SRFboceS9eRedcLu1yGvAoMq2YKX5o' --to=global_pull_secret
oc registry login --registry="ccr-wl-vrf-vcu-01.wroclaw.nsn-rdnet.net:443" --auth-basic='robot$vrf:biG31GZUCZ0XCUIWVGp8eaKsHBzH8nIR' --to=global_pull_secret

oc get cm registry-vrf -n openshift-config -o yaml

oc set data secret/pull-secret -n openshift-config --from-file=.dockerconfigjson=global_pull_secret
