*** Settings ***
Documentation    Author: tomasz.blaszczyszyn@nokia.com; kacper.halas@nokia.com; filip.radwanski@nokia.com; michal.laski@nokia.com
...              Maintainer: tomasz.blaszczyszyn@nokia.com; kacper.halas@nokia.com; filip.radwanski@nokia.com; michal.laski@nokia.com
...              Description: These keywords handles actions performed with ute_admin library refering to ADMIN functionalities
...              FT in charge: name + mailing list
...              Confluence link:
...              References: (documentation link(e.g. doors or sphinx))
...              QualityCenter: (test set url to QC)
...              Sample execution:

Library     OperatingSystem
Library     ute_syslog
Library     ute_tshark

Resource    ./admin.robot
Resource    ./admin_infomodel.robot
Resource    ./pretest_posttest.robot
Resource    ./emssim.robot

*** Variables ***
${LOGGING_ADMIN_ALIAS}               admin_1
${LOGGING_ADMIN_API_LOG_DIR}=        ${OUTPUT_DIR}
${LOGGING_ADMIN_INFOMODEL_ALIAS}=    infomodel_1
${LOGGING_ADMIN_INFOMODEL_FILENAME}  infomodel.ims2
${LOGGING_ADMIN_INFOMODEL_LOG_DIR}   ${OUTPUT_DIR}
${LOGGING_ENB_IP}=                   192.168.255.126
${LOGGING_ENB_SYSLOG_LOGNAME}=       syslog_enb.log
${LOGGING_ENB_LOG_DIR}=              /tmp
${LOGGING_ENB_SYSLOG_ALIAS}=         syslog_enb
${LOGGING_IPHY_IP}=                  192.168.200.126
${LOGGING_IPHY_SYSLOG_LOGNAME}=      syslog_iphy.log
${LOGGING_IPHY_LOG_DIR}=             /tmp
${LOGGING_IPHY_SYSLOG_ALIAS}=        syslog_iphy
${LOGGING_RESULTS_DIR}=              ${OUTPUT DIR}
${LOGGING_TSHARK_LOGNAME}            tshark_log
${LOGGING_TSHARK_ALIAS_NAME}         tshark
${LOGGING_EMSSIM_LOG_DIR}            /home/flexi1/emssim_log.log
${LOGGING_EMSSIM_ENB_ID}             1
${LOGGING_EMSSIM_HOST}               10.0.1.1
${LOGGING_EMSSIM_PORT}               4001

