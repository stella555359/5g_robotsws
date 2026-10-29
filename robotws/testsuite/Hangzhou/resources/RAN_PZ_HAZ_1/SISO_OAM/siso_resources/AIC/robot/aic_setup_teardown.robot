*** Settings ***
Documentation
...    SISO Common Resource files

Library     json
Library     Process
Library     taf.ccs.aashell    WITH NAME    aashell
Library     taf.sw.scout    WITH NAME    scout
Library     ../python/bts/vDuInfo.py
Library     ../../tools/truck_roll.py

Resource    ./bts/aic_bts_common_oam.robot
Resource    ../../common_func.robot
Resource    ./log/aic_capture_analysis_log.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot
Resource    ./bts/variables.robot



*** Keywords ***
Cloud Suite Precondition
    Create Cloud BTSCONFIG Dictionary
    Set Suite Logs Dir Path
    ${GLO_CU_ALLOWED_ALARM}    Combine Lists    ${CU_ALLOWED_FAULT}    ${ADDITIONAL_CU_ALLOWED_ALARMS}
    ${GLO_VDU_ALLOWED_ALARM}    Combine Lists    ${VDU_ALLOWED_FAULT}    ${ADDITIONAL_VDU_ALLOWED_ALARMS}
    Set Suite Variable    ${GLO_CU_ALLOWED_ALARM}
    Set Suite Variable    ${GLO_VDU_ALLOWED_ALARM}
    Set Suite Variable    ${SW_BUILDS_DIR_PATH}    ${SW_BUILDS_DIR_PATH}cloud/
    Log Variables

    ${supported_call}    Run Keyword And Return Status    Variable Should Exist    ${tl_config.SUPPORTED_CALL}
    ${IS_SUPPORTED_CALL}    Set Variable If    ${supported_call}     ${tl_config.SUPPORTED_CALL}     ${True}
    Set Suite Variable    ${IS_SUPPORTED_CALL}

Cloud Suite Postcondition
    Cloud Cleanup Environment

Cloud Testcase Basic Precondition
    [Arguments]    ${config_id}=${EMPTY}    ${force_recommission}=${False}
    Log    ${force_recommission}
    Set TC Dir Path
    Cloud Cleanup Environment
    Create Cloud Parameters Init    ${config_id}
    Cloud Change Testline Configuration    ${config_id}
    ${status}    Run Keyword If    "${NOT_COMMISSIONED}"=="True"    Run Keyword And Return Status    vDU Verify All Cells Onair For All CUs
    Run Keyword And Continue On Failure    Run Keyword If    "${NOT_COMMISSIONED}"=="True" and "${status}" == "False"
    ...    vDU Reset VDU And Check Onair For All CUs
    ...    ELSE IF    "${NOT_COMMISSIONED}"=="False"    Wait For All Cells Onair In All vDUs
    vCU Verify All Cells Onair For All CUs
    Run keyword And Ignore Error    Start To Get Resources Usage For All vDUs
    Check Alarms In CUs
    Check Alarms In vDUs
    ${cu_origin_historical_alarms}    Get Historical Alarm In CUs
    ${vdu_origin_historical_alarms}    Get Historical Alarm In vDUs
    Set Test Variable    ${CU_ORIGIN_HISTORICAL_ALARMS}
    Set Test Variable    ${VDU_ORIGIN_HISTORICAL_ALARMS}

Cloud Testcase Basic Postcondition
    [Arguments]     ${pass_number}=${1}    ${run_number}=${1}
    Log    ${pass_number}
    Log    ${run_number}
    Run Keyword If Test Failed    SISO Capture AIC Log    Flag=snapshot_cu
    Run Keyword If Test Failed    SISO Capture AIC Log    Flag=snapshot_du
    Stop and Fix
    Run Keyword And Ignore Error    Stop And Compare Resources Usage In All vDUs
#    Run Keyword And Ignore Error    Rep Reporting With Config Id    pass_number=${pass_number}    run_number=${run_number}
    Run Keyword And Ignore Error    interface.Common step trigger

Cloud Cleanup Environment
    Run Keyword And Ignore Error    Process.Terminate All Processes    kill=True
