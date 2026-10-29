# *** Settings ***
# Documentation
# ...    author: gongyue     #Jack.zeng
# ...    contact:yue.1.gong@nokia-sbell.com
# ...    squad group: 5G_PZ_HZ_3_SG
# ...    feature : 5GC002559
# 
# Force Tags    5G_SISO            0.836    0.830    9.1800
# ...    PY36
# 
# Suite Setup    Run Keywords
# ...            Run Keyword And Ignore Error    Common Suite Setup for COAM    AND
# ...            Load SCF for each TL 80M
# 
# Suite Teardown    Run Keywords
# ...    Run Keyword And Ignore Error    Connect and Modify the ENB parameter    value=3
# ...    dist_name=${enb1_def_gnb_dist}    parameter=${enb_def_cell_para}   AND
# ...               Run Keyword And Ignore Error    Common Suite Teardown for COAM   AND
# ...               Run Keyword And Ignore Error    COAM Teardown gnb connections
# 
# 
# 
# Resource    SISO_Pre.robot
# #Resource    ../FGCR_4454/Resources/FGCR_4454_common_KW.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/android_common_keyword.robot
# Library            taf.transport.ssh		WITH NAME	ssh
# 
# Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/FGCR-7256/Common_resources.robot
# 
# *** Variables ***
# #${tl_scf_dir_path}   /opt/workspace/CRT/Master/SCF_file/
# #${tl_scf_filename}    Full_Configuration_scf_MRBTS-5GC002559_AWHHF_80M_0ms.xml
# #${tl_scf_dir_path}    /opt/workspace/SCF/
# #${tl_scf_filename}    gold_347_236_233_80m.xml
# #${dl_port}      ${tl.ues[0].iperf_details.port}
# #${ul_port}     ${tl.ues[0].iperf_details.ssh_connection_details.port}
# ${Qualcomm_CtrlPC_IP}           ${tl.ues[0].ssh_connection_details.addr}
# ${Qualcomm_CtrlPC_USERNAME}     ${tl.ues[0].ssh_connection_details.username}
# ${Qualcomm_CtrlPC_PASSWORD}     ${tl.ues[0].ssh_connection_details.password}
# ${ASP_1A_IP}      ${tl.gnbs[0].dus[0].airscale.common_units[0].capacity_units[0].addr}
# ${TS_CASE_LOG_PATH}      /opt/workspace/CIT/Master/Case_Logs/
# ${ue1_type}     ${tl.ues[1].capabilities[0]}
# #${ue_index}     0
# ${sleep_time}    10
# ${SUITE_LOG_PATH}     /opt/workspace/CIT/Master/Case_Logs/
# #${enb1_def_gnb_dist}     MRBTS-${tl.enbs[1].instance_id}/LNBTS-${tl.enbs[1].instance_id}/LNCEL-1
# #${enbx2_cell_para}     defaultLnRelGnbCellId
# #@{BTSID}    23311    236    34711
# #${gnb_instance}     ${tl.gnbs[0].instance_id}
# #${enb1_gnb1_x2_dist}    MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNADJGNB-1
# #${eNB_X2_ON_OFF}    administrativeState
# @{gnb_ips}    ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}    ${tl.gnbs[1].cu.oam_ssh_connection_details.addr}
# 
# *** Test Cases ***
# [1]FGCR-7256_02_General_SiSo_E2E_system_setup_with_data_transfer_peaktp_AWHHF_new_BW_80M
#     [Documentation]    Decription:The purpose of this test case is to check new Added BW 80M supported to AWHHF with TA.
#     ...    Measured TCP UDP UL/DL TCP UDP Throughput is corresponding to calculated
#     ...    throughput ( > 98% theoretical value of given mcs )
#     [Tags]     huawei    classical    CRT_TRUNK    CRT_23R1    CRT_22R3    CRT_22R4
#     [Timeout]    1 hour
#     [Setup]
#     robot_common_operations.Common Case Setup
#     Connect and Modify the ENB parameter    value=locked    dist_name=${enb2_gnb2_x2_dist}
#     ...    enb_index=${1}    parameter=${eNB_X2_ON_OFF}
#     Connect and Modify the ENB parameter    value=3    dist_name=${enb2_def_gnb_dist}
#     ...    enb_index=${1}    parameter=${enb_def_cell_para}
#     Online modify NIDD on gnb1 and gnb2    Modify_Para_Online_GNB2=${Lock_gnb2_AMF1}
#     ...    ModifySCF_Aftercommission_for_GNB2=True
#     Connect and Modify the ENB parameter    value=unlocked    dist_name=${enb2_gnb2_x2_dist}
#     ...    enb_index=${1}    parameter=${eNB_X2_ON_OFF}
#     Prepare the atten for each TL E2G2
#     ${cell1_id}=    COAM Get nrcellid with lcrid    lcrid=${1}    gnb_index=${1}
#     ${list_of_cell_ids}    Create list    ${cell1_id}
#     power_ue.Prepare UE    ue_type=${ue1_type}    ue_index=${0}    ui_version=S20UI2.5    power_reset=True
# #    Start capture gNB log on master    filename=${gNB1_nglogname}   gNB_index=${0}
#     Attach and check power UE    ue_type=${ue1_type}    ue_index=${0}    gnb_index=${1}
#     power_ue.Start traffic    ue_type=${ue1_type}    direction=dl    throughput=${dl_throughput}    duration=${duration}
#     ...    ue_index=${0}    iperf_port=${dl_port}
#     power_ue.Start traffic    ue_type=${ue1_type}    direction=ul    throughput=${ul_throughput}    duration=${duration}
#     ...    ue_index=${0}    iperf_port=${ul_port}
#     sleep    120s
#     power_ue.Check throughput    ue_type=${ue1_type}    direction=dl
#     ...    throughput=${dl_expect_throughput}    gnb_index=${1}
#     power_ue.Check throughput    ue_type=${ue1_type}    direction=ul
#     ...    throughput=${ul_expect_throughput}    gnb_index=${1}
#     Stop UL DL data transfer    ue_index=${0}    dl_port=${DL_PORT}    ul_port=${UL_PORT}
#     power_ue.UE Detach    ue_type=${ue1_type}    ue_index=${0}
#     [Teardown]    Run Keywords
#     ...    Online modify NIDD on gnb1 and gnb2    Modify_Para_Online_GNB2=${Unlock_gnb2_AMF1}
#     ...    ModifySCF_Aftercommission_for_GNB2=True    AND
#     ...    power_ue.UE Detach    ue_type=${ue1_type}    ue_index=${0}    AND
#     ...    check hanging resource for per UE on gnb    gnb_ips=@{gnb_ips}    UE_Type_Index=${0}    AND
#     ...    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
# 
# *** Keywords ***
# Suite preparation
#     Run Keyword And Ignore Error    csn.Reset Cache
#     Run Keyword And Ignore Error    Change SWconf
#     Common Suite Setup for COAM
#     Run Keyword And Ignore Error    Prepare the classical COAM BTS cell onair
#     FGCR_4454_common_KW.SISO suite setup
# 
# Prepare PA for case
#     Run Keyword If    '${gnb_instance}' == '@{BTSID}[0]'    Prepare the atten for Huawei trunk
#     Run Keyword If    '${gnb_instance}' == '@{BTSID}[1]'    Prepare the atten for Huawei 19B
#     Run Keyword If    '${gnb_instance}' == '@{BTSID}[2]'    Prepare the atten for 20A Qualcomm Env
# 
# Suite teardown
#     [Documentation]  Author: jack
#     Connect to gnb coam via ssl
#     Connect to Common Unit Master    alias=ASIK Master
#     Run keyword and ignore error    Tear down all SISO connections
#     FGCR_4454_common_KW.SISO suite teardown
# 
# Case env recovery for data transfer
#     Run Keyword And Ignore Error    CI_interface.Common Case Teardown
# #    Case env recovery
# #    Run Keyword And Ignore Error    1795 Case TearDown
# 
# Case env recovery for cell lock
#     Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    Perform Cell Unlock    cell_idx=${1}
#     Case env recovery
# 
# Case env recovery
#     Run Keyword And Ignore Error    csn.Reset Cache
#     Run keyword and ignore error    FGCR_4454_common_KW.Tests Recover
#     Common Suite Teardown for COAM
# 
# Case env recovery for data transfer for 21A
#     #Connect and Modify the parameter on enblte for SISO    enb_index=${1}    dist_name=${enbx2_cell_dist}
#     #...     parameter=${enbx2_cell_para}    value=1
#     Run Keyword And Ignore Error    CI_interface.Common Case Teardown
#     Case env recovery
#     Run Keyword And Ignore Error    1795 Case TearDown