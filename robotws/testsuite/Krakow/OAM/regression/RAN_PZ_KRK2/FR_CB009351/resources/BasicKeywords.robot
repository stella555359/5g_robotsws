*** Settings ***
Documentation
...    author:  OAM
...    Keywords related to admin
...    Maintainer: Michal Dziedzic, michal.dziedzic@nokia.com

Library      Collections
Library      taf.sbts.oam.coam.admin     WITH NAME    admin_api

Resource     taf/rfrl/bts/robot/gnb.robot
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot

Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py

*** Variables ***
${LOG_PATH}              ${OUTPUT_DIR}
${SUITE_LOG_PATH}        ${OUTPUT_DIR}
${TS_LOG_PATH_BASE}      ${OUTPUT_DIR}
${GNB_SSH_ADDR}          ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${GNB_SSH_USERNAME}      ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
${GNB_SSH_PASSWORD}      ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
${GNB_HTTP_ADDR}         ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${GNB_HTTP_USERNAME}     ${tl.gnbs[0].cu.oam_http_connection_details.username}
${GNB_HTTP_PASSWORD}     ${tl.gnbs[0].cu.oam_http_connection_details.password}


*** Keywords ***
Connect to gNB cOAM via SSL
    [Arguments]  ${connection}=GNB_OAM    ${bts_host}=${GNB_HTTP_ADDR}    ${username}=${GNB_HTTP_USERNAME}
    ...    ${password}=${GNB_HTTP_PASSWORD}    ${admin_api_log_dir}=${LOG_PATH}
    admin_api.connect_to    bts_host=${bts_host}
    ...                     bts_port=${443}
    ...                     username=${username}
    ...                     password=${password}
    ...                     name=${connection}
    ...                     admin_api_log_dir=${admin_api_log_dir}
    ...                     release=SBTS00

Teardown gNB cOAM SSL Connection
    [Arguments]    ${connection}=GNB_OAM
    admin_api.teardown    connection=${connection}

Enable FaultSignature If Necessary
    [Arguments]    ${FEATCADM_DN}    ${connection}=default    ${bts_host}=${GNB_HTTP_ADDR}
    Connect to gnb coam via ssl   connection=${connection}   bts_host=${bts_host}
    ${FEATCADM_Objects}    admin_api.get_managed_objects    FEATCADM_A    connection=${connection}
    ${actFaultSignature}    Set Variable    ${FEATCADM_Objects[0]['parameters']['actFaultSignature']}
    Run Keyword If    "${actFaultSignature}" != "True"    admin_api.perform_parameter_recommissioning
    ...    dist_name=${FEATCADM_DN}
    ...    parameter=actFaultSignature
    ...    operation=update
    ...    value=true
    ...    connection=${connection}

Perform Site Reset
    [Arguments]    ${connection}=GNB_OAM    ${bts_host}=${GNB_HTTP_ADDR}
    [Documentation]    Keyword To Perform site reset
    Wait until keyword succeeds    60 sec    20 sec    Connect to gnb coam via ssl
    ...                                                connection=${connection}
    ...                                                bts_host=${bts_host}
    admin_api.reset_site    timeout=300    connection=${connection}
    [Teardown]    Teardown gNB cOAM SSL Connection    ${connection}

ADMIN Is Alarm Active
    [Arguments]    ${fault_id}    ${connection}=check_alarm
    @{out_alarms_objects_list}    admin_api.get_active_alarms   connection=${connection}
    FOR    ${alarm}    IN    @{out_alarms_objects_list}
        ${dict_fault_id}    Get From Dictionary    ${alarm}    faultId
        Return From Keyword If    '${dict_fault_id}' == '${fault_id}'    ${TRUE}
    END
    [Return]    ${FALSE}

Set Allowed Alarms
    Set Test Variable    @{allowed_alarms}      SSH enabled
    ...                                         R&D Service Port enabled
    ...                                         Service account root access is enabled
    ...                                         Ethernet port security is disabled
    ...                                         LMP access via port 443

Set Allowed Alarms With Diagnostic Files
    Append To List    ${allowed_alarms}    Radio Diagnostic Files collected
