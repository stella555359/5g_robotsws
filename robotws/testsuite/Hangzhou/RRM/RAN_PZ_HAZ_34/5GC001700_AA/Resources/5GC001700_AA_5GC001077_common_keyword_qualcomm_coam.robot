*** Settings ***
Documentation  Author: Lei Jia
...            Description: Feature 5GC001700_AA_5GC001077 common keywords on COAM.

Library    BuiltIn
Library    Collections
Library    String
Library    DateTime
Library    OperatingSystem
Library    taf.rfrl.common_resources.python.SWConfig    WITH NAME    swconf
Library    taf.config.scf    WITH NAME    scf
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
#Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/rrm_log_check.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_calculation_common_keywords.robot
Resource    taf/rfrl/common_resources/robot/coam_selenium.robot
Resource    taf/rfrl/common_resources/robot/TTI_Trace.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/BIP_trace/BIP_trace_collector.robot
Resource    taf/rfrl/common_resources/robot/connection_alias_store.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/check_android_ue_l3_call_process.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    taf/rfrl/common_resources/robot/common_setup_teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/Common_setup_and_teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    ../../common/BIP.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Variables   ../../5GC002007/TestData/2007_A_1796_E_scf_modify.py
Variables   ../../5GC002007/TestData/2007_A_1796_E_swconf_modify.py


*** Variables ***
${ASIK_MASTER_ALIAS}    ASIK Master
${ABIL_MASTER_ALIAS}    ABIL Master

${att_port10}           ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[1].port_no}
${TSHARK_PATH}    /usr/bin/tshark
${FILTER}    dldata_pdschsendreq||dldata_pdcchsendreq||uldata_puschreceivereq||uldata_pucchreceiverespharqd
${TSHARK_BIP_CMD}    {tshark_path} -r {pcap_file} -X lua_script:{luashark_path} -Y  \"${FILTER}\" -T pdml
${TSHARK_CPIF_CMD}    {tshark_path} -r {pcap_file} -X lua_script:{luashark_path} -Y \"nr-rrc\"  -T pdml


*** Keywords ***
#-----------------------Begin of Setup and Teardown-------------------------------------#
1700 Suite SetUp
    [Arguments]    ${value}=${None}    ${is_modify_att_needed}=${False}    ${asik_alais}=ASIK Master
    robot_common_operations.Common Suite Setup
    SISO Coam Suite Setup
    Run Keyword If    '${is_modify_att_needed}'=='True'    run keyword and continue on failure    Modify Programmable ATT Channel Vaules
    ...    value=${value}
    ...    vendor=${tl.attenuator.vendor}

1700 Suite TearDown
    robot_common_operations.Common Suite Teardown
    run keyword and ignore error    COAM Teardown gnb connections

1700 Case SetUp
    [Arguments]    ${is_initial_PA_needed}=${False}
    robot_common_operations.Common Case Setup
    Wait Until Keyword Succeeds    5 min    5 sec    connection_alias_store.Connect to Common Unit Master
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
    COAM Create log directory
    COAM Wait For Gnb Ready And Cell Setup    timeout=15 min
    Run Keyword If    '${is_initial_PA_needed}'=='${True}'    Get Initial Attenuation Values For CaseSetup
    run keyword and ignore error    COAM Teardown gnb connections
    Wait Until Keyword Succeeds    3 min    5 sec    Connect to gnb coam via ssl
    Get Luashark Path based on stream version

1700 Case TearDown
    [Arguments]    ${ue_index}=${0}    ${iperf_type}=via_app
    Run Keyword And Ignore Error    Stop Traffic With Power UE    ue_index=${ue_index}    iperf_type=${iperf_type}
    Run Keyword And Ignore Error    run    command=ps -ef | grep firefox |awk '{print $2}' | xargs kill -9
#    Run Keyword If Test Failed    Run Keyword And Ignore Error    COAM Save snapshot via rest api    timeout=${600}
    robot_common_operations.Common Case Teardown
    run keyword and continue on failure    CI_interface.Common Case Teardown
    Connections TearDown

Connections TearDown
    Run Keyword And Ignore Error    csn.disconnect    connection=ABIL Loner
    Run Keyword And Ignore Error    csn.disconnect    connection=ABIL Slave
    Run Keyword And Ignore Error    csn.disconnect    connection=ABIL Master
    Run Keyword And Ignore Error    csn.disconnect    connection=ASIK Master
    run keyword and ignore error    COAM Teardown gnb connections

531 Case Teardown
    [Arguments]    ${is_swconfig_modify}=${True}    ${is_initial_PA_needed}=${False}    ${ue_index}=${0}    ${iperf_type}=via_app
    Run Keyword If    ${is_initial_PA_needed}==${True}    wait until keyword succeeds    30 sec    5 sec
    ...    gnb_classical_hangzhou.Restore Attenuation Values For RU    initial_att_values=${initial_att_values}    vendor=${tl.attenuator.vendor}
    Run Keyword If    ${is_swconfig_modify}==${True}    run keywords
    ...    Connect to Common Unit Master    alias=${ASIK_MASTER_ALIAS}    AND
    ...    Run Keyword And Ignore Error    swconf.restore_swConfig_file_on_asik_and_crasign    asik_alias=${ASIK_MASTER_ALIAS}    AND
    ...    Run Keyword And Ignore Error    Perform BTS Site Reset    AND
    ...    Run Keyword And Ignore Error    sleep    60s    AND
    ...    Wait Until Keyword Succeeds    15 min    30 sec    connection_alias_store.Connect to Capacity Unit Master    AND
    ...    Wait until keyword succeeds    15 min    20 sec    COAM Check GNB cell on air via WebUI
    1700 Case TearDown    ue_index=${ue_index}    iperf_type=${iperf_type}

#-----------------------End of Setup and Teardown-------------------------------------#

Get SCF File Name based on stream version
    [Documentation]    Author: Jia Lei
    ...                Description: return SBTS_${scf_file_name} for common build.
    ...                             for 0.800 release, return original ${scf_file_name}.
    ...                             for common build, use SBTS_${scf_file_name}.
    [Arguments]      ${scf_file_name}=${None}
    ...               ${connection}=GNB_OAM
    ${sw_release_name}    coam.get_sw_release_name    connection=${connection}
    ${scf_file_name} =    set variable if    'SBTS' in '${sw_release_name}'    SBTS_${scf_file_name}    ${scf_file_name}
    [Return]    ${scf_file_name}

Get Luashark Path based on stream version
    [Documentation]    Author: Jia Lei
    ...                Description: return luashark_path for UTE cloud and jenkins
    [Arguments]      ${connection}=GNB_OAM
    ...    ${jenkins_luashark_path}=/home/ute/luashark_script/generated_luashark/luashark.lua
    ...    ${utecloud_luashark_path}=/opt/luashark/luashark.lua
    ${ute_env}    run keyword and return status    run keywords
    ...    Variable Should Exist    ${CONFIGURATION}    AND    Variable Should Exist    ${ENB_BUILD}
    ${utecloud_luashark}    Set Variable    ${utecloud_luashark_path}
    ${jenkins_luashark}    Set Variable    ${jenkins_luashark_path}
    ${luashark_path} =    set variable if    ${ute_env}    ${utecloud_luashark}    ${jenkins_luashark}
    Set Test Variable    ${luashark_path}

Get Initial Attenuation Values For CaseSetup
    [Arguments]    ${vendor}=${tl.attenuator.vendor}
    ${initial_att_values} =    gnb_classical_hangzhou.Get Initial Attenuation Values For RU    vendor=${vendor}
    set test variable    ${initial_att_values}
    ${att_port10}    convert to string    ${att_port10}
    set test variable    ${att_port10}

###Begin of Modify SCF####
Modify SCF and Perform Commission
    [Documentation]   Author: lei.jia@nokia-sbell.com
    ...              Description: This keyword can only support to modify elements parameter and list elements in scf
    ...              Element under MOs, Add if element not present
    ...              Element under List/Items match by index
    ...              two ways can be used for commission:
    ...              '${scf_file_name}' != '${None}, commission with given ${scf_path}/${scf_file_name}
    ...              set ${scf_file_name} to ${None}, download current scf from cluster, modify it and perform commission.
    ...              ${scf_dir_path}: Refer to the scf folder for storing the modified scf file
    [Arguments]      ${scf_file_name}=${None}
    ...               ${scf_path}=/home/ute/SCF
    ...               ${scf_dir_path}=${SUITE_LOG_PATH}
    ...               ${is_pdl_checking_needed}=${True}
    ...               ${ParameterToDelete}='NULL'
    ...               ${MOsToAdd}='NULL'
    ...               ${ParamterToModify}='NULL'
    ...               ${ListParamterToModify}='NULL'
    ...               ${ListToAdd}='NULL'
    Connect to gnb coam via ssl
    ${commssion_scf_file_path}    Run keyword if    '${scf_file_name}'!= '${None}'    Join Path    ${scf_path}    ${scf_file_name}
    ${scf_file_path}    set variable if    '${scf_file_name}'!= '${None}'    ${commssion_scf_file_path}    ${Golden_SCF_Path}
    ${modified_scf_file_path}    Load SCF and Define modified scf path    scf_file_path=${scf_file_path}    scf_dir_path=${scf_dir_path}
    run keyword if  not ${ParameterToDelete}=='NULL'     Delete Objects in SCF    parameters_lists=${ParameterToDelete}
    run keyword if  not ${MOsToAdd}=='NULL'    Add MOs To SCF with Given version
    ...                                                   parameters_lists=${MOsToAdd}
    run keyword if  not ${ParamterToModify}=='NULL'     Add and Modify elements to scf
    ...                                                   parameters_lists=${ParamterToModify}
    run keyword if  not ${ListParamterToModify}=='NULL'     Modify ListElements to scf
    ...                                                       parameters_lists=${ListParamterToModify}
    run keyword if  not ${ListToAdd}=='NULL'     AddLists to SCF    parameters_lists=${ListToAdd}
    scf.Save scf    ${modified_scf_file_path}
    COAM Commission with scf file    scf_file_path=${modified_scf_file_path}    timeout=900
    ...    is_pdl_checking_needed=${is_pdl_checking_needed}
    sleep    60s
#    Wait until keyword succeeds    15 min    20 sec    COAM Check GNB cell on air via WebUI    download_dir=${scf_dir_path}
    COAM Wait For Gnb Ready And Cell Setup    timeout=15 min

Load SCF and Define modified scf path
    [Documentation]   Author: lei.jia@nokia-sbell.com
    ...              Description: This keyword load scf and return modified scf path for future use.
    ...              ${scf_dir_path}: Refer to the scf folder for storing the modified scf file
    [Arguments]      ${scf_file_path}    ${scf_dir_path}=${SUITE_LOG_PATH}
    ${default_scf_file_path}    Copy file    source=${scf_file_path}    destination=${scf_dir_path}
    ${scf_file_name}    Fetch from right    ${scf_file_path}    /
#    ${scf_dir_path}    String.Replace string    ${scf_file_path}    /${scf_file_name}    ${EMPTY}
    ${file_name_without_extention}    String.Replace string    ${scf_file_name}    .xml    ${EMPTY}
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    ${scf_file_name_after_modify}    catenate  SEPARATOR=${EMPTY}    ${file_name_without_extention}    _${timestamp}_updated.xml
    ${modified_scf_file_path}    set variable    ${scf_dir_path}/${scf_file_name_after_modify}
    scf.Load scf    ${default_scf_file_path}
    [Return]    ${modified_scf_file_path}

Delete Objects in SCF
    [Documentation]   Remove object , Mo, List, Element with p_name.
    [Arguments]     ${parameters_lists}
    FOR    ${item}    IN    @{parameters_lists}
        ${res_dist_name}=    Run Keyword And Ignore error    set suite variable    ${dist_name_to_delete}   ${item}[dist_name]
        ${res_list_name}=    Run Keyword And Ignore error    set suite variable    ${list_name_to_delete}   ${item}[list_name]
        ${res_p_name}=    Run Keyword And Ignore error    set suite variable    ${p_name_to_delete}   ${item}[p_name]
        Run Keyword If   ${res_p_name}== ('PASS', None)
        ...              Run Keyword And Ignore error    scf.Remove Element From Scf    &{item}
        Run Keyword If   ${res_list_name}== ('PASS', None) and ${res_p_name}!= ('PASS', None)
        ...              Run Keyword And Ignore error    scf.remove_list_from_scf    dist_name=${item}[dist_name]   list_name=${item}[list_name]
        Run Keyword If   ${res_list_name}!= ('PASS', None) and ${res_p_name}!= ('PASS', None)
        ...              Run Keyword And Ignore error    scf.remove_mo_with_descendant_mos    dist_name=${item}[dist_name]
    END

Add and Modify elements to scf
    [Documentation]   Author: lei.jia@nokia-sbell.com
    [Arguments]   ${parameters_lists}
    FOR    ${item}    IN    @{parameters_lists}
        ${res}    scf.is_element_in_object    dist_name=${item}[dist_name]    p_name=${item}[p_name]
        Run Keyword If    '${res}'=='True'     scf.modify_scf_element    value=${item}[value]   &{item}
        ...      ELSE                          scf.add element to scf
        ...                                    value=${item}[value]   dist_name=${item}[dist_name]    p_name=${item}[p_name]
    END

