*** Settings ***
Force Tags      CLOUD_5G_O_H_AP_LOO   CRT   RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     CONFIGURED

Documentation    :copyright: Nokia
...              :author:
...              :contact:
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
Resource         CB008227_keywords.robot
Library          ../resources/python/BIP_Capture.py
Library          ../resources/python/CPRT_Capture.py
Resource         ../resources/robot/configuration_id.robot

Suite Setup         Run keywords    Run Keyword and Ignore Error      Suite setup from scratch
...                 AND     OperatingSystem.Run     sudo ip addr add 10.0.1.123/24 dev eth3
...                 AND     OperatingSystem.Run     sudo ip addr add 10.0.1.124/24 dev eth3
...                 AND     OperatingSystem.Run     sudo ip addr add 10.0.2.90/24 dev eth4
...                 AND     OperatingSystem.Run     sudo ip addr add 10.0.2.91/24 dev eth4

*** Test Cases ***
CB008227-D#B1_TC36_NBR_congestion_detection_and_handling_with_pdsch_congestion_control_and_congWeightAlg_prioritylevel
    [Documentation]
    ...
    ...             author:           Manasa
    ...             maintainer:       manasa.shankarappa@nokia.com
    ...
    ...             INTRODUCTION:     This user scenario describes the gNB behavior related to NBR bearers
    ...                               congestion detection and congestion handling with both
    ...                               "PDSCH & PUSCH congeztion control" and congWeightAlg set to "prioritylevel"
    ...
    ...             TEST SET NAME:    CB008227
    ...             TESTING SPLIT:    Refer CB008227 Test Plan
    ...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
    ...             REFERENCES:       CB008227 CFAM
    ...             Requirement ID:   5G_RAN_USR_RRM_20653
    [Setup]     Run Keywords
    ...         start Log   btslog
    ...         AND     Start WTS Using WTS_Runner      ${wts_cfg_file_TC36}
    ${TEST_NAME}    Set Variable   D_B1_TC36
    set suite variable     ${TEST_NAME}
    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    Perform SCF Delta Commissioning with ${TC36_delta_file_name}
    X2AP Link Should be UP
    Wait until the next Measurement Period starts
    log to console   "SA UE attach with NBR Bearers are trigerring now"
#Step 1. Attach SA UE's with 1 default Bearer and 3 NBR Beareres
    Start Log    cprt
    MultiUE Register should be Successful    ${TC36_sa_ue_id1}     ${TC36_sa_ue_id1}
    sleep     2s
    Add new Bearer for Multiple SA UE    ${TC36_sa_ue_id1}    ${TC36_sa_ue_id1}    ${Pdu_session_ID}    ${QFI_ID2}
    Add new Bearer for Multiple SA UE    ${TC36_sa_ue_id1}    ${TC36_sa_ue_id1}    ${Pdu_session_ID}    ${QFI_ID3}
    Add new Bearer for Multiple SA UE    ${TC36_sa_ue_id1}    ${TC36_sa_ue_id1}    ${Pdu_session_ID}    ${QFI_ID4}
    ${path1}    Stop Log    cprt   test_scenario=usersetup
    Trigger High DL Traffic SA   ue_id=${TC36_sa_ue_id1}    dl_rate=300   pdu_id=${Pdu_session_ID}   qfi_id=${QFI_ID}
    Trigger High DL Traffic SA   ue_id=${TC36_sa_ue_id1}    dl_rate=300   pdu_id=${Pdu_session_ID}   qfi_id=${QFI_ID2}
    Trigger High DL Traffic SA   ue_id=${TC36_sa_ue_id1}    dl_rate=300   pdu_id=${Pdu_session_ID}   qfi_id=${QFI_ID3}
    Trigger High DL Traffic SA   ue_id=${TC36_sa_ue_id1}    dl_rate=300   pdu_id=${Pdu_session_ID}   qfi_id=${QFI_ID4}
    sleep   10s
    Validate DL Traffic For UEs diff QFI   52   200   92   58
    Trigger High UL Traffic SA   ue_id=${TC36_sa_ue_id1}    ul_data=60   pdu_id=${Pdu_session_ID}   qfi_id=${QFI_ID}
    Trigger High UL Traffic SA   ue_id=${TC36_sa_ue_id1}    ul_data=60   pdu_id=${Pdu_session_ID}   qfi_id=${QFI_ID2}
    Trigger High UL Traffic SA   ue_id=${TC36_sa_ue_id1}    ul_data=40   pdu_id=${Pdu_session_ID}   qfi_id=${QFI_ID3}
    Trigger High UL Traffic SA   ue_id=${TC36_sa_ue_id1}    ul_data=40   pdu_id=${Pdu_session_ID}   qfi_id=${QFI_ID4}
    sleep   10s
    Run Keyword And Continue on Failure    Link SCOUT SCF to Configuration ID for Reporting
    Validate UL Traffic For UEs diff QFI   60   40
    Wait until the current Measurement Period stops
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File   output_dirpath=${OUTPUT DIR}/pmcounter1
#Update counter values according to testing
    Verify Any Counters In File
    ...  M55139C03509  900  SA_DU_DRB_NBR_DL
    ...  M55300C12010  600  ACC_DU_DRB_NBR_DL_DEPRIO_CONG
    ...  M55370C00041  900  ACC_DU_DRB_NBR_UL_DEPRIO_CONG
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${TC36_CELL_ID}
    ...  file_path=${pm_counter_file}
    [Teardown]      Run Keywords
    ...             MultiUE Deregister should be Successful    ${TC36_sa_ue_id1}    ${TC36_sa_ue_id1}
    ...             AND    Perform SCF Delta Commissioning with ${TC36_revert_delta}
    ...             AND    Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
    ...             AND    Stop Log   btslog    snapshot    sosreport


