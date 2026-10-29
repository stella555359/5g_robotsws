*** Settings ***
Documentation
...    Author:        amy.wu@nokia-sbell.com
...    Maintainer:    amy.wu@nokia-sbell.com

Library    Collections
Library    OperatingSystem
Library    Process
Library    robot.libraries.DateTime
Library    SSHLibrary
Library    String
Library    XML    use_lxml=true


Library    taf.sbts.oam.coam.admin    WITH NAME    coam
Library    taf.gnb.oam.coam.admin    WITH NAME    gnb_coam
Library    taf.sw.scout    WITH NAME    scout
Library    taf.ccs.aashell    WITH NAME    aashell
#Library    taf.ccs.aashell    4G    WITH NAME    4g_aashell
Library    ute_fsmaccess
Library    ute_reporting_portal
Library    ./siteInfo.py
Library    ./utils/others.py
Library    ./tools/FW.py
Library    ./tools/truck_roll.py

Resource    taf/rfrl/bts/robot/common/gnb_bbu.robot
Resource    ./variables.robot
Resource    ./test_model.robot
Resource    ./pdu.robot
Resource    ./logging.robot
Resource    ./swconfig.robot
Resource    ./admin.robot
Resource    ./bts_common_interface.robot
Resource    ./SAS_SIM.robot
Resource    ./common_func.robot
#Resource    ../../../RRM/RAN_PZ_HAZ_1/Resources/RRM_Custom_Config.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot


*** Variables ***
${CURRENT_CONFIG_ID}
${TESTED_CONFIG_ID}
@{TRUCK_ROLL_FAULTS}    ${10}  ${1806}  ${4341}  ${4352}  ${4383}

*** Keywords ***

Suite Precondition
    Create BTSCONFIG Dictionary
    Set Suite Logs Dir Path
    ${GLO_ADMIN_ALLOWED_ALARM}    Create List    @{ALLOWED_FAULT}    @{ADDITIONAL_ADMIN_ALLOWED_ALARMS}
    Set Suite Variable    ${GLO_ADMIN_ALLOWED_ALARM}

    ${GLO_ADMIN_HISTORY_ALLOWED_ALARM}     Create List
    Set Suite Variable    ${GLO_ADMIN_HISTORY_ALLOWED_ALARM}

    Set Suite Variable    ${SW_BUILDS_DIR_PATH}    ${SW_BUILDS_DIR_PATH}cloud/
    Cleanup Environment
    Log Variables

    ${supported_call}    Run Keyword And Return Status    Variable Should Exist    ${tl_config.SUPPORTED_CALL}
    ${IS_SUPPORTED_CALL}    Set Variable If    ${supported_call}     ${tl_config.SUPPORTED_CALL}     ${True}
    Set Suite Variable    ${IS_SUPPORTED_CALL}
    Run keyword And Ignore Error    Copy File    ${CURDIR}/tools/arti_netrc    /home/ute/.netrc
    Set Library Search Order    qualcomm_common_keywords    real_ue

Suite Postcondition
    Cleanup Environment
    Run keyword And Ignore Error    OperatingSystem.Remove File    /home/ute/.netrc
    #Run Keyword And Ignore Error    Send Logs To Server And Remove Local Logs

Testcase Basic Precondition
    [Arguments]    ${case_name}    ${config_id}=${EMPTY}    ${force_recommission}=${False}
    ${func}    Set Variable    Testcase Precondition
    Run Keyword    ${func}    ${case_name}    config_id=${config_id}    force_recommission=${force_recommission}

Testcase Basic Postcondition
    [Arguments]     ${pass_number}=${1}    ${run_number}=${1}
    ${func}    Set Variable    Testcase Postcondition
    Run Keyword    ${func}    pass_number=${pass_number}    run_number=${run_number}

Testcase Precondition
    [Arguments]    ${case_name}    ${config_id}=${EMPTY}    ${force_recommission}=${False}
    Close Multi Node Process
    Set Test Variable    ${CASE_NAME}    ${case_name}
    Set TC Dir Path
    Create Nodes Parameters Init    ${config_id}    force=False
    Update Qc Id Tag
#    ${site_mode}    Set Variable    ${${CURRENT_CONFIG_ID}.site_mode}
#    ${aashell_name}    Set Variable If    "${site_mode}" == "4G"    4g_aashell    aashell
#    Set Test Variable    ${aashell_name}
#    Run Keyword And Ignore Error    Get Resource Usage Setup    aashell_name=${aashell_name}
    Run Keyword If    "${${CURRENT_CONFIG_ID}.site_mode}"!="4G"    Run Keyword And Ignore Error
    ...    Get Resource Usage Setup    aashell_name=aashell
    Logging Multinode Start    ${TEST_LOGS_DIR_PATH}/setup
    ${out_SAS_SIM_config}    Run Keyword And Return Status    Variable Should Exist    ${tl_config.SAS_SIM}
    ${out_need_SAS_SIM}    Set Variable If     ${out_SAS_SIM_config}      ${tl_config.SAS_SIM}    False
    Run Keyword If     "${out_need_SAS_SIM}"=="True"    Run Keywords    Restart SAS Simulator
    ...    AND    Sleep    2 min
    Log Dictionary    ${NODE_CFG}
    Change Testline Configuration    ${config_id}    force_recommission=${force_recommission}
    #Set Constant Variables
#    ${ue_list}    Set Variable      ${tl_config.SUPPO}
    ${status}    Run Keyword If    "${NOT_COMMISSIONED}"=="True"    Run Keyword And Return Status    Verify All Cells OnAir
    Run Keyword And Continue On Failure    Run Keyword If    "${NOT_COMMISSIONED}"=="True" and "${status}" == "False"
    ...    Reset BTS Until Onair    timeout=${ONAIR_TIME}
    ...    ELSE IF    "${NOT_COMMISSIONED}"=="False"    Wait For All Cells OnAir        timeout=${ONAIR_TIME}
#    ...    AND    Check Default Value Of Parameter
#    ...    AND    Run Keyword If    ${NODE_CFG["${MASTER_BTS_ID}"].fullrack}    Upload Swconfig File    ${SW_CONFIG_PATH}
#    ...    remote_host=${BTS_CONFIG["HOST_IP"]["TL2"]}    host=192.168.255.7
    Check Multinode Without Unexpect Alarm
    [Teardown]    Run Keyword If    "${KEYWORD STATUS}"=="PASS"    Run Keywords
    ...    Logging Multinode Stop    ${TEST_LOGS_DIR_PATH}/setup/
    ...    AND    Logging Multinode Start
    ...    AND    Logging Gnb Admin Start
    ...    AND    Get And Check Reset Counter For All BTS Node


Testcase Postcondition
    [Arguments]     ${pass_number}=${1}    ${run_number}=${1}
    Logging Multinode Stop    test_status=${TEST STATUS}
    ${stop_fix_flag}    Get Variable Value    ${STOP_FIX}    ${False}
    Run Keyword If    ${stop_fix_flag}    Stop and Fix
    Run Keyword And Ignore Error    Logging Gnb Admin Stop
    Run Keyword And Ignore Error    Rep Reporting With Config Id    pass_number=${pass_number}    run_number=${run_number}
    Run Keyword If    "${${CURRENT_CONFIG_ID}.site_mode}"!="4G"    Run Keyword And Ignore Error
    ...    Get Resource Usage Teardown    aashell_name=aashell
    Run Keyword And Ignore Error    interface.Common step trigger