Modify ListElements to scf
    [Documentation]   Modify List element. report error If not present
    [Arguments]   ${parameters_lists}
    FOR    ${item}    IN    @{parameters_lists}
        ${res}    scf.is_list_in_object    dist_name=${item}[dist_name]    list_name=${item}[list_name]
        Run Keyword If    '${res}'=='True'  Modify SCF ListElements   dist_name=${item}[dist_name]  list_name=${item}[list_name]
        ...        elements=${item}[elements]
    END

Modify SCF ListElements
    [Documentation]   Author: lei.jia@nokia-sbell.com
    [Arguments]   ${dist_name}    ${list_name}    ${elements}
    FOR    ${item}   IN    @{elements}
        scf.modify_scf_element    value=${item}[value]   dist_name=${dist_name}  list_name=${list_name}
        ...    p_name=${item}[p_name]    index=${item}[index]
    END

AddLists to SCF
    [Documentation]   add List items and elements, if the items are present, remove it first.
    [Arguments]    ${parameters_lists}
    FOR    ${item}    IN    @{parameters_lists}
        ${res}    scf.is_list_in_object    dist_name=${item}[dist_name]    list_name=${item}[list_name]
        Run Keyword If    '${res}'!='True'     scf.add_list_to_scf    dist_name=${item}[dist_name]    list_name=${item}[list_name]
        ${res}=    Run Keyword And Ignore error    scf.add item to list
        ...        dist_name=${item}[dist_name]    list_name=${item}[list_name]    elements=${item}[elements]
        Run keyword if    ${res} != ('PASS', None)    scf.add_elements_to_list
        ...        dist_name=${item}[dist_name]    list_name=${item}[list_name]    elements=${item}[elements]
    END

Add MOs To SCF with Given version
    [Documentation]   Add Mos for given version, used for add channels
    [Arguments]   ${parameters_lists}
    ${channel_version}=    scf.get_mo_attribute    MRBTS-${tl.gnbs[0].instance_id}/MNL-1/MNLENT-1/CELLMAPPING-1    version
    FOR    ${item}    IN    @{parameters_lists}
        scf.add object to scf  class_name=${item}[class_name]    dist_name=${item}[dist_name]   version=${channel_version}
    END
###End of Modify SCF####

Perform gNB Restart And Check on air via rest api
    [Documentation]    Auther:lei.jia@nokia-sbell.com
    ...                <<Keyword>> is to restart gnb one time and check gnb on air status.
    ...                Recommend to use this keywoed in TEST SETUP.
    [Arguments]    ${timeout}=600   ${connection}=GNB_OAM
    run keyword and ignore error    COAM Teardown gnb connections
    Connect to gnb coam via ssl    connection=${connection}
    coam.reset_site    wait_for_reconnection=${True}    timeout=${timeout}    connection=${connection}
    COAM Wait for gnb ready and cell setup    timeout=${timeout}

Check OLLA MCS transition with BIP
    [Documentation]   BIP: this keyword is used to check mcs 18-27 for UL and DL
    [Arguments]    ${expect_dl_tput}
    ...    ${expect_ul_tput}
    ...    ${bip_log_prefix}
    ...    ${ul_data_transfer}=30M
    ...    ${dl_data_transfer}=500M
    ...    ${is_ul_mcs_checked}=${False}
    ...    ${expect_ul_mcs_list}=${None}
    ...    ${is_dl_mcs_checked}=${False}
    ...    ${expect_dl_mcs_list}=${None}
    ...    ${scf_modify}=${None}
    ...    ${swconfig_modify}=${None}
    ...    ${is_cpc_restart}=${False}
    ...    ${is_called_in_test_case_level}=${False}
    ...    ${is_ulbler_calcu}=${False}
    ...    ${is_commission_need}=${True}
    ...    ${download_dir}=${TS_CASE_LOG_PATH}
    ...    ${rnti_item}=15
    ...    ${is_pdl_checking_needed}=${False}
    ...    ${ue_index}=${0}
    ...    ${is_askey_used}=False
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
    ${scf_path}    Download SCF Download Via Rest Api    scf_dir_path=${SAVE LOG DIRECTORY}
    Wait Until Keyword Succeeds    5 min    5 sec    connection_alias_store.Connect to Common Unit Master
    swconf.download_swConfig_file_from_asik_to_test_pc    localFilePath=${download_dir}/swconfig.txt
    ...    asik_alias=ASIK Master
    Run Keyword If    ${is_commission_need}==${True}    RUN KEYWORDS
    ...    Preparation with swconfig modification and comissioning    swconfig_modify=${swconfig_modify}
    ...    scf_modify=${scf_modify}    is_called_in_test_case_level=${is_called_in_test_case_level}
    ...    scf_template_path=${scf_path}    swconfig_template_path=${download_dir}/swconfig.txt
    ...    is_pdl_checking_needed=${is_pdl_checking_needed}    AND
    ...    Wait until keyword succeeds    15 min    20 sec    COAM Check GNB cell on air via WebUI
    ${direction_component_list}    Create List   UL_L2LO    DL_L2LO
    ${bip_log_file}    Start L3 Call And Capture BIP Log
    ...    ul_data_transfer=${ul_data_transfer}
    ...    dl_data_transfer=${dl_data_transfer}
    ...    bip_log_prefix=${bip_log_prefix}
    ...    download_dir=${download_dir}
    ...    is_cpc_restart=${is_cpc_restart}
    ...    ue_index=${ue_index}
    ...    is_askey_used=${is_askey_used}
    Verify Throughput And UL Bler
    ...    direction_component_list=${direction_component_list}
    ...    expect_ul_tput=${expect_ul_tput}
    ...    expect_dl_tput=${expect_dl_tput}
    ...    is_ulbler_calcu=${is_ulbler_calcu}
    Run Keyword If    ${is_ul_mcs_checked}==${True}    run keyword and continue on failure    Get UL MCS and Verify From BIP
    ...    bip_log=${bip_log_file}    expect_ul_mcs_list=${expect_ul_mcs_list}    rnti_item=${rnti_item}
    Run Keyword If    ${is_dl_mcs_checked}==${True}    run keyword and continue on failure    Get DL MCS and Verify From BIP
    ...    bip_log=${bip_log_file}   expect_dl_mcs_list=${expect_dl_mcs_list}    rnti_item=${rnti_item}

Start L3 Call And Capture BIP Log
    [Documentation]
    ...    This keyword is used to start bip capture before L3 call.
    [Arguments]    ${bip_log_prefix}=${None}
    ...    ${ul_data_transfer}=${None}
    ...    ${dl_data_transfer}=${None}
    ...    ${download_dir}=${TS_CASE_LOG_PATH}
    ...    ${is_cpc_restart}=${False}
    ...    ${connection}=ASIK Master
    ...    ${ue_index}=${0}
    ...    ${is_askey_used}=False
    ${bip_log}    Start L3 Call And Capture BIP Log With Aasyslog
    ...               ul_data_transfer=${ul_data_transfer}
    ...               dl_data_transfer=${dl_data_transfer}
    ...               download_dir=${download_dir}
    ...               connection=${connection}
    ...               ue_index=${ue_index}
    ...               is_askey_used=${is_askey_used}
    [Return]    ${bip_log}

Start L3 Call And Capture BIP Log With Aasyslog
    [Documentation]
    ...    This keyword is used to start bip capture before L3 call with Aasyslog..
    [Arguments]    ${ul_data_transfer}
    ...    ${dl_data_transfer}
    ...    ${download_dir}=${TS_CASE_LOG_PATH}
    ...    ${is_cpc_restart}=${False}
    ...    ${connection}=ASIK Master
    ...    ${reset_sol}=ue_reboot
    ...    ${connection}=ASIK Master
    ...    ${ue_index}=${0}
    ...    ${is_askey_used}=False
    run keyword and ignore error    csn.disconnect    connection=${connection}
    Start UE Attach With Power UE    reset_sol=${reset_sol}
    ...           ue_index=${ue_index}
    ...           is_askey_used=${is_askey_used}
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
    Bip Capture with gnbMirroring scripts with retry
    ...                         connection=${connection}
    Start L3 Call With Power UE
    ...                        ul_data_transfer=${ul_data_transfer}
    ...                        dl_data_transfer=${dl_data_transfer}
    ...                        ue_index=${ue_index}
    sleep    3s
    ${bip_log_list}    Stop BIP capture on ASIK if needed and download BIP Logs to testPC
    ...                        log_path=${download_dir}
    [Return]    ${bip_log_list}[0]
    [Teardown]    Run Keyword And Ignore Error    Stop BIP Capture On ASIK

Get UL MCS and Verify From BIP
    [Documentation]   this keyword is used to get ul mcs list and verify
    [Arguments]    ${bip_log}    ${expect_ul_mcs_list}    ${rnti_item}=15
    ${ul_mcs_list} =    Get UL MCS in UlData_PuschReceiveReq From BIP    bip_log=${bip_log}    rnti_item=${rnti_item}
    Verify MCS From BIP    mcs_list=${ul_mcs_list}    expect_mcs_list=${expect_ul_mcs_list}

Get DL MCS and Verify From BIP
    [Documentation]   this keyword is used to get dl mcs list and verify
    [Arguments]    ${bip_log}    ${expect_dl_mcs_list}    ${rnti_item}=15
    ${dl_mcs_list} =    Get DL MCS in DlData_PdschsendReq From BIP    bip_log=${bip_log}    rnti_item=${rnti_item}
    Verify MCS From BIP    mcs_list=${dl_mcs_list}    expect_mcs_list=${expect_dl_mcs_list}

Fixed_rank_PDSCH_transmission
    [Documentation]
    ...    This test case is used to test 1451 cases : fixed rank for closedloop adptive PMI and openloop
    [Arguments]    ${dl_data_transfer}
    ...           ${direction_component_list}
    ...           ${swconfig_modify}=${None}
    ...           ${pdschSendReq_fixed_rank}=${None}
    ...           ${rank}=${None}
    ...           ${is_called_in_test_case_level}=${True}
    ...           ${ul_data_transfer}=60M
    ...           ${expect_ul_tput}=${None}
    ...           ${expect_dl_tput}=${None}
    ...           ${expect_ul_bler}=${None}
    ...           ${is_bip_log_capture}=${True}
    ...           ${bip_log_prefix}=${None}
    ...           ${is_bip_precondition_need}=${True}
    ...           ${is_wireshark_log_capture}=${False}
    ...           ${wireshark_log_prefix}=x2_log_attach
    ...           ${is_cpc_restart}=${False}
    ...           ${is_ulbler_calcu}=${False}
    ...           ${download_dir}=${TS_CASE_LOG_PATH}
    ...           ${is_gnb_restrat_after_online_modify}=${True}
    ...           ${CsiRsSendReq_IEs}=${CsiRsSendReq}
    ...           ${csiRsResources_item}=11
    ...           ${rnti_item}=7
    ...           ${ue_type}=Andriod
    ...           ${is_fixed_rank_checked}=${False}
    ...           ${duration}=180
    ...           ${is_swconfig_modify}=${True}
    ...           ${is_scf_modify}=${True}
    ...           ${parameters_to_update_via_webui}=${None}
    ...           ${is_scf_modify_via_admin}=${False}
    ...           ${parameters_to_update_via_admin}=${None}
    ...           ${ul_traffic_duration}=600s
    ...           ${iperf_type}=via_app
    ...           ${is_chbw_modify_via_admin_needed}=${False}
    ...           ${bandwidth}=40MHz
    ...           ${hw_slot}=${1}
    ...           ${ue_index}=${0}
    ...           ${is_askey_used}=False
    ...           ${reset_sol}=ue_reboot
    ...           ${ignore_time}=1min
    ...           ${target_avg_percent}=1.0
    ...           ${actCarrierAggregation}=${False}
    ...           ${list_all_cell_ids}=${False}
    Run Keyword If    ${is_swconfig_modify}==${True}    run keywords
    ...    Backup and Modify swconfig file    is_called_in_test_case_level=${is_called_in_test_case_level}
    ...    swconfig_modify=${swconfig_modify}    AND
    ...    Perform gNB Restart And Check on air via rest api
    ${gnb_startup_time}    robot.libraries.DateTime.Get current date    UTC
    set test variable    ${gnb_startup_time}
    Run Keyword If    ${is_scf_modify}==${True}    COAM Update several parameters via webUI
    ...    parameters_to_update_via_webui=${parameters_to_update_via_webui}
    ...    download_dir=${download_dir}
    ...    is_gnb_restrat_after_online_modify=${is_gnb_restrat_after_online_modify}
    Run Keyword If    ${is_scf_modify_via_admin}==${True}    Modify All SCF Paras via Admin
    ...    parameters_to_update_via_admin=${parameters_to_update_via_admin}
    Run Keyword If    ${is_chbw_modify_via_admin_needed}==${True}    Modify All Chbw Paras via Admin
    ...    bandwidth=${bandwidth}
    ${x2_log_file}    ${bip_log_file}    Start Qualcomm L3 Call And Verify Throughput
    ...    ul_data_transfer=${ul_data_transfer}
    ...    dl_data_transfer=${dl_data_transfer}
    ...    direction_component_list=${direction_component_list}
    ...    is_wireshark_log_capture=${is_wireshark_log_capture}
    ...    wireshark_log_prefix=${wireshark_log_prefix}
    ...    is_bip_log_capture=${is_bip_log_capture}
    ...    bip_log_prefix=${bip_log_prefix}
    ...    expect_ul_tput=${expect_ul_tput}
    ...    expect_dl_tput=${expect_dl_tput}
    ...    is_ulbler_calcu=${is_ulbler_calcu}
    ...    ue_type=${ue_type}
    ...    check_tp_duration=${duration}
    ...    ul_traffic_duration=${ul_traffic_duration}
    ...    iperf_type=${iperf_type}
    ...    hw_slot=${hw_slot}
    ...    ue_index=${ue_index}
    ...    is_askey_used=${is_askey_used}
    ...    reset_sol=${reset_sol}
    ...    ignore_time=${ignore_time}
    ...    target_avg_percent=${target_avg_percent}
    ...    actCarrierAggregation=${actCarrierAggregation}
    ...    list_all_cell_ids=${list_all_cell_ids}
    set test variable    ${x2_log_file}
    set test variable    ${bip_log_file}
    Run Keyword If    ${is_fixed_rank_checked}==${True}
    ...    run keyword and continue on failure    Verify IE of PdschSendReq Openloop Fixed Rank
    ...    bip_log=${bip_log_file}
    ...    checked_IE_content=${pdschSendReq_fixed_rank}
    ...    rank=0x0000000${rank}
    ...    rnti_item=${rnti_item}