*** Keywords ***
LOGGING Start Logging
    [Arguments]    ${enb_syslog}=${LOGGING_ENB_SYSLOG}
    ...            ${enb_ip}=${LOGGING_ENB_IP}
    ...            ${enb_syslog_logname}=${LOGGING_ENB_SYSLOG_LOGNAME}
    ...            ${enb_log_dir}=${LOGGING_ENB_LOG_DIR}
    ...            ${enb_syslog_alias}=${LOGGING_ENB_SYSLOG_ALIAS}
    ...            ${iphy_syslog}=${LOGGING_IPHY_SYSLOG}
    ...            ${iphy_ip}=${LOGGING_IPHY_IP}
    ...            ${iphy_syslog_logname}=${LOGGING_IPHY_SYSLOG_LOGNAME}
    ...            ${iphy_log_dir}=${LOGGING_IPHY_LOG_DIR}
    ...            ${iphy_syslog_alias}=${LOGGING_IPHY_SYSLOG_ALIAS}
    ...            ${admin_log}=${LOGGING_ADMIN_LOG}
    ...            ${admin_port}=${ADMIN_PORT}
    ...            ${admin_alias}=${LOGGING_ADMIN_ALIAS}
    ...            ${admin_api_log_dir}=${LOGGING_ADMIN_API_LOG_DIR}
    ...            ${admin_infomodel_log}=${LOGGING_ADMIN_INFOMODEL_LOG}
    ...            ${admin_infomodel_alias}=${LOGGING_ADMIN_INFOMODEL_ALIAS}
    ...            ${admin_infomodel_ip}=${ADMIN_INFOMODEL_BTS_HOST}
    ...            ${admin_infomodel_port}=${ADMIN_PORT}
    ...            ${emssim_log}=${LOGGING_EMSSIM_LOG}
    ...            ${emssim_enb_id}=${LOGGING_EMSSIM_ENB_ID}
    ...            ${emssim_host}=${LOGGING_EMSSIM_HOST}
    ...            ${emssim_port}=${LOGGING_EMSSIM_PORT}
    ...            ${emssim_log_dir}=${LOGGING_EMSSIM_LOG_DIR}
    ...            ${results_dir}=${LOGGING_RESULTS_DIR}/${TEST_NAME}
    Create Directory    ${results_dir}
    Run Keyword If  ${admin_log}
    ...  ADMIN Setup Admin  alias=${admin_alias}
    ...                     bts_port=${admin_port}
    ...                     admin_api_log_dir=${admin_api_log_dir}
    Run Keyword If  ${admin_infomodel_log}
    ...  ADMIN INFOMODEL Start Logging    admin_infomodel_ip=${admin_infomodel_ip}
    ...                                   admin_infomodel_port=${admin_infomodel_port}
    ...                                   alias=${admin_infomodel_alias}
    Run Keyword If  ${enb_syslog}
    ...  LOGGING Start Syslog Enb  ip=${enb_ip}
    ...                            log_dir=${enb_log_dir}
    ...                            log_name=${enb_syslog_logname}
    ...                            alias=${enb_syslog_alias}
    Run Keyword If  ${iphy_syslog}
    ...  LOGGING Start Syslog Iphy  ip=${iphy_ip}
    ...                             log_dir=${iphy_log_dir}
    ...                             log_name=${iphy_syslog_logname}
    ...                             alias=${iphy_syslog_alias}
    Run Keyword If   ${emssim_log}
    ...  EMSSIM Setup Emssim    enb_id=${emssim_enb_id}
    ...                         host=${emssim_host}
    ...                         port=${emssim_port}
    ...                         log_dir=${emssim_log_dir}

LOGGING Stop Logging
    [Arguments]  ${enb_syslog}=${LOGGING_ENB_SYSLOG}
    ...          ${enb_ip}=${LOGGING_ENB_IP}
    ...          ${enb_syslog_logname}=${LOGGING_ENB_SYSLOG_LOGNAME}
    ...          ${enb_log_dir}=${LOGGING_ENB_LOG_DIR}
    ...          ${enb_syslog_alias}=${LOGGING_ENB_SYSLOG_ALIAS}
    ...          ${iphy_syslog}=${LOGGING_IPHY_SYSLOG}
    ...          ${iphy_ip}=${LOGGING_IPHY_IP}
    ...          ${iphy_syslog_logname}=${LOGGING_IPHY_SYSLOG_LOGNAME}
    ...          ${iphy_log_dir}=${LOGGING_IPHY_LOG_DIR}
    ...          ${iphy_syslog_alias}=${LOGGING_IPHY_SYSLOG_ALIAS}
    ...          ${admin_alias}=${LOGGING_ADMIN_ALIAS}
    ...          ${admin_log}=${LOGGING_ADMIN_LOG}
    ...          ${admin_infomodel_log}=${LOGGING_ADMIN_INFOMODEL_LOG}
    ...          ${admin_infomodel_filename}=${LOGGING_ADMIN_INFOMODEL_FILENAME}
    ...          ${admin_infomodel_log_dir}=${LOGGING_ADMIN_INFOMODEL_LOG_DIR}
    ...          ${admin_infomodel_alias}=${LOGGING_ADMIN_INFOMODEL_ALIAS}
    ...          ${emssim_log}=${LOGGING_EMSSIM_LOG}
    ...          ${emssim_log_dir}=${LOGGING_EMSSIM_LOG_DIR}
    ...          ${results_dir}=${LOGGING_RESULTS_DIR}/${TEST_NAME}
    Run Keyword If    ${admin_log}
    ...  ADMIN Teardown Admin  alias=${admin_alias}
    Run Keyword If    ${admin_infomodel_log}
    ...  ADMIN INFOMODEL Stop Logging  filename=${admin_infomodel_filename}
    ...                                log_dir=${results_dir}
    ...                                alias=${admin_infomodel_alias}
    Run Keyword If    ${enb_syslog}
    ...  LOGGING Stop Syslog Enb  log_name=${enb_syslog_logname}
    ...                           log_dir=${results_dir}
    ...                           alias=${enb_syslog_alias}
    Run Keyword If    ${iphy_syslog}
    ...  LOGGING Stop Syslog Iphy  log_name=${iphy_syslog_logname}
    ...                            log_dir=${results_dir}
    ...                            alias=${iphy_syslog_alias}
    Run Keyword If   ${emssim_log}
    ...  EMSSIM Teardown Emssim    output_log_dir=${results_dir}
    ...                            emssim_log_dir=${emssim_log_dir}

