*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO   CRT   RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     CONFIGURED

Documentation    :copyright: Nokia
...              :author: Mundanad Vishnu
...              :contact: mundanad.vishnu@nokia.com
...
...             INTRODUCTION:     This user scenario describes the gNB behaviour for the successful setup of Non GBR QoS Flow
...                               with configured DL/UL Nominal Bit Rate in DRB profile which is triggered by Intra-frequency
...                               Inter-gNB handover procedure (SA).
...             TEST SET NAME:    CB008227
...             TESTING SPLIT:    Refer CB008227 Test Plan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB008227 CFAM
...             Requirement ID:   5G_RAN_USR_RRM_20701



Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../resources/robot/Setup_Env.robot
Resource         ../resources/robot/Airphone.robot
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ../resources/robot/PM_Counters.robot
Resource         CB008227_Resource.robot
Library          ../resources/python/BIP_Capture.py
Library          ../resources/python/CPRT_Capture.py
Resource         ../resources/robot/configuration_id.robot

Suite Setup         Run keywords    Run Keyword and Ignore Error      Suite setup from scratch
...                 AND     OperatingSystem.Run     sudo ip addr add 10.0.1.123/24 dev eth3
...                 AND     OperatingSystem.Run     sudo ip addr add 10.0.1.124/24 dev eth3
...                 AND     OperatingSystem.Run     sudo ip addr add 10.0.2.90/24 dev eth4
...                 AND     OperatingSystem.Run     sudo ip addr add 10.0.2.91/24 dev eth4
...                 AND     Modify IPHY File And Send to Airphone Custom    ${IPHY_FILE}
...                 AND     Find Scfc And Fix And Send Full Commissioning
...                           scfc_filename=CB008227_IntergNB_HO_scf_100M_feature_on.xml
...                 AND     Load CFG Config And Verify cell setup in Capture CPRT Traces      ${wts_cfg_file}   ${no_of_cells}
...                 AND     Check gNB Bulid

Suite Teardown      Run Keywords
...                 Stop Log   snapshot
...                 AND     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/wts_aehc_new.cfg
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${sa_ue_id1}      ${1}
${sa_ue_id2}      ${2}
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${TRF_ID}     1
${QFI_ID}     1
${TEST_NAME}     TC28
${epc_log_path}    /tmp/
${IPHY_FILE}                    ${CURDIR}/config/iphy_AEHC.xml
${no_of_cells}    2
*** Test Cases ***

CB008227-C#B3_TC28_Support_Nominal_Bit_Rate_of_nonGBR_bearers_for_Intra-frequency_Inter_gNB_handover_SA
    [Documentation]   This user scenario describes the gNB behaviour for the successful setup of Non GBR QoS Flow
    ...               with configured DL/UL Nominal Bit Rate in DRB profile which is triggered by Intra-frequency
    ...               Inter-gNB handover procedure (SA).
    Verify actNbrForNonGbrBearers In CellSetupReq
    log to console   UE attach trigerring now...
    Start Log    btslog   cprt
    Run Keyword And Continue On Failure       Link SCOUT SCF to Configuration ID for Reporting
    UE Register with ICS should be Successful   ${sa_ue_id1}
    sleep     5s
     ${path1}    Stop Log    cprt   test_scenario=bearersetup
    Verify nbrDrbSpecificParams In BearerSetupReq   ${path1}[cprt]/NODECPRT_GNB.pcap    sctp    180124   60567
    UE Register with ICS should be Successful   ${sa_ue_id2}
    sleep     5s
    MultiUE Trigger DL Traffic for SA    ${sa_ue_id1}  ${sa_ue_id1}   Traffic_rate=mbps     dl_rate=50        pdu_id=1     trf_id=1     qfi_id=1
    sleep     5s
    Start Log    cprt
    Inter-gNB HO for UE to simulated gNB   ${sa_ue_id1}
    sleep     30s
    Inter-gNB HO for UE to actual gNB   ${sa_ue_id1}
    sleep      10s
    ${path2}    Stop Log    cprt   test_scenario=IntergNB_HO_1
    Verify nbrDrbSpecificParams In BearerSetupReq   ${path1}[cprt]/NODECPRT_GNB.pcap    sctp    180124   60567
     Start Log    cprt
    Inter-gNB HO for UE to simulated gNB   ${sa_ue_id2}
    sleep     30s
    Inter-gNB HO for UE to actual gNB   ${sa_ue_id2}
    sleep      10s
    ${path3}    Stop Log    cprt   test_scenario=IntergNB_HO_2
    Verify nbrDrbSpecificParams In BearerSetupReq   ${path1}[cprt]/NODECPRT_GNB.pcap    sctp    180124   60567
    Validate DL Traffic For MultiUE for SA   ${sa_ue_id1}  ${sa_ue_id1}   dl_rate=50   pdu_id=1   qfi_id=1
    Stop MultiUE Data Traffic for SA     ${sa_ue_id1}    ${sa_ue_id2}
    MultiUE Deregister should be Successful   ${sa_ue_id1}    ${sa_ue_id2}
    Stop Log   btslog

*** Keywords ***

Inter-gNB HO for UE to simulated gNB
    [Arguments]    ${ue_id}
    wtsrunner.ue_history_information_list_add_ngran     id=${ue_id}     gnb_id=3    cell_type=medium    nrcgi=311:489|0x03  time_ue_stayed_in_cell=100
    wtsrunner.ue_history_information_list   id=${ue_id} action=commit
    wtsrunner.ue_enb_param     id=${ue_id} ue_history_list=1
    wtsrunner.upf_param   id=${ue_id} end_markers_delay=10s
    wtsrunner.ue_measurement_send_nr       id=${ue_id}  meas_id=1 event=A3 srsrp_nr=19 phycell_id=52 nrsrp_nr=100

Inter-gNB HO for UE to actual gNB
     [Arguments]    ${ue_id}
    wtsrunner.ue_history_information_list_add_ngran     id=${ue_id}     gnb_id=2    cell_type=medium    nrcgi=311:489|0x03  time_ue_stayed_in_cell=100
    wtsrunner.ue_history_information_list   id=${ue_id} action=commit
    wtsrunner.ue_enb_param     id=${ue_id} ue_history_list=1
    wtsrunner.upf_param   id=${ue_id} end_markers_delay=10s
    wtsrunner.ue_measurement_send_nr       id=${ue_id}  meas_id=1 event=A3 srsrp_nr=19 phycell_id=50 nrsrp_nr=100