Modify All Chbw Paras via Admin
    [Documentation]   lei.jia@nokia-sbell.com
    ...           This keyword is used to modify all chbws with 2197 configuration via admin CLI.
    [Arguments]      ${bandwidth}=40MHz
    ${parameters_to_update}    Modify All Chbw Paras with 2197    bandwidth=${bandwidth}
    Wait Until Keyword Succeeds    3 min    5 sec    Connect to gnb coam via ssl
    COAM Update Several Parameters Via Rest Api    parameters_to_update_via_api=${parameters_to_update}    timeout=900
    Coam Wait For Gnb Ready And Cell Setup    timeout=15 min

Modify All SCF Paras via Admin
    [Documentation]   lei.jia@nokia-sbell.com
    ...           This keyword is used to modify all scf parameters via admin CLI.
    [Arguments]      ${parameters_to_update_via_admin}=${NULL}
    run keyword and ignore error    COAM Teardown gnb connections
    Wait Until Keyword Succeeds    3 min    5 sec    Connect to gnb coam via ssl
    COAM Update Several Parameters Via Rest Api    parameters_to_update_via_api=${parameters_to_update_via_admin}    timeout=900
    Coam Wait For Gnb Ready And Cell Setup    timeout=15 min

Modify lteToNrTimeOffset Value Via Rest api
    [Documentation]   lei.jia@nokia-sbell.com
    ...           This keyword is used to modify lteToNrTimeOffset and manualFrameTimingAdjustment parameter value for TDD 1116 3ms.
    ${cell_list}    get all cell id
    ${parameters_to_update_via_admin}    create list
    FOR    ${cellid}    IN    @{cell_list}
        ${lteToNrFrameShift_value}    Get Parameter Value From SCF    parameter=lteToNrFrameShift    NRCELL_id=${cellid}
        ${lteToNrFrameShift_value}    fetch from left     ${lteToNrFrameShift_value}       ms
        ${lteToNrTimeOffset_value} =    evaluate    ${lteToNrFrameShift_value} * 10
        ${lteToNrTimeOffset_value}    convert to string    ${lteToNrTimeOffset_value}
		&{parameters_lteToNrTimeOffset}    Create Dictionary    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cellid}
        ...                                                     parameter=lteToNrTimeOffset
        ...                                                     value=${lteToNrTimeOffset_value}
		append to list    ${parameters_to_update_via_admin}    ${parameters_lteToNrTimeOffset}
    END
    ${manualFrameTimingAdjustment_value} =    evaluate    ${lteToNrFrameShift_value} * 10000000
    ${manualFrameTimingAdjustment_value}    convert to string    ${manualFrameTimingAdjustment_value}
    &{parameters_manualFrameTimingAdjustment}    Create Dictionary
    ...                     dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/SYNC-1
    ...                     parameter=manualFrameTimingAdjustment
    ...                     value=${manualFrameTimingAdjustment_value}
    append to list    ${parameters_to_update_via_admin}    ${parameters_manualFrameTimingAdjustment}
    run keyword and ignore error    COAM Teardown gnb connections
    Wait Until Keyword Succeeds    3 min    5 sec    Connect to gnb coam via ssl
    COAM Update Several Parameters Via Rest Api    parameters_to_update_via_api=${parameters_to_update_via_admin}    timeout=900
    Coam Wait For Gnb Ready And Cell Setup    timeout=15 min

Modify Programmable ATT Channel Vaules
    [Documentation]   lei.jia@nokia-sbell.com
    ...           Modify values in hbte for several channel several ports or all ports.
    ...           para ${modified_channels}: <list> or  ${None}
    ...           this argumnets need to be set as list when you want to modify several ports.
    ...           for example:${modified_channels} = [5, 6, 7, 8], it means these four ports are modified.
    ...           default is ${None}, it means all channel ports got from testconfiguration will be modified.
    ...           para ${value}: <list>, it can be several values or only one.
    ...           for example:${value} = [10, 10, 20, 20], when you give four ports with four values,
    ...           if ${modified_channels} = [5, 6, 7, 8] and ${value} = [10, 20, 20, 30], it means port 5=10, 6=20, 7=20, 9=30
    ...           when you set ${value} = [10] , only one value for several ports, it will set modified_channels with the same value 10.
    ...           if ${modified_channels} = [5, 6, 7, 8] and ${value} = [10], it means port 5=10, 6=10, 7=10, 9=10
    ...           if ${modified_channels}=${None} and ${value} = [10], it will set all ports to value 10.
    [Arguments]    ${value}    ${modified_channels}=${None}    ${RU_id}=0    ${gnb_id}=0    ${vendor}=${tl.attenuator.vendor}
    ${all_channels}    gnb_classical_hangzhou.Get Attenuation Channels For RU    RU_id=${RU_id}    gnb_id=${gnb_id}
    attenuator.setup_attenuator
    ...    ip_addr=${ATTENUATOR_ADDR}
    ...    port=${attenuation_port}
    ...    attenuation_port_numbers=${all_channels}
    ...    vendor=${vendor}
    ${value_length}    get length    ${value}
    ${channels_to_modify}    Create Dictionary
    ${channels}    set variable if    ${modified_channels}!=${None}    ${modified_channels}    ${all_channels}
    FOR    ${channel}    IN    @{channels}
        ${index} =    get index from list    ${channels}    ${channel}
        ${value_dict}    set variable if    ${value_length}==1    ${value[0]}    ${value}[${index}]
        ${channel}    Convert To String    ${channel}
        Set To Dictionary    ${channels_to_modify}    ${channel}    ${value_dict}
    END
    Log To Console    ${channels_to_modify}
    gnb_classical_hangzhou.Modify Attenuation    channels_to_modify=${channels_to_modify}    RU_id=${ru_id}    gnb_id=${gnb_id}

#Modify PA values for RU
#    [Documentation]    Author: lei.jia@nokia-sbell.com
#    [Arguments]    ${value}    ${RU_id}=0    ${gnb_id}=0
#    log to console    \nINFO: begin to modify PA values.
#    ${all_channels}    gnb_classical_hangzhou.Get Attenuation Channels For RU    RU_id=${RU_id}    gnb_id=${gnb_id}
#    attenuator.setup_attenuator
#    ...    ip_addr=${ATTENUATOR_ADDR}
#    ...    port=${attenuation_port}
#    ...    attenuation_port_numbers=${all_channels}
#    ...    vendor=${tl.attenuator.vendor}
#    ${channels_to_modify}    Create Dictionary
#    FOR    ${channel}    IN    @{all_channels}
#        ${channel}    Convert To String    ${channel}
#        Set To Dictionary    ${channels_to_modify}    ${channel}    ${value}
#    END
#    Log To Console    ${channels_to_modify}
#    gnb_classical_hangzhou.Modify Attenuation    channels_to_modify=${channels_to_modify}    RU_id=${ru_id}    gnb_id=${gnb_id}

Calculate Power and Check
    [Arguments]    ${bip_log}=${None}
    ...    ${luashark_path}=${None}
    ...    ${numOfTRX}=${16}
    ...    ${csi_item_value}=0
    ...    ${rdPdcchPrecodingOption4X4}=${2}
    ...    ${rdPdschPrecodingOption4X4}=${2}
    ...    ${pdcch_item_value}=0
    Get SSB Power Parameters Via Coam Admin
    Check SSB Power Calculation Parameters    numOfTRX=${numOfTRX}
    Analyze DL Power In BIP
    ...    bip_log_file=${bip_log}
    ...    csi_item_value=${csi_item_value}
    ...    rdPdcchPrecodingOption4X4=${rdPdcchPrecodingOption4X4}
    ...    rdPdschPrecodingOption4X4=${rdPdschPrecodingOption4X4}
    ...    pdcch_item_value=${pdcch_item_value}
    ...    luashark_path=${luashark_path}

Check Beamforming calibration on AAHF
    [Documentation]  Author: Jia Lei
    ...                Description: Fetch the latest calibration log and grep "bad" in log file.
    [Arguments]    ${asik_connection}=ASIK Master    ${ru_index}=1
    run keyword and ignore error    csn.disconnect    connection=${asik_connection}
    run keyword and ignore error    COAM Teardown gnb connections
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
    connection_alias_store.Connect to Common Unit Master    alias=${asik_connection}
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}    asik_alias=ASIK Master
    ${connection}    csn.get connection by alias    alias=RU_${ru_index}
    ${channel}    Call Method    ${connection}    invoke_shell
    Call Method    ${channel}    send    cd /ram/bfcali/ \n
    Sleep    1 sec
    Call Method    ${channel}    recv    ${65535}
    Call Method    ${channel}    send     find . -name 'SYS_LOG_*.log' -type f -mmin -30 \n
    sleep  2s
    ${cali_log_output}    Call Method    ${channel}    recv    ${65535}
    ${cali_log_output}    Convert To String    ${cali_log_output}
    Should not contain    ${cali_log_output}    No such file or directory    msg=cannot find latest calibration file!
    @{cali_log_list}    split string      string=${cali_log_output}    separator=\r\n
    ${SYS_LOG_name}    Fetch From Right    string=${cali_log_list}[1]    marker=/
    ${cmd}   Set Variable  cat /ram/bfcali/${SYS_LOG_name}| grep -i "bad"
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    ${status_output}    run keyword and return status    Should Be Empty    ${output}
    run keyword if    ${status_output}== ${False}    Get calibration failure time    output=${output}
    Call Method    ${channel}    close
    csn.disconnect    connection=RU_${ru_index}

Get calibration failure time
    [Documentation]  Author: Jia Lei
    ...               Description: grep calibration bad time in log and compare with curret datetime to avoid gnb startup calibration error.
    [Arguments]    ${output}
    @{list}    split string    ${output}    \n
    Remove Values From List    ${list}   ${empty}
    ${len}    Get Length    ${list}
    ${last_line}    Run keyword if    ${len}>0    Get From List    ${list}    -1
    ${cali_bad_time}    Run keyword if    ${len}>0    Get Regexp Matches
    ...    ${last_line}    \\d{4}\\-\\d{2}\\-\\d{2}.\\d{2}\\:\\d{2}\\:\\d{2}\\.[\\d]*
    ${cali_bad_time}    replace string    string=${cali_bad_time[0]}    search_for=T    replace_with=${SPACE}
    ${current_date}    robot.libraries.DateTime.Get current date    UTC
    ${cali_bad_time_interval}    Subtract Date From Date    ${current_date}    ${cali_bad_time}
    ${gnb_startup_time_interval}    Subtract Date From Date    ${current_date}    ${gnb_startup_time}
    Run keyword if    ${cali_bad_time_interval} < ${gnb_startup_time_interval}   Fail    msg=calibration failed!

