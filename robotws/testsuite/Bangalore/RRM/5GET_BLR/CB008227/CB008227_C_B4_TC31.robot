*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO   CRT   RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     CONFIGURED

Documentation    :copyright: Nokia
...              :author: Mohan
...              :contact: mohanavel.p@nokia.com
...
...             INTRODUCTION:     This user scenario describes the gNB behaviour for the successful setup of Non GBR QoS Flow
...                               with configured DL/UL Nominal Bit Rate in DRB profile which is triggered by Intra-frequency
...                               Intra-DU Intra-gNB handover handover procedure (SA).
...             TEST SET NAME:    CB008227
...             TESTING SPLIT:    Refer CB008227 Test Plan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB008227 CFAM
...             Requirement ID:   5G_RAN_USR_RRM_20702



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
...                           scfc_filename=CB008227_IntraDU_IntragNB_scf_100M_feature_on.xml
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
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${TRF_ID}     1
${QFI_ID}     1
${epc_log_path}    /tmp/
${IPHY_FILE}                    ${CURDIR}/config/iphy_AEHC.xml
${no_of_cells}    2

*** Test Cases ***

CB008227-C#B4_TC31_Support_NBR_of_nonGBR_bearers_for_Intra-frequency_Intra-DU_Intra-gNB handover_SA
    [Documentation]   This user scenario describes the gNB behaviour for the successful setup of Non GBR QoS Flow
    ...               with configured DL/UL Nominal Bit Rate in DRB profile which is triggered by Intra-frequency
    ...               Intra-DU Intra-gNB handover handover procedure (SA).
    Verify actNbrForNonGbrBearers In CellSetupReq
    log to console   UE attach trigerring now...
    Start Log    btslog   cprt
    UE Register with ICS should be Successful   ${sa_ue_id1}
    sleep     5s
    ${path1}    Stop Log    cprt   test_scenario=bearersetup
    Verify nbrDrbSpecificParams In BearerSetupReq   ${path1}[cprt]/NODECPRT_GNB.pcap    sctp    180000   60000
    MultiUE Trigger DL Traffic for SA    ${sa_ue_id1}  ${sa_ue_id1}   Traffic_rate=mbps     dl_rate=50        pdu_id=1     trf_id=1     qfi_id=1
    sleep     5s
    Start Log    cprt
    IntragNB Intercell HO SA A5 UE measurements   ${sa_ue_id1}
    ${path2}    Stop Log    cprt   test_scenario=IntraDU_HO
    Validate DL Traffic For MultiUE for SA   ${sa_ue_id1}  ${sa_ue_id1}   dl_rate=50   pdu_id=1   qfi_id=1
    Verify NBR counter updating for handover in target cell
    Stop MultiUE Data Traffic for SA     ${sa_ue_id1}    ${sa_ue_id1}
    MultiUE Deregister should be Successful   ${sa_ue_id1}    ${sa_ue_id1}
    Stop Log   btslog
    [Teardown]    Link SCOUT SCF to Configuration ID for Reporting