Testcase KPI postcondition
    [Arguments]    ${CaseType}=Upgrade    ${customer}=Optus
    ${status}    ${return}    Run Keyword And Ignore Error    Variable Should Exist    ${TOP50}
    Run Keyword IF    '${status}'=='FAIL'   Set Test Variable    ${TOP50}    False
    Run Keyword IF  '${TOP50}'=='True'    Set Candidate
    Run Keyword IF  '${TOP50}'=='True'    Get Hostname
    ${NODE_INFO}    Get Dictionary Values    ${NODE_CFG}
    ${SingleSite}    Get From List    ${NODE_INFO}    0
    Set Test Variable    ${build}    ${SingleSite['software_active']}
    ${status}    ${return}    Run Keyword And Ignore Error    Variable Should Exist    ${TBUILD}
    Run Keyword IF    '${status}'=='PASS'   Set Test Variable    ${build}    ${TBUILD}
    ${status}    ${return}    Run Keyword And Ignore Error    message_should_exist_in_syslog_file
    ...    regexp=Message handling error: can't find domainId   alias=${CASE_NAME}_${MASTER_BTS_ID}
    Run Keyword IF  '${status}'=='PASS'    log    find the msg£ºMessage handling error: can't find domainId
    Run Keyword IF  '${TOP50}'=='True'    Run Keyword If Test Failed
    ...    Report To Reporting Portal    ${CASE_NAME}    1   failed    ${build}    ${CaseType}    customer=${customer}
    Run Keyword IF  '${TOP50}'=='True'    Run Keyword If Test Passed
    ...    Report To Reporting Portal    ${CASE_NAME}    1   passed    ${build}    ${CaseType}    customer=${customer}
    [Teardown]    Run Keyword And Ignore Error    Testcase Basic Postcondition

Cleanup Environment
    Run Keyword And Ignore Error    Process.Terminate All Processes    kill=True
    coam.Teardown All Aliases For Admin
    ${host_ip_list}    Get Dictionary Values    ${BTS_CONFIG["HOST_IP"]}
    FOR    ${host_ip}    IN    @{host_ip_list}
        Run Keyword And Ignore Error    Close Btslog Process    ${host_ip}
    END

Close Multi Node Process
    ${host_ip_list}    Get Dictionary Values    ${BTS_CONFIG["HOST_IP"]}
    FOR    ${host_ip}    IN    @{host_ip_list}
        Run Keyword And Ignore Error    Close Node Process    ${host_ip}
    END

Get Node SW Build And Release
    [Arguments]    ${node}
    Run Keyword If    '${node}'=='TL1'
    ...    coam.Setup Admin    bts_host=${BTS_HOST}    username=Nemuadmin    password=nemuuser    timeout=30
    ...    ELSE    coam.Setup Admin    bts_host=${BTS_HOST}    username=Nemuadmin    password=nemuuser
    ...            remote_host=${BTS_CONFIG.HOST_IP.${node}}    timeout=30
    ${active_sw_version}    coam.get_sw_version
    Should Not Be Empty    ${active_sw_version}
    ${build_is_trunk}    Evaluate    "_ENB_9" in """${active_sw_version}""" or "_FSM3_9" in """${active_sw_version}"""
    ${sw_trunk}    Replace String Using Regexp    ${active_sw_version}    ^([A-Z]+)\\d+[A-Z]\\d?    SBTS00
    ${out_sw_version}    Set Variable If    ${build_is_trunk}    ${sw_trunk}   ${active_sw_version}
    ${sw_release_name}    coam.get_sw_release_name
    ${out_sw_release}    Set Variable If    ${build_is_trunk}    SBTS00    ${sw_release_name}
    [Teardown]    coam.Teardown
    [Return]    ${out_sw_version}    ${out_sw_release}

Set Node Flags In Swconfig
    [Arguments]    ${bts_id}
    ${status}    ${flags}    Run Keyword And Ignore Error    Get From Dictionary    ${ADDITIONAL_FLAGS}    ${bts_id}
    ${additional_flags}    Set Variable If    "${status}"=="PASS"    ${flags}    ${EMPTY}
    Set Flags In Swconfig    additional_flags=${additional_flags}    remote_host=${NODE_CFG['${bts_id}']['host_ip']}

Change Testline Configuration
    [Arguments]    ${config_id}=${EMPTY}    ${pre_alias}=${CASE_NAME}    ${force_recommission}=${False}
    Set Test Variable    ${NOT_COMMISSIONED}    True
    ${bts_status}    coam.get_bts_statuses     connection=${pre_alias}_${MASTER_BTS_ID}
    Return From Keyword If
    ...  '${TESTED_CONFIG_ID}'=='${CURRENT_CONFIG_ID}' and '${bts_status["proceduralState"]}'!='NotCommissioned' and '${force_recommission}'=='False'
    Return From Keyword If    "${config_id}"=="${EMPTY}"
#    Set Suite Variable    ${TESTED_CONFIG_ID}    ${CURRENT_CONFIG_ID}
#    ${recommissioning_not_requested}    Run Keyword And Return Status    Should Be Empty    ${config_id}
#    Return From Keyword If    ${recommissioning_not_requested}
#    Report Enb Hardware Configuration    ${OUT_CURRENT_HW_ID}
    Set Fiber Switch Configuration    ${CURRENT_CONFIG_ID}
    PDU Switch Off Not Needed Hardware
    PDU Switch On Needed Hardware
    MultiNode Template File Commissioning
    Verify HW State
    Sleep    30 sec
    Software Check And Correct
    Set Suite Variable    ${TESTED_CONFIG_ID}    ${CURRENT_CONFIG_ID}
    Set Test Variable    ${NOT_COMMISSIONED}    False

MultiNode Template File Commissioning
    [Arguments]    ${pre_alias}=${CASE_NAME}
    FOR   ${bts_id}    IN    @{ALL_BTS_ID_LIST}
        coam.assert any    SMOD    parameters=operationalState=regex"(?i)Enabled", serialNumber=${NODE_CFG['${bts_id}'].master_sm}
        ...    timeout=600s    connection=${pre_alias}_${bts_id}
        Set Node Flags In Swconfig    ${bts_id}
#        Run Keyword And Ignore Error    Remove Hwbin File
        Perform Template File Commissioning    ${bts_id}    connection=${pre_alias}_${bts_id}
    END

Create Nodes Parameters Init
    [Arguments]    ${config_id}=${EMPTY}    ${force}=True
    ${bool_value}    Evaluate    '${config_id}'=='${EMPTY}' or '${CURRENT_CONFIG_ID}'=='${config_id}'
    Return From Keyword If    '${CURRENT_CONFIG_ID}'!='${EMPTY}' and ${bool_value} and "${force}"=="False"
#    Return From Keyword If    '${CURRENT_CONFIG_ID}'!='${EMPTY}' and '${CURRENT_CONFIG_ID}'=='${config_id}'
    ${current_config_id}    Run Keyword If    '${config_id}'=='${EMPTY}' and '${CURRENT_CONFIG_ID}'=='${EMPTY}'
    ...    Set Variable    ${INIT_CONFIG_ID}
    ...    ELSE IF    '${config_id}'!='${EMPTY}'    Set Variable    ${config_id}
    ...    ELSE    Set Variable    ${CURRENT_CONFIG_ID}
    Set Suite Variable    ${CURRENT_CONFIG_ID}    ${current_config_id}
    ${status}    Run Keyword And Return Status    List Should Contain Value    ${${CURRENT_CONFIG_ID}}    peak_rate_config
    ${peak_rate_config}    Run Keyword If    ${status}    Evaluate    ${${CURRENT_CONFIG_ID}.peak_rate_config}
    ${status}    Run Keyword And Return Status    List Should Contain Value    ${${CURRENT_CONFIG_ID}}    iperf_type
    ${iperf_type}    Set Variable If    ${status}    ${${CURRENT_CONFIG_ID}.iperf_type}    via_app
#    Set Suite Variable    ${OUT_CURRENT_HW_ID}    ${${CURRENT_CONFIG_ID}.HW_ID}
    Set Suite Variable    ${IPERF_TYPE}    ${iperf_type}
    Set Suite Variable    ${PEAK_RATE_CONFIG}    ${peak_rate_config}
    Set Suite Variable    ${SITE_MODE}    ${${CURRENT_CONFIG_ID}.site_mode}
    Set Suite Variable    ${ONAIR_TIME}    ${${CURRENT_CONFIG_ID}.ONAIR_TIME}
    ${nodes_status}    Run Keyword And Return Status    List Should Contain Value    ${${CURRENT_CONFIG_ID}}    NODES
    ${external_nodes}    Run Keyword If    ${nodes_status}    Config Nodes List Split    ${CURRENT_CONFIG_ID}
    ...    ELSE    Create Dictionary
    ${multi_config_id}    Create Dictionary    TL1=${CURRENT_CONFIG_ID}    &{external_nodes}
#    Power On Test Node FSM    ${multi_config_id}
    Init Node Parameters    ${multi_config_id}

