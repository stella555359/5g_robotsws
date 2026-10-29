ocp_local_image_registry_url=image-registry.openshift-image-registry.svc:5000
dockercfg_secret=`kubectl -n nokia-sync-operator get secret --no-headers=true -o custom-columns=Name:metadata.name |grep builder-dockercfg`
ocp_local_image_registry_auth=`kubectl -n nokia-sync-operator get secret ${dockercfg_secret} -o jsonpath='{.data.*}' | base64 -d | jq -r --arg reg ${ocp_local_image_registry_url} '.[$reg] | .auth' | base64 -d`
for image_tar_file in `ls ./Image`; do echo $image_tar_file; load_output=$(podman load -i ./Image/$image_tar_file); old_tag=${load_output##* }; new_tag=${ocp_local_image_registry_url}/nokia-sync-operator/${old_tag##*/}; podman tag ${old_tag} ${new_tag}; podman push --creds ${ocp_local_image_registry_auth} ${new_tag}; podman rmi $old_tag; done
podman image ls |grep -i sync