#    ${host_ip_list}    Get Dictionary Values    ${BTS_CONFIG["HOST_IP"]}
#    FOR    ${host_ip}    IN    @{host_ip_list}
#        Run Keyword And Ignore Error    Close Btslog Process    ${host_ip}
#    END

Cloud Change Testline Configuration
    [Arguments]    ${config_id}=${EMPTY}    ${force_recommission}=${False}
    Set Test Variable    ${NOT_COMMISSIONED}    True
    Return From Keyword If
    ...  ('${TESTED_CONFIG_ID}'=='${CURRENT_CONFIG_ID}' and '${force_recommission}'=='False') or "${config_id}"=="${EMPTY}"
    Set Fiber Switch Configuration    ${CURRENT_CONFIG_ID}
    PDU Switch Off Not Needed Hardware
    PDU Switch On Needed Hardware
    Template File Commissioning In Multi CUs
    Template File Commissioning In Multi vDUs
    vDUs Should Ping
    ${status}    Run Keyword And Return Status    Wait Until Keyword Succeeds   180s    10s
    ...    Check Expected Alarms Is Appear In vDUs    23
    Run Keyword If    ${status}    Wait Until Keyword Succeeds    15 min    30 sec
    ...    Check Expected Alarms Is Not Appear In vDUs    23
    Wait Until Keyword Succeeds    ${ONAIR_TIME}    30 sec    Check RU List Status Should Be As Expected
    Check RU List Status Should Be As Expected
    Set Test Variable    ${NOT_COMMISSIONED}    False

Create Cloud BTSCONFIG Dictionary
    ${host_ip}     Set Variable    ${tl.test_pc.default_ssh_connection_details.addr}
    ${BTS_CONFIG}    Create Dictionary    FR=&{EMPTY}    HOST_IP=${host_ip}
    Set Suite Variable    ${BTS_CONFIG}
    ${gnbs_count}    Get Length    ${tl.gnbs}
    FOR    ${gnb_index}    IN RANGE    ${gnbs_count}
        Create Cloud RU_GNB In CU    ${gnb_index}
    END
    ${TL_NAME}    aic_setup_teardown.Get Testline Name
    ${match}    ${conf_root_path}    Should Match Regexp     ${CURDIR}    (.*)/testsuite
    ${git_node_status}    Run Keyword And Return Status    OperatingSystem.Directory Should Exist
    ...    ${conf_root_path}/commissionings/HGZ/${TL_NAME}/DEP_SCF_FILES/CU_0
    ${gerrit_node_status}    Run Keyword And Return Status    OperatingSystem.Directory Should Exist
    ...    /home/ute/testline_configuration/${TL_NAME}/DEP_SCF_FILES/CU_0
    ${config_path}    Set Variable If    ${git_node_status}    ${conf_root_path}/commissionings/HGZ/${TL_NAME}/
    ...    ${gerrit_node_status}    /home/ute/testline_configuration/${TL_NAME}
    Set Suite Variable    ${CONFIG_PATH}
    Set Suite Variable    ${TL_NAME}
    Log Dictionary    ${BTS_CONFIG}

Create Cloud RU_GNB In CU
    [Arguments]    ${gnb_index}
    ${vdu_count}    Get Length    ${tl.gnbs[${gnb_index}].dus}
    FOR    ${vdu_index}    IN RANGE    ${vdu_count}
        Create Cloud RU_GNB In vDU    ${gnb_index}    ${vdu_index}
    END

