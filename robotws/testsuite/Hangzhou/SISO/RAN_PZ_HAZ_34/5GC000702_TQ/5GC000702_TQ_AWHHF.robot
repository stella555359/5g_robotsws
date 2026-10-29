#*** Settings ***
#Documentation
#...    author: gongyue    #cris cai
#...    contact: yue.1.gong@nokia-sbell.com
#...    squad group: 5G_PZ_HZ_3_SG
#...    feature : 5GC000702
#
#Force Tags    5G_SISO            7.1836
#...    PY36
#
#
#Suite Setup    Run Keywords
#...            robot_common_operations.Common Suite Setup    AND
#...            Run Keyword And Ignore Error    Common Suite Setup for COAM    AND
#...            Load SCF for each TL
#
#Suite Teardown    Run Keywords
#...    Run Keyword And Ignore Error    Connect and Modify the ENB parameter    value=3
#...    dist_name=${enb1_def_gnb_dist}    parameter=${enb_def_cell_para}   AND
#...               Run Keyword And Ignore Error    Common Suite Teardown for COAM   AND
#...               Run Keyword And Ignore Error    COAM Teardown gnb connections
#
#
#Resource    SISO_Pre.robot
##Resource    ../FGCR_4454/Resources/FGCR_4454_common_KW.robot
##Resource     ../../../RRM/RAN_PZ_HAZ_34/5GC000496_C/Resources/L3Call.robot
#Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/android_common_keyword.robot
##Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/FGCR-7256/Common_resources.robot
#Library             taf.transport.ssh		WITH NAME	ssh
#Library            ute_ue
#Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Atten.robot
#Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Common_setup_and_teardown.robot
#
#*** Variables ***
#${PB_RU2_IP}     ${tl.gnbs[0].dus[0].rus[1].pdu.addr}
#${PB_RU2_PORT}    ${tl.gnbs[0].dus[0].rus[1].pdu_port.port_no}
##${dl_port}      ${tl.ues[0].iperf_details.port}
##${ul_port}     ${tl.ues[0].iperf_details.ssh_connection_details.port}
#${Qualcomm_CtrlPC_IP}           ${tl.ues[0].ssh_connection_details.addr}
#${Qualcomm_CtrlPC_USERNAME}     ${tl.ues[0].ssh_connection_details.username}
#${Qualcomm_CtrlPC_PASSWORD}     ${tl.ues[0].ssh_connection_details.password}
#&{fault_61524}    faultId=${61524}    source=SMOD_R-1    #faultId:SSH_ENABLED  source:RU1
#&{fault_61652}    faultId=${61652}    source=SMOD_R-1    #faultId:R&D_SERVICE_PORT_ENABLED  source:RU1
#&{fault_7319}    faultId=${7319}    source=NRBTS     #faultId:EFaultId_X2LinkNotAvailableAl
#&{fault_7300}    faultId=${7300}    source=NRBTS     #faultId:EFaultId_NoneX2LinkAvailableAl
#@{ALLOWED_FAULT_LIST}    &{fault_61524}    &{fault_61652}
#${atten_ip}    ${tl.attenuator[0].ip_addr}
#${RECOVERY_TIMEOUT}    15 min
#${cluster_start_up_timeout}     15 min
#${TS_CASE_LOG_PATH}      /opt/workspace/CIT/Master/Case_Logs/
#${ue_type}     ${tl.ues[0].capabilities[0]}
##${ue_index}     0
#${sleep_time}    10
#${SUITE_LOG_PATH}     /opt/workspace/CIT/Master/Case_Logs/
#${Qualcomm_CtrlPC_IP}           ${tl.ues[0].ssh_connection_details.addr}
#${Qualcomm_CtrlPC_USERNAME}     ${tl.ues[0].ssh_connection_details.username}
#${Qualcomm_CtrlPC_PASSWORD}     ${tl.ues[0].ssh_connection_details.password}
#${ASP_1A_IP}      ${tl.gnbs[0].dus[0].airscale.common_units[0].capacity_units[0].addr}
#${nrcell_id}     ${tl.gnbs[0].instance_id}
##${enbx2_cell_dist}     MRBTS-${tl.enbs[1].instance_id}/LNBTS-${tl.enbs[1].instance_id}/LNCEL-1
##${enbx2_cell_para}     defaultLnRelGnbCellId
##@{BTSID}    23311    236    34711
##${gnb_instance}     ${tl.gnbs[0].instance_id}
#${ul_throughput}            20M
#${dl_throughput}            680M
#${dl_expect_throughput}    100
#${ul_expect_throughput}    7
#@{gnb_ips}    ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}    ${tl.gnbs[1].cu.oam_ssh_connection_details.addr}
#
#*** Test Cases ***
#[1]5GC000702_T_05_SiSo_Auto_RF_reset_success_rate_from_WebUI_AWHHF
#    [Documentation]    Author: Jack Zeng
#    ...                Description: The purpose of this test case is to verify success rate of Radio Unit reset activated from WebUI interface
#    [Tags]     classical    CRT_TRUNK    CRT_22R2    CRT_22R3    CRT_22R4
#    [Timeout]    3 hour
#    [Setup]
#    robot_common_operations.Common Case Setup
#    Connect and Modify the ENB parameter    value=locked    dist_name=${enb1_gnb1_x2_dist}    parameter=${eNB_X2_ON_OFF}
#    Connect and Modify the ENB parameter    value=3    dist_name=${enb1_def_gnb_dist}    parameter=${enb_def_cell_para}
#    Online modify NIDD on gnb1 and gnb2    Modify_Para_Online=${Lock_gnb2_AMF1}
#    ...    ModifySCF_Aftercommission=True
#    Connect and Modify the ENB parameter    value=unlocked    dist_name=${enb1_gnb1_x2_dist}    parameter=${eNB_X2_ON_OFF}
#    Prepare the atten for each TL
#    ${cell1_id}=    COAM Get nrcellid with lcrid    lcrid=${1}    gnb_index=${1}
#    ${list_of_cell_ids}    Create list    ${cell1_id}
#    Calculate BTS or ru reset pass rate    reset_type=ru    reset_times=5
#    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}    ui_version=S20UI2.5    power_reset=True
#    Attach and check power UE    ue_type=${ue_type}    ue_index=${0}    gnb_index=${1}
#    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_throughput}    duration=${duration}
#    ...    ue_index=${0}    iperf_port=${dl_port}
#    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${ul_throughput}    duration=${duration}
#    ...    ue_index=${0}    iperf_port=${ul_port}
#    sleep    120s
#    power_ue.Check throughput    ue_type=${ue_type}    direction=dl
#    ...    throughput=${dl_expect_throughput}    gnb_index=${1}
#    power_ue.Check throughput    ue_type=${ue_type}    direction=ul
#    ...    throughput=${ul_expect_throughput}    gnb_index=${1}
#    Stop UL DL data transfer    ue_index=${1}    dl_port=${DL_PORT}    ul_port=${UL_PORT}
#    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}
#    [Teardown]    Run Keywords
#    ...    Run Keyword And Ignore Error     power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}    AND
#    ...    Run Keyword And Ignore Error    Connect and Modify the ENB parameter    value=3
#    ...    dist_name=${enb1_def_gnb_dist}    parameter=${enb_def_cell_para}    AND
#    ...    Online modify NIDD on gnb1 and gnb2    Modify_Para_Online_GNB2=${Unlock_gnb2_AMF1}
#    ...    ModifySCF_Aftercommission_for_GNB2=True    AND
#    ...    check hanging resource for per UE on gnb    gnb_ips=@{gnb_ips}    UE_Type_Index=${0}    AND
#    ...    Run Keyword And Ignore Error    CI_interface.Common Case Teardown    AND
#    ...    Run Keyword And Ignore Error    Common Suite Teardown for COAM    gnb_index=${1}   AND
#    ...    Run Keyword And Ignore Error    COAM Teardown gnb connections
#
#*** Keywords ***
#Prepare the atten for cases
#    Run Keyword If    '${gnb_instance}' == '@{BTSID}[0]'    Prepare the atten for Huawei trunk
#    Run Keyword If    '${gnb_instance}' == '@{BTSID}[1]'    Prepare the atten for Huawei 19B
#    Run Keyword If    '${gnb_instance}' == '@{BTSID}[2]'    Prepare the atten for 20A Qualcomm Env
#
#Setup Case for 40M for general
#    Run Keyword If    '${gnb_instance}' == '@{BTSID}[0]'    Setup Case for 40M for trunk    mcs=27
#    Run Keyword If    '${gnb_instance}' == '@{BTSID}[1]'    Setup Case for 40M for 20B    mcs=27
#    Run Keyword If    '${gnb_instance}' == '@{BTSID}[2]'    Setup Case for 40M for 20A    mcs=27
#
#Setup Case for 40M
#    [Arguments]    ${mcs}=0
#    Run keyword If    ${mcs}==0    power UE.SetTestVariables    mcs=0    ul=16M    dl=42M
#    Run keyword If    ${mcs}==16   power UE.SetTestVariables    mcs=16    ul=64M    dl=248M
#    Run keyword If    ${mcs}==20    power UE.SetTestVariables    mcs=20    ul=83M    dl=323M
#    Run keyword If    ${mcs}==21    power UE.SetTestVariables    mcs=21    ul=91M    dl=352M
#    Run keyword If    ${mcs}==26    power UE.SetTestVariables    mcs=26    ul=129M    dl=495M
#    Run keyword If    ${mcs}==27    power UE.SetTestVariables    mcs=27    ul=41M    dl=505M    ULTPpercent=98
#    ...     DLTPpercent=180
#    Run keyword If    ${mcs}==28    power UE.SetTestVariables    mcs=28    ul=72M    dl=900M
#
#Setup Case for 40M for 20B
#    [Arguments]    ${mcs}=0
#    Run keyword If    ${mcs}==0    power UE.SetTestVariables    mcs=0    ul=16M    dl=42M
#    Run keyword If    ${mcs}==16   power UE.SetTestVariables    mcs=16    ul=64M    dl=248M
#    Run keyword If    ${mcs}==20    power UE.SetTestVariables    mcs=20    ul=83M    dl=323M
#    Run keyword If    ${mcs}==21    power UE.SetTestVariables    mcs=21    ul=91M    dl=352M
#    Run keyword If    ${mcs}==26    power UE.SetTestVariables    mcs=26    ul=129M    dl=495M
#    Run keyword If    ${mcs}==27    power UE.SetTestVariables    mcs=27    ul=41M    dl=505M    ULTPpercent=98
#    ...     DLTPpercent=90
#    Run keyword If    ${mcs}==28    power UE.SetTestVariables    mcs=28    ul=72M    dl=900M
#
#Setup Case for 100M
#    [Arguments]    ${mcs}=0
#    Run keyword If    ${mcs}==0    SetTestVariables    mcs=0    ul=16M    dl=42M
#    Run keyword If    ${mcs}==16   SetTestVariables    mcs=16    ul=64M    dl=248M
#    Run keyword If    ${mcs}==20    SetTestVariables    mcs=20    ul=83M    dl=323M
#    Run keyword If    ${mcs}==21    SetTestVariables    mcs=21    ul=91M    dl=352M
#    Run keyword If    ${mcs}==26    SetTestVariables    mcs=26    ul=129M    dl=495M
#    Run keyword If    ${mcs}==27    SetTestVariables    mcs=27    ul=120M    dl=1200M
#    Run keyword If    ${mcs}==28    SetTestVariables    mcs=28    ul=140M    dl=536M
#
#Suite preparation
#    Run Keyword And Ignore Error    Common Suite Setup for COAM
#    Prepare the classical COAM BTS cell onair
#    Run Keyword And Ignore Error    Wait until cluster is on cell on air status    timeout=${cluster_start_up_timeout}
#    ...    is_all_cells_checking_needed=${True}
#
#Calculate BTS or ru reset pass rate
#    [Documentation]  Author: Jack Zeng
#    ...              Description: this keyword is used for calculate the pass rate of BTS or RU after reset given times
#    ...                           ${reset_type}: optional,value can be 'bts' or 'ru'
#    ...                           ${reset_times}: given the reset times
#    [Arguments]    ${reset_type}    ${reset_times}
#    ${fail_times}    Set variable    ${0}
#    :FOR    ${0}    IN RANGE    ${reset_times}
#    \    Run keyword if    '${reset_type}' == 'bts'    Perform BTS Site Reset
#        ...    ELSE IF    '${reset_type}' == 'ru'    Perform gnb RU Reset
#        ...    ELSE    Fail    ${reset_type} is invalid input,please retype!
#    \    sleep    180s
#    \    ${status}    run keyword and return status    Wait until cluster is on cell on air status    timeout=${RECOVERY_TIMEOUT}
#        ...    is_all_cells_checking_needed=${True}
#    \    ${fail_times}    Run keyword if    ${status}==${False}    Evaluate    ${fail_times}+1    ELSE    set variable    ${fail_times}
#    ${pass_rate}    Evaluate    (1-${fail_times}/${reset_times})*100
#    Log to console    reset ${reset_type} ${reset_times} times,fail ${fail_times} times,pass rate is ${pass_rate}%
#    Should be true    ${pass_rate}>90
#
#Perform gnb RU Reset
#    [Documentation]   Auther: Stella.lin@nokia-sbell.com
#    [Arguments]    ${ru_index}=${1}   ${download_dir}=${TS_CASE_LOG_PATH}
#    ${ru_index}  Convert To Integer    ${ru_index}
#    COAM Navigate to login page via webUI   download_dir=${download_dir}    gnb_index=${1}
#    selenium_coam.reset_ru  ru_index=${ru_index}
#    [Teardown]  COAM selenium logout
#
#
##Suite teardown
##    [Documentation]  Author: jack
##    Connect to gnb coam via ssl
##    Connect to Common Unit Master    alias=ASIK Master
##    Run keyword and ignore error    Tear down all SISO connections
##
##Case env recovery for data transfer
##    Case env recovery
##    Run Keyword And Ignore Error    1795 Case TearDown
##
##Case env recovery
##    Run keyword and ignore error    FGCR_4454_common_KW.Tests Recover
##    Common Suite Teardown for COAM
##
##Case env recovery for 21A
##    #Connect and Modify the parameter on enblte for SISO    enb_index=${1}    dist_name=${enbx2_cell_dist}
##    #...     parameter=${enbx2_cell_para}    value=1
##    Run keyword and ignore error    FGCR_4454_common_KW.Tests Recover
##    Common Suite Teardown for COAM
##
##Case preparation
##    #Case preparation common
##    Prepare the atten for Huawei 19B