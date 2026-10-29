*** Settings ***
Documentation    Suite description
...    Author:Frank Luo
...    contact:frank.s.luo@nokia-sbell.com

Library    OperatingSystem
Library    Collections
Library    String
Library    BuiltIn
Library    DateTime
Variables    ./TLConfigurationDefault.py
Variables    ./CaseConfiguration.py
Resource     ../../../../RRM/RAN_PZ_HAZ_34/5GC000496_C/Resources/L3Call.robot
#Resource  testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/LTE/General_SiSo_Commissioning_BTS_Template_Commissioning.robot
#Resource  testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/LTE/
#          /General_SiSo_Configuration_BPF_and_TargetBD_support_for_RF_module.robot
#Resource  testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/LTE/General_SiSo_BTS_startup_with_RF_delayed_startup.robot
#Resource  testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/LTE/General_SiSo_SOAP_RP1_verification.robot

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_LTE.robot
Resource    ${BASIC_PATH_COMMON}/SBTS_Setup_And_Teardown.robot
Resource    ${BASIC_PATH_COMMON}/Manual_SiSo_CM_Recommissioning.robot
Resource    ${BASIC_PATH_COMMON}/Manual_SiSo_CM_Commissioning_Configuration_reset.robot
Resource    ${BASIC_PATH_COMMON}/General_KPI_Test_Case.robot
Resource    ${BASIC_PATH_COMMON}/Auto_BTS_site_reset.robot
Resource    ${BASIC_PATH_COMMON}/Manual_SiSo_SWM_Software_download_and_activation.robot
Resource    ${BASIC_PATH_COMMON}/Manual_SiSo_SM_BTS_Block_Site.robot
Resource    ${BASIC_PATH_COMMON}/Auto_RF_reset_success_rate_from_WebUI_with_L3Call.robot
Resource    ${BASIC_PATH_COMMON}/General_SiSo_BB_sub-unit_reset_with_L3_call.robot
Resource    ${BASIC_PATH_COMMON}/General_SiSo_BB_sub-unit_lock_and_unlock_with_L3_call.robot
Resource    ${BASIC_PATH_COMMON}/General_SiSo_SBTS_reset_without_HWF_in_loop.robot
Resource    ${BASIC_PATH_COMMON}/General_SiSo_SBTS_reset_without_HWF_in_loop.robot
Resource    ${BASIC_PATH_LTE}/General_SiSo_Commissioning_BTS_Template_Commissioning.robot
Resource    ${BASIC_PATH_LTE}/General_SiSo_Configuration_BPF_and_TargetBD_support_for_RF_module.robot
Resource    ${BASIC_PATH_LTE}/Manual_SiSo_SM_RF_Module_lock_unlock.robot
Resource    ${BASIC_PATH_LTE}/General_SiSo_BTS_startup_with_RF_delayed_startup.robot
Resource    ${BASIC_PATH_LTE}/General_SiSo_SOAP_RP1_verification.robot
Resource    ${BASIC_PATH_LTE}/5GC000561_eCPRI_sync_counters.robot
Resource    ${BASIC_PATH_LTE}/General_SiSo_Fault_1900_EFaultId_FrConfiguringFailed.robot

*** Variables ***

${WEBUI_URL}           https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_USERNAME}      ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}      ${tl.gnbs[0].cu.oam_http_connection_details.password}
${WEBUI_IP}            ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${ASIK_IP_Mplane}      ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${ASIK_IP}             ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${ASIK_username}	   ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${ASIK_password}	   ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${MRBTS_ID}            ${tl.gnbs[0].instance_id}
${NRBTS_ID}            ${tl.gnbs[0].global_bts_id}
&{condition_ru_same}     rf-FRU6=diff
${PA_INFO}             ${tl.attenuator[0]}