CB008227-C#B4_TC31_Support_NBR_of_nonGBR_bearers_for_Intra-frequency_Intra-DU_Intra-gNB handover_SA
    [Documentation]   This user scenario describes the gNB behaviour for the successful setup of Non GBR QoS Flow
    ...               with configured DL/UL Nominal Bit Rate in DRB profile which is triggered by Intra-frequency
    ...               Intra-DU Intra-gNB handover handover procedure (SA).
    [Setup]      Testcase Setup ASOH   ${IPHY_TC31}   ${scf_TC31}   ${wts_cfg_file_TC31}   ${no_of_cells}
    ${TEST_NAME}    Set Variable   C_B4_TC31
    set suite variable     ${TEST_NAME}
    Verify actNbrForNonGbrBearers In CellSetupReq ASOH
    log to console   UE attach trigerring now...
    Start Log    btslog
    CPRT Monitoring Start ASOE
    UE Register with ICS should be Successful   ${sa_ue_id1}
    sleep     5s
    CPRT Monitoring Stop Collect ASOE    ${LOG_PATH}
    set suite variable    ${LOG_PATH}
    Verify nbrDrbSpecificParams In BearerSetupReq   ${LOG_PATH}/SYSCOM_NODECPRT_GNB.pcap    itf_l2_ps_user_bearersetupreq    180000   60000
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
    [Teardown]    Run Keywords   Link SCOUT SCF to Configuration ID for Reporting
    ...           AND   common Teardown

