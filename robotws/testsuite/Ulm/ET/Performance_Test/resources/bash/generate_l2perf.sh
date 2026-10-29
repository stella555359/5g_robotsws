#!/bin/bash

# How to use
# /home/ute/DEVELOPMENT/robotws/testsuite/Ulm/ET/Performance_Test/resources/bash/generate_l2perf.sh "${LOG_PATH}" "${LXC_CONTAINER}" "${DISP_LOG}"
#

echo "################################################################################"
echo "generate_l2perf.sh"
echo "################################################################################"

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
LIBRARY_UPDATE_FREQ=604800

LOG_PATH=$1
LXC_CONTAINER=$2
DISP_LOG=$3

SETUP_ONLY=0
MAX_RETRY=10

UTE_SH_PY_ENV=/home/ute/DEVELOPMENT/env_activate
REPO_LOCATION=/home/ute/DEVELOPMENT/l2perf
VAR_IS_FAILED=0

if [ -z "${LOG_PATH}" ];then
    echo "LOG_PATH or 'setup' must be provided as first arg!"
    exit 1
fi
if [[ "${LOG_PATH}" != "setup" ]]; then

    if [ -z "${LXC_CONTAINER}" ];then
        echo "LXC_CONTAINER must be provided as second arg! e.x. 0x1730"
        exit 1
    fi

    if [ -z "${DISP_LOG}" ];then
        echo "DISP_LOG must be provided as third arg! e.x. Disp_4,Disp_5"
        exit 1
    fi
else
    SETUP_ONLY=1
fi


update_git_l2perf(){
    echo "--------------------------------------------------------------------------------"
    echo "update_git_l2perf"
    echo "--------------------------------------------------------------------------------"
    # export {http,https,ftp}_proxy=http://87.254.212.120:8080/

    mkdir -p ${REPO_LOCATION}

    echo "    ------------------------------------------------------------------------"
    echo "    clone l2perf.git"
    echo "    ------------------------------------------------------------------------"
    git -C ${REPO_LOCATION} pull || git clone https://nvaldez:glpat-2PTv6yY6zbUXyeobcFnZ@gitlabe1.ext.net.nokia.com/l2-sw-krk-10/l2perf.git ${REPO_LOCATION}
    echo "    clone l2perf.git done..."
    set +e
    pushd ${REPO_LOCATION}
        git reset --hard && git clean -fd && git checkout -B main origin/main && git checkout main && git pull --prune && git status;
    popd
    unset {http,https,ftp}_proxy
    set -e

    update_check_location='/tmp/l2perf_update.txt'
    if [ ! -f ${update_check_location} ]; then
        touch ${update_check_location}
    fi
    echo "    ------------------------------------------------------------------------"
    echo "    python3 -m pip install -r requirements.txt"
    echo "    ------------------------------------------------------------------------"
    current=$(date +%s)
    last_modified=$(stat -c "%Y" ${update_check_location})
    if [ $((current - last_modified)) -gt ${LIBRARY_UPDATE_FREQ} ]; then
        pushd ${REPO_LOCATION}
            python3 -m pip install -r requirements.txt
            echo "    pip install requirements.txt done..."
        popd
    else
        echo '    Skip library update'
    fi
    echo "update_git_l2perf done..."
}


collect_logs(){
    echo "--------------------------------------------------------------------------------"
    echo "collect_logs"
    echo "--------------------------------------------------------------------------------"
    pushd ${REPO_LOCATION}
        echo "    ------------------------------------------------------------------------"
        echo "    python3 l2perf.py get_info"
        echo "    ------------------------------------------------------------------------"
        echo "" > /tmp/get_info.txt
        retry_count=0
        while : ; do
            python3 l2perf.py get_info | tee -a /tmp/get_info.txt
            if [[ "$(cat /tmp/get_info.txt)" == *"L2PsSch"* ]]; then
                break
            fi
            if [[ ${retry_count} -gt ${MAX_RETRY} ]]; then
                echo "        ------------------------------------------------------------------------"
                echo "        max retry reached!"
                echo "        ------------------------------------------------------------------------"
                exit 1;
            else
                retry_count=$((${retry_count}+1))
                echo "        ------------------------------------------------------------------------"
                echo "        Retry (${retry_count})"
                echo "        ------------------------------------------------------------------------"
            fi
        done
        echo "    python3 l2perf.py get_info done.."

        # wait for credentials prompt
        # Enter SVN username: ca_l2perf
        # Enter SVN password: L2PerfBench
        echo "    ------------------------------------------------------------------------"
        echo "    python3 l2perf.py download"
        echo "    ------------------------------------------------------------------------"
        python3 l2perf.py download
        echo "    python3 l2perf.py download done..."
        # ${SCRIPT_DIR}/generate_l2perf_expect.sh

        echo "    ------------------------------------------------------------------------"
        echo "    python3 l2perf.py install"
        echo "    ------------------------------------------------------------------------"
        python3 l2perf.py install -l ${LXC_CONTAINER}
        echo "    python3 l2perf.py install done.."
        mkdir -p ${LOG_PATH}

        echo "    ------------------------------------------------------------------------"
        echo "    python3 l2perf.py collect_logs "
        echo "    -l ${LXC_CONTAINER}"
        echo "    -d ${DISP_LOG}"
        echo "    -o ${LOG_PATH}"
        echo "    ------------------------------------------------------------------------"
        python3 l2perf.py collect_logs -l ${LXC_CONTAINER} -d ${DISP_LOG} -o ${LOG_PATH}
        echo "    python3 l2perf.py collect_logs done..."
        result=$?
        if [ ${result} != 0 ];then
            VAR_IS_FAILED=${result}
        fi
    popd
    echo "collect_logs done..."
}

main(){
    # echo "    ------------------------------------------------------------------------"
    # echo "    source ${UTE_SH_PY_ENV}"
    # echo "    ------------------------------------------------------------------------"
    # source ${UTE_SH_PY_ENV}
    update_git_l2perf

    if [[ "${SETUP_ONLY}" == "0" ]]; then
        collect_logs
    fi
    if [ ${VAR_IS_FAILED} != 0 ];then
        echo "generate_l2perf failed with exit code: ${VAR_IS_FAILED} !!!"
        exit ${VAR_IS_FAILED}
    fi
    echo "    ------------------------------------------------------------------------"
    echo '    generate_l2perf.sh done!'
    echo "    ------------------------------------------------------------------------"
}

main