Config Nodes List Split
    [Arguments]    ${config_id}=${CURRENT_CONFIG_ID}
    ${nodes_cn_list}=     Get From Dictionary    ${${config_id}}    NODES
    ${nodes_list}=    Split String    ${nodes_cn_list}    |
    ${external_nodes}    Create Dictionary
    FOR    ${node}    IN    @{nodes_list}
        ${node_set}    Split String    ${node}    :
        Set To Dictionary    ${external_nodes}    ${node_set[0]}=${node_set[1]}
    END
    [Return]    ${external_nodes}

Power On Test Node FSM
    [Arguments]    ${multi_config_id}
    ${nodes}    Get Dictionary Keys    ${multi_config_id}
    ${sm_sn_list}    Get Dictionary Keys    ${BTS_CONFIG['FSM']}
    ${sm_under_test}    Create List
    FOR    ${sn}    IN    @{sm_sn_list}
        Run Keyword If    "${BTS_CONFIG['FSM']['${sn}']['node']}" in "${nodes}"    Append To List    ${sm_under_test}    ${sn}
    END
    PDU Turn On All Devices From Serial Number List    ${sm_under_test}    ${BTS_CONFIG}    FSM

Init Node Parameters
    [Arguments]    ${multi_config_id}
    ${node_cfg}    Create Dictionary
    ${used_fr_sn_list}    Create List
    ${tested_fr_sn_list}    Create List
    ${used_fhs_sn_list}    Create List
    ${used_sm_sn_list}    Create List
    ${used_bbmod_sn_list}    Create List
    ${all_bts_id_list}    Create List
    ${bts_list}    Create List
    ${all_cell_list}    Create List
    ${2g_3g_distname_list}    Create List
    ${nodes}    Get Dictionary Keys    ${multi_config_id}
    ${master_bts_id}    Set Variable
    FOR    ${node}    IN    @{nodes}
        ${sw_version}    ${sw_release}    Wait Until Keyword Succeeds    5 min    30 sec    Get Node SW Build And Release    ${node}
        Set Suite Variable    ${sw_release}
        Set Suite Variable    ${sw_version}
        ${node_id}    Get Regexp Matches    ${node}    (\\d+)    1
        ${prefix_name}    Get SCFC Prefix Name    ${CONFIG_PATH}/node${node_id[0]}/${sw_release}/    ${multi_config_id.${node}}
        ${scf_path}    Join Path    ${CONFIG_PATH}/node${node_id[0]}/${sw_release}/${prefix_name}_${multi_config_id.${node}}.xml
        ${bts_id}    ${lnbts}    ${nrbts}    SCFC Get BtsId    ${scf_path}
        ${category_alarms}     SCFC Create Activate Category Alarms Value    ${scf_path}
        ${fhs_sn_list}    SCFC Create FHS Serial Number List    ${scf_path}
        ${gncel_distname_list}    ${wncel_distname_list}    SCFC Get 2G 3G Cell Distname    ${scf_path}
        ${bbu_list}    ${rmod_list}    ${cell_list}    ${rmod_chain}    btsInfo    ${scf_path}
        ${sm_sn_list}    ${bbmod_sn_list}    ${bbu_info}    Get BBU Info    ${bbu_list}
        ${fr_sn_list}    ${rmod_info}    Get RMOD Info    ${rmod_list}
        ${cells_class_name}    Get Configured Cell CLass Name    ${cell_list}
        ${lcrid_list}    Get Cell lcrid List   ${cell_list}
        ${fr_list_exclude_anchor}    Get FR List Exclude Anchor    ${cell_list}    ${fr_sn_list}
        ${fullrack}    ${active_sm}    ${passive_sm}    ${active_bbmod_list}    Current Configuration Check Full Rack    ${scf_path}
        ${tmp}    Create Dictionary
        Append To List    ${used_fr_sn_list}    @{fr_sn_list}
        Append To List    ${tested_fr_sn_list}    @{fr_list_exclude_anchor}
        Append To List    ${used_fhs_sn_list}    @{fhs_sn_list}
        Append To List    ${used_sm_sn_list}    @{sm_sn_list}
        Append To List    ${used_bbmod_sn_list}    @{bbmod_sn_list}
        Append To List    ${all_bts_id_list}    ${bts_id}
        Run Keyword If    "${SITE_MODE}" != "NSA"    Append To List    ${bts_list}    ${bts_id}
        ...    ELSE IF    "${node}" == "TL1"    Append To List    ${bts_list}    ${bts_id}
        ${all_cell_list}     combine_lists    ${all_cell_list}    ${cell_list}
        ${2g_3g_distname_list}    combine_lists    ${gncel_distname_list}    ${wncel_distname_list}
        Set To Dictionary    ${tmp}    host_ip=${BTS_CONFIG.HOST_IP.${node}}
        ...   scf_file_path=${scf_path}
        ...   node=${node}
        ...   id=${multi_config_id.${node}}
        ...   software_release=${sw_release}
        ...   software_active=${sw_version}
        ...   master_sm=${active_sm}
        ...   slave_sm=${passive_sm}
        ...   master_bbmod_list=${active_bbmod_list}
        ...   fr_sn_list=${fr_sn_list}
        ...   fr_exclude_anchor=${fr_list_exclude_anchor}
        ...   fr_chain_list=${rmod_chain}
        ...   fhs_sn_list=${fhs_sn_list}
        ...   bbmod_sn_list=${bbmod_sn_list}
        ...   sm_sn_list=${sm_sn_list}
        ...   category_alarms=${category_alarms}
        ...   cells_class_name=${cells_class_name}
        ...   lcrid_list=${lcrid_list}
        ...   rmod_info=${rmod_info}
        ...   bbu_info=${bbu_info}
        ...   fullrack=${fullrack}
        ...   lnbts=${lnbts}
        ...   nrbts=${nrbts}
        Set To Dictionary    ${node_cfg}    ${bts_id}=&{tmp}
        ${master_bts_id}    Set Variable If    '${node}'=='TL1'    ${bts_id}    ${master_bts_id}
    END
    ${all_cell_list}    Update Nsa Anchor Cell    ${all_cell_list}
    Recalculate Muticarrier   @{all_cell_list}
    ${used_fr_sn_list}    Remove Duplicates    ${used_fr_sn_list}
    ${used_fhs_sn_list}    Remove Duplicates    ${used_fhs_sn_list}
    ${used_sm_sn_list}    Remove Duplicates    ${used_sm_sn_list}
    ${used_bbmod_sn_list}    Remove Duplicates    ${used_bbmod_sn_list}
    Set Suite Variable    ${NODE_CFG}    ${node_cfg}
    Set Suite Variable    ${USED_FR_SN_LIST}    ${used_fr_sn_list}
    Set Suite Variable    ${TESTED_FR_SN_LIST}    ${tested_fr_sn_list}
    Set Suite Variable    ${USED_FHS_SN_LIST}    ${used_fhs_sn_list}
    Set Suite Variable    ${USED_SM_SN_LIST}    ${used_sm_sn_list}
    Set Suite Variable    ${USED_BBMOD_SN_LIST}   ${used_bbmod_sn_list}
    Set Suite Variable    ${MASTER_BTS_ID}    ${master_bts_id}
    Set Suite Variable    ${ALL_BTS_ID_LIST}    ${all_bts_id_list}
    Set Suite Variable    ${BTS_LIST}    ${bts_list}
    Set Suite Variable    ${ALL_CELL_LIST}    ${all_cell_list[0]}
    Set Suite Variable    ${2G_3G_DISTNAME_LIST}    ${2g_3g_distname_list}

Get SCFC Prefix Name
    [Arguments]    ${directory}    ${config_id}
    ${file_name_list}    OperatingSystem.List Directory    ${directory}
    FOR    ${file_name}    IN    @{file_name_list}
        ${status}    Run Keyword And Return Status    Should Contain    ${file_name}    ${config_id}
        Continue For Loop If    "${status}" =="False"
        ${prefix_file_name}    Split String    ${file_name}    _
        Return From Keyword If    ${status}    ${prefix_file_name[0]}
    END