Create Cloud RU_GNB In vDU
    [Arguments]    ${gnb_index}    ${vdu_index}
    ${status}    Run Keyword And Return Status    Should Be Equal As Strings
    ...    ${tl.gnbs[${gnb_index}].dus[${vdu_index}].fhgws}  None
    ${ru_length}    Run Keyword If    ${status}    Get Length    ${tl.gnbs[${gnb_index}].dus[${vdu_index}].rus}
    ...    ELSE    Get Length    ${tl.gnbs[${gnb_index}].dus[${vdu_index}].fhgws[0].rus}
    ${tl_ru_dict}    Create Dictionary    &{EMPTY}
    FOR    ${ru}    IN RANGE    ${ru_length}
        ${ru_serial_number}  Set Variable If  ${status}  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].rus[${ru}].serial_number}
        ...    ${tl.gnbs[${gnb_index}].dus[${vdu_index}].fhgws[0].rus[${ru}].serial_number}
        ${ru_pdu_addr}  Set Variable If  ${status}  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].rus[${ru}].pdu_port.pdu.addr}
        ...    ${tl.gnbs[${gnb_index}].dus[${vdu_index}].fhgws[0].rus[${ru}].pdu_port.pdu.addr}
        ${ru_pdu_model}  Set Variable If  ${status}  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].rus[${ru}].pdu_port.pdu.vendor}
        ...    ${tl.gnbs[${gnb_index}].dus[${vdu_index}].fhgws[0].rus[${ru}].pdu_port.pdu.vendor}
        ${ru_pdu_port}  Set Variable If  ${status}  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].rus[${ru}].pdu_port.port_no}
        ...    ${tl.gnbs[${gnb_index}].dus[${vdu_index}].fhgws[0].rus[${ru}].pdu_port.port_no}
        ${pdu_dict}=    Create Dictionary    port=${ru_pdu_port}    type=${ru_pdu_model}    ip_addr=${ru_pdu_addr}
        ${tl_pdu_dict}=    Create Dictionary   pdu=${pdu_dict}
        ${ru_list}    Get Dictionary Keys    ${BTS_CONFIG['FR']}
        Run Keyword If    "${ru_serial_number}" not in "${ru_list}"
        ...    Set To Dictionary    ${BTS_CONFIG['FR']}    ${ru_serial_number}=${tl_pdu_dict}
    END

Get Testline Name
    ${conf_path}=    Run Keyword And Return Status    Should Contain    ${CONFIGURATION}    \.
    ${SITE}    ${testline}=   Run Keyword If    ${conf_path}    Split String     ${CONFIGURATION}    .
    ${testline_name}    Get Variable Value    ${testline_name}    null
    ${tl_name}    Set Variable If    "${testline_name}"=="null" or "${testline_name}"=="${EMPTY}"
    ...    ${testline}    ${testline_name}
    [Return]    ${tl_name}

Create Cloud Parameters Init
    [Arguments]    ${config_id}=${EMPTY}
    Return From Keyword If    '${CURRENT_CONFIG_ID}'!='${EMPTY}' and ('${config_id}'=='${EMPTY}' or '${CURRENT_CONFIG_ID}'=='${config_id}')
    ${current_config_id}    Run Keyword If    '${config_id}'=='${EMPTY}' and '${CURRENT_CONFIG_ID}'=='${EMPTY}'
    ...    Set Variable    ${INIT_CONFIG_ID}
    ...    ELSE IF    '${config_id}'!='${EMPTY}'    Set Variable    ${config_id}
    ...    ELSE    Set Variable    ${CURRENT_CONFIG_ID}
    Set Suite Variable    ${CURRENT_CONFIG_ID}    ${current_config_id}
    ${status}    Run Keyword And Return Status    List Should Contain Value    ${${CURRENT_CONFIG_ID}}    peak_rate_config
    ${peak_rate_config}    Run Keyword If    ${status}    Evaluate    ${${CURRENT_CONFIG_ID}.peak_rate_config}
    Set Suite Variable    ${PEAK_RATE_CONFIG}    ${peak_rate_config}
    Set Suite Variable    ${ONAIR_TIME}    ${${CURRENT_CONFIG_ID}.ONAIR_TIME}
    Create Parameters Init    ${CURRENT_CONFIG_ID}
    Set Suite Variable    ${ALL_CELL_LIST}    ${ALL_VDU_CELL_LIST}
    Log     ${CU_VDU_RESOURCE_MAPPING}
    Log     ${NODE_CFG}
    Log     ${ALL_VDU_CELL_LIST}
    Log     ${ALL_CELL_LIST}
    Log     ${USED_FR_SN_LIST}
    Log     ${VDU_LIST}
    Log     ${CU_LIST}