CB008227-B#B1_TC19_UL_power_with_limited_UE_will_not_be_able_to_meet_their_NBR both UL_DL
    [Documentation]  This user scenario describes UL power limited UEs will not be able to meet their NBR but they
    ...              will achieve greater than or equal to the UL throughput that they had achieved prior to NBR being enabled
    [Setup]      Testcase Setup ASOH   ${IPHY_TC19}   ${scf_TC19}   ${wts_cfg_file_TC19}   ${no_of_cells}
    ${TEST_NAME}    Set Variable   B_B1_TC19
    set suite variable     ${TEST_NAME}
    Perform SCF Delta Commissioning with ${delta_commissioning_off_json}
    sleep   5s
    Start Log    btslog
    Start Log    biptaf
    UE Register with ICS+PDU should be Successful   ${sa_ue_id1}
    UE Register with ICS+PDU should be Successful      ${sa_ue_id2}
    UE Register should be Successful Vonr          ${sa_ue_id3}
    Set Power Class For UE 1
    Set Power Class For UE 2
    MultiUE Trigger DL Traffic for SA    ${sa_ue_id1}  ${sa_ue_id1}   Traffic_rate=mbps     dl_rate=50        pdu_id=1     trf_id=1     qfi_id=1
    MultiUE Trigger UL Traffic for SA    ${sa_ue_id1}  ${sa_ue_id1}   Traffic_rate=mbps     ul_rate=20        pdu_id=1     trf_id=1     qfi_id=1
    MultiUE Trigger DL Traffic for SA    ${sa_ue_id2}  ${sa_ue_id2}   Traffic_rate=mbps     dl_rate=50        pdu_id=1     trf_id=1     qfi_id=1
    MultiUE Trigger UL Traffic for SA    ${sa_ue_id2}  ${sa_ue_id2}   Traffic_rate=mbps     ul_rate=20        pdu_id=1     trf_id=1     qfi_id=1
    Trigger DL Traffic for SA Vonr    ${sa_ue_id3}   1    ${Pdu_session_ID}   ${TRF_ID}    ${QFI_ID}
    Trigger UL Traffic for SA Vonr    ${sa_ue_id3}   1    ${Pdu_session_ID}   ${TRF_ID}    ${QFI_ID}
    sleep     5s
    Validate DL Traffic For MultiUE for SA   ${sa_ue_id1}  ${sa_ue_id1}   dl_rate=50   pdu_id=1   qfi_id=1
    Validate UL Traffic For MultiUE for SA   ${sa_ue_id1}  ${sa_ue_id1}   ul_rate=20   pdu_id=1   qfi_id=1
    Validate DL Traffic For MultiUE for SA   ${sa_ue_id2}  ${sa_ue_id2}   dl_rate=50   pdu_id=1   qfi_id=1
    Validate UL Traffic For MultiUE for SA   ${sa_ue_id2}  ${sa_ue_id2}   ul_rate=20   pdu_id=1   qfi_id=1
    Deregister UEs TC19
    Stop Log   btslog
    Stop Log    biptaf
    Perform SCF Delta Commissioning with ${delta_commissioning_on_json}
    log to console   UE attach trigerring now...
    Start Log    btslog
    Start Log    biptaf
    UE Register with ICS+PDU should be Successful   ${sa_ue_id1}
    UE Register with ICS+PDU should be Successful      ${sa_ue_id2}
    UE Register should be Successful Vonr          ${sa_ue_id3}
    MultiUE Trigger DL Traffic for SA    ${sa_ue_id1}  ${sa_ue_id1}   Traffic_rate=mbps     dl_rate=50        pdu_id=1     trf_id=1     qfi_id=1
    MultiUE Trigger UL Traffic for SA    ${sa_ue_id1}  ${sa_ue_id1}   Traffic_rate=mbps     ul_rate=20        pdu_id=1     trf_id=1     qfi_id=1
    MultiUE Trigger DL Traffic for SA    ${sa_ue_id2}  ${sa_ue_id2}   Traffic_rate=mbps     dl_rate=50        pdu_id=1     trf_id=1     qfi_id=1
    MultiUE Trigger UL Traffic for SA    ${sa_ue_id2}  ${sa_ue_id2}   Traffic_rate=mbps     ul_rate=20        pdu_id=1     trf_id=1     qfi_id=1
    Trigger DL Traffic for SA Vonr    ${sa_ue_id3}   1    ${Pdu_session_ID}   ${TRF_ID}    ${QFI_ID}
    Trigger UL Traffic for SA Vonr    ${sa_ue_id3}   1    ${Pdu_session_ID}   ${TRF_ID}    ${QFI_ID}
    sleep     5s
    Validate DL Traffic For MultiUE for SA   ${sa_ue_id1}  ${sa_ue_id1}   dl_rate=50   pdu_id=1   qfi_id=1
    Validate UL Traffic For MultiUE for SA   ${sa_ue_id1}  ${sa_ue_id1}   ul_rate=20   pdu_id=1   qfi_id=1
    Validate DL Traffic For MultiUE for SA   ${sa_ue_id2}  ${sa_ue_id2}   dl_rate=50   pdu_id=1   qfi_id=1
    Validate UL Traffic For MultiUE for SA   ${sa_ue_id2}  ${sa_ue_id2}   ul_rate=20   pdu_id=1   qfi_id=1
    Deregister UEs TC19
    Stop Log   btslog
    Stop Log    biptaf
    [Teardown]    Run Keywords   Link SCOUT SCF to Configuration ID for Reporting
    ...           AND   common Teardown

