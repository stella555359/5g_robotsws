#!/bin/bash

# Usage: $0 <nop_component> <registry_url> [registry_auth]
if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Usage: $0 <nop_component> <registry_url> [registry_auth]"
  exit 1
fi

nop_component=$1
ocp_image_registry_url=$2

if [ "$ocp_image_registry_url" = "image-registry.openshift-image-registry.svc:5000" ]; then
  dockercfg_secret=$(kubectl -n $nop_component get secret --no-headers=true -o custom-columns=Name:metadata.name | grep builder-dockercfg)
  ocp_image_registry_auth=$(kubectl -n $nop_component get secret ${dockercfg_secret} -o jsonpath='{.data.*}' | base64 -d | jq -r --arg reg ${ocp_image_registry_url} '.[$reg] | .auth' | base64 -d)
else
  if [ -z "$3" ]; then
    echo "For remote registry, provide registry_auth as third argument."
    exit 1
  fi
  ocp_image_registry_auth=$3
fi

for image_tar_file in $(ls ./Image); do
  echo $image_tar_file
  load_output=$(podman load -i ./Image/$image_tar_file)
  old_tag=${load_output##* }
  new_tag=${ocp_image_registry_url}/$nop_component/${old_tag##*/}
  podman tag ${old_tag} ${new_tag}
  podman push --creds ${ocp_image_registry_auth} ${new_tag}
  podman rmi $old_tag
done

podman image ls | grep -i $nop_component