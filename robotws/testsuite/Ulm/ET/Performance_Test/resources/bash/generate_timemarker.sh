#!/bin/bash

# How to use
# generate_timemarker.sh <SNAPSHOT_PATH>
#

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

TM2CHROME_PY=${SCRIPT_DIR}/tm2chrome.py
UTE_SH_PY_ENV=/home/ute/DEVELOPMENT/env_activate

echo "################################################################################"
echo "generate_timemarker.sh"
echo "################################################################################"
SNAPSHOT_PATH=$1
TM2CHROME_PY=$2

TMP_SNAPSHOT_EXTRACT_DIR='/tmp/snapshot_extract'
TMP_TIMEMARKER_DIR='/tmp/time_marker'

VAR_IS_FAILED=0

if [ ! -f "${SNAPSHOT_PATH}" ];then
        echo "SNAPSHOT_PATH is not a file !!!"
        echo "pass it as first argument !!!"
        exit 1
fi

if [ -z "${TM2CHROME_PY}" ];then
    if  [ -f ${SCRIPT_DIR}/tm2chrome.py ];then
        TM2CHROME_PY=${SCRIPT_DIR}/tm2chrome.py
    else
        echo "TM2CHROME_PY is undefined !!!"
        echo "pass it as second argument !!!"
        exit 1
    fi
fi

extract_snapshot(){
    rm -rf ${TMP_SNAPSHOT_EXTRACT_DIR}/

    unzip -q ${SNAPSHOT_PATH} -d /tmp/snapshot_extract

    pushd ${TMP_SNAPSHOT_EXTRACT_DIR}/
        unzip -q \*.zip
    popd
}

generate_timemarker_json(){
    echo "generate_timemarker_json"
    rm -rf ${TMP_TIMEMARKER_DIR}/
    mkdir ${TMP_TIMEMARKER_DIR}/

    cp $(find ${TMP_SNAPSHOT_EXTRACT_DIR}/ -type f -name "*TimeMarker*") ${TMP_TIMEMARKER_DIR}/

    for tmfile in $(find ${TMP_TIMEMARKER_DIR}/ -type f -name "*TimeMarker*")
    do
        echo - extracting: ${tmfile}
        unxz ${tmfile}
    done


    for tmfile in $(find ${TMP_TIMEMARKER_DIR}/ -type f -name "*TimeMarker*")
    do
        echo python3 ${TM2CHROME_PY} -f ${tmfile} -d
        python3 ${TM2CHROME_PY} -f ${tmfile} -d
        result=$?
        if [ ${result} != 0 ];then
            VAR_IS_FAILED=${result}
        fi
    done
    echo "generate_timemarker_json done..."
}

generate_html(){
    echo "generate_html"
    repo_location=/home/ute/DEVELOPMENT/catapult

    mkdir -p ${repo_location}
    export {http,https,ftp}_proxy=http://87.254.212.120:8080/
    git -C ${repo_location} pull || git clone https://chromium.googlesource.com/catapult ${repo_location}
    unset {http,https,ftp}_proxy

    for jsonfile in $(find ${TMP_TIMEMARKER_DIR}/ -type f -name "*.json*")
    do
        echo "${repo_location}/tracing/bin/trace2html ${jsonfile}"
        ${repo_location}/tracing/bin/trace2html ${jsonfile}
        result=$?
        if [ ${result} != 0 ];then
            VAR_IS_FAILED=${result}
        fi
    done
    echo "generate_html done..."
}

main(){
    echo Extracting Snapshot: ${SNAPSHOT_PATH}
    source ${UTE_SH_PY_ENV}
    extract_snapshot
    echo ''
    generate_timemarker_json
    echo $(find ${TMP_TIMEMARKER_DIR}/ -type f -name "*TimeMarker*")
    echo ''
    generate_html
    echo $(find ${TMP_TIMEMARKER_DIR}/ -type f -name "*.html*")


    if [ ${VAR_IS_FAILED} != 0 ];then
        echo "generate_timemarker failed with exit code: ${VAR_IS_FAILED} !!!"
        exit ${VAR_IS_FAILED}
    fi

    echo 'generate_timemarker.sh done!'
}

main
