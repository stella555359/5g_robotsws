#!/bin/bash


function help()

{

  echo "###############################################################################"
  echo "#                              SCRIPT USAGE INFO                              #"
  echo "###############################################################################"
  echo "# Please enter certificare files names as a arguments                         #"
  echo "# Usage: $0 <cert_file_1> <cert_file_2> ... <cert_file_n>        #"
  echo "###############################################################################"
  exit 1
}

if [ "$#" -lt 1 ]; then
  help
elif [ "$1" == "-h" ]; then
  help
fi

kubectl get cm -n openshift-config user-ca-bundle -o yaml > configmap.yaml
cp configmap.yaml configmap.yaml.bak

echo "[info] Removing unnecessary data from configmap..."

sed -i '/uid:/d' configmap.yaml
sed -i '/resourceVersion:/d' configmap.yaml
sed -i '/creationTimestamp:/d' configmap.yaml
sed -i '/apiVersion:/d' configmap.yaml
sed -i '/kind:/d' configmap.yaml
sed -i '/metadata:/d' configmap.yaml
sed -i '/annotations:/d' configmap.yaml
sed -i '/openshift.io/d' configmap.yaml
sed -i '/name:/d' configmap.yaml
sed -i '/namespace:/d' configmap.yaml

echo "[info] Modyfing configmap..."

touch tmpConfigmap.yaml

cat <<'EOF' >> tmpConfigmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  annotations:
    openshift.io/owning-component: End User
  name: user-ca-bundle
  namespace: openshift-config
EOF

cat configmap.yaml >> tmpConfigmap.yaml

rm -rf configmap.yaml
cp tmpConfigmap.yaml configmap.yaml
rm -rf tmpconfigmap.yaml

echo "[info] Adding new certificates to the configmap..."

for cert in "$@"; do
  if [[ -r "$cert" ]]; then
    sed 's/^/    /' "$cert" >> "configmap.yaml"
  else
    echo "[error] Unable to add cert: $cert" >&2
  fi
done



kubectl apply -f configmap.yaml