*** Keywords ***
TC.General_SiSo_Commissioning_BTS_Template_Commissioning
#    Set test variable    ${CASE_LOG_PATH}    ${LOG_PATH}
#    Set test variable    ${sbts_addr}    ${WEBUI_IP}
#    Set test variable    ${http_username}    ${WEBUI_USERNAME}
#    Set test variable    ${http_password}    ${WEBUI_PASSWORD}
    Set test variable    ${mrbtsID}    ${tl.gnbs[0].instance_id}
    General_SiSo_Commissioning_BTS_Template_Commissioning

TC.General_SiSo_Configuration_BPF_and_TargetBD_support_for_RF_module
    Set test variable    ${ssh_username}    ${ASIK_username}
    Set test variable    ${ssh_password}    ${ASIK_password}
    General_SiSo_Configuration_BPF_and_TargetBD_support_for_RF_module

TC.Manual_SiSo_SM_RF_Module_lock_unlock
    Manual_SiSo_SM_RF_Module_lock_unlock

TC.General_SiSo_BTS_startup_with_RF_delayed_startup
    set test variable    ${tl.enbs[0].system_module[0].pdu_port.pdu.vendor}    ${CASE_INPUT_CB008712['system_moudle_pdu_vernder']}
    set test variable    ${tl.enbs[0].system_module[0].pdu_port.pdu.addr}    ${CASE_INPUT_CB008712['system_moudle_pdu_addr']}
    set test variable    ${tl.enbs[0].system_module[0].pdu_port.port_no}    ${CASE_INPUT_CB008712['system_moudle_pdu_port']}


    General_SiSo_BTS_startup_with_RF_delayed_startup

TC.General_SiSo_SOAP_RP1_verification
    Set test variable    ${ssh_username}    ${ASIK_username}
    Set test variable    ${ssh_password}    ${ASIK_password}
    Set test variable    ${tl.enbs[0].rms[0].default_ssh_connection_details.username}    rfsw
    Set test variable    ${tl.enbs[0].rms[0].default_ssh_connection_details.password}    KRG3dFggxxHw+s0z64U0AR22VyjfnXdHrAVdSv5jpc4=

    General_SiSo_SOAP_RP1_verification

TC.General_SiSo_Fault_1900_EFaultId_FrConfiguringFailed
    Set test variable    ${ssh_username}    ${ASIK_username}
    Set test variable    ${ssh_password}    ${ASIK_password}
    General_SiSo_Fault_1900_EFaultId_FrConfiguringFailed_PMAX

TC.5GC000561_eCPRI_sync_counters
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test is to verify collecting PM counter data on eCPRI
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 2022.5.22 - - Created
    ...    *******************
    ...    Owner_jiayi.tang@nokia-sbell.com
    ${origin_value}    KW.Change NCPRI PM Interval LTE   interval=5min
    csn.connect to    hostname=${ASIK_IP}    username=${ASIK_USERNAME}    password=${ASIK_PASSWORD}  alias=ASIK Master
    KW.Check Sync Counter LTE   change_interval=5
    KW.Change NCPRI PM Interval LTE    interval=15min
    KW.Check Sync Counter LTE   change_interval=15
    [Teardown]  csn.Disconnect    connection=ASIK Master

KW.Change NCPRI PM Interval LTE
    [Arguments]  ${interval}
    log to console   \nChange NCPRI PM Interval to ${interval}
#    Selenium Logout And Close Browser
#    Selenium Login And Disable Screen Lock    download_dir=${CASE_LOG_PATH}    url=https://${sbts_addr}
#    ...    username=${http_username}    password=${http_password}
    COAM_WebEM.Login
    ${dist_name}    set variable    ${mrbtsID}/MNL-1/MNLENT-1/PMMNL-1
    ${filter_param}    set variable    SBTS NR eCPRI Master Statistics
    ${origin_value}  Get Parameter Via Webem    dist_name=${dist_name}    filter_param=${filter_param}
    run keyword if    '${interval}'!='${origin_value}'    selenium_coam.set_parameter_value  dist_name=${dist_name}
    ...    filter_param=${filter_param}
    ...    abbr=eCpriMasterStatisticsInterval    new_value=${interval}
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${True}
    sleep    5s
    [Return]    ${origin_value}
    [Teardown]  COAM_WebEM.Logout