Get BBU Info
    [Arguments]    ${bbu_list}
    ${sm_sn_list}    Create List
    ${bbmod_sn_list}    Create List
    ${bbu_info}    Create Dictionary
    FOR    ${bbu}    IN    @{bbu_list}
        ${status}    Run Keyword And Return Status     Dictionary Should Contain Key    ${bbu}    serialNumber
        Continue For Loop If    not ${status}
        ${serialNumber}    Pop From Dictionary    ${bbu}    serialNumber
        ${keys}    Get Dictionary Keys    ${bbu}
        Run Keyword If    "smodId" in "${keys}"    Append To List    ${sm_sn_list}    ${serialNumber}
        ...    ELSE IF    "bbmodId" in "${keys}"    Append To List    ${bbmod_sn_list}    ${serialNumber}
        Set To Dictionary    ${bbu_info}    ${serialNumber}=${bbu}
    END
    [Return]    ${sm_sn_list}    ${bbmod_sn_list}    ${bbu_info}

Get Configured Cell CLass Name
    [Arguments]    ${cell_list}
    ${cells_class_name}    Create List
    FOR    ${cell}    IN    @{cell_list}
        Run Keyword If    "${cell['NetworkType']}"=="NSA" or "${cell['NetworkType']}"=="SA"
        ...    Append To List    ${cells_class_name}    NRCEL
        ...    ELSE IF    "${cell['NetworkType']}"=="4G"    Append To List    ${cells_class_name}    LNCEL
        ...    ELSE IF    "${cell['NetworkType']}"=="3G"    Append To List    ${cells_class_name}    WNCEL
        ...    ELSE IF    "${cell['NetworkType']}"=="2G"    Append To List    ${cells_class_name}    GNCEL
    END
    ${cells_class_name}    Remove Duplicates    ${cells_class_name}
    [Return]    ${cells_class_name}

Get Cell lcrid List
    [Arguments]    ${cell_list}
    ${lcrid_list}    Create List
    FOR    ${cell}    IN    @{cell_list}
        ${lcrid}    Get From Dictionary    ${cell}    lcrId
        Append To List    ${lcrid_list}    ${lcrid}
    END
    [Return]     ${lcrid_list}

Get FR List Exclude Anchor
    [Arguments]    ${cell_list}    ${fr_sn_list}
    ${fr_sn_list_tmp}    Create List    @{fr_sn_list}
    FOR    ${cell}    IN    @{cell_list}
        Continue For Loop If    "${cell['NetworkType']}" != "4G"
        ${anchor_status}    Run Keyword And Return Status    List Should Contain Value    ${cell}    nrCellList
         ${fr_sn_list_tmp}    Run Keyword If    ${anchor_status}    Remove FR From FR List    ${cell["RF"]}    ${fr_sn_list_tmp}
         ...    ELSE    Create List    @{fr_sn_list_tmp}
    END
    [Return]    ${fr_sn_list_tmp}

Remove FR From FR List
    [Arguments]    ${rf_list}    ${fr_sn_list}
    FOR    ${rf_info}    IN    @{rf_list}
        Remove Values From List    ${fr_sn_list}    ${rf_info["serialNumber"]}
    END
    [Return]    ${fr_sn_list}

