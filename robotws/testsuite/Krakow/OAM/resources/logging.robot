*** Settings ***
Documentation
...              Author: krzysztof.gryga@nokia.com, rafal.janik@nokia.com, adam.masztalerz@nokia.com, piotr.pinderak@nokia.com
...              Maintainer: rafal.janik@nokia.com, krzysztof.gryga@nokia.com, adam.masztalerz@nokia.com, piotr.pinderak@nokia.com

Library    OperatingSystem
Library    taf.gnb.oam.coam.admin
Library    taf.transport.ssh

Resource    btslog_collecting.robot
Resource    admin.robot


*** Variables ***
${LOGGING_ADMIN_ALIAS}                 default
${LOGGING_ADMIN_API_LOG_DIR}=          ${OUTPUT_DIR}
${LOGGING_ADMIN_INFOMODEL_ALIAS}=      infomodel_1
${LOGGING_ADMIN_INFOMODEL_FILENAME}    infomodel.ims2
${LOGGING_ADMIN_INFOMODEL_LOG_DIR}     ${OUTPUT_DIR}
${LOGGING_ENB_IP}=                     192.168.255.126
${LOGGING_ENB_SYSLOG_LOGNAME}=         syslog_enb.log
${LOGGING_ENB_LOG_DIR}=                /tmp
${LOGGING_ENB_SYSLOG_ALIAS}=           syslog_enb
${LOGGING_RESULTS_DIR}=                ${OUTPUT DIR}
${LOGGING_TSHARK_LOGNAME}              tshark_log
${LOGGING_TSHARK_ALIAS_NAME}           tshark
${LMP_IP}=                             192.168.255.1
${LMP_PORT}=                           443
${ROOT_USERNAME}=                      toor4nsn
${ROOT_PASSWORD}=                      oZPS0POrRieRtu

*** Keywords ***
LOGGING Start Logging
    [Arguments]    ${enb_syslog}=${LOGGING_ENB_SYSLOG}
    ...            ${enb_ip}=${LOGGING_ENB_IP}
    ...            ${enb_syslog_logname}=${LOGGING_ENB_SYSLOG_LOGNAME}
    ...            ${enb_log_dir}=${LOGGING_ENB_LOG_DIR}
    ...            ${enb_syslog_alias}=${LOGGING_ENB_SYSLOG_ALIAS}
    ...            ${admin_log}=${LOGGING_ADMIN_LOG}
    ...            ${admin_port}=${ADMIN_BTS_PORT}
    ...            ${admin_alias}=${LOGGING_ADMIN_ALIAS}
    ...            ${admin_api_log_dir}=${LOGGING_ADMIN_API_LOG_DIR}
    ...            ${admin_infomodel_log}=${LOGGING_ADMIN_INFOMODEL_LOG}
    ...            ${admin_infomodel_alias}=${LOGGING_ADMIN_INFOMODEL_ALIAS}
    ...            ${admin_infomodel_ip}=${ADMIN_INFOMODEL_BTS_HOST}
    ...            ${admin_infomodel_port}=${ADMIN_BTS_PORT}
    ...            ${results_dir}=${OUTPUT_DIR}/${TEST_NAME}
    Create Directory    ${results_dir}

    BTSLOG Start btslog on local machine

    Run Keyword If  ${admin_log}
    ...    ADMIN Setup Admin
    ...    alias=${admin_alias}
    ...    bts_port=${admin_port}
    ...    admin_api_log_dir=${admin_api_log_dir}

LOGGING Stop Logging
    [Arguments]  ${enb_syslog}=${LOGGING_ENB_SYSLOG}
    ...          ${enb_ip}=${LOGGING_ENB_IP}
    ...          ${enb_syslog_logname}=${LOGGING_ENB_SYSLOG_LOGNAME}
    ...          ${enb_log_dir}=${LOGGING_ENB_LOG_DIR}
    ...          ${enb_syslog_alias}=${LOGGING_ENB_SYSLOG_ALIAS}
    ...          ${admin_alias}=${LOGGING_ADMIN_ALIAS}
    ...          ${admin_log}=${LOGGING_ADMIN_LOG}
    ...          ${admin_infomodel_log}=${LOGGING_ADMIN_INFOMODEL_LOG}
    ...          ${admin_infomodel_filename}=${LOGGING_ADMIN_INFOMODEL_FILENAME}
    ...          ${admin_infomodel_log_dir}=${LOGGING_ADMIN_INFOMODEL_LOG_DIR}
    ...          ${admin_infomodel_alias}=${LOGGING_ADMIN_INFOMODEL_ALIAS}
    ...          ${results_dir}=${OUTPUT_DIR}/${TEST_NAME}
    taf.transport.ssh.connect_to
    ...    hostname=${LMP_IP}
    ...    username=${ROOT_USERNAME}
    ...    password=${ROOT_PASSWORD}
    ...    alias=cOAM_toor4nsn
    taf.transport.ssh.force reconnect
    ...    connection=cOAM_toor4nsn
    Run Keyword If    ${admin_infomodel_log}
    ...    taf.gnb.oam.coam.admin.Collect Infomodel Log From Current Session    # update due to 1525_TA_06_29
    ...    target_file_name=${OUTPUT_DIR}/${TEST_NAME}/IM_snapshot.ims2
    ...    connection=${admin_alias}
    ADMIN Setup Admin
    ...    alias=tempalias
    ...    bts_port=${ADMIN_BTS_PORT}
    ...    admin_api_log_dir=${LOGGING_ADMIN_API_LOG_DIR}
#    ADMIN Collect Snapshot
#    ...    snapshot_name=${OUTPUT_DIR}/${TEST_NAME}/Snapshot.zip
#    ...    timeout=900s
#    ...    alias=tempalias

    BTSLOG Collect btslog

    Run Keyword If    ${admin_log}
    ...    ADMIN Teardown Admin
    ...    alias=tempalias

LOGGING Start Syslog Enb
    [Arguments]    ${ip_address}=${LMP_IP}
    ...            ${alias}=cOAM_toor4nsn
    ...            ${password}=${ROOT_PASSWORD}
    ...            ${port}=${LMP_PORT}
    taf.transport.ssh.connect_to
    ...    hostname=${LMP_IP}
    ...    username=${ROOT_USERNAME}
    ...    password=${ROOT_PASSWORD}
    ...    alias=cOAM_toor4nsn
    taf.transport.ssh.send command
    ...    command=journalctl -f > sys.log
    ...    connection=cOAM_toor4nsn
    [Teardown]  taf.transport.ssh.disconnect
    ...    connection=cOAM_toor4nsn