Start Qualcomm L3 Call And Verify Throughput
    [Documentation]    Auther:lei.jia@nokia-sbell.com
    ...                Description：this keyword is used to perform ue attach, start ul&dl traffic and calculate throughput.
    [Arguments]     ${ul_data_transfer}
    ...           ${dl_data_transfer}
    ...           ${direction_component_list}
    ...           ${expect_ul_tput}=${None}
    ...           ${expect_dl_tput}=${None}
    ...           ${expect_ul_bler}=0.03
    ...           ${is_bip_log_capture}=${False}
    ...           ${bip_log_prefix}=${None}
    ...           ${is_bip_precondition_need}=${True}
    ...           ${is_wireshark_log_capture}=${False}
    ...           ${wireshark_log_prefix}=x2_log_attach
    ...           ${is_cpc_restart}=${False}
    ...           ${is_ulbler_calcu}=${True}
    ...           ${ue_type}=Andriod
    ...           ${check_tp_duration}=180
    ...           ${ul_traffic_duration}=600s
    ...           ${ue_index}=${0}
    ...           ${4G_check}=True
    ...           ${iperf_type}=via_app
    ...           ${hw_slot}=${1}
    ...           ${is_askey_used}=False
    ...           ${ignore_time}=1min
    ...           ${target_avg_percent}=1.0
    ...           ${actCarrierAggregation}=${False}
    ...           ${list_all_cell_ids}=${False}
    ...           ${reset_sol}=ue_reboot
    ${ul_traffic_duration_split}    fetch from left    ${ul_traffic_duration}    s
    ${ul_traffic_duration}    set variable    ${ul_traffic_duration_split}
    ${attach_x2_log}    ${bip_log}    Start Qualcomm L3 Call And Verify Throughput With Aasyslog
    ...               ul_data_transfer=${ul_data_transfer}
    ...               dl_data_transfer=${dl_data_transfer}
    ...               direction_component_list=${direction_component_list}
    ...               expect_ul_tput=${expect_ul_tput}
    ...               expect_dl_tput=${expect_dl_tput}
    ...               expect_ul_bler=${expect_ul_bler}
    ...               is_bip_log_capture=${is_bip_log_capture}
    ...               is_wireshark_log_capture=${is_wireshark_log_capture}
    ...               wireshark_log_prefix=${wireshark_log_prefix}
    ...               is_ulbler_calcu=${is_ulbler_calcu}
    ...               check_tp_duration=${check_tp_duration}
    ...               start_traffic_duration=${ul_traffic_duration}
    ...               ue_index=${ue_index}
    ...               4G_check=${4G_check}
    ...               iperf_type=${iperf_type}
    ...               hw_slot=${hw_slot}
    ...               is_askey_used=${is_askey_used}
    ...               reset_sol=${reset_sol}
    ...               ignore_time=${ignore_time}
    ...               target_avg_percent=${target_avg_percent}
    ...               actCarrierAggregation=${actCarrierAggregation}
    ...               list_all_cell_ids=${list_all_cell_ids}
    [Return]    ${attach_x2_log}    ${bip_log}

Start Qualcomm L3 Call And Verify Throughput With Aasyslog
    [Documentation]    Auther:lei.jia@nokia-sbell.com
    ...                Description：this keyword is used to perform ue attach, start ul&dl traffic and calculate throughput with power ue
    [Arguments]     ${ul_data_transfer}
    ...           ${dl_data_transfer}
    ...           ${direction_component_list}
    ...           ${expect_ul_tput}=${None}
    ...           ${expect_dl_tput}=${None}
    ...           ${expect_ul_bler}=0.03
    ...           ${is_bip_log_capture}=${False}
    ...           ${is_wireshark_log_capture}=${False}
    ...           ${wireshark_log_prefix}=x2_log_attach
    ...           ${is_ulbler_calcu}=${False}
    ...           ${check_tp_duration}=180
    ...           ${start_traffic_duration}=600
    ...           ${reset_sol}=ue_reboot
    ...           ${connection}=ASIK Master
    ...           ${is_prepare_ue_needed}=${True}
    ...           ${ue_index}=${0}
    ...           ${4G_check}=True
    ...           ${iperf_type}=via_app
    ...           ${hw_slot}=${1}
    ...           ${is_askey_used}=False
    ...           ${ignore_time}=1min
    ...           ${target_avg_percent}=1.0
    ...           ${actCarrierAggregation}=${False}
    ...           ${list_all_cell_ids}=${False}
    ...           ${is_do_require_ue}=${True}
    run keyword and ignore error    csn.disconnect    connection=${connection}
    Run Keyword And Ignore Error    csn.disconnect      connection=cpc_${ue_index}
    connection_alias_store.Connect to Common Unit Master
    log to console    \nStart UE Attach With Power UE.
    ${attach_x2_log} =     Run Keyword If    ${is_prepare_ue_needed}
    ...    Start UE Attach With Power UE
    ...           is_wireshark_log_capture=${is_wireshark_log_capture}
    ...           wireshark_log_prefix=${wireshark_log_prefix}
    ...           reset_sol=${reset_sol}
    ...           ue_index=${ue_index}
    ...           4G_check=${4G_check}
    ...           is_askey_used=${is_askey_used}
    ...           is_do_require_ue=${is_do_require_ue}
    ${iperf_type}    Set Variable If    '${ue_type}' == 'samsung'     via_command    via_app
    log to console    \nStart L3 Call With Power UE.
    Start L3 Call With Power UE
    ...            ul_data_transfer=${ul_data_transfer}
    ...            dl_data_transfer=${dl_data_transfer}
    ...            duration=${start_traffic_duration}
    ...            iperf_type=${iperf_type}
    ...            ue_index=${ue_index}
    log to console    \nVerify Throughput And UL Bler.
    run keyword and continue on failure    Check Tput With Power UE
    ...            direction_component_list=${direction_component_list}
    ...            expect_ul_tput=${expect_ul_tput}
    ...            expect_dl_tput=${expect_dl_tput}
    ...            expect_ul_bler=${expect_ul_bler}
    ...            is_ulbler_calcu=${is_ulbler_calcu}
    ...            duration=${check_tp_duration}
    ...            ignore_time=${ignore_time}
    ...            target_avg_percent=${target_avg_percent}
    ...            actCarrierAggregation=${actCarrierAggregation}
    ...            list_all_cell_ids=${list_all_cell_ids}
    ${bip_log}    Run Keyword If    ${is_bip_log_capture}==${True}    Start BIP Capture and Download File with gnbMirroring scripts
    [Return]    ${attach_x2_log}    ${bip_log}

Start BIP Capture and Download File with gnbMirroring scripts
    [Arguments]    ${bip_capturetime}=3s
    ...    ${download_dir}=${TS_CASE_LOG_PATH}
    ...    ${connection}=ASIK Master
    log to console    INFO: start to capture bip log.
    run keyword and ignore error    COAM Teardown gnb connections
    Run Keyword And Ignore Error    csn.disconnect    connection=${connection}
    Wait Until Keyword Succeeds    3 min    5 sec    Connect to gnb coam via ssl
    Connect to Common Unit Master
    Bip Capture with gnbMirroring scripts with retry
    ...                         connection=${connection}
    sleep    ${bip_capturetime}
    ${bip_log_list}    Stop BIP capture on ASIK if needed and download BIP Logs to testPC
    ...                        log_path=${download_dir}
    [Return]    ${bip_log_list}[0]
    [Teardown]    Run Keyword And Ignore Error    Stop BIP Capture On ASIK

Start BIP Capture and Download File with SEM
    [Documentation]    Auther:Stella.lin@nokia-sbell.com
    [Arguments]    ${log_prefix}=l1l2bip_log
    Collect Interface Mirroring Bip Collector    target_file_name=${log_prefix}
    Sleep    2 sec
    ${bip_log_list}    Get Bip Log Via Interface Mirroring Collector    target_file_name=${log_prefix}
    [Return]    ${bip_log_list[0]}

Get Cell ID list via Admin CLI
    [Documentation]    :Author: lei.jia@nokia-sbell.com
    ...                  this keyword is used to get cell id list from GNB via admin cli.
    ...                  for example:    [u'NRCELL-2', u'NRCELL-1']
    [Arguments]    ${connection}=GNB_OAM
    Wait Until Keyword Succeeds    3 min    5 sec    Connect to gnb coam via ssl
    ${cell_info}   coam.get_subcells_status   timeout=20    connection=${connection}
    ${cell_group_list}    get dictionary keys    ${cell_info}
    ${cell_list}   create list
    FOR    ${cell_group}    IN    @{cell_group_list}
        ${cell_from_cellgrp}    Get from Dictionary    ${cell_info}    ${cell_group}
        ${cell_id_list}    Get Dictionary Keys    ${cell_from_cellgrp}
        ${cell_list}    combine lists    ${cell_id_list}    ${cell_list}
    END
    sort list    ${cell_list}
    [Return]    ${cell_list}
    [Teardown]    COAM Teardown gnb connections

Get RU Number and perform commission via rest api
    [Documentation]    :Author: lei.jia@nokia-sbell.com
    ...                  this keyword is used to modify 2S1CC to 1S2CC.
    run keyword and ignore error    COAM Teardown gnb connections
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
    ${ru_index_list}  Get All RU Index
    ${count_ru}    get length    ${ru_index_list}
    run keyword if    '${count_ru}'>'${1}'    Modify SCF and Perform Commission
    ...    ParameterToDelete=${PARAMS_TO_DELETE_4RX_1S2CC}
    ...    ParamterToModify=${PARAMS_TO_MODIFY_4RX_1S2CC_Trunk}
    ...    ListToAdd=${LIST_TO_ADD_4RX_1S2CC}
    ...    is_pdl_checking_needed=${False}

Modify All Chbw Paras with 2197
    [Documentation]  Author: lei.jia
    ...                Descrition：get cell number from site
    ...                modify_cell_ids: can be a list for cell index, and also can be a string, like 1;
    ...                   Default to all: all cells on GNB will be updated
    ...               it only support modify NSA CHBW
    [Arguments]   ${bandwidth}=100MHz
    ...            ${shutdown_value}=none
    ...            ${gscn}=none
    ...            ${connection}=GNB_OAM
    ...            ${nr_bts_id}=${tl.gnbs[0].global_bts_id}
    ...            ${PDCCH_CONFIG_DEDICATED}=PDCCH-1/PDCCH_CONFIG_DEDICATED-1
    ...            ${modify_cell_ids}=all
    ...            ${gnb_index}=0
    ...            ${prachRootSequenceIndex}=none
    &{shutdown_param}    Create Dictionary    dist_name=NRBTS-${nr_bts_id}   parameter=shutdownNogNBCellTmr    value=${shutdown_value}
    @{modify_param}    Create List
    run keyword if  not "${shutdown_value}"=="none"    Append To List    ${modify_param}    ${shutdown_param}
    ${gnb_nr_cell_id_mapping}    get_relation_mapping_between_cell_index_and_other_ids    connection_alias=${connection}
    ${all_cell_ids}    Get dictionary keys    ${gnb_nr_cell_id_mapping}
    ${is_all_cellls_entered}    Run keyword and return status    Should contain    ${modify_cell_ids}    all
    ${modify_cell_ids}    Set variable if    ${is_all_cellls_entered}    ${all_cell_ids}    ${modify_cell_ids}
    Wait Until Keyword Succeeds    3 min    5 sec    Connect to gnb coam via ssl
    FOR    ${cell_index}    IN    @{modify_cell_ids}
        &{bandwidth_param}    Create Dictionary    dist_name=NRBTS-${nr_bts_id}/NRCELL-${cell_index}    parameter=chBw    value=${bandwidth}
        Append To List    ${modify_param}    ${bandwidth_param}
        ${gscn_value}    coam_parameter.get_single_value_from_scf_file    parameter=gscn    dist_name=NRBTS-${nr_bts_id}/NRCELL-${cell_index}
        ...                                                               connection=${connection}
        ${gscn_value_length}    Get Length    ${gscn_value}
        ${gscn_param_name}    set variable if    "${gscn_value_length}"=="0"     gscnOrSsPbchArfcn    gscn
        &{gscn_param}    Create Dictionary    dist_name=NRBTS-${nr_bts_id}/NRCELL-${cell_index}    parameter=${gscn_param_name}    value=${gscn}
        run keyword if  not "${gscn}"=="none"    Append To List    ${modify_param}    ${gscn_param}
        &{prachRootSequenceIndex_param}    Create Dictionary    dist_name=NRBTS-${nr_bts_id}/NRCELL-${cell_index}
        ...    parameter=prachRootSequenceIndex    value=${prachRootSequenceIndex}
        run keyword if  not "${prachRootSequenceIndex}"=="none"    Append To List    ${modify_param}    ${prachRootSequenceIndex_param}
    END
    ${PDCCH_CONFIG_DEDICATED_params}    Modify 2197 parameter based on chbw for cells    modify_cell_ids=${modify_cell_ids}
    ...    connection=${connection}        gnb_index=${gnb_index}    bandwidth=${bandwidth}
    ${modify_param}    combine lists    ${modify_param}    ${PDCCH_CONFIG_DEDICATED_params}
    [Return]    @{modify_param}