Create Parameters Init
    [Arguments]    ${config_id}=${CURRENT_CONFIG_ID}
    ${cus}=     Get From Dictionary    ${${config_id}}    CUS
    ${cus_list}=    Split String    ${cus}    |
    ${cu_vdu_resource_mapping}    Create Dictionary
    ${node_cfg}    Create Dictionary
    ${ALL_VDU_CELL_LIST}    Create List
    ${used_fr_sn_list}    Create List
    ${vdu_list}    Create List
    Set Suite Variable    ${CU_VDU_RESOURCE_MAPPING}
    Set Suite Variable    ${NODE_CFG}
    Set Suite Variable    ${ALL_VDU_CELL_LIST}
    Set Suite Variable    ${USED_FR_SN_LIST}
    Set Suite Variable    ${VDU_LIST}
    FOR    ${cu}    IN    @{cus_list}
        Create Parameters Init In Node    ${cu}
    END
    ${cu_list}    Get Dictionary Keys    ${CU_VDU_RESOURCE_MAPPING}
    Set Suite Variable    ${CU_LIST}

Create Parameters Init In Node
    [Arguments]    ${cu}
    ${cu_set}    Split String    ${cu}    :
    ${cu_index}    Set Variable    ${cu_set[0]}
    ${gnb_index}    Fetch From Right    ${cu_index}    _
    ${vdu_list}    Split String    ${cu_set[1]}    -
    ${config_id}    Set Variable    ${cu_set[2]}
    Set To Dictionary    ${CU_VDU_RESOURCE_MAPPING}    ${cu_index}=&{EMPTY}
    Set To Dictionary    ${NODE_CFG}    ${cu_index}=&{EMPTY}
    ${cu_software_version}    Get CU Version    ${cu_index}
    ${match}    ${cu_version}    ${cu_release}    Should Match Regexp    ${cu_software_version}    vCUCNF(.*)_(\\d+\.\\d+)\.\\d+
    ${cu_version}    Convert To Lowercase    ${cu_version}
    ${cu_scfc}    Join Path    ${CONFIG_PATH}/DEP_SCF_FILES/${cu_index}/${cu_release}/CU_${config_id}.xml
    Set To Dictionary    ${NODE_CFG["${cu_index}"]}    scfc=${cu_scfc}
    ...    software_active=${cu_software_version}
    ...    host=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}
    ...    username=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...    password=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ...    cu_version=cuoam_${cu_version}
    ...    vdu_list=${vdu_list}
    FOR    ${vdu_index}    IN    @{vdu_list}
        ${vdu_scfc}    Join Path    ${CONFIG_PATH}/DEP_SCF_FILES/${cu_set[0]}/${cu_release}/${vdu_index}/vDU_${config_id}.xml
        Create Parameters Init In vDU    ${vdu_scfc}    ${vdu_index}    ${cu_index}
    END

Create Parameters Init In vDU
    [Arguments]    ${scfc_file_path}    ${vdu_index}=vDU_0    ${cu_index}=CU_0
    ${vdu_dict}    Create Dictionary
    ${vdu_resource_dict}    Create Dictionary
    ${vdu_software_version}    Get vDU Version    ${vdu_index}    ${cu_index}
    ${match}    ${vdu_version}    Should Match Regexp    ${vdu_software_version}    vDUCNF(.*)_.*
    ${vdu_version}    Convert To Lowercase    ${vdu_version}
    ${rmod_list}    ${cell_list}    ${rmod_chain}    vDuInfo    ${scfc_file_path}
    ${pci_list}    Get Cell PhyCellId List    ${cell_list}
    ${fr_sn_list}    ${rmod_info}    Get RMOD Info    ${rmod_list}
    ${gnb_index}    Fetch From Right    ${cu_index}    _
    ${vdu_only_index}    Fetch From Right    ${vdu_index}    _
    Set To Dictionary    ${vdu_dict}    scfc=${scfc_file_path}
    ...    software_active=${vdu_software_version}
    ...    host=${tl.gnbs[${gnb_index}].dus[${vdu_only_index}].oam_http_connection_details.addr}
    ...    username=${tl.gnbs[${gnb_index}].dus[${vdu_only_index}].oam_http_connection_details.username}
    ...    password=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ...    phyCellId_list=${pci_list}
    ...    fr_chain_list=${rmod_chain}
    ...    fr_sn_list=${fr_sn_list}
    ...    rmod_info=${rmod_info}
    ...    vdu_version=cuoam_${vdu_version}
    Set To Dictionary    ${vdu_resource_dict}
    ...    cell=${pci_list}
    ...    fr=${fr_sn_list}
    Set to Dictionary    ${CU_VDU_RESOURCE_MAPPING["${cu_index}"]}    ${vdu_index}=${vdu_resource_dict}
    Set To Dictionary    ${NODE_CFG["${cu_index}"]}    ${vdu_index}=${vdu_dict}
    Append To List    ${VDU_LIST}    ${cu_index}-${vdu_index}
    Append To List    ${ALL_VDU_CELL_LIST}    @{cell_list}
    Append To List    ${USED_FR_SN_LIST}    @{fr_sn_list}

