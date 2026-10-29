*** Settings ***
Resource    taf/rfrl/bts/robot/common/gnb_log.robot

*** Variables ***
${snapshot_dir}    ${OUTPUT DIR}

*** Test Cases ***
Get Bts Snapshot
    Collect Snapshot From gNB    log_dir=${snapshot_dir}