LOGGING Start Syslog Enb
    [Arguments]    ${log_dir}=${LOGGING_ENB_LOG_DIR}
    ...            ${log_name}=${LOGGING_ENB_SYSLOG_LOGNAME}
    ...            ${ip}=${LOGGING_ENB_IP}
    ...            ${alias}=${LOGGING_ENB_SYSLOG_ALIAS}
    ute_syslog.Start Syslog    log_dir=${log_dir}
    ...                        log_name=${log_name}
    ...                        ip=${ip}
    ...                        alias=${alias}

LOGGING Start Syslog Iphy
    [Arguments]    ${log_dir}=${iphy_log_dir}
    ...            ${log_name}=${iphy_syslog_logname}
    ...            ${ip}=${iphy_ip}
    ...            ${alias}=${iphy_syslog_alias}
    ute_syslog.Start Syslog    log_dir=${log_dir}
    ...                        log_name=${log_name}
    ...                        ip=${ip}
    ...                        alias=${alias}

LOGGING Stop Syslog Enb
    [Arguments]  ${log_name}=${enb_syslog_logname}
    ...          ${log_dir}=${results_dir}
    ...          ${alias}=${enb_syslog_alias}
    ute_syslog.Collect Syslog Results    unzip=false
    ...                                  destination=${log_dir}/${log_name}.tar.gz
    ...                                  alias=${alias}

LOGGING Stop Syslog Iphy
    [Arguments]  ${log_name}=${iphy_syslog_logname}
    ...          ${log_dir}=${results_dir}
    ...          ${alias}=${iphy_syslog_alias}
    ute_syslog.Collect Syslog Results    unzip=false
    ...                                  destination=${log_dir}/${log_name}.tar.gz
    ...                                  alias=${alias}

LOGGING Start Tshark
   [Arguments]  ${interface}
   ...          ${tshark_alias_name}=${LOGGING_TSHARK_ALIAS_NAME}
   ...          ${tshark_logname}=${LOGGING_TSHARK_LOGNAME}
   ...          ${tshark_logdir}=${LOGGING_RESULTS_DIR}
#   ${rc}  ${interface} =  Run and Return RC and Output  netstat -ie | grep -B1 "10.0.1.1" | head -n1 | awk '{print $1}'
   ute_tshark.Setup Tshark  interface=${interface}  alias=${tshark_alias_name}  log_dir=${tshark_logdir}  log_name=${tshark_alias_name}.pcap
   ute_tshark.Start Capturing  capture_filter=sctp  alias=${tshark_alias_name}

LOGGING Stop Tshark
   [Arguments]  ${tshark_alias_name}=${LOGGING_TSHARK_ALIAS_NAME}
   Stop Capturing  alias=${tshark_alias_name}
   [Teardown]    ute_tshark.Teardown Tshark  alias=${tshark_alias_name}