Get Cell PhyCellId List
    [Arguments]    ${cell_list}
    ${pci_list}    Create List
    FOR    ${cell}    IN    @{cell_list}
        ${phyCellId}    Get From Dictionary    ${cell}    phyCellId
        Append To List    ${pci_list}    ${phyCellId}
    END
    [Return]     ${pci_list}

Get vDU Version
    [Arguments]    ${vdu_index}    ${cu_index}
    Login To vDU By Rest    vdu_index=${vdu_index}    cu_index=${cu_index}
    ${vdu_data}=    vdu.get_vdu_state_data
    ${vdu_software_version}    set variable    ${vdu_data['software_version']}
    [Return]    ${vdu_software_version}
    [Teardown]    Logout To vDU By Rest

Get CU Version
    [Arguments]    ${cu_index}
    Login To CU By Rest    cu_index=${cu_index}
    ${cu_software_version}=    cu.get_active_software_version
    [Return]    ${cu_software_version}
    [Teardown]    Logout To CU By Rest

Verify Rmod Status In vDU If Truck Roll
    [Arguments]    ${vdu_index}=vDU_0    ${cu_index}=CU_0
    Login To vDU By Rest    ${vdu_index}    ${cu_index}
    ${ru_info_list}    vdu.get_rmods_status
    FOR    ${ru_info}    IN    @{ru_info_list}
        ${status}    Run Keyword And Return Status    Variable Should Exist    ${ru_info["availability_status"]}
        ${status2}    Run Keyword If    ${status}    Run Keyword And Return Status    Should Not Contain
        ...    ${ru_info["availability_status"]}    nstalled
        ...    ELSE    Set Variable    ${True}
        Run Keyword If    not ${status2}    Log To Console    Truck roll: ${ru_info["serialNumber"]} not installed!
        Should Be True    ${status2}
    END
   [Teardown]   Run Keyword And Ignore Error    Logout To vDU By Rest

Verify Rmod Status In vDUs If Truck Roll
    [Arguments]    ${vdu_list}=${VDU_LIST}
    FOR    ${vdu}    IN    @{vdu_list}
        ${cu_index}    ${vdu_index}    Split String    ${vdu}    -
        Verify Rmod Status In vDU If Truck Roll    ${vdu_index}    ${cu_index}
    END

Cloud Get And Check Truck Roll Alarm
    ${expected_fault_list}    Create List    10     1806    4341    4352    4383
    FOR    ${expected_fault_id}    IN    @{expected_fault_list}
        ${vdu_status}    Run Keyword And Return Status    Check Expected Alarms Is Appear In vDUs
        ...    ${expected_fault_id}
        ${cu_status}    Run Keyword And Return Status    Check Expected Alarms Is Appear In CUs
        ...    ${expected_fault_id}
        Run Keyword If    not ${vdu_status}    Log To Console    Truck roll: fault ${alarm["faultId"]} exists in vDU!
        Run Keyword If    not ${cu_status}    Log To Console    Truck roll: fault ${alarm["faultId"]} exists in CU!
        Should Be True    ${vdu_status}
        Should Be True    ${cu_status}
    END

CLoud Need Stop And Fix
    ${ru_status}    Run Keyword And Return Status    Verify Rmod Status In vDUs If Truck Roll
    Return From Keyword If    not ${ru_status}    ${True}
    ${fault_status}    Run Keyword And Return Status    Cloud Get And Check Truck Roll Alarm
    Return From Keyword If    ${fault_status}    ${False}    ${True}