Current Configuration Check Full Rack
    [Arguments]     ${scf_file_path}
    ${smod_count_tmp}=    Evaluate Xpath    ${scf_file_path}
    ...    count(.//managedObject[@class="com.nokia.srbts.eqmr:SMOD_R"])
    ${smod_count_tmp}=    Convert To Integer    ${smod_count_tmp}
    ${smod_role_types}=    Evaluate Xpath    ${scf_file_path}
    ...     .//managedObject[@class="com.nokia.srbts.eqmr:SMOD_R"]/p[@name="activeRole"]/text()
    ${fullrack}=    Set Variable If   'Secondary' in ${smod_role_types}  True   False
    ${active_sm}=    Run Keyword If   ${fullrack}
    ...    Get Element Text   ${scf_file_path}
    ...    xpath=//managedObject[@class='com.nokia.srbts.eqmr:SMOD_R'][p[@name="activeRole"]='Primary']/p[@name="serialNumber"]
    ...    ELSE   Get Element Text   ${scf_file_path}
    ...    xpath=//managedObject[@class='com.nokia.srbts.eqmr:SMOD_R']/p[@name="serialNumber"]
        ${active_cfgDN}    Run Keyword If   ${fullrack}
    ...    Get Element Text   ${scf_file_path}
    ...    xpath=//managedObject[@class='com.nokia.srbts.eqmr:SMOD_R'][p[@name="activeRole"]='Primary']/p[@name="configDN"]
    ...    ELSE   Get Element Text   ${scf_file_path}
    ...    xpath=//managedObject[@class='com.nokia.srbts.eqmr:SMOD_R']/p[@name="configDN"]
    ${active_bbmod_configDN_list}    Evaluate Xpath   ${scf_file_path}
    ...  .//managedObject[@class="com.nokia.srbts.eqm:CABLINK" and p[@name="firstEndpointDN"]="${active_cfgDN}"]/p[@name="secondEndpointDN"]/text()
    ${active_bbmod_list}    Create List
    FOR    ${bbmod_configDN}    IN    @{active_bbmod_configDN_list}
        ${type}    Fetch From Right    ${bbmod_configDN}    /
        ${status}    Run Keyword And Return Status    Should Match Regexp    ${type}    BBMOD
        Continue For Loop If    not ${status}
        ${active_bbmod}    Get Element Text     ${scf_file_path}
        ...    //managedObject[@class='com.nokia.srbts.eqmr:BBMOD_R'][p[@name="configDN"]='${bbmod_configDN}']/p[@name="serialNumber"]
        Append To List    ${active_bbmod_list}    ${active_bbmod}
    END
    ${passive_sm}=    Run Keyword If   ${fullrack}
    ...    Get Element Text   ${scf_file_path}
    ...    xpath=//managedObject[@class='com.nokia.srbts.eqmr:SMOD_R'][p[@name="activeRole"]='Secondary']/p[@name="serialNumber"]
    [Return]    ${fullrack}    ${active_sm}    ${passive_sm}    ${active_bbmod_list}

Logging Multinode Start
    [Arguments]    ${logs_dir}=${TEST_LOGS_DIR_PATH}    ${pre_alias}=${CASE_NAME}    ${timeout}=120
    FOR   ${bts_id}    IN    @{ALL_BTS_ID_LIST}
        Run Keyword If   '${bts_id}' == '${MASTER_BTS_ID}'
        ...    Logging Start     ${logs_dir}    ${NODE_CFG['${bts_id}']['software_release']}    alias=${pre_alias}_${bts_id}    timeout=${timeout}
        ...    ELSE    Logging Start    ${logs_dir}    ${NODE_CFG['${bts_id}']['software_release']}    ${NODE_CFG['${bts_id}']['host_ip']}
        ...            alias=${pre_alias}_${bts_id}    timeout=${timeout}
    END

Logging Multinode Start KPI
    [Arguments]    ${logs_dir}=${TEST_LOGS_DIR_PATH}    ${pre_alias}=${CASE_NAME}    ${timeout}=120
    FOR   ${bts_id}    IN    @{ALL_BTS_ID_LIST}
        Run Keyword If   '${bts_id}' == '${MASTER_BTS_ID}'
        ...    Logging Start KPI     ${logs_dir}    ${NODE_CFG['${bts_id}']['software_release']}
        ...    alias=${pre_alias}_${bts_id}    timeout=${timeout}
        ...    ELSE    Logging Start KPI    ${logs_dir}    ${NODE_CFG['${bts_id}']['software_release']}
        ...    ${NODE_CFG['${bts_id}']['host_ip']}
        ...            alias=${pre_alias}_${bts_id}    timeout=${timeout}
    END

Logging Multinode Stop
    [Arguments]    ${logs_dir}=${TEST_LOGS_DIR_PATH}    ${test_status}=PASS    ${pre_alias}=${CASE_NAME}
    ${save_log}    Get Variable Value    ${GLO_PERFORM_SAVE_LOG}    FAIL
    FOR   ${bts_id}    IN    @{ALL_BTS_ID_LIST}
        Run Keyword If   '${bts_id}' == '${MASTER_BTS_ID}'
        ...   Logging Stop     ${logs_dir}    test_status=${test_status}    alias=${pre_alias}_${bts_id}    save_log=${save_log}
        ...   ELSE    Logging Stop    ${logs_dir}    test_status=${test_status}    alias=${pre_alias}_${bts_id}
        ...           save_log=${save_log}
    END

Logging Multinode Restart
    [Arguments]    ${logs_dir}=${TEST_LOGS_DIR_PATH}    ${pre_alias}=${CASE_NAME}    ${test_status}=PASS
    ${save_log}    Get Variable Value    ${GLO_PERFORM_SAVE_LOG}    FAIL
    FOR    ${bts_id}    IN    @{ALL_BTS_ID_LIST}
        Run Keyword If   '${bts_id}' == '${MASTER_BTS_ID}'
        ...    Logging Restart     ${logs_dir}    ${NODE_CFG['${bts_id}']['software_release']}    alias=${pre_alias}_${bts_id}
        ...    test_status=${test_status}    save_log=${save_log}
        ...    ELSE    Logging Restart    ${logs_dir}    ${NODE_CFG['${bts_id}']['software_release']}
        ...            host_ip=${NODE_CFG['${bts_id}']['host_ip']}
        ...            alias=${pre_alias}_${bts_id}    test_status=${test_status}    save_log=${save_log}
    END

Verify HW state
    [Arguments]    ${pre_alias}=${CASE_NAME}
    FOR    ${bts_id}    IN   @{ALL_BTS_ID_LIST}
        Admin HW Check    SMOD   ${NODE_CFG['${bts_id}'].sm_sn_list}    parameters=operationalState=regex"(?i)Enabled"
        ...    timeout=600s    connection=${pre_alias}_${bts_id}
        Admin HW Check    BBMOD   ${NODE_CFG['${bts_id}'].bbmod_sn_list}    parameters=operationalState=regex"(?i)Enabled"
        ...    timeout=600s    connection=${pre_alias}_${bts_id}
        Admin HW Check    RMOD   ${NODE_CFG['${bts_id}'].fr_sn_list}     parameters=operationalState=regex"(?i)Enabled|Disabled"
        ...    timeout=600s    connection=${pre_alias}_${bts_id}
    END

Perform Template File Commissioning
    [Arguments]        ${bts_id}    ${ignore_errors}=False    ${connection}=default
    Log    \nBTS template commissioning procedure on bts_id node=${bts_id} started    console=True
#    RUn Keyword If    "${reset_conf}" == "True"    Run Keyword And Continue On Failure    Run Keywords
#    ...    coam.Reset Configuration    timeout=1800    connection=${connection}
#    ...    AND    sleep    120s
#    ...    AND    coam.assert any    SMOD    parameters=operationalState=regex"(?i)Enabled", serialNumber=${NODE_CFG['${bts_id}'].master_sm}
#    ...    timeout=600s    connection=${connection}
#    ...    AND    Admin HW Check    BBMOD   ${NODE_CFG['${bts_id}'].master_bbmod_list}    parameters=operationalState=regex"(?i)Enabled"
#    ...    timeout=600s    connection=${connection}
#    ...    AND    Sleep    1 min
    coam.Perform Commissioning
    ...    ${bts_id}    ${NODE_CFG['${bts_id}']['scf_file_path']}    skip_parameter_relation_errors=${ignore_errors}
    ...    should_activate=True    timeout=1200    connection=${connection}
#    ${status}    ${response}=    Run Keyword And Ignore Error
#    ...    Set Variable    ${result['commissioningResult']['activationResult']['resultNode']['parameters']['result']}
#    Run Keyword If       '${response}' != 'Success'    Log   Recommissioning failed due to  ${response}
#    Should Be True       '${response}' == 'Success'
#    [Return]    ${status}   ${result}

Remove Hwbin File
    FOR    ${bts_id}    IN    @{ALL_BTS_ID_LIST}
        ${host_ip}    Set Variable    ${NODE_CFG["${bts_id}"]["host_ip"]}
        Setup eNB FSM Access    host=${BTS_HOST}    timeout=15    remote_host=${host_ip}    alias=rm_config_${host_ip}
        execute_command_on_enb    cmd=rm -rf /ffs/run/config/hwf.bin.gz    alias=rm_config_${host_ip}
    END
    [Teardown]    teardown_all_aliases_for_enb_fsmaccess

Perform Parameters Commissioning
    [Arguments]        ${bts_id}    ${ignore_errors}=True    ${connection}=default
    ...    ${online_commissioning_tmp}=${online_commissioning}
    Log    \nBTS parameters commissioning procedure on bts_id node=${bts_id} started    console=True
    ${online_commissioning_tmp}    Evaluate    ${online_commissioning_tmp}
    coam.Create delta
    FOR    ${parament}    IN    @{online_commissioning_tmp}
        coam.Append parameter update to delta    ${parament[0]}    ${parament[1][0]}    ${parament[1][1]}
    END
    ${delta_update}=    coam.Get delta
    ${result}    Run Keyword And Continue On Failure    coam.perform_delta_recommissioning
    ...    ${delta_update}    skip_parameter_relation_errors=${ignore_errors}
    ...    should_activate=True    timeout=600    connection=${connection}
    ${status}    ${response}=    Run Keyword And Ignore Error
    ...    Set Variable    ${result['commissioningResult']['activationResult']['resultNode']['parameters']['result']}
    Run Keyword If       '${response}' != 'Success'    Log   Recommissioning failed due to  ${response}
    Should Be True       '${response}' == 'Success'
    [Return]    ${status}   ${result}

Admin HW Check
    [Arguments]    ${class_name}    ${hw_list}    ${parameters}=operationalState=Enabled, availabilityStatus=Online
    ...    ${timeout}=5s    ${connection}=default
    ${detected_list}=        Create List
    ${not_detected_list}=    Create List
    FOR    ${sm_id}    IN    @{hw_list}
           ${assert_parameters}=    Set Variable    ${parameters}, serialNumber=${sm_id}
           ${status}=    Run Keyword And Return Status    coam.Assert Any
    ...    class_name=${class_name}
    ...    parameters=${assert_parameters}
    ...    timeout=${timeout}
    ...    connection=${connection}
           Run Keyword If   ${status}    Append To List    ${detected_list}    ${sm_id}
    ...                 ELSE              Append To List    ${not_detected_list}    ${sm_id}
           Run Keyword And Continue On Failure    Should Be True   ${status}
    END
    Run Keyword If   ${not_detected_list}    Log    Not Detected ${class_name} list: ${not_detected_list}. console=True
    Run Keyword If   ${detected_list}    Log    Detected ${class_name} list: ${detected_list}.     console=True

#Verify Node Cells OnAir
#    [Arguments]    ${bts_id}    ${timeout}=200 sec    ${pre_alias}=${CASE_NAME}
#    Admin HW Check    RMOD   ${NODE_CFG['${bts_id}'].fr_sn_list}
#    ...   parameters=availabilityStatus=Online, operationalState=Enabled    timeout=600s    connection=${pre_alias}_${bts_id}
#    FOR    ${class_name}    IN    @{NODE_CFG['${bts_id}'].cells_class_name}
#        coam.Assert Every    ${class_name}    availabilityStatus=Online, operationalState=Enabled
#        ...   timeout=${timeout}   connection=${pre_alias}_${bts_id}
#    END
#
#Verify All Cells Onair
#    FOR   ${bts_id}    IN    @{ALL_BTS_ID_LIST}
#        Verify Node Cells OnAir    ${bts_id}

#Verify All Cells OnAir
#    [Arguments]    ${pre_alias}=${CASE_NAME}
#    FOR    ${cell_list}    IN    @{ALL_CELL_LIST}
#        ${cell_info}    coam.Get Cell Specific Info    cell_id=${cell_list["distName"]}    connection=${pre_alias}_${cell_list["btsId"]}
#        Should Be Equal As Strings    ${cell_info["status"]["operationalState"]}    Enabled
#        Should Be Equal As Strings    ${cell_info["status"]["availabilityStatus"]}    Online
#        Should Be Equal As Strings    ${cell_info["status"]["blockingState"]}    Unblocked
#    END
#
#Wait For All Cells OnAir
#    [Arguments]    ${timeout}=600s
#    Wait Until Keyword Succeeds    ${timeout}    30 sec    Verify All Cells OnAir

Check Multinode Without Unexpect Alarm
    [Arguments]    ${pre_alias}=${CASE_NAME}
    FOR    ${bts_id}    IN    @{ALL_BTS_ID_LIST}
        Admin Alarms Get And Check    allowed=${GLO_ADMIN_ALLOWED_ALARM}    alias=${pre_alias}_${bts_id}
    END

Software Check And Correct
    [Arguments]    ${pre_alias}=${CASE_NAME}
    FOR    ${bts_id}    IN    @{ALL_BTS_ID_LIST}
        ${sw_compatible_status}    Check FR SW Version Is Compatible With BTS SW    ${bts_id}    ${pre_alias}
        Continue For Loop If     '${sw_compatible_status}'=='True'
        ${status}    Run Keyword And Return Status    OperatingSystem.Directory Should Not Exist   ${SW_BUILDS_DIR_PATH}
        Run Keyword If    ${status}    OperatingSystem.Create Directory    ${SW_BUILDS_DIR_PATH}
        ${files}    OperatingSystem.List Files In Directory    ${SW_BUILDS_DIR_PATH}
        ${sw_downloaded}    Run Keyword And Return Status    Should Contain Match    ${files}
        ...    regexp=${NODE_CFG['${bts_id}'].software_active}
        ${package_type}    Get Variable Value    ${tl_config.PACKAGE_TYPE}    Normal
        Run Keyword If    '${sw_downloaded}'=='False'    Sw Package Download    ${NODE_CFG['${bts_id}'].software_active}
        ...    target_dir=${SW_BUILDS_DIR_PATH}    package_type=${package_type}
        ${files}    OperatingSystem.List Files In Directory    ${SW_BUILDS_DIR_PATH}
        ${matched_file}    Get Matches   ${files}    ${NODE_CFG['${bts_id}'].software_active}*
        Set To Dictionary    ${NODE_CFG['${bts_id}']}    active_file_path=${matched_file[0]}
        Run Keyword And Ignore Error    coam.wait_sw_update_possible    connection=${pre_alias}_${bts_id}
        coam.Update Software    ${SW_BUILDS_DIR_PATH}/${matched_file[0]}    timeout=3600    connection=${pre_alias}_${bts_id}
    END

Check FR SW Version Is Compatible With BTS SW
    [Arguments]    ${bts_id}    ${pre_alias}=default
    ${rmod_version_dict}    Wait Until Keyword Succeeds    15 min    30 sec    Get Node RU Version    ${bts_id}    ${pre_alias}
    ${fr_serial_number_list}    Get Dictionary Keys    ${rmod_version_dict}
    ${targetbd_path}    Get TargetBD File    remote_host=${NODE_CFG['${bts_id}'].host_ip}
    FOR    ${fr_sn}    IN    @{fr_serial_number_list}
        ${radio_version_targetbd}    Get Node RU Version From TargetBD
        ...    variant=${rmod_version_dict['${fr_sn}']['productName']}    radio_build=${rmod_version_dict['${fr_sn}']['buildVersion']}
        ...    targetbd_path=${targetbd_path}
        ${status}    Run Keyword And Return Status    Should Be Equal    ${radio_version_targetbd}
        ...    ${rmod_version_dict['${fr_sn}']['buildVersion']}
        Exit For Loop If    '${status}'=='False'
    END
    [Return]    ${status}

Get Node RU Version
    [Arguments]    ${bts_id}    ${pre_alias}=default
    ${rmod_parameters_list}    coam.get parameters for all    RMOD    connection=${pre_alias}_${bts_id}
    ${actual_rmod_count}    Get Length    ${rmod_parameters_list}
    ${rmod_count}    Get Length    ${NODE_CFG["${bts_id}"].fr_sn_list}
    Should Be Equal As Integers    ${actual_rmod_count}    ${rmod_count}
    ${rmod_version_dict}    Create Dictionary
    FOR    ${rmod_parameters}    IN    @{rmod_parameters_list}
        Should Not Be Equal    ${rmod_parameters.buildVersion}    ${EMPTY}
        Should Not Be Equal    ${rmod_parameters.buildVersion}    ${None}
        ${tmp}    Create Dictionary    buildVersion    ${rmod_parameters.buildVersion}    productName
        ...    ${rmod_parameters.productName}
        Set To Dictionary    ${rmod_version_dict}    ${rmod_parameters.serialNumber}=${tmp}
    END
    [Return]    ${rmod_version_dict}

Get TargetBD File
    [Arguments]    ${ip_addr}=${BTS_HOST}    ${remote_host}=None    ${timeout}=240
    IF    "${remote_host}" != "None"
        csn.connect to    ${remote_host}    ute    ute    port=22    alias=remote_host
        csn.connect to    ${ip_addr}    toor4nsn    oZPS0POrRieRtu    port=22    proxy=remote_host    timeout=${timeout}
        ...    alias=bts
    ELSE
        csn.connect to    ${ip_addr}    toor4nsn    oZPS0POrRieRtu    port=22    timeout=${timeout}    alias=bts
    END
    ${active_path}    csn.execute    readlink -f /ffs/run    connection=bts
    ${active_path}    Strip String    ${active_path}
    ${targetbd}    csn.execute    cat ${active_path}/TargetBD_*.xml    connection=bts
    Create File    ${TEST_LOGS_DIR_PATH}/targetbd.xml    ${targetbd}
    [Teardown]    Run Keywords    Run Keyword If    "${remote_host}" != "None"    Run Keyword And Ignore Error
    ...    csn.disconnect    connection=remote_host
    ...    AND    csn.disconnect    connection=bts
    [Return]    ${TEST_LOGS_DIR_PATH}/targetbd.xml


Get Node RU Version From TargetBD
    [Arguments]    ${variant}    ${radio_build}    ${targetbd_path}
    ${radio_version_targetbd}    Get Elements    ${targetbd_path}
    ...    //hwResource[contains(@resourceBuildKey, '${variant}')]/@resourceSWVersion
    ${matches}    Get Matches    ${radio_version_targetbd}    ${radio_build[:7]}*
    ${status}     Run Keyword And Return Status    Should Not Be Empty    ${matches}
    ${ru_version}    Set Variable If    ${status}    ${matches[0]}    ${radio_version_targetbd[0]}
    [Return]    ${ru_version}

SCFC Get BtsId
    [Arguments]    ${scfc_file_path}
    [Documentation]    Returns value of btsId that is defined in given SCFC file stored on local Robot PC.
    ...    Author:      artur.dobosz@nokia.com
    ...    Maintainer:  Author
    ${out_dist_name}=    Evaluate Xpath    ${scfc_file_path}
    ...  string(.//managedObject[contains(@class, ":MRBTS")]/@distName | .//managedObject[@class='BTSSCL']/p[@name='btsId'])
    ${out_bts_id}=    Should Match Regexp    ${out_dist_name}    (?:MRBTS-)?(\\d+)
    ${lnstatus}    ${ln_dist_name}    Run Keyword And Ignore Error    Evaluate Xpath    ${scfc_file_path}
    ...    string(.//managedObject[@class='NOKLTE:LNBTS']/@distName)
    ${nrstatus}    ${nr_dist_name}    Run Keyword And Ignore Error    Evaluate Xpath    ${scfc_file_path}
    ...    string(.//managedObject[@class='com.nokia.srbts.nrbts:NRBTS']/@distName)
    ${lnbtsid}    Run Keyword If    "${lnstatus}"=="PASS" and "${ln_dist_name}"!="${EMPTY}"    Fetch From Right
    ...    ${ln_dist_name}    LNBTS-
    ${nrbtsid}    Run Keyword If    "${nrstatus}"=="PASS" and "${nr_dist_name}"!="${EMPTY}"    Fetch From Right
    ...    ${nr_dist_name}    NRBTS-
    [Return]    ${out_bts_id[1]}    ${lnbtsid}    ${nrbtsid}

SCFC Create FHS Serial Number List
    [Arguments]    ${scf_file}
    [Documentation]    Returns list of serial numbers for all FHSs defined in given SCFC file stored on local Robot PC.
    ...    Author:
    ...    Maintainer:  Author
    ${fhs_sn_list}=    Evaluate Xpath    ${scf_file}
    ...     .//managedObject[contains(@class, 'FHS_R')]/p[@name='serialNumber']/text()
    [Return]    @{fhs_sn_list}

SCFC Get 2G 3G Cell Distname
    [Arguments]    ${scf_file_path}
    ${gncel_distname}    Evaluate Xpath    ${scf_file_path}
    ...    .//managedObject[@class='com.nokia.srbts.gsm:GNCEL']/@distName
    ${wncel_distname}    Evaluate Xpath    ${scf_file_path}
    ...    .//managedObject[@class='com.nokia.srbts.wcdma:WNCEL']/@distName
    [Return]    ${gncel_distname}    ${wncel_distname}

SCFC Create Activate Category Alarms Value
    [Arguments]    ${scf_file_path}
    ${out_value}=    Evaluate Xpath    ${scf_file_path}
    ...     string(.//managedObject[@class='com.nokia.srbts.mnl:FMCADM']/p[@name='actCategoryAlarms'])
    ${out_value}=    Convert To Boolean    ${out_value}
    [Return]    ${out_value}

Get Current Scfc
    [Arguments]    ${bts_id}
    ${node}    Set Variable    ${NODE_CFG["${bts_id}"].node}
    Run Keyword If    '${node}'=='TL1'
    ...    coam.Setup Admin    bts_host=${BTS_HOST}    username=Nemuadmin    password=nemuuser    timeout=30
    ...    ELSE    coam.Setup Admin    bts_host=${BTS_HOST}    username=Nemuadmin    password=nemuuser
    ...            remote_host=${BTS_CONFIG.HOST_IP.${node}}    timeout=30
    ${date}    Get Current Date    result_format=%Y%m%d%H%M%S
    coam.get_current_scf_file    ${TEST_LOGS_DIR_PATH}    SCFC_${bts_id}_${date}.xml    export_type=configurationAndRuntimeObjects
        ...    timeout=120
    [Teardown]    coam.Teardown
    [Return]    ${TEST_LOGS_DIR_PATH}/SCFC_${bts_id}_${date}.xml

Create Node Parameters From Current SCF
    ${ALL_CELL_LIST}    Create List
    ${tested_fr_sn_list}    Create List
    FOR    ${bts_id}    IN    @{ALL_BTS_ID_LIST}
        ${sw_version}    ${sw_release}    Get Node SW Build And Release    ${NODE_CFG["${bts_id}"].node}
        ${current_scfc}    Get Current Scfc    ${bts_id}
        ${category_alarms}     SCFC Create Activate Category Alarms Value    ${current_scfc}
        ${bbu_list}    ${rmod_list}    ${cell_list}    ${rmod_chain}    btsInfo    ${current_scfc}
        ${sm_sn_list}    ${bbmod_sn_list}    ${bbu_info}    Get BBU Info    ${bbu_list}
        ${fr_sn_list}    ${rmod_info}    Get RMOD Info    ${rmod_list}
        ${cells_class_name}    Get Configured Cell CLass Name    ${cell_list}
        ${lcrid_list}    Get Cell lcrid List   ${cell_list}
        ${fr_list_exclude_anchor}    Get FR List Exclude Anchor    ${cell_list}    ${fr_sn_list}
        ${tested_fr_sn_list}    combine_lists    ${tested_fr_sn_list}    ${fr_list_exclude_anchor}
        ${all_cell_list}     combine_lists    ${all_cell_list}    ${cell_list}
        Set To Dictionary    ${NODE_CFG["${bts_id}"]}    scf_file_path=${current_scfc}
        ...   category_alarms=${category_alarms}
        ...   cells_class_name=${cells_class_name}
        ...   lcrid_list=${lcrid_list}
        ...   rmod_info=${rmod_info}
        ...   bbu_info=${bbu_info}
        ...   fr_exclude_anchor=${fr_list_exclude_anchor}
        ...   fr_chain_list=${rmod_chain}
        ...   software_release=${sw_release}
        ...   software_active=${sw_version}
    END
    ${all_cell_list}    Update Nsa Anchor Cell    ${all_cell_list}
    Recalculate Muticarrier     @{all_cell_list}
    Set Suite Variable    ${ALL_CELL_LIST}    ${all_cell_list[0]}
    Set Suite Variable    ${TESTED_FR_SN_LIST}    ${tested_fr_sn_list}

Logging Gnb Admin Start
    [Arguments]    ${timeout}=120
    FOR   ${bts_id}    IN    @{ALL_BTS_ID_LIST}
        Logging Node Gnb Admin Start    ${bts_id}    timeout=${timeout}
    END

Logging Node Gnb Admin Start
    [Arguments]    ${bts_id}    ${try_count}=3    ${logs_dir}=${TEST_LOGS_DIR_PATH}    ${pre_alias}=${CASE_NAME}    ${timeout}=120
    FOR   ${i}    IN RANGE    ${try_count}
        ${status}    ${output}    Run Keyword And Ignore Error
        ...    Run Keyword If   '${bts_id}' == '${MASTER_BTS_ID}'
        ...    gnb_coam.Setup Admin         bts_host=${BTS_HOST}
        ...                      bts_port=443
        ...                      admin_api_log_dir=${logs_dir}/Gnb_Admin_logs/
        ...                      timeout=${timeout}
        ...                      alias=${pre_alias}_${bts_id}
        ...  ELSE
        ...  gnb_coam.Setup Admin         bts_host=${BTS_HOST}
        ...                      bts_port=443
        ...                      admin_api_log_dir=${logs_dir}/Gnb_Admin_logs/
        ...                      remote_host=${NODE_CFG['${bts_id}']['host_ip']}
        ...                      timeout=${timeout}
        ...                      alias=${pre_alias}_${bts_id}
        Exit For Loop If    "${status}" == "PASS"
    END

Logging Gnb Admin Stop
    [Arguments]    ${pre_alias}=${CASE_NAME}
    FOR   ${bts_id}    IN    @{ALL_BTS_ID_LIST}
        gnb_coam.Teardown    ${pre_alias}_${bts_id}
    END

Power Off Test Node FSM
    [Arguments]    ${multi_config_id}
    ${nodes}    Get Dictionary Keys    ${multi_config_id}
    ${sm_sn_list}    Get Dictionary Keys    ${BTS_CONFIG['FSM']}
    ${sm_under_test}    Create List
    FOR    ${sn}    IN    @{sm_sn_list}
        Run Keyword If    "${BTS_CONFIG['FSM']['${sn}']['node']}" in "${nodes}"    Append To List    ${sm_under_test}    ${sn}
    END
    PDU Turn Off All Devices From Serial Number List    ${sm_under_test}    ${BTS_CONFIG}    FSM

Get Resource Usage Setup
    [Arguments]    ${aashell_name}=aashell
    run keyword    ${aashell_name}.Create Aashell Cli    name=aashell
    run keyword    ${aashell_name}.Setup    aashell
    ${resources_usage1}    run keyword    ${aashell_name}.Get Resources Usage    aashell
    Set Test Variable    ${resources_usage1}
    [Teardown]    run keyword    ${aashell_name}.Teardown    aashell

Get Resource Usage Teardown
    [Arguments]    ${aashell_name}=aashell
    run keyword    ${aashell_name}.Create Aashell Cli    name=aashell
    run keyword    ${aashell_name}.Setup    aashell
    ${resources_usage2}    run keyword    ${aashell_name}.Get Resources Usage    aashell
    run keyword    ${aashell_name}.Should Be Equal As Resources
    ...    ${resources_usage1}
    ...    ${resources_usage2}
    ...    exclude=//bufferPoolFreeCount
    [Teardown]    run keyword    ${aashell_name}.Teardown    aashell

Get And Check Truck Roll Alarm
    [Arguments]    ${bts_id}
    ${out_active_alarms_list}=    coam.Get Active Alarms   connection=${CASE_NAME}_${bts_id}
    FOR    ${alarm}    IN    @{out_active_alarms_list}
        ${status}    Run Keyword And Return Status    Dictionary Should Contain Key    ${alarm}    faultId
        Continue For Loop If    not ${status}
        ${status}    Run Keyword And Return Status    List Should Not Contain Value    ${TRUCK_ROLL_FAULTS}    ${alarm["faultId"]}
        Run Keyword If    not ${status}    Log To Console    Truck roll: fault ${alarm["faultId"]} exists!
        Should Be True    ${status}
    END

Verify HW state If Truck Roll
    [Arguments]    ${bts_id}
    ${bts_info}    coam.get_bts_info     connection=${CASE_NAME}_${bts_id}
    ${all_hw_info}    Create List    @{bts_info["systemModules"]}    @{bts_info["basebandModules"]}    @{bts_info["radioModules"]["rmod"]}
    FOR    ${hw_info}    IN    @{all_hw_info}
        ${status}    Run Keyword And Return Status    Variable Should Exist    ${hw_info["status"]["availabilityStatus"]}
        ${status2}    Run Keyword If    ${status}    Run Keyword And Return Status    Should Not Contain
        ...    ${hw_info["status"]["availabilityStatus"]}    nstalled
        ...    ELSE    Set Variable    ${True}
        Run Keyword If    not ${status2}    Log To Console    Truck roll: ${hw_info["serialNumber"]} not installed!
        Should Be True    ${status2}
    END

Lmp Is Reachable
    [Arguments]    ${bts_id}
    ${host_ip}    Set Variable    ${NODE_CFG['${bts_id}']['host_ip']}
    csn.connect_to    hostname=${host_ip}    username=ute    password=ute    port=22    alias=reachable
    csn.send_command    ping -c 4 -w 10 ${BTS_HOST}    timeout=20   connection=reachable
    ${lmp_result}    csn.read_output    connection=reachable
    ${status}    Run Keyword And Return Status    Should Contain    ${lmp_result}    4 received, 0% packet loss
    Run Keyword If    not ${status}    Log To Console    Truck roll: ${BTS_HOST} not available!
    Should Be True    ${status}
    [Teardown]    Run Keyword And Ignore Error    csn.disconnect    connection=reachable

Mplane Is Reachable
    [Arguments]    ${bts_id}
    ${host_ip}    Set Variable    ${NODE_CFG['${bts_id}']['host_ip']}
    csn.connect_to    hostname=${host_ip}    username=ute    password=ute    port=22    alias=reachable
    ${localIpAddr}    Get Scfc localIpAddr    ${NODE_CFG["${bts_id}"]["scf_file_path"]}
    csn.send_command    ping -c 4 -w 10 ${localIpAddr}    timeout=20   connection=reachable
    ${mplane_result}    csn.read_output    connection=reachable
    ${status}    Run Keyword And Return Status    Should Match Regexp    ${mplane_result}    4 received,.*0% packet loss
    Run Keyword If    not ${status}    Log To Console    Truck roll: ${localIpAddr} not available!
    Should Be True    ${status}
    [Teardown]    Run Keyword And Ignore Error    csn.disconnect    connection=reachable

Need Stop And Fix
    FOR    ${bts_id}    IN    @{ALL_BTS_ID_LIST}
        ${lmp_status}    Run Keyword And Return Status    Lmp Is Reachable    ${bts_id}
        Return From Keyword If    not ${lmp_status}    ${True}
    END
    Logging Multinode Start    ${TEST_LOGS_DIR_PATH}/truck_roll
    FOR    ${bts_id}    IN    @{ALL_BTS_ID_LIST}
        ${bts_status}    coam.get_bts_statuses     connection=${CASE_NAME}_${bts_id}
        Continue For Loop If    '${bts_status["proceduralState"]}'=='NotCommissioned'
        ${mplane_status}    Run Keyword And Return Status    Mplane Is Reachable    ${bts_id}
        Return From Keyword If    not ${mplane_status}    ${True}
        ${hw_status}    Run Keyword And Return Status    Verify HW state If Truck Roll    ${bts_id}
        Return From Keyword If    not ${hw_status}    ${True}
        ${fault_status}    Run Keyword And Return Status    Get And Check Truck Roll Alarm    ${bts_id}
        Return From Keyword If    not ${fault_status}    ${True}
    END
    Return From Keyword    ${False}
    [Teardown]    Run Keyword And Ignore Error    Logging Multinode Stop    ${TEST_LOGS_DIR_PATH}/truck_roll

Stop and Fix
    FOR    ${i}    IN RANGE    12
        ${stop_fix}    Need Stop And Fix
        Exit For Loop If    not ${stop_fix}
        Sleep    5 min
    END
    Run Keyword If    ${stop_fix}    Run Keywords    Log To Console    One of four conditions has been met, Stop and fix!
    ...    AND    Run Keyword And Ignore Error    truck_roll.Stop Fix Notification
    ...    AND    Run Keyword And Ignore Error    truck_roll.Send Email
    ...    AND    Sleep    72h

SCFC Get climateControlProfiling Value
    [Arguments]    ${scf_file_path}
    ${out_value}=    Evaluate Xpath    ${scf_file_path}
    ...     string(.//managedObject[@class='com.nokia.srbts.eqm:SMOD']/p[@name='climateControlProfiling'])
    [Return]    ${out_value}

Check Default Value Of Parameter
    ${check_fan_profile}    Get Variable Value    ${CHECK_CLIMATECONTROLPROFILING_DEFAULT}    ${True}
    Return From Keyword If    not ${check_fan_profile}
    ${bts_id}    Set Variable    ${MASTER_BTS_ID}
    ${release}    Set Variable    ${NODE_CFG["${bts_id}"]["software_release"]}
    Return From Keyword If    "${release}"=="SBTS23R1" or "${release}"=="SBTS22R4" or "${release}"=="SBTS22R3" or "${release}"=="SBTS22R2"
    ${software_active}    Set Variable    ${NODE_CFG["${bts_id}"]["software_active"]}
    Return From Keyword If    "FSM3" in "${software_active}"
#    ${localIpAddr}    Get Scfc localIpAddr    ${NODE_CFG["${bts_id}"]["scf_file_path"]}
    Selenium Login    url=https://${BTS_HOST}    version=${release}    alias=${CASE_NAME}_${bts_id}_ui
    ${detail}    selenium_coam.get_parameter_details    dist_name=MRBTS-${bts_id}/EQM-1/APEQM-1/CABINET-1/SMOD-1
    ...    filter_param=Climate control profiling    abbr=climateControlProfiling    sbts=${CASE_NAME}_${bts_id}_ui
    Should Be Equal As Strings    ${detail["Default value"]}    Optimized Cooling
    Return From Keyword If    "${release}"=="SBTS23R2"
    selenium_coam.refresh_page    sbts=${CASE_NAME}_${bts_id}_ui
    Sleep    10s
    ${status}    ${detail3}    Run Keyword And Ignore Error     selenium_coam.get_parameter_details
    ...    dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/FEATCADM-1
    ...    filter_param=Transceiver alarm monitoring    abbr=actTransceiverAlarmMonitoring    sbts=${CASE_NAME}_${bts_id}_ui
    Run Keyword IF    '${status}'=='FAIL'      Sleep    5s
    ${detail3}    Run Keyword If    '${status}'=='FAIL'    selenium_coam.get_parameter_details
    ...    dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/FEATCADM-1
    ...    filter_param=Transceiver alarm monitoring    abbr=actTransceiverAlarmMonitoring    sbts=${CASE_NAME}_${bts_id}_ui
    ...    ELSE    Set Variable    ${detail3}
    Should Be Equal As Strings    ${detail3["Default value"]}    Transceiver alarms
    [Teardown]    Run Keyword And Ignore Error    Selenium Logout    alias=${CASE_NAME}_${bts_id}_ui

Update Qc Id Tag
    [Arguments]    ${sw}=${sw_release}
    Log    Tags un-updated: ${TEST TAGS}
    FOR    ${tag}    IN    @{TEST TAGS}
        ${sp}    split string    ${tag}    :
        ${len}    Get Length    ${sp}
        Continue For Loop If    '${len}'=='1'
        ${status}    ${return}    Run Keyword And Ignore Error    Should Contain    ${tag}    SBTS
        Run Keyword IF    '${status}'=='PASS'    Run Keyword IF     '${sp[0]}'=='${sw}'    Set Tags    ${sp[1]}
        Run Keyword IF    '${status}'=='PASS'    Remove tags    ${tag}
    END
    Log    Tag updated: ${TEST TAGS}