Modify 2197 parameter based on chbw for cells
    [Documentation]  Author: Jia Lei
    ...    list_cell_ids: can be a list for cell index, and also can be a string, like 1;
    ...                   Default to all: all cells on GNB will be updated
    [Arguments]    ${modify_cell_ids}=all    ${connection}=GNB_OAM    ${gnb_index}=0
    ...             ${bandwidth}=100MHz
    ...             ${connection}=GNB_OAM
    ...             ${PDCCH_CONFIG_DEDICATED}=PDCCH-1/PDCCH_CONFIG_DEDICATED-1
    @{bwpdN_list}    Create List
    @{modify_2197_params}    Create List
    FOR    ${cell_index}    IN    @{modify_cell_ids}
        ${dist_name}    set variable    MRBTS-${tl.gnbs[${gnb_index}].instance_id}/NRBTS-${tl.gnbs[${gnb_index}].global_bts_id}/NRCELL-${cell_index}
        ${bwpDN_value}    Get BWPDN From SCF File based on cellid    nrcell_id=${cell_index}
        ...                                                          connection=${connection}
        ...                                                          nr_bts_id=${tl.gnbs[${gnb_index}].global_bts_id}
        append to list    ${bwpdN_list}    ${bwpDN_value}
    END
    FOR    ${bwpDN}    IN    @{bwpdN_list}
         ${2197_params}    Modify 2197 related Paras    bwpDN=${bwpDN}    bandwidth=${bandwidth}    connection=${connection}
         ${modify_2197_params}    combine lists    ${modify_2197_params}    ${2197_params}
    END
    [Return]    @{modify_2197_params}

Get BWPDN From SCF File based on cellid
    [Documentation]    :Author: lei.jia@nokia-sbell.com
    ...                  this keyword is used to get BWP Profile Dist Name from SCF according to cellBwpId.
    ...                  for example: for cellBwpId==1, bwpDN is MRBTS-275/NRBTS-1/BWP_PROFILE-41
    [Arguments]     ${cellBwpId}=1
    ...              ${nrcell_id}=1
    ...              ${connection}=GNB_OAM
    ...              ${nr_bts_id}=${tl.gnbs[0].global_bts_id}
    ${bwp_dn_paras}    Get BWPDN For Specific Cell    nrcell_id=${nrcell_id}
    ...                                               connection=${connection}
    ...                                               nr_bts_id=${nr_bts_id}
    FOR    ${bwp_dn_para}    IN    @{bwp_dn_paras}
        ${cellbwpid_value}    Get from Dictionary    ${bwp_dn_para}    cellBwpId
        ${bwpDN_value}    run keyword if    ${cellbwpid_value}==${cellBwpId}    Get from Dictionary    ${bwp_dn_para}    bwpDN
    END
    [Return]    ${bwpDN_value}

Get BWPDN For Specific Cell
    [Documentation]    :Author: xiaoxia.hao@nokia-sbell.com
    ...                  this keyword is used to get BWP Profile Dist Name Paras.
    ...                  for example:    [{u'cellBwpId': '1', u'bwpDN': 'MRBTS-84/NRBTS-1/BWP_PROFILE-44'}]
    [Arguments]    ${nrcell_id}=1
    ...             ${connection}=GNB_OAM
    ...             ${nr_bts_id}=${tl.gnbs[0].global_bts_id}
    @{bwp_profile_ids}    create list
    @{bwp_dn_value}    create list
    @{cellBwpList_params}    create list
    &{cellBwpList0}    Create Dictionary    cellBwpId=0    bwpDN=None
    &{cellBwpList1}    Create Dictionary    cellBwpId=1    bwpDN=None
    Append To List    ${bwp_dn_value}    ${cellBwpList0}    ${cellBwpList1}
    @{bwp_profile_ids}    Create List
    &{bwp_param}    Create Dictionary    dist_name=NRBTS-${nr_bts_id}/NRCELL-${nrcell_id}
    ...    parameter=cellBwpList
    ...    value=${bwp_dn_value}
    Append To List    ${cellBwpList_params}    ${bwp_param}
    ${bwp_profile_dn}    coam_parameter.get_list_values_from_scf_file    parameters=${cellBwpList_params}   connection=${connection}
    [Return]    ${bwp_profile_dn[0]['value']}

Modify 2197 related Paras
    [Documentation]    :Author: lei.jia@nokia-sbell.com
    ...                  this keyword is used to modify 2197 related paras for chbw 20M/40M on NSA
    ...                  paras: size, numOfPdcchCandidatesInAL4, numOfPdcchCandidatesInAL4
    [Arguments]    ${bwpDN}
    ...             ${bandwidth}=100MHz
    ...             ${connection}=GNB_OAM
    ...             ${PDCCH_CONFIG_DEDICATED}=PDCCH-1/PDCCH_CONFIG_DEDICATED-1
    @{coresetDedicated}    create list
    @{searchSpaceDedicated_value}    create list
    @{PDCCH_CONFIG_DEDICATED_params}    create list
    ${chBw}    Fetch From Left    string=${bandwidth}    marker=MHz
    ${numOfPdcchCandidatesInAL4_coresetid0}   Set Variable If
    ...   '${chBw}' in ['20', '30', '40', '70', '80', '90', '100']    n2
    ...   '${chBw}' in ['50', '60']    n4
    ${numOfPdcchCandidatesInAL4_coresetid1} =    run keyword if
    ...               '${chBw}' == '20'    set variable    n2
    ...    ELSE IF    '${chBw}' == '30'    set variable    n3
    ...    ELSE IF    '${chBw}' == '40'    set variable    n4
    ...    ELSE       set variable    n5
    &{searchSpaceDedicated0}    Create Dictionary    numOfPdcchCandidatesInAL4=${numOfPdcchCandidatesInAL4_coresetid0}
    &{searchSpaceDedicated1}    Create Dictionary    numOfPdcchCandidatesInAL4=${numOfPdcchCandidatesInAL4_coresetid1}
    Append To List    ${searchSpaceDedicated_value}    ${searchSpaceDedicated0}    ${searchSpaceDedicated1}
    &{searchSpaceDedicated_params}    Create Dictionary    dist_name=${bwpDN}/${PDCCH_CONFIG_DEDICATED}
    ...    parameter=searchSpaceDedicated
    ...    value=${searchSpaceDedicated_value}
    ${coresetDedicated_size} =    run keyword if
    ...               '${chBw}' == '20'    set variable    48
    ...    ELSE IF    '${chBw}' == '30'    set variable    72
    ...    ELSE IF    '${chBw}' == '40'    set variable    96
    ...    ELSE       set variable    120
    &{coresetDedicated_size_dict}    Create Dictionary    size=${coresetDedicated_size}
    Append To List    ${coresetDedicated}    ${coresetDedicated_size_dict}
    &{coresetDedicated_params}    Create Dictionary    dist_name=${bwpDN}/${PDCCH_CONFIG_DEDICATED}
    ...    parameter=coresetDedicated
    ...    value=${coresetDedicated}
    Append To List    ${PDCCH_CONFIG_DEDICATED_params}    ${searchSpaceDedicated_params}    ${coresetDedicated_params}
    [Return]    @{PDCCH_CONFIG_DEDICATED_params}

Get Parameter Value From SCF
    [Arguments]     ${parameter}
    ...              ${connection}=GNB_OAM
    ...              ${nr_bts_id}=${tl.gnbs[0].global_bts_id}
    ...              ${MRBTS_id}= ${tl.gnbs[0].instance_id}
    ...              ${NRCELL_id}=1
    ...              ${dist_name}=MRBTS-${MRBTS_id}/NRBTS-${nr_bts_id}/NRCELL-${NRCELL_id}
    run keyword and ignore error    COAM Teardown gnb connections
    Wait Until Keyword Succeeds    3 min    5 sec    Connect to gnb coam via ssl
    ${parameter_value}    coam_parameter.get_single_value_from_scf_file    parameter=${parameter}
    ...              dist_name=${dist_name}
    ...              connection=${connection}
    [Return]    ${parameter_value}

Get Numoflayer From BIP log
    [Documentation]    Author: lei.jia@nokia-sbell.com
    ...                This keyword is used to get numoflayer from bip log, filter dldata_pdschsendreq
    [Arguments]    ${file_path}
    ...    ${luashark_path}
    ...    ${connection}=GNB_OAM
    ${numOfLayers_xpath} =    set variable
    ...    .//DlData_PdschSendReq.grants_item_0.numOfLayers
    Load PCAP File    command_template=${TSHARK_BIP_CMD}    file_path=${file_path}
    ...    luashark_path=${luashark_path}
    ${numOfLayers_list}    ${numOfLayers_length}    Get IE Length and Value Of BIP    xpath=${numOfLayers_xpath}
    ...    filter_expression=dldata_pdschsendreq
    sort list    ${numOfLayers_list}
    Reverse List 	${numOfLayers_list}
    run keyword if      ${numOfLayers_length} > 1    Log    DL numofLayers is ${numOfLayers_list}!    WARN
    [Return]    ${numOfLayers_list}[0]

Check DL Layer From BIP log
    [Documentation]    Author: lei.jia@nokia-sbell.com
    ...                This keyword is used to verify dl layer in bip log should be the same as dlmimomode config.
    [Arguments]    ${bip_file_path}    ${luashark_path}
    ${dlMimoMode}    Get Parameter Value From SCF    parameter=dlMimoMode
    ${expected_dl_layer} =    set variable if    '2x2' in '${dlMimoMode}'    ${2}    ${4}
    ${numOfLayers}    Get Numoflayer From BIP log    file_path=${bip_file_path}    luashark_path=${luashark_path}
    should be equal as integers    ${numOfLayers}    ${expected_dl_layer}

Remove Duplicates And Get Float IE Length
    [Documentation]  Author: Jia Lei
    ...              Description: remove duplicates in bip log
    [Arguments]   ${list}
    @{new_list}    create list
    FOR    ${item}    IN     @{list}
        ${integer_item}    evaluate    round(${item}, 1)
        append to list    ${new_list}    ${integer_item}
    END
    ${new_list}      remove duplicates      ${new_list}
    ${list_length}=      get length     ${new_list}
    [Return]    ${new_list}   ${list_length}

Compare Slot and SlotForProcessing for different sfn and subcells
    [Documentation]    Author: lei.jia@nokia-sbell.com
    ...                for the same subcell, slot and slotforprocessing compare result should be different between sfns.
    ...                    for eample, subecell 0, sfn=0x0372, slot=ox08, slotForProcessing=0x0b which is not equal to slot
    ...                           then subecell 0, sfn=0x0373, slot=ox08, slotForProcessing should be the same with slot
    ...                for the same sfn, slot and slotforprocessing compare result should be different between subcells.
    ...                    for eample, subecell 0, sfn=0x0372, slot=ox08, slotForProcessing=0x0b which is not equal to slot
    ...                           then subecell 1, sfn=0x0372, slot=ox08, slotForProcessing should be ox08
    [Arguments]    ${bip_file_path}
    ...    ${luashark_path}
    log to console    \nINFO: Compare Slot and SlotForProcessing for different sfns and subcells.
    ${sfn_xpath} =    set variable    .//UlData_PuschReceiveReq.PuschReceiveReq.sfn
    ${subcellId_xpath} =    set variable    .//UlData_PuschReceiveReq.subcells_item_3.subcellId
    Load PCAP File    command_template=${TSHARK_BIP_CMD}    file_path=${bip_file_path}
    ...    luashark_path=${luashark_path}
    ${sfn_list}    Get Field Value By Xpath From Pdml     xpath=${sfn_xpath}
    ...    filter_expression=uldata_puschreceivereq
    ${sfn_list}    Remove Duplicates    ${sfn_list}
    ${subcellId_list}    Get Field Value By Xpath From Pdml    xpath=${subcellId_xpath}
    ...    filter_expression=uldata_puschreceivereq
    ${subcellId_list}    Remove Duplicates    ${subcellId_list}
    ${sfn_list}    Get Slice From SFN List    sfn_list=${sfn_list}
    FOR    ${subcellId}    IN     @{subcellId_list}
        Get Slot and SlotForProcessing of different sfns in the same subcell
        ...    sfn_list=${sfn_list}    subcellId=${subcellId}
    END
    FOR    ${sfn}    IN     @{sfn_list}
        Get Slot and SlotForProcessing of different subcells in the same sfn
        ...    sfn=${sfn}    subcellId_list=${subcellId_list}
    END

Get Slice From SFN List
    [Documentation]    Author: lei.jia@nokia-sbell.com
    ...                 original sfn list is too long, get half of it.
    [Arguments]    ${sfn_list}
    ${sfn_list_length}    get length    ${sfn_list}
    ${end_flag}    set variable if    ${sfn_list_length}>${4}   4    ${None}
    ${new_sfn_list}    get slice from list    ${sfn_list}    1    ${end_flag}
    [Return]    ${new_sfn_list}

