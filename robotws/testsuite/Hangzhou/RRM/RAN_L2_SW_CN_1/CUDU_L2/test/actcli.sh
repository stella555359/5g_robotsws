#!/bin/bash
unset https_proxy
unset http_proxy
echo "Doing my own stuff in $dir ..."
set -x
echo "Collect snapshot and scf file"
TEMPDIR=/tmp/admin-cli
rm -rf $TEMPDIR
mkdir $TEMPDIR
pushd $TEMPDIR > /dev/null
sshpass -p oZPS0POrRieRtu scp -q toor4nsn@192.168.255.1:/ffs/run/swpool/OAM/admin-cli*zip ./
unzip -q admin-cli*zip
popd > /dev/null
$TEMPDIR/admin-cli.sh --bundles-dir=$TEMPDIR --bts-username=Nemuadmin --bts-password=nemuuser --bts-host=192.168.255.1 --bts-port=443 --data='{"requestId":1,"parameters":{"name":"generateScf"}}' --output-file SCF.xml
rm -rf $TEMPDIR
echo "Done with $dir"