CB008227-A#B1_TC8_Scheduling_of_5G_UEs_with_non-GBR_bearers_with_respect_to_5QI_and_PLMNID_for_SA_mode_when_actRanSharing_True Downlink only FDD
    [Documentation]
    ...             author:           Ashutosh
    ...             maintainer:       ashutosh.k.jaiswal@nokia.com
    ...
    ...             INTRODUCTION:     This user scenario describes the gNB behaviour for the successful setup of
    ...                               Non GBR QoS Flow with configured DL/UL Nominal Bit Rate in DRB profile which
    ...                               is triggered by Initial Context Setup Request procedure when actRanSharing enable
    ...             TEST SET NAME:    CB008227
    ...             TESTING SPLIT:    Refer CB008227 Test Plan
    ...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
    ...             REFERENCES:       CB008227 CFAM
    ...             Requirement ID:   xxxxx
    [Setup]      Testcase Setup ASOH   ${IPHY_TC8}   ${scf_TC8}   ${wts_cfg_file_TC8}   ${no_of_cells}
    ${TEST_NAME}    Set Variable   A_B1_TC8
    set suite variable     ${TEST_NAME}
    log to console   TC8 Verifying feature activation in Full recommissioning
    Wait until the next Measurement Period starts
    Verify actNbrForNonGbrBearers In CellSetupReq ASOH
    log to console   UE attach trigerring now...
#    Start Log    btslog   cprt   bip
    CPRT Monitoring Start ASOH
    UE Register with ICS+PDU should be Successful   ${sa_ue_id1}
    UE Register with ICS+PDU should be Successful   ${sa_ue_id2}
    sleep     5s
#    ${path1}    Stop Log    cprt   test_scenario=bearersetup
    CPRT Monitoring Stop Collect ASOH    ${LOG_PATH}
    Verify nbrDrbSpecificParams In BearerSetupReq    ${LOG_PATH}/SYSCOM_NODECPRT_GNB.pcap    itf_l2_ps_user_bearersetupreq    10000   10000
    MultiUE Trigger DL Traffic for SA    ${sa_ue_id1}  ${sa_ue_id1}   Traffic_rate=mbps     dl_rate=50        pdu_id=1     trf_id=1     qfi_id=1
    MultiUE Trigger DL Traffic for SA    ${sa_ue_id2}  ${sa_ue_id2}   Traffic_rate=mbps     dl_rate=50        pdu_id=1     trf_id=1     qfi_id=1
    sleep     5s
    Validate DL Traffic For MultiUE for SA   ${sa_ue_id1}  ${sa_ue_id1}   dl_rate=50   pdu_id=1   qfi_id=1
    sleep     5s
    Validate DL Traffic For MultiUE for SA   ${sa_ue_id2}  ${sa_ue_id2}   dl_rate=50   pdu_id=1   qfi_id=1
    sleep     5s
    Wait until the current Measurement Period stops
    ${pm_files}     Collect and Store PM Counter Files
    Validate SA_DU_DRB_NBR_DL Counter     ${pm_files}
    Stop MultiUE Data Traffic for SA     ${sa_ue_id1}    ${sa_ue_id1}
    Stop MultiUE Data Traffic for SA     ${sa_ue_id2}    ${sa_ue_id2}
    MultiUE Deregister should be Successful   ${sa_ue_id1}    ${sa_ue_id1}
    MultiUE Deregister should be Successful   ${sa_ue_id2}    ${sa_ue_id2}
    Stop Log   btslog
    [Teardown]    Run Keywords   Link SCOUT SCF to Configuration ID for Reporting
    ...           AND   common Teardown