Get Slot and SlotForProcessing of different subcells in the same sfn
    [Documentation]    Author: lei.jia@nokia-sbell.com
    [Arguments]    ${sfn}    ${subcellId_list}
    ${slot_xpath} =    set variable    .//UlData_PuschReceiveReq.PuschReceiveReq.slot
    ${slotForProcessing_xpath} =    set variable    .//UlData_PuschReceiveReq.subcells_item_3.slotForProcessing
    @{comapre_result_list}    Create list
    FOR    ${subcellId}    IN     @{subcellId_list}
        ${filter_expression}=    Catenate    uldata_puschreceivereq    and     UlData_PuschReceiveReq.subcells_item_3.subcellId == ${subcellId}
        ...   and    UlData_PuschReceiveReq.PuschReceiveReq.sfn == ${sfn}
        ${slot_list}    Get Field Value By Xpath From Pdml    xpath=${slot_xpath}
        ...    filter_expression=${filter_expression}
        ${slotForProcessing_list}    Get Field Value By Xpath From Pdml
        ...    xpath=${slotForProcessing_xpath}
        ...    filter_expression=${filter_expression}
        ${compare_result}    run keyword and return status    Lists Should Be Equal    ${slot_list}    ${slotForProcessing_list}
        Append to list    ${comapre_result_list}    ${compare_result}
    END
    ${value_length}    get length    ${comapre_result_list}
    FOR    ${index}    IN RANGE    ${value_length}
        ${next_index}    evaluate     ${index} + ${1}
        Exit For Loop If    '${next_index}' == '${value_length}'
        run keyword and continue on failure    should not be equal    ${comapre_result_list[${index}]}    ${comapre_result_list[${next_index}]}
    END

Get Slot and SlotForProcessing of different sfns in the same subcell
    [Documentation]    Author: lei.jia@nokia-sbell.com
    [Arguments]    ${sfn_list}    ${subcellId}
    ${slot_xpath} =    set variable    .//UlData_PuschReceiveReq.PuschReceiveReq.slot
    ${slotForProcessing_xpath} =    set variable    .//UlData_PuschReceiveReq.subcells_item_3.slotForProcessing
    @{comapre_result_list}    Create list
    FOR    ${sfn}    IN     @{sfn_list}
        ${filter_expression}=    Catenate    uldata_puschreceivereq    and     UlData_PuschReceiveReq.subcells_item_3.subcellId == ${subcellId}
        ...   and    UlData_PuschReceiveReq.PuschReceiveReq.sfn == ${sfn}
        ${slot_list}    Get Field Value By Xpath From Pdml    xpath=${slot_xpath}
        ...    filter_expression=${filter_expression}
        ${slotForProcessing_list}    Get Field Value By Xpath From Pdml
        ...    xpath=${slotForProcessing_xpath}
        ...    filter_expression=${filter_expression}
        ${compare_result}    run keyword and return status    Lists Should Be Equal    ${slot_list}    ${slotForProcessing_list}
        Append to list    ${comapre_result_list}    ${compare_result}
    END
    ${value_length}    get length    ${comapre_result_list}
    FOR    ${index}    IN RANGE    ${value_length}
        ${next_index}    evaluate     ${index} + ${1}
        Exit For Loop If    '${next_index}' == '${value_length}'
        run keyword and continue on failure    should not be equal    ${comapre_result_list[${index}]}    ${comapre_result_list[${next_index}]}
    END

Check sinrOfAnt Values of PuschReceiveRespPs
    [Documentation]  Author: Jia Lei
    ...              Description: check max sinrOfAnt value should be lower than sinr of layer in  UlData_PuschReceiveRespPs
    [Arguments]    ${bip_file_path}
    ...    ${luashark_path}
    ${display_filter} =    set variable    uldata_puschreceiverespps
    ${sinrOfAnt0} =    set variable    .//UlData_PuschReceiveRespPs.sinrOfAnt.sinrOfAnt_item_0
    ${sinrOfAnt1} =    set variable    .//UlData_PuschReceiveRespPs.sinrOfAnt.sinrOfAnt_item_1
    ${sinrOfAnt2} =    set variable    .//UlData_PuschReceiveRespPs.sinrOfAnt.sinrOfAnt_item_2
    ${sinrOfAnt3} =    set variable    .//UlData_PuschReceiveRespPs.sinrOfAnt.sinrOfAnt_item_3
    ${sinr_item_0} =    set variable    .//UlData_PuschReceiveRespPs.sinr.sinr_item_0
    ${sinr_item_1} =    set variable    .//UlData_PuschReceiveRespPs.sinr.sinr_item_1
    ${FILTER}    set variable    uldata_puschreceiverespps
    ${command_template}    set variable    {tshark_path} -r {pcap_file} -X lua_script:{luashark_path} -Y "${FILTER}" -T pdml
    Load PCAP File    file_path=${bip_file_path}
    ...    luashark_path=${luashark_path}
    ...    command_template=${command_template}
    ${sinr0_org} =   Get Field Value By Xpath From Pdml
    ...    filter_expression=${FILTER}
    ...    xpath=${sinr_item_0}
    ${sinr1_org} =   Get Field Value By Xpath From Pdml
    ...    filter_expression=${FILTER}
    ...    xpath=${sinr_item_1}
    ${sinrOfAnt0_org} =   Get Field Value By Xpath From Pdml
    ...    filter_expression=${FILTER}
    ...    xpath=${sinrOfAnt0}
    ${sinrOfAnt0_value}    ${count_of_sinrOfAnt0} =    Remove Duplicates And Get Float IE Length
    ...    list=${sinrOfAnt0_org}
     ${sinrOfAnt1_org} =   Get Field Value By Xpath From Pdml
    ...    filter_expression=${FILTER}
    ...    xpath=${sinrOfAnt1}
    ${sinrOfAnt1_value}    ${count_of_sinrOfAnt1} =    Remove Duplicates And Get Float IE Length
    ...    list=${sinrOfAnt1_org}
    ${sinrOfAnt2_org} =   Get Field Value By Xpath From Pdml
    ...    filter_expression=${FILTER}
    ...    xpath=${sinrOfAnt2}
    ${sinrOfAnt2_value}    ${count_of_sinrOfAnt2} =    Remove Duplicates And Get Float IE Length
    ...    list=${sinrOfAnt2_org}
    ${sinrOfAnt3_org} =   Get Field Value By Xpath From Pdml
    ...    filter_expression=${FILTER}
    ...    xpath=${sinrOfAnt3}
    ${sinrOfAnt3_value}    ${count_of_sinrOfAnt3} =    Remove Duplicates And Get Float IE Length
    ...    list=${sinrOfAnt3_org}
    ${num_sinrOfAnt0}=    Get length    ${sinrOfAnt0_org}
    FOR    ${index}    IN RANGE    ${num_sinrOfAnt0}
        @{sinrOfAnt_list}    create list    ${sinrOfAnt0_org[${index}]}    ${sinrOfAnt1_org[${index}]}
        ...    ${sinrOfAnt2_org[${index}]}    ${sinrOfAnt3_org[${index}]}
        ${sinrOfAnt_max_value}    evaluate     max(${sinrOfAnt_list})
        @{sinroflayer_list}    create list    ${sinr0_org[${index}]}    ${sinr1_org[${index}]}
        ${sinroflayer_max_value}    evaluate     max(${sinroflayer_list})
        should be true    ${sinroflayer_max_value} >= ${sinrOfAnt_max_value}
    END

Start Qualcomm L3 Call With Two UEs
    [Documentation]    Auther:lei.jia@nokia-sbell.com
    ...                Description：this keyword is used to perform ue attach, start ul&dl traffic and calculate throughput with power ue
    [Arguments]     ${ul_data_transfer}
    ...           ${dl_data_transfer}
    ...           ${direction_component_list}
    ...           ${expect_ul_tput}=${None}
    ...           ${expect_dl_tput}=${None}
    ...           ${is_bip_log_capture}=${False}
    ...           ${check_tp_duration}=180
    ...           ${start_traffic_duration}=900
    ...           ${reset_sol}=ue_reboot
    ...           ${connection}=ASIK Master
    ...           ${4G_check}=True
    ...           ${iperf_type}=via_command
    ...           ${hw_slot}=${1}
    ...           ${is_askey_used}=False
    ...           ${target_avg_percent}=1.0
    run keyword and ignore error    csn.disconnect    connection=${connection}
    Run Keyword And Ignore Error    csn.disconnect      connection=cpc_${ue_index}
    connection_alias_store.Connect to Common Unit Master
    Run Keyword And Ignore Error    Start UE Attach With Power UE
    ...           reset_sol=${reset_sol}
    ...           ue_index=${0}
    ...           4G_check=${4G_check}
    ...           is_askey_used=${is_askey_used}
    Run Keyword And Ignore Error    Start UE Attach With Power UE
    ...           reset_sol=${reset_sol}
    ...           ue_index=${1}
    ...           4G_check=${4G_check}
    ...           is_askey_used=${is_askey_used}
    ${iperf_type}    Set Variable If    '${ue_type}' == 'samsung'     via_command    via_app
    Start L3 Call With Power UE
    ...            ul_data_transfer=${ul_data_transfer}
    ...            dl_data_transfer=${dl_data_transfer}
    ...            duration=${start_traffic_duration}
    ...            iperf_type=${iperf_type}
    ...            ue_index=${0}
    Start L3 Call With Power UE
    ...            ul_data_transfer=${ul_data_transfer}
    ...            dl_data_transfer=${dl_data_transfer}
    ...            duration=${start_traffic_duration}
    ...            iperf_type=${iperf_type}
    ...            ue_index=${1}
    Run Keyword And Continue On Failure    Check Tput With Power UE
    ...            direction_component_list=${direction_component_list}
    ...            expect_ul_tput=${expect_ul_tput}
    ...            expect_dl_tput=${expect_dl_tput}
    ...            duration=${check_tp_duration}
    ...            list_all_cell_ids=${True}
    ...            is_ulbler_calcu=${False}
    ...            target_avg_percent=${target_avg_percent}
    ${bip_log}    Run Keyword If    ${is_bip_log_capture}==${True}    Start BIP Capture and Download File with gnbMirroring scripts
    Run Keyword And Ignore Error    Stop Traffic With Power UE    ue_index=${0}
    Run Keyword And Ignore Error    Stop Traffic With Power UE    ue_index=${1}
    [Return]    ${bip_log}

Load PCAP File
    [Documentation]    author:lei.jia@nokia-sbell.com
    ...    Description: convert to pcap file to pdml format, pdml can be used for value check.
    [Arguments]    ${file_path}    ${command_template}=${TSHARK_BIP_CMD}
    ...    ${luashark_path}=/opt/ute/luashark/luashark_script/generated_luashark/luashark.lua
    ...    ${alias}=parser
    cap.load_pcap_file    pcap_file=${file_path}  tshark_path=${TSHARK_PATH}
    ...    luashark_path=${luashark_path}
    ...    command_template=${command_template}
    ...    alias=${alias}

Verify UL And DL Schedule Supported
    [Arguments]    ${bip_file}    ${num_of_slot}
    ...    ${luashark_path}
    ...    ${startSymbolNumber}=.//DlData_PdcchSendReq.dciInfo_item_15.startSymbolNumber
    ...    ${slot}=DlData_PdcchSendReq.PdcchSendReq.slot
    ${element_expression}    set variable      ${startSymbolNumber}
    ${condition_expression} =    set variable    ${slot} == ${num_of_slot}
    ${condition_expression}    Catenate    ${condition_expression}    and     dldata_pdcchsendreq
    ${FILTER}    set variable    dldata_pdschsendreq||dldata_pdcchsendreq||dldata_csirssendreq
    ${command_template}    set variable    {tshark_path} -r {pcap_file} -X lua_script:{luashark_path} -Y "${FILTER}" -T pdml
    Load PCAP File    file_path=${bip_file}
    ...    luashark_path=${luashark_path}
    ...    command_template=${command_template}
    ${startSymbolNumber_value}    ${count_of_startSymbol} =    Get IE Length and Value Of BIP
    ...    xpath=${element_expression}
    ...    filter_expression=${condition_expression}
    run keyword if    ${count_of_startSymbol}<${2}    FAIL    UL&DL SHOULD BE SCHEDULED FOR SLOT  ${num_of_slot}
    ${startSymbolNumber_value} =    Change str list to int list    str_list=${startSymbolNumber_value}
    run keyword and continue on failure    list should contain value    ${startSymbolNumber_value}     ${0}
    run keyword and continue on failure    list should contain value    ${startSymbolNumber_value}     ${1}

Verify At Least One Schedule Supported
    [Arguments]    ${bip_file}    ${num_of_slot}
    ...    ${luashark_path}
    ...    ${startSymbolNumber}=.//DlData_PdcchSendReq.dciInfo_item_15.startSymbolNumber
    ...    ${slot}=DlData_PdcchSendReq.PdcchSendReq.slot
    ${element_expression}    set variable      ${startSymbolNumber}
    ${condition_expression} =    set variable    ${slot} == ${num_of_slot}
    ${condition_expression}    Catenate    ${condition_expression}    and     dldata_pdcchsendreq
    ${FILTER}    set variable    dldata_pdschsendreq||dldata_pdcchsendreq||dldata_csirssendreq
    ${command_template}    set variable    {tshark_path} -r {pcap_file} -X lua_script:{luashark_path} -Y "${FILTER}" -T pdml
    Load PCAP File    file_path=${bip_file}
    ...    luashark_path=${luashark_path}
    ...    command_template=${command_template}
    ${startSymbolNumber_value}    ${count_of_startSymbol} =    Get IE Length and Value Of BIP
    ...    xpath=${element_expression}
    ...    filter_expression=${condition_expression}
    RUN KEYWORD IF     ${count_of_startSymbol}<${1}     FAIL    NO UL&DL SCHEDULED FOR SLOT  ${num_of_slot}

