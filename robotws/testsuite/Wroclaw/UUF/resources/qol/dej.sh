#!/bin/bash
HOST=$(hostname)
suffix=${HOST##*-}
if [[ ${#suffix} != 1 ]]; then
  #without suffix such as -1, -2 etc
  REALHOST=$HOST
else
  #with suffix such as -1, -2
  if [[ $suffix != "1" ]]; then
    #not on primary node
    suffix=""
  fi
  REALHOST=${HOST%-*}
fi

if [[ -z $suffix ]]; then
  #catch exception not on primary node
  echo "you are on the wrong node, you dummy!"
else
  UNDERHOST="${REALHOST//-/_}"
  CONFIGPATH="/home/ute/testline_configuration/$UNDERHOST"
  CHECKMOUNT=$(mount | grep /home/ute/.ute-ca/cache/bts)
  LABEL=$(cat ${CONFIGPATH}/__init__.py | grep tl_cloud_topology | cut -d'"' -f 2)
  if [[ -z "$1" ]]; then
    echo "set the build, you dummy!"
  elif [[ -z "$LABEL" ]]; then
    echo "couldn't detect topology from /home/ute/testline_configuration/$UNDERHOST/__init__.py"
  elif [[ -n "$CHECKMOUNT" ]]; then
    echo "burak is mounted, use alias:uteca to dismount, you dummy!"
  elif [[ $1 =~ ^(SBTS)[0-9]{2}((R)[0-9]{1})?(_)(ENB|FSM3)(_)[0-9]{4}(_)[0-9]{6}(_)[0-9]{6}$ ]]; then
    agentctl exec --label ${LABEL} --sm-build $1 --required-state on_air
    echo $?
  else
    echo "set the PROPER build, you dummy!"
  fi
fi