KW.Check Sync Counter LTE
    [Arguments]    ${change_interval}=5
    log to console  \n***Check Sync Counter***
    Wait Until Next Counter Update    counter_period=${change_interval}
    COAM_WebEM.Login
    ${SyncMsg_Latest_value}    Get Transport Counters    counter_id=M40102C0
    ...                                        full_path=TNL-2/ETHLK/ETHLK-2/SBTS_NCPRI/topTxEcpriMstSyncMessg
    ${status}    Run Keyword And Ignore Error    Should Be True    4798 <= ${SyncMsg_Latest_value} <= 4802
    run keyword and ignore error    selenium_coam.refresh_page
    ${AnnMsg_Latest_value}    Get Transport Counters    counter_id=M40102C1
    ...                                       full_path=TNL-2/ETHLK/ETHLK-2/SBTS_NCPRI/topTxEcpriMstAnnounceMessg
    ${status}    Run Keyword And Ignore Error    Should Be True    2398 <= ${AnnMsg_Latest_value} <= 2402
    run keyword and ignore error    selenium_coam.refresh_page
    ${DelayRespMsg_Latest_value}    Get Transport Counters    counter_id=M40102C2
    ...                                       full_path=TNL-2/ETHLK/ETHLK-2/SBTS_NCPRI/topTxEcpriMstDelayRespMessg
    run keyword and ignore error    selenium_coam.refresh_page
    ${DelayReqMsg_Latest_value}    Get Transport Counters    counter_id=M40102C3
    ...                                       full_path=TNL-2/ETHLK/ETHLK-2/SBTS_NCPRI/topRxEcpriMstDelayReqMessg
    Should Be True    ${DelayRespMsg_Latest_value} == ${DelayReqMsg_Latest_value}
    run keyword and ignore error    selenium_coam.refresh_page
    ${SsmMsg_Latest_value}    Get Transport Counters    counter_id=M40102C4
    ...                                       full_path=TNL-2/ETHLK/ETHLK-2/SBTS_NCPRI/synceTxEcpriMstSsmMessg
    ${status}    Run Keyword And Ignore Error    Should Be True    298 <= ${SsmMsg_Latest_value} <= 302
    [Teardown]  COAM_WebEM.Logout
KW.AdaptCaseInput
    Basic.CheckVariableValid    var=CASE_INPUT_CB005845['DeltaSCFCellNumber']    default_value=None
    Basic.CheckVariableValid    var=CASE_INPUT_CB005845['CellType']    default_value=SA
    Basic.CheckVariableValid    var=CASE_INPUT_CB005845['TC11']['ru_index']     default_value=${1}
    Basic.CheckVariableValid    var=CASE_INPUT_CB005845['TC14']['ru_index']     default_value=${1}
    Basic.CheckVariableValid    var=CASE_INPUT_CB005845['TC16']['with_call']    default_value=${False}
    Basic.CheckVariableValid    var=CASE_INPUT_CB005845['TC16']['with_peak']    default_value=${False}
    Basic.CheckVariableValid    var=CASE_INPUT_CB005845['TC17']['with_call']    default_value=${True}
    Basic.CheckVariableValid    var=CASE_INPUT_CB005845['TC18']['addition_deletion_cell']       default_value=${1}
    Basic.CheckVariableValid    var=CASE_INPUT_CB005845['TC18']['addition_deletion_cellgrp']    default_value=${0}
    Basic.CheckVariableValid    var=CASE_INPUT_CB005845['TC19']['cell_id']     default_value=${1}
    Basic.CheckVariableValid    var=CASE_INPUT_CB005845['TC20']['ru_index']    default_value=${1}
    Basic.CheckVariableValid    var=CASE_INPUT_CB005845['TC21']['ru_index']    default_value=${1}
    Basic.CheckVariableValid    var=CASE_INPUT_CB005845['TC22']['ru_index']    default_value=${1}
    Basic.CheckVariableValid    var=CASE_INPUT_CB005845['TC22']['Tdanger_target']    default_value=30.0
    Basic.CheckVariableValid    var=CASE_INPUT_CB005845['TC23']['cell_id']     default_value=${1}
    Basic.CheckVariableValid    var=CASE_INPUT_CB005845['TC24']['band']        default_value=${71}
    Basic.CheckVariableValid    var=CASE_INPUT_CB005845['TC24']['ru_index']    default_value=${1}
    Basic.CheckVariableValid    var=CASE_INPUT_CB005845['TC24']['cell_id']     default_value=${1}
    Basic.CheckVariableValid    var=CASE_INPUT_CB005845['TC37']['ru_index']    default_value=${1}
    Basic.CheckVariableValid    var=CASE_INPUT_CB005845['TC39']['ue_index']    default_value=${0}
    Basic.CheckVariableValid    var=CASE_INPUT_CB005845['TC47']['frame_structure']    default_value=${1}
    Basic.CheckVariableValid    var=CASE_INPUT_CB005845['TC47']['ru_index']    default_value=${1}
    Basic.CheckVariableValid    var=CASE_INPUT_CB005845['TC47']['cell_id']     default_value=${1}
    Basic.CheckVariableValid    var=CASE_INPUT_CB005845['TC47']['ue_num_each_call']    default_value=${1}
    Basic.CheckVariableValid    var=CASE_INPUT_CB005845['TC47']['random_access']    default_value=${False}
    Basic.CheckVariableValid    var=CASE_INPUT_CB005845['TC48']['cell_band_frame_structure_list']    default_value=${1}
    Basic.CheckVariableValid    var=CASE_INPUT_CB005845['TC48']['cell_id']    default_value=${1}
    Basic.CheckVariableValid    var=CASE_INPUT_CB005845['TC48']['ue_num_each_call']    default_value=${1}
    Basic.CheckVariableValid    var=CASE_INPUT_CB005845['TC48']['random_access']    default_value=${False}

SISO 8712 Suite Setup
    UTECloud.ForceAdaptCommissionFiles
    TestSuite.Start
    set suite variable      ${SAVE LOG DIRECTORY}    ${LOG_PATH}
    set suite variable      ${UPDATE_FILE_PATH}    ${LOG_PATH}
    ${StreamTarget}      ${version_Target}      Basic.GetStreamAndVersion
    set suite variable    ${TARGETSW}    ${version_Target}
    set suite variable    ${TargetStream}     ${StreamTarget}
    set suite variable    ${OldCommissionSCF}    ${CFGFILE_PATH}/${TL_BASE_SCF_NR}
    KW.AdaptCaseInput
    log    ${default_cell_id}
    log    ${CASE_INPUT_CB005845['TC11']['ru_index']}

    Set suite variable    ${sbts_addr}    ${WEBUI_IP}
    Set suite variable    ${http_username}    ${WEBUI_USERNAME}
    Set suite variable    ${http_password}    ${WEBUI_PASSWORD}
    SBTS Suite Setup

KW.SBTS Test Setup
    log to console    \n***SBTS Test Setup***
    log to console    Active_SW_version(SBTS):${Active_SW_version}
    log to console    Golden_SCF_Path:${Golden_SCF_Path}
    Generate SBTS Test Case Log Path
    log to console  CASE_LOG_PATH:${CASE_LOG_PATH}
    ${ru_status}    Run Keyword And Return Status    COAM Check GNB RU status
#    ${cell_status}    Run Keyword And Return Status    Verify all cells should be onair    cell_type=${cell_type}
#    Run Keyword If    ${ru_status}==${False} or ${cell_status}==${False}
#    ...    Commissioning SCF And Check On Air    scf_path=${Golden_SCF_Path}
#    Start Btslog With Path Check
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    Selenium Login And Disable Screen Lock    download_dir=${CASE_LOG_PATH}    url=https://${sbts_addr}
    ...    username=${http_username}    password=${http_password}    version=${stream}
    gNB.FormatBTSID    lte=true
#    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