#-----------------------Begin of Common Cases Steps-------------------------------------#
5GC002244-A_BF_enable_Refine_disable_Traffic_2SSB_4Rx
    [Documentation]    Author: Jia Lei
    ${direction_component_list}    Create List   UL_L2LO    DL_L2LO
    ${expected_dl_tput}    set variable if    '${gNb_CuType}' == 'NSA'    ${expected_dl_tput_60M}     ${900_dl_tput_60M}
    ${nrCellType}    Get Parameter Value From SCF    parameter=nrCellType
    ${4DL4UL_used} =    set variable if    '4DL4UL' in '${nrCellType}'    ${True}    ${False}
    run keyword if    '${4DL4UL_used}'=='${False}'    Modify SCF and Perform Commission
    ...    MOsToAdd=${Mos_TO_ADD_Two_Channels}
    ...    ParamterToModify=${PARAMS_TO_MODIFY_Two_Channels}
    ...    is_pdl_checking_needed=${False}
    Fixed_rank_PDSCH_transmission
    ...    is_swconfig_modify=${False}
    ...    is_called_in_test_case_level=${True}
    ...    is_scf_modify=${False}
    ...    is_scf_modify_via_admin=${True}
    ...    parameters_to_update_via_admin=${MODIFY_PARA_Refine_Disable_2SSB}
    ...    dl_data_transfer=900M
    ...    ul_data_transfer=60M
    ...    direction_component_list=${direction_component_list}
    ...    bip_log_prefix=${bip_log_prefix}
#    ...    is_wireshark_log_capture=${True}
#    ...    wireshark_log_prefix=x2_log_attach
    ...    CsiRsSendReq_IEs=${None}
    ...    expect_ul_tput=${expected_ul_tput_60M}
    ...    expect_dl_tput=${expected_dl_tput}
    ...    iperf_type=via_command
    run keyword and continue on failure    Check sinrOfAnt Values of PuschReceiveRespPs
    ...    bip_file_path=${bip_log_file}
    ...    luashark_path=${luashark_path}

5GC002244-A_BF_enable_Refine_enable_Traffic_2Refine_4Rx_UE_1Tx
    [Documentation]    Author: Jia Lei
    ${direction_component_list}    Create List   UL_L2LO    DL_L2LO
    ${expected_dl_tput}    set variable if    '${gNb_CuType}' == 'NSA'    ${expected_dl_tput_60M}     ${900_dl_tput_60M}
    ${nrCellType}    Get Parameter Value From SCF    parameter=nrCellType
    ${4DL4UL_used} =    set variable if    '4DL4UL' in '${nrCellType}'    ${True}    ${False}
    run keyword if    '${4DL4UL_used}'=='${False}'    Modify SCF and Perform Commission
    ...    MOsToAdd=${Mos_TO_ADD_Two_Channels}
    ...    ParamterToModify=${PARAMS_TO_MODIFY_Two_Channels}
    ...    is_pdl_checking_needed=${False}
    Fixed_rank_PDSCH_transmission
    ...    is_swconfig_modify=${False}
    ...    is_called_in_test_case_level=${True}
    ...    is_scf_modify=${False}
    ...    is_scf_modify_via_admin=${True}
    ...    parameters_to_update_via_admin=${MODIFY_PARA_Refine_Enable_2Refine}
    ...    dl_data_transfer=800M
    ...    ul_data_transfer=60M
    ...    direction_component_list=${direction_component_list}
    ...    bip_log_prefix=${bip_log_prefix}
    ...    CsiRsSendReq_IEs=${None}
    ...    expect_ul_tput=${expected_ul_tput_60M}
    ...    expect_dl_tput=${expected_dl_tput}
    ...    iperf_type=via_command
    run keyword and continue on failure    Check sinrOfAnt Values of PuschReceiveRespPs
    ...    bip_file_path=${bip_log_file}
    ...    luashark_path=${luashark_path}

5GC002244-A_BF_enable_Refine_enable_Traffic_DL_1Refine_UL_2Refine_4Rx
    [Documentation]    Author: Jia Lei
    ${direction_component_list}    Create List   UL_L2LO    DL_L2LO
    ${expected_dl_tput}    set variable if    '${gNb_CuType}' == 'NSA'    ${nsa_dl_tput_60M_1PMI}    ${900_dl_tput_60M_1PMI}
    ${nrCellType}    Get Parameter Value From SCF    parameter=nrCellType
    ${4DL4UL_used} =    set variable if    '4DL4UL' in '${nrCellType}'    ${True}    ${False}
    run keyword if    '${4DL4UL_used}'=='${False}'    Modify SCF and Perform Commission
    ...    MOsToAdd=${Mos_TO_ADD_Two_Channels}
    ...    ParamterToModify=${PARAMS_TO_MODIFY_Two_Channels}
    ...    is_pdl_checking_needed=${False}
    Fixed_rank_PDSCH_transmission
    ...    is_swconfig_modify=${False}
    ...    is_called_in_test_case_level=${True}
    ...    is_scf_modify=${False}
    ...    is_scf_modify_via_admin=${True}
    ...    parameters_to_update_via_admin=${MODIFY_PARA_DL_1Refine_UL_2Refine}
    ...    dl_data_transfer=800M
    ...    ul_data_transfer=60M
    ...    direction_component_list=${direction_component_list}
    ...    bip_log_prefix=${bip_log_prefix}
    ...    CsiRsSendReq_IEs=${None}
    ...    expect_ul_tput=${expected_ul_tput_60M}
    ...    expect_dl_tput=${expected_dl_tput}
    ...    iperf_type=via_command
    run keyword and continue on failure    Check sinrOfAnt Values of PuschReceiveRespPs
    ...    bip_file_path=${bip_log_file}
    ...    luashark_path=${luashark_path}

5GC002244-A_Traffic_with_DL_1PMI_UL_2SSB_4Rx
    [Documentation]    Author: Jia Lei
    ${direction_component_list}    Create List   UL_L2LO    DL_L2LO
    ${expected_dl_tput}    set variable if    '${gNb_CuType}' == 'NSA'    $${nsa_dl_tput_60M_1PMI}     ${900_dl_tput_60M_1PMI}
    ${dlMimoMode}    Get Parameter Value From SCF    parameter=dlMimoMode
    ${dlmimo_8x4_used} =    set variable if    '8x4' in '${dlMimoMode}'    ${True}    ${False}
    run keyword if    '${dlmimo_8x4_used}'=='${False}'    Modify SCF and Perform Commission
    ...    ParameterToDelete=${PARAMS_TO_DELETE_DL_1PMI_UL_2SSB}
    ...    MOsToAdd=${Mos_TO_ADD_Two_Channels}
    ...    ParamterToModify=${PARAMS_TO_MODIFY_DL_1PMI_UL_2SSB}
    ...    ListParamterToModify=${LIST_PARAMS_TO_MODIFY_DL_1PMI_UL_2SSB}
    ...    ListToAdd=${LIST_TO_ADD_DL_1PMI_UL_2SSB}
    ...    is_pdl_checking_needed=${False}
    Fixed_rank_PDSCH_transmission
    ...    is_swconfig_modify=${False}
    ...    is_called_in_test_case_level=${True}
    ...    is_scf_modify=${False}
    ...    is_scf_modify_via_admin=${True}
    ...    parameters_to_update_via_admin=${MODIFY_PARA_DL_1PMI_UL_2SSB}
    ...    dl_data_transfer=800M
    ...    ul_data_transfer=60M
    ...    direction_component_list=${direction_component_list}
    ...    bip_log_prefix=${bip_log_prefix}
    ...    CsiRsSendReq_IEs=${None}
    ...    expect_ul_tput=${expected_ul_tput_60M}
    ...    expect_dl_tput=${expected_dl_tput}
    ...    iperf_type=via_command
    run keyword and continue on failure    Check sinrOfAnt Values of PuschReceiveRespPs
    ...    bip_file_path=${bip_log_file}
    ...    luashark_path=${luashark_path}

5GC001077_B_TC05_Call_on_single_subcell_configured_in_40MHz_bandwidth_with_256QAM_mcs_27
    [Documentation]    Author: Jia Lei
    [Arguments]    ${is_askey_used}=${True}    ${reset_sol}=ue_reboot
    ${direction_component_list}    Create List   UL_L2LO    DL_L2LO
    Fixed_rank_PDSCH_transmission
    ...    is_called_in_test_case_level=${True}
    ...    is_scf_modify=${False}
    ...    parameters_to_update_via_webui=${None}
    ...    dl_data_transfer=600M
    ...    ul_data_transfer=25M
    ...    direction_component_list=${direction_component_list}
    ...    is_wireshark_log_capture=${True}
    ...    wireshark_log_prefix=${x2_file}
    ...    bip_log_prefix=${bip_log_prefix}
    ...    expect_ul_tput=${ul_mcs27_expect_tput}
    ...    expect_dl_tput=${expected_dl_tput_256QAM}
    ...    CsiRsSendReq_IEs=${None}
    ...    is_swconfig_modify=${True}
    ...    swconfig_modify=${SWCONFIG_CPRT_LOGLEVEL}
    ...    iperf_type=via_command
    ...    ue_index=${1}
    ...    is_askey_used=${is_askey_used}
    ...    reset_sol=${reset_sol}
    Run Keyword And Ignore Error    Calculate Power and Check
    ...    bip_log=${bip_log_file}
    ...    luashark_path=${luashark_path}
    Run Keyword And Ignore Error
    ...    Check DL Layer From BIP log    bip_file_path=${bip_log_file}
    ...    luashark_path=${luashark_path}
    run keyword and continue on failure    Check Beamforming calibration on AAHF

5GC001077_B_TC05_Call_on_single_subcell_configured_in_40MHz_and_60MHz
    [Documentation]    Author: Jia Lei
    [Arguments]    ${is_askey_used}=${True}    ${ue_index}=${1}
    ${direction_component_list}    Create List   UL_L2LO    DL_L2LO
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    set test variable    ${ue_type}
    Run keyword if    '${ue_type}' == 'qct_dx50'    Check UE device exist    ue_index=${ue_index}
    Run keyword if    '${ue_type}' == 'qct_dx50'     ADB Reboot UE    ue_index=${ue_index}
    Fixed_rank_PDSCH_transmission
    ...    is_called_in_test_case_level=${True}
    ...    is_scf_modify=${False}
    ...    parameters_to_update_via_webui=${None}
    ...    dl_data_transfer=600M
    ...    ul_data_transfer=25M
    ...    direction_component_list=${direction_component_list}
    ...    is_wireshark_log_capture=${False}
    ...    bip_log_prefix=${bip_log_prefix}
    ...    expect_ul_tput=${ul_mcs27_expect_tput}
    ...    expect_dl_tput=${expected_dl_tput_256QAM}
    ...    CsiRsSendReq_IEs=${None}
    ...    is_swconfig_modify=${True}
    ...    swconfig_modify=${SWCONFIG_CPRT_LOGLEVEL}
    ...    iperf_type=via_command
    ...    ue_index=${ue_index}
    ...    is_askey_used=${is_askey_used}
    ...    reset_sol=none
    Run Keyword And Ignore Error    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul
    Run Keyword And Ignore Error    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl
    Run Keyword And Ignore Error    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
    Common_setup_and_teardown.Case Common SetUp    update_param_name=${FRAME_TO_11160ms_60MHz_6Symbols}
    ...                  is_dynamic_pdcch_update=${True}
    ...                  is_case_level_update_params_exist=${True}
    ...                  scf_file_path=${Golden_SCF_Path}
    COAM Wait for gnb ready and cell setup
    Run Keyword And Ignore Error    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}
    Start Qualcomm L3 Call And Verify Throughput With Aasyslog
    ...    is_do_require_ue=${False}
    ...    ul_data_transfer=60M
    ...    dl_data_transfer=900M
    ...    direction_component_list=${direction_component_list}
    ...    is_bip_log_capture=${False}
    ...    expect_ul_tput=${30}
    ...    expect_dl_tput=${690}
    ...    ue_index=${ue_index}
    ...    reset_sol=none
    run keyword and continue on failure    Check Beamforming calibration on AAHF
    Run Keyword And Ignore Error    Calculate Power and Check
    ...    bip_log=${bip_log_file}
    ...    luashark_path=${luashark_path}

