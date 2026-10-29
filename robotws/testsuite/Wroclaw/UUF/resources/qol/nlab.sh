#!/bin/bash
LAB="2001"
if [[ $1 ]]; then
  LAB="$1"
fi

google-chrome https://srnclab"$LAB"lbwas.srnblr.nsn-rdnet.net/authentication/Login &>/dev/null &
