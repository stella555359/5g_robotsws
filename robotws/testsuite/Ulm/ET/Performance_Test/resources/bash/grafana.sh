#!/bin/bash


scripts_dir=${1}
snapshot_dir=${2}
TEST_STATUS=${3}
deployment=${4}
board=${5}
TEST_NAME=${6}
WORKSPACE=${7}
gnb_version=${8}
ap_version=${9}
database=${10}
report_to_grafana=${11}

JOB_NAME=${12}
JOB_URL=${13}
BUILD_ID=${14}

export JOB_NAME=${JOB_NAME}
export JOB_URL=${JOB_URL}
export BUILD_ID=${BUILD_ID}


snapshot_extract(){
    echo '* * * * * * * * * * * * * * * * * *  Running snapshot_extract.py  * * * * * * * * * * * * * * * * * *'
    mkdir -p ${WORKSPACE}/KpiData
    echo 'N' | python3 ${scripts_dir}/step4_scripts/snapshot_extract.py \
        -o ${WORKSPACE} \
        -s ${snapshot_dir}/gnb-0-classical-snapshot/snapshot.zip \
        -v ${TEST_STATUS} \
        -d ${deployment} \
        -b ${board} \
        -t ${TEST_NAME} \
        -f ${scripts_dir}/step4_scripts/ \
        -p ${scripts_dir}/step4_scripts/path2L2PsLogs/ \
        -g ${gnb_version} \
        -a ${ap_version} \
        -db ${database}
}

update_json(){
    echo '* * * * * * * * * * * * * * * * * * * *  Running update_json.py * * * * * * * * * * * * * * * * * * * *'
    python3 ${scripts_dir}/step5_scripts/update_json.py ${WORKSPACE}/KpiData/data_${TEST_NAME}.json
}

perfdata_processor(){
    if [[ "${report_to_grafana}" == "true" && "${TEST_STATUS^^}" == "PASS" ]]
    then
        echo '* * * * * * * * * * * * * * * * * *  Running perfdata_processor.py  * * * * * * * * * * * * * * * * * *'
        python3 ${scripts_dir}/step5_scripts/perfdata_processor.py by_json ${WORKSPACE}/KpiData/data_${TEST_NAME}.json
    else
        echo '! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! SKIP REPORT TO GRAFANA ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! !'
    fi
}

main(){
    # shellcheck disable=SC1091
    source /home/ute/DEVELOPMENT/env_activate
    snapshot_extract
    update_json
    # perfdata_processor   # this is now handled by robot to intercept json
}

main