FGCR2801_5GC001116_C_14_L3_cal_with_one_UE
    [Documentation]    Author: Jia Lei
    [Arguments]    ${is_askey_used}=${True}
    ${direction_component_list}    Create List    UL_L2LO    DL_L2LO
    run keyword and ignore error    Modify_Band_Frame_Structure  frame_structure=1116_3ms_GP2_B6
    ...    band=40    prach_index=160    beamset=4 beams
    ...    dl_ul_layer=4DL2UL    dl_modulation=dl_256QAM
    Modify lteToNrTimeOffset Value Via Rest api
    Fixed_rank_PDSCH_transmission
    ...    is_called_in_test_case_level=${True}
    ...    is_scf_modify=${False}
    ...    parameters_to_update_via_webui=${None}
    ...    ul_data_transfer=30M
    ...    dl_data_transfer=30M
    ...    direction_component_list=${direction_component_list}
    ...    is_wireshark_log_capture=${False}
    ...    bip_log_prefix=bip_2504
    ...    expect_ul_tput=${1}
    ...    expect_dl_tput=${5}
    ...    CsiRsSendReq_IEs=${None}
    ...    is_swconfig_modify=${True}
    ...    swconfig_modify=${SWCONFIG_PARA_FGCR_2504}
    ...    iperf_type=via_command
    ...    ue_index=${1}
    ...    is_askey_used=${is_askey_used}
    Run Keyword And Continue On Failure    Verify UL And DL Schedule Supported
    ...    bip_file=${bip_log_file}    num_of_slot=${slot5}
    ...    luashark_path=${luashark_path}
    Run Keyword And Continue On Failure    Verify At Least One Schedule Supported
    ...    bip_file=${bip_log_file}    num_of_slot=${slot15}
    ...    luashark_path=${luashark_path}

5GC001796_E_700_[03]DL_OLLA_MCS_transition_inside_64QAM-table_PTRS-OFF_Rank2_BW-40MHz_cmW
    [Documentation]    Author: Jia Lei
    [Arguments]    ${is_askey_used}=${True}
    Check OLLA MCS transition with BIP
    ...    expect_dl_tput=${dl_expect_tput_64QAM}
    ...    expect_ul_tput=${ul_mcs27_expect_tput}
    ...    bip_log_prefix=${bip_file}
    ...    is_ul_mcs_checked=${False}
    ...    expect_ul_mcs_list=${MCS_2T2R_64QAM}
    ...    is_dl_mcs_checked=${False}
    ...    expect_dl_mcs_list=${MCS_2T2R_64QAM}
    ...    is_cpc_restart=${True}
    ...    swconfig_modify=${SWCONFIG_2T2R_64QAM_40M}
    ...    scf_modify=${MODIFY_SCF_OLLA_64QAM}
    ...    rnti_item=15
    ...    ue_index=${1}
    ...    is_askey_used=${is_askey_used}

5GC002244-C_Buffered_UL_C4_2S_1CC_Traffic_1UE_in_each_Cell_with_1116-0FS
    [Documentation]    Author: Jia Lei
    ${direction_component_list}    Create List   UL_L2LO    DL_L2LO
    ${expected_dl_tput}    set variable if    '${gNb_CuType}' == 'NSA'    ${530}     ${467}
    Modify All Attenuation Ports Value For Specific RU    value=120
    ${status}    run keyword and return status    Modify_Band_Frame_Structure  frame_structure=1116_0ms_GP1_A8
    ...    band=40    prach_index=156    beamset=4 beams
    ...    dl_ul_layer=4DL4UL    dl_modulation=dl_256QAM
    run keyword and ignore error    COAM Teardown gnb connections
    Wait Until Keyword Succeeds    3 min    5 sec    Connect to gnb coam via ssl
    Run Keyword If    ${status}==${False}    Modify_Band_Frame_Structure  frame_structure=1116_0ms_GP1_A8
    ...    band=40    prach_index=156    beamset=4 beams
    ...    dl_ul_layer=4DL4UL    dl_modulation=dl_256QAM
    run keywords    Backup and Modify swconfig file    is_called_in_test_case_level=${True}
    ...    swconfig_modify=${SWCONFIG_AASYSLOG}    AND
    ...    Perform gNB Restart And Check on air via rest api
    ${bip_log_file}    Start Qualcomm L3 Call With Two UEs
    ...    dl_data_transfer=650M
    ...    ul_data_transfer=60M
    ...    direction_component_list=${direction_component_list}
    ...    is_bip_log_capture=${True}
    ...    expect_ul_tput=${20}
    ...    expect_dl_tput=${expected_dl_tput}
    ...    iperf_type=via_command
    ...    is_askey_used=${True}
    run keyword and continue on failure    Compare Slot and SlotForProcessing for different sfn and subcells
    ...    bip_file_path=${bip_log_file}
    ...    luashark_path=${luashark_path}
    [Teardown]    Modify All Attenuation Ports Value For Specific RU    value=0

5GC002244-C_Buffered_UL_C4_1S_2CC_Traffic_1UE_in_each_Cell_with_1208FS
    [Documentation]    Author: Jia Lei
    ...                 In order to reuse UE2 between 2S1CC and 1S2CC, UE2 connects both to RU1 and RU2.
    ...                 Thus RU2 need to be power off in case preparation and power on in case teardown.
    [Arguments]  ${ru_index}=2
    ${direction_component_list}    Create List   UL_L2LO    DL_L2LO
    ${expected_dl_tput}    set variable if    '${gNb_CuType}' == 'NSA'    ${540}     ${486}
    Modify All Attenuation Ports Value For Specific RU    value=0
    ${status}    run keyword and return status    Modify_Band_Frame_Structure  frame_structure=1208_GP1_A1
    ...    band=40    prach_index=157    beamset=4 beams
    ...    dl_ul_layer=4DL4UL    dl_modulation=dl_256QAM
    run keyword and ignore error    COAM Teardown gnb connections
    Wait Until Keyword Succeeds    3 min    5 sec    Connect to gnb coam via ssl
    Run Keyword If    ${status}==${False}    run keywords    Perform gNB Restart And Check on air via rest api     AND
    ...    Modify_Band_Frame_Structure  frame_structure=1208_GP1_A1
    ...    band=40    prach_index=157    beamset=4 beams
    ...    dl_ul_layer=4DL4UL    dl_modulation=dl_256QAM
    Get RU Number and perform commission via rest api
    Perform RU Power Off    ru_index=${ru_index}    model=${tl.gnbs[0].dus[0].rus[${ru_index}-1].pdu_port.pdu.vendor}
    ${bip_log_file}    Start Qualcomm L3 Call With Two UEs
    ...    dl_data_transfer=650M
    ...    ul_data_transfer=60M
    ...    direction_component_list=${direction_component_list}
    ...    is_bip_log_capture=${True}
    ...    expect_ul_tput=${20}
    ...    expect_dl_tput=${expected_dl_tput}
    ...    iperf_type=via_command
    ...    is_askey_used=${True}
    run keyword and continue on failure    Compare Slot and SlotForProcessing for different sfn and subcells
    ...    bip_file_path=${bip_log_file}
    ...    luashark_path=${luashark_path}
    [Teardown]    Perform RU Power On    ru_index=${ru_index}    model=${tl.gnbs[0].dus[0].rus[${ru_index}-1].pdu_port.pdu.vendor}

5GC002244-C_Buffered_UL_C4_1S_2CC_Traffic_1UE_in_each_Cell_with_1070FS
    [Documentation]    Author: Jia Lei
    ...                 In order to reuse UE2 between 2S1CC and 1S2CC, UE2 connects both to RU1 and RU2.
    ...                 Thus RU2 need to be power off in case preparation and power on in case teardown.
    [Arguments]  ${ru_index}=2
    ${direction_component_list}    Create List   UL_L2LO    DL_L2LO
    ${expected_dl_tput}    set variable if    '${gNb_CuType}' == 'NSA'    ${450}     ${405}
    Modify All Attenuation Ports Value For Specific RU    value=0
    ${status}    run keyword and return status    Modify_Band_Frame_Structure  frame_structure=1070_GP1_A3
    ...    band=40    prach_index=98    beamset=4 beams
    ...    dl_ul_layer=4DL4UL    dl_modulation=dl_256QAM
    run keyword and ignore error    COAM Teardown gnb connections
    Wait Until Keyword Succeeds    3 min    5 sec    Connect to gnb coam via ssl
    Run Keyword If    ${status}==${False}    run keywords    Perform gNB Restart And Check on air via rest api     AND
    ...    Modify_Band_Frame_Structure  frame_structure=1070_GP1_A3
    ...    band=40    prach_index=98    beamset=4 beams
    ...    dl_ul_layer=4DL4UL    dl_modulation=dl_256QAM
    Get RU Number and perform commission via rest api
    Perform RU Power Off    ru_index=${ru_index}    model=${tl.gnbs[0].dus[0].rus[${ru_index}-1].pdu_port.pdu.vendor}
    ${bip_log_file}    Start Qualcomm L3 Call With Two UEs
    ...    dl_data_transfer=600M
    ...    ul_data_transfer=60M
    ...    direction_component_list=${direction_component_list}
    ...    is_bip_log_capture=${True}
    ...    expect_ul_tput=${35}
    ...    expect_dl_tput=${expected_dl_tput}
    ...    iperf_type=via_command
    ...    is_askey_used=${True}
    run keyword and continue on failure    Compare Slot and SlotForProcessing for different sfn and subcells
    ...    bip_file_path=${bip_log_file}
    ...    luashark_path=${luashark_path}
    [Teardown]    Perform RU Power On    ru_index=${ru_index}    model=${tl.gnbs[0].dus[0].rus[${ru_index}-1].pdu_port.pdu.vendor}

5GC002244-C_Buffered_UL_C4_2S_1CC_Traffic_1UE_in_each_Cell_with_1116-3FS
    [Documentation]    Author: Jia Lei
    ${direction_component_list}    Create List   UL_L2LO    DL_L2LO
    ${expected_dl_tput}    set variable if    '${gNb_CuType}' == 'NSA'    ${530}     ${467}
    Modify All Attenuation Ports Value For Specific RU    value=120
    ${status}    run keyword and return status    Modify_Band_Frame_Structure  frame_structure=1116_3ms_GP1_A5
    ...    band=40    prach_index=160    beamset=4 beams
    ...    dl_ul_layer=4DL4UL    dl_modulation=dl_256QAM
    run keyword and ignore error    COAM Teardown gnb connections
    Wait Until Keyword Succeeds    3 min    5 sec    Connect to gnb coam via ssl
    Run Keyword If    ${status}==${False}    run keywords    Perform gNB Restart And Check on air via rest api     AND
    ...    Modify_Band_Frame_Structure  frame_structure=1116_3ms_GP1_A5
    ...    band=40    prach_index=160    beamset=4 beams
    ...    dl_ul_layer=4DL4UL    dl_modulation=dl_256QAM
    ${bip_log_file}    Start Qualcomm L3 Call With Two UEs
    ...    dl_data_transfer=650M
    ...    ul_data_transfer=60M
    ...    direction_component_list=${direction_component_list}
    ...    is_bip_log_capture=${True}
    ...    expect_ul_tput=${20}
    ...    expect_dl_tput=${expected_dl_tput}
    ...    iperf_type=via_command
    ...    is_askey_used=${True}
    run keyword and continue on failure    Compare Slot and SlotForProcessing for different sfn and subcells
    ...    bip_file_path=${bip_log_file}
    ...    luashark_path=${luashark_path}
    [Teardown]    Modify All Attenuation Ports Value For Specific RU    value=0

5GC001077_B_TC05_Call_on_single_subcell_configured_in_40MHz_bandwidth_with_256QAM_mcs_27_AEHC
    [Documentation]
    ...    This test case is used to test 1077 256QAM peak TP.
    ...    CHBW:40MHz
    [Arguments]    ${is_scf_modify_via_admin}=${False}    ${parameters_to_update_via_admin}=${None}
    ${expected_dl_tput}    set variable if    '${gNb_CuType}' == 'NSA'    ${expected_dl_tput_256QAM}    ${900_dl_tput_256QAM}
    ${direction_component_list}    Create List   UL_L2LO    DL_L2LO
    Fixed_rank_PDSCH_transmission
    ...    is_called_in_test_case_level=${True}
    ...    is_scf_modify=${False}
    ...    parameters_to_update_via_webui=${None}
    ...    dl_data_transfer=600M
    ...    ul_data_transfer=25M
    ...    direction_component_list=${direction_component_list}
    ...    is_wireshark_log_capture=${False}
    ...    wireshark_log_prefix=${x2_file}
    ...    bip_log_prefix=${bip_log_prefix}
    ...    expect_ul_tput=${ul_mcs27_expect_tput}
    ...    expect_dl_tput=${expected_dl_tput}
    ...    CsiRsSendReq_IEs=${None}
    ...    is_swconfig_modify=${False}
    ...    iperf_type=via_command
    ...    is_chbw_modify_via_admin_needed=${True}
    ...    bandwidth=40MHz
    ...    is_scf_modify_via_admin=${is_scf_modify_via_admin}
    ...    parameters_to_update_via_admin=${parameters_to_update_via_admin}
    ...    duration=360
#    run keyword and continue on failure    Check DL Layer From BIP log
#    ...    bip_file_path=${bip_log_file}
#    ...    luashark_path=${luashark_path}

#-----------------------End of Common Cases Steps-------------------------------------#
