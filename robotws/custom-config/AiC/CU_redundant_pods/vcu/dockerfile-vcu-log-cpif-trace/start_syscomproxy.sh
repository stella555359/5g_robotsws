#! /bin/sh
echo -e "[control]\nLoggingSeverity=trace" > /ffs/run/cp_runtime.ini; chmod a+r /ffs/run/cp_runtime.ini
echo "Start to run syscom-proxy"
/usr/bin/env sh -c "/opt/nokia/SS_SYSCOMPROXY/syscom-proxy 2>&1"