Stop and Fix
    FOR    ${i}    IN RANGE    12
        ${stop_fix}    CLoud Need Stop And Fix
        Exit For Loop If    not ${stop_fix}
        Sleep    5 min
    END
    Run Keyword If    ${stop_fix}    Run Keywords    Log To Console    One of four conditions has been met, Stop and fix!
    ...    AND    truck_roll.Stop Fix Notification
    ...    AND    truck_roll.Send Email
    ...    AND    Sleep    72h

Get K8s Master SSH Connection Info In vDU
    [Arguments]    ${cu_index}=CU_0    ${vdu_index}=vDU_0
    ${gnb_index}    Fetch From Right    ${cu_index}    _
    ${vdu_index}    Fetch From Right    ${vdu_index}    _
    ${result}    ${addr}        Run Keyword And Ignore Error
    ...   set variable    ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.addr}
    Should Be True    "${result}"=="PASS"    Please give K8s Master SSH ip in __init__.py for vdu_index=${vdu_index}

    ${result}    ${username}    Run Keyword And Ignore Error
    ...   set variable    ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.username}
    Should Be True  "${result}"=="PASS"    Please give K8s Master SSH username in __init__.py for vdu_index=${vdu_index}

    ${result}    ${password}    Run Keyword And Ignore Error
    ...   set variable    ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.password}
    Should Be True  "${result}"=="PASS"    Please give K8s Master SSH password in __init__.py for vdu_index=${vdu_index}

    ${result}    ${port}        Run Keyword And Ignore Error
    ...   set variable    ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.port}
    Should Be True    "${result}"=="PASS"    Please give K8s Master SSH port in __init__.py for vdu_index=${vdu_index}

    ${vdu_namespace}=    set variable    ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.namespace}

    ${du_info}    create dictionary    addr=${addr}    username=${username}    password=${password}    port=${port}    ns=${vdu_namespace}
    [Return]  ${du_info}

Get SSH Connection Infor For Multiple vDUs K8s Master
    ${vdu_info_dict}=  create dictionary
    FOR    ${vdu}    IN    @{VDU_LIST}
        ${cu_index}    ${vdu_index}    Split String    ${vdu}    -
        ${vdu_k8s_master_ssh_connection_info}    Get K8s Master SSH Connection Info In VDU    cu_index=${cu_index}
        ...                                                                                vdu_index=${vdu_index}
        Set To Dictionary   ${vdu_info_dict}       ${vdu}=${vdu_k8s_master_ssh_connection_info}
    END
    [Return]    ${vdu_info_dict}

_Get Resource Usage
    [Arguments]    ${host}    ${user}    ${password}    ${namespace}    ${port}=15057
#    ${pod_list}    create list    po-cran1-cprt-0    po-cran1-up-0
    ${pod_list}    create list    po-cran1-cprt-0
    &{hop}=    Create Dictionary
    ...    host=${PC_HOST}
    ...    user=${PC_USER}
    ...    password=${PC_PASSWORD}
    &{k8s}=    Create Dictionary
    ...    host=${host}
    ...    user=${user}
    ...    password=${password}
    ...    proxy=${hop}
    ${resources_usage_list}    create list
    FOR    ${pod}    IN   @{pod_list}
        aashell.create_aashell_cli
        ...    name=aashell
        ...    hops=${k8s}
        ...    namespace=${namespace}
        ...    pod=${pod}
        ...    port=${port}
        aashell.Setup    aashell
        ${resources_usage}    aashell.Get Resources Usage    aashell
        Append To List    ${resources_usage_list}    ${resources_usage}
    END
    [Return]    ${resources_usage_list}
    [Teardown]    aashell.Teardown    aashell

Start To Get Resources Usage For All vDUs
    ${pod_list}    create list    po-cran1-cprt-0    po-cran1-up-0
    ${begin_resources_usage_dict}=  Create Dictionary
    ${vdu_info_dict}    Get SSH Connection Infor For Multiple vDUs K8s Master
    FOR    ${vdu}    IN    @{VDU_LIST}
        ${begin_vdu_resources_usage_list}    _Get Resource Usage    ${vdu_info_dict["${vdu}"]["addr"]}
        ...                                                         ${vdu_info_dict["${vdu}"]["username"]}
        ...                                                         ${vdu_info_dict["${vdu}"]["password"]}
