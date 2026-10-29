*** Settings ***
Documentation   Keywords regarding preparation setup, teardown and base logs collection.
...             Author:     Tomasz Stawowczyk
...             Contact:    tomasz.stawowczyk@nokia.com

Library         taf.sbts.oam.coam.admin  WITH NAME   coam_admin
Library         OperatingSystem
Library         taf.sw.syslog            WITH NAME    syslog

*** Keywords ***
Creating Log Directory
    ${timestamp}  OperatingSystem.Run  date +%F_%H-%M-%S
    ${LOG_PATH}   OperatingSystem.Join Path  ${OUTPUT DIR}  ${timestamp}_${TEST NAME}
    Create Directory  ${LOG_PATH}
    Set Test Variable  ${LOG_PATH}

TC Setup
    Creating Log Directory
    Setup Admin    bts_host=${MPLANE}    alias=${CONNECTION}
    Start Syslog    log_dir=${LOG_PATH}    log_name=UDP_eNB    ip=${SYSLOG_IP}    ssh_password=${VM_PASS}    alias=${CONNECTION}
    Wait Until Keyword Succeeds     1m    30s    Check That The BTS Is Fully Operational
    ...    connection=${CONNECTION}    ignored_alarms=${IGNORED_ALARMS}

TC Teardown
    Collect Syslog Results    unzip=False    alias=${CONNECTION}
    Teardown Admin    connection=${CONNECTION}

Create Abstract Library Path
    ${hostname}    Run    hostname
    ${hostname}    Evaluate    '${hostname}'.replace('-', '_')
    Set Suite Variable    ${ABSTRACT_LIB_CONFIG}    /home/ute/testline_configuration/${hostname}/ta_ue_config.yaml