#        ...                                                         ${vdu_info_dict["${vdu}"]["port"]}
        ...                                                         ${vdu_info_dict["${vdu}"]["ns"]}
        Set To Dictionary    ${begin_resources_usage_dict}    ${vdu}=${begin_vdu_resources_usage_list}
    END
    Set Test Variable    ${BEGIN_RESOURCES_USAGE_DICT}
    [Return]    ${BEGIN_RESOURCES_USAGE_DICT}

Stop To Get Resources Usage In All vDUs
    ${end_resources_usage_dict}=  Create Dictionary
    ${vdu_info_dict}    Get SSH Connection Infor For Multiple vDUs K8s Master
    FOR    ${vdu}    IN    @{VDU_LIST}
        ${end_vdu_resources_usage_list}    _Get Resource Usage    ${vdu_info_dict["${vdu}"]["addr"]}
        ...                                                         ${vdu_info_dict["${vdu}"]["username"]}
        ...                                                         ${vdu_info_dict["${vdu}"]["password"]}
#        ...                                                         ${vdu_info_dict["${vdu}"]["port"]}
        ...                                                         ${vdu_info_dict["${vdu}"]["ns"]}
        Set To Dictionary    ${end_resources_usage_dict}    ${vdu}=${end_vdu_resources_usage_list}
    END
    [Return]    ${end_resources_usage_dict}

Stop And Compare Resources Usage In All vDUs
    ${end_resources_usage_dict}    Stop To Get Resources Usage In All VDUs
    FOR    ${vdu}    IN    @{VDU_LIST}
        Run Keyword And Ignore Error    Should Be Equal As Resources    ${BEGIN_RESOURCES_USAGE_DICT["${vdu}"]}
        ...                                                             ${end_resources_usage_dict["${vdu}"]}
        ...                                                             exclude=//bufferPoolFreeCount
    END

Ping to destination from local
    [Arguments]     ${destation}
    ${rc}=    Run and return rc    ping ${destation} -w 10
    Should be equal as numbers    first=${0}    second=${rc}

vDUs Should Ping
    [Arguments]    ${vdu_list}=${VDU_LIST}
    FOR    ${vdu}    IN    @{vdu_list}
        ${cu_index}    ${vdu_index}    Split String    ${vdu}    -
        ${host}    Set Variable    ${NODE_CFG["${cu_index}"]["${vdu_index}"]["host"]}
        Ping to destination from local    ${host}
    END

CUs Should Ping
    [Arguments]    ${cu_list}=${CU_LIST}
    FOR    ${cu_index}    IN    @{cu_list}
        ${host}    Set Variable    ${NODE_CFG["${cu_index}"]["host"]}
        Ping to destination from local    ${host}
    END

Cloud Rep Reporting With Config Id
    [Arguments]    ${case_result}=${TEST STATUS}    ${pass_number}=${1}    ${run_number}=${1}
    ${if_reporting_rep}    Get Variable Value    ${if_reporting_rep}    ${False}
    ${scout_testline_name}    Get Variable Value    ${GLO_SCOUT_TESTLINE_NAME}    ${TL_NAME}
    ${status}    Run Keyword And Return Status    Should Not End With    ${scout_testline_name}    _1
    Run Keyword If    "${if_reporting_rep}"=="False"    Get SCF Internal Id By Scout    ${scout_testline_name}    ${False}
    Return From Keyword If    not ${if_reporting_rep}
    FOR    ${tag}    IN    @{TEST TAGS}
        ${status}    Run Keyword And Return Status    Should Match Regexp    ${tag}    QC_
        Continue For Loop If    not ${status}
        ${qc_id}    Get Regexp Matches    ${tag}    QC_(\\d+)    1
        Exit For Loop
    END
    Send ReP With Scf Id    ${qc_id[0]}    bts_id=${scout_testline_name}    case_result=${case_result}
    ...    sw=${NODE_CFG['${MASTER_BTS_ID}'].software_active}    pass_number=${pass_number}    run_number=${run_number}
