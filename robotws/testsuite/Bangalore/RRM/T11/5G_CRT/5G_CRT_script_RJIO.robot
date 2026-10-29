*** Settings ***
Force Tags      CLOUD_5G_O_E_AP_LOOO   CRT  RAN_5G    5G_RAN_TDD    5G_RAN   SBTS00    CONFIGURED

Documentation    :copyright: Nokia
...              :author: Mohan
...              :contact: mohanavel.p@nokia.com
...
...             INTRODUCTION:     This user scenario describes the gNB behavior that NBR service
...                                works fine with enhanced DL MU-MIMO.
...             TEST SET NAME:    CB008227
...             TESTING SPLIT:    Refer CB008227 Test Plan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB008227 CFAM
...             Requirement ID:   5G_RAN_USR_RRM_21178

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../../../resources/robot/Setup_Env.robot
Resource         ../../../resources/robot/Airphone.robot
Resource         ../../../resources/robot/WTS_Runner_Keywords.robot
Resource         ../../../resources/robot/PM_Counters.robot
Resource         ../../../resources/ECEcommon/common_setup_teardown.robot
Resource         ./resources/common_Resource.robot
Resource         ./resources/common_keywords.robot
Library          ../../../resources/python/BIP_Capture.py
Library          ../../../resources/python/CPRT_Capture.py
Resource         ../../../resources/robot/configuration_id.robot

Suite Setup         Run keywords    Suite setup from scratch
...                 AND     Modify IPHY File And Send to Airphone Custom    ${iphy_file_TC56}
...                 AND     Update bsr package
...                 AND     gnb.Perform gNB reboot
...                 AND     sleep    180s


*** Test Cases ***
CB008227-E_B7_TC56_NBR_IWK_DL_MUMIMO_Enhanced
    [Documentation]   This user scenario describes the gNB behavior that NBR service
    ...               works fine with enhanced DL MU-MIMO.
    [Setup]      Testcase setup with delta Commissioning   ${TC56_delta_file_name}   ${wts_cfg_file_TC56}   ${no_of_cells_TC56}
    ${TEST_NAME}    Set Variable   8227_E_B7_TC56
    set suite variable     ${TEST_NAME}
    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    log to console   Wait until the next Measurement Period starts
    Wait until the next Measurement Period starts
    Start Log    btslog
    CPRT Monitoring Start ASOE
    Set UE1 and UE2 Pos
    #UE-1 with non-NBR bearer
    UE Register should be Success   ${sa_ue_id1}   ${Pdu_ID}   ${nwslice_ID}   ${gw_ID}
    #UE-2 with NBR bearer
    UE Register should be Success   ${sa_ue_id2}   ${Pdu_ID2}   ${nwslice_ID}   ${gw_ID}
    Modify PDU session for UE   ${sa_ue_id2}   ${Pdu_ID2}
    Activate CSI Override command
    Send DL data to UEs and check throughput   ${sa_ue_id1}   ${sa_ue_id2}
    CPRT Monitoring Stop Collect ASOE      ${LOG_PATH}
    Move File    ${LOG_PATH}/SYSCOM_NODECPRT_GNB.pcap    ${LOG_PATH}/SYSCOM_NODECPRT_GNB_UE_Attach_TC56.pcap
    Move File    ${LOG_PATH}/External_NODECPRT_GNB.pcap    ${LOG_PATH}/External_NODECPRT_GNB_UE_Attach_TC56.pcap
    Verify nbrDrbSpecificParams In bearersetupreq ASOE   ${LOG_PATH}/SYSCOM_NODECPRT_GNB_UE_Attach_TC56.pcap
    ...      itf_l2_ps_user_bearersetupreq    300000   100000
    Start Log   ttitrace   ${phy_id_tc56}
    sleep   5s
    ${path2}   Stop Log   ttitrace   test_scenario=tti1
    Stop Log   btslog
    Verify DL_MUMIO Pairing     ${path2}
    log to console   Wait until the current Measurement Period stops
    Wait until the current Measurement Period stops
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File   output_dirpath=${OUTPUT DIR}/pmcounter1
#Update counter values according to testing
    Verify Any Counters In File
    ...  M55139C03509  300  SA_DU_DRB_NBR_DL
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${pm_cellID}
    ...  file_path=${pm_counter_file}
    Deregister UEs   ${sa_ue_id1}   ${sa_ue_id2}
    [Teardown]      Run Keywords
    ...             Run Keyword And Continue on Failure    Link SCOUT SCF to Configuration ID for Reporting
    ...             AND    Send Delta Commissioning     ${TC56_revert_changes}

CB008227-E#B7_TC57_CNI_105919_B3_TC4
    [Documentation]  This user scenario describes behaviour of NBR IWK with MU MIMO.
    ...             author:           Manasa
    ...             maintainer:       manasa.shankarappa@nokia.com
    ...
    ...             INTRODUCTION:     This user scenario describes behaviour of NBR IWK with MU MIMO.
    ...
    ...             TEST SET NAME:    CB008227
    ...             TESTING SPLIT:    Refer CB008227  Test Plan
    ...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
    ...             REFERENCES:       CB008227 CFAM
    ...             Requirement ID:   5G_RAN_USR_RRM_xxxxx

    [Setup]    Run keywords
    ...        Start Log   btslog
    ...        AND    Start WTS Using WTS_Runner      ${wts_cfg_file_TC57}
    ...        AND     sleep   60s
    ${TEST_NAME}    Set Variable   EA_B7_TC57
    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
# Start of CB008227-E#B7_TC57_NBR_interworking_with_MU_MIMO_UL
    CB008227-E_B7_TC57_NBR_interworking_with_MU_MIMO_UL
# Start of CNI-105919#B3_TC4
    CNI-105919#B3_TC4_UE_Release_on_PDCP_PDU_discards_due_to_the_RoHC_decompression_failures_with_Multiple_Ues_multiple_DRB
#    [Teardown]   Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
    [Teardown]   Run keywords
    ...         Link SCOUT SCF to Configuration ID for Reporting
    ...         AND     MultiUE Deregister should be Successful    ${TC57_sa_ue_id1}    ${TC57_sa_ue_id3}
    ...         AND     Stop Log   btslog    snapshot    sosreport
    ...         AND     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner

USCNI-140556#TC2_Verification_of_blanking_patterns_with_interference_and_with_Bilateral_agreement_SA
    [Documentation]  This User Scenario verifies the correct DL symbols are muted in the gNB cell,
    ...              which is configured with tdLTE without LTE to NR shift, interfering frame structure
    ...              is semistatic 6:4 for SA call
    ...             author:           Manasa
    ...             maintainer:       manasa.shankarappa@nokia.com
    ...
    [Setup]    Run keywords
    ...        Start Log   btslog
    ...        AND    Start WTS Using WTS_Runner      basic_setup.cfg
    ...        AND     sleep   100s
    set suite variable     ${TEST_NAME}
    set test variable      ${LOG_PATH}
    log to console   "SA UE attach"
##Step 1. Attach SA UE's with Feature Disable
    ${rnti_list}   MultiUE Register should be Successful    ${CNI_140556_sa_ue_id1}     ${CNI_140556_sa_ue_id1}
    sleep     2s
    Log to console   ${rnti_list}
    MultiUE Trigger UL Traffic for SA   ${CNI_140556_sa_ue_id1}    ${CNI_140556_sa_ue_id1}    Traffic_rate=mbps   ul_rate=150
    ...   pdu_id=1     trf_id=1     qfi_id=1
    MultiUE Trigger High DL Traffic for SA   ${CNI_140556_sa_ue_id1}    ${CNI_140556_sa_ue_id1}   dl_rate=750   pdu_id=${Pdu_session_ID}
    ...   qfi_id=${QFI_ID}
    sleep   300s
## Due to AP restrictions, chekcing ue_stats_nr
    Run Keyword and Continue on Failure    Validate PDSCH UE Stats for Given CC    ue_id=${CNI_140556_sa_ue_id1}  scell_idx=0   dl_data_rate=743
    Run Keyword and Continue on Failure    Validate PUSCH UE Stats for Given CC    ue_id=${CNI_140556_sa_ue_id1}  scell_idx=0   ul_data_rate=116
#    Run Keyword and Continue on Failure    Validate DL Traffic For MultiUE for SA   ${CNI_140556_sa_ue_id1}    ${CNI_140556_sa_ue_id1}   dl_rate=523
#    Run Keyword and Continue on Failure    Validate UL Traffic For MultiUE for SA   ${CNI_140556_sa_ue_id1}    ${CNI_140556_sa_ue_id1}   ul_rate=115
    Start Log    ttitrace
    sleep   2s
    ${tti_log_path_1}=     Stop Log    ttitrace      test_scenario=${tti_dir_name1}
    common_log_collection.Decode TTI Trace    ${tti_dir_name1}
    ${muted_slot_count}=    Verify DL Muting in TTI Trace     ${tti_log_path_1}[ttitrace]/output_dl_formated.csv   ${muted_slot}
    Should Be True     ${muted_slot_count} >= 200
    MultiUE Deregister should be Successful    ${CNI_140556_sa_ue_id1}    ${CNI_140556_sa_ue_id1}
##Step 2. Attach SA UE's with Feature Enable
    ta5g_commissioning.Send Delta Commissioning    ${CNI_140556_delta_filename}
    sleep   100s
    ${rnti_list}   MultiUE Register should be Successful    ${CNI_140556_sa_ue_id1}     ${CNI_140556_sa_ue_id1}
    sleep     2s
    Log to console   ${rnti_list}
    MultiUE Trigger UL Traffic for SA   ${CNI_140556_sa_ue_id1}    ${CNI_140556_sa_ue_id1}    Traffic_rate=mbps   ul_rate=150
    ...   pdu_id=1     trf_id=1     qfi_id=1
    MultiUE Trigger High DL Traffic for SA   ${CNI_140556_sa_ue_id1}    ${CNI_140556_sa_ue_id1}   dl_rate=750   pdu_id=${Pdu_session_ID}
    ...   qfi_id=${QFI_ID}
    sleep   300s
## Due to AP restrictions, chekcing ue_stats_nr
    Run Keyword and Continue on Failure    Validate PDSCH UE Stats for Given CC    ue_id=${CNI_140556_sa_ue_id1}  scell_idx=0   dl_data_rate=556
    Run Keyword and Continue on Failure    Validate PUSCH UE Stats for Given CC    ue_id=${CNI_140556_sa_ue_id1}  scell_idx=0   ul_data_rate=116
#    Run Keyword and Continue on Failure    Validate DL Traffic For MultiUE for SA   ${CNI_140556_sa_ue_id1}    ${CNI_140556_sa_ue_id1}   dl_rate=650
#    Run Keyword and Continue on Failure    Validate UL Traffic For MultiUE for SA   ${CNI_140556_sa_ue_id1}    ${CNI_140556_sa_ue_id1}   ul_rate=115
    Start Log    ttitrace
    sleep   2s
    ${tti_log_path_2}=     Stop Log    ttitrace      test_scenario=${tti_dir_name2}
    common_log_collection.Decode TTI Trace    ${tti_dir_name2}
    ${muted_slot_count}=    Verify DL Muting in TTI Trace     ${tti_log_path_2}[ttitrace]/output_dl_formated.csv   ${muted_slot}
    Should be Equal as integers    ${muted_slot_count}     0
    [Teardown]  Run Keywords   Link SCOUT SCF to Configuration ID for Reporting
    ...         AND   MultiUE Deregister should be Successful    ${CNI_140556_sa_ue_id1}    ${CNI_140556_sa_ue_id1}
    ...         AND   ta5g_commissioning.Send Delta Commissioning     ${CNI_140556_delta_filename1}
    ...         AND     Stop Log   btslog    snapshot    sosreport
    ...         AND     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner

USCB006877-A#11_TC37_CNI-94156_interworking_when_CB006877_is_enabled_20MHZ
    [Documentation]   :copyright: Nokia
    ...             :authors: Manasa
    ...             :contact: manasa.shankarappa@nokia.com
    ...             INTRODUCTION:     This user scenario describes the gNB behaviour when UE setups the RRC connection
    ...                               using dedicated config in initialDownlinkBWP with CB006877 enabled. This user scenario
    ...                               also tests if the DL and UL resource utilization and peak throughput are stable for
    ...                               dedicated BWP.
    ...                               This user scenario validates the correct working of CB006877 when UL PRB blanking is
    ...                               enabled.This user scenario describes if 21PRB are blanked at the low edge in UL FDD
    ...                               10 MHz cell, the UL traffic can be scheduled within non-blanked area. Once UE attach
    ...                               in 5G cell, the SRS / PTRS / PUCCH / PRACH / PUSCH resource should be assigned
    ...                               within non-blanked area.
    ...                               Thic TC combines UL PRB Balnking and CNI_94156
    ...             TEST SET NAME:    CB006877
    ...             TESTING SPLIT:    Refer CB006877 Test Plan
    ...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
    ...             REFERENCES:       CB006877 CFAM
    ...             Requirement ID:   5G_RAN_USR_RRM_24139
    [Setup]       Run Keywords   Start WTS Using WTS_Runner      ${TC37_basic_cfg}
    ...           AND     sleep    60s
    ...           AND     Start Log   btslog
    ${TEST_NAME}    Set Variable   A_TC37
    set suite variable     ${TEST_NAME}
    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    ta5g_commissioning.Send Delta Commissioning     ${TC37_dummy_json}
    CPRT Monitoring Start ASOE
    Start Log    cprt
    ta5g_commissioning.Send Delta Commissioning     ${TC37_delta_file_name}
    sleep   2s
    ${path1}    Stop Log    cprt   test_scenario=feature_activation
    CPRT Monitoring Stop Collect ASOE    ${LOG_PATH}
    ${longPucchStartPuschPrb}    ${longPucchStartDynPuschPrb}=     Verify UL PUSCH PRBs In CellSetupReq ASOH
    ...  ${LOG_PATH}
    MultiUE Register should be Successful    ${sa_ue_id_cell4}   ${en_ue_id_cell4}
    MultiUE Register should be Successful    ${sa_ue_id_cell5}   ${en_ue_id_cell5}
    MultiUE Trigger DL Traffic for SA    ${sa_ue_id_cell4}    ${en_ue_id_cell4}    mbps    100
    MultiUE Trigger UL Traffic for SA    ${sa_ue_id_cell4}    ${en_ue_id_cell4}    mbps    100
    MultiUE Trigger DL Traffic for SA    ${sa_ue_id_cell5}    ${en_ue_id_cell5}    mbps    100
    MultiUE Trigger UL Traffic for SA    ${sa_ue_id_cell5}    ${en_ue_id_cell5}    mbps    100
    sleep    20s
    Start Log    biptaf
    sleep   2s
    ${bip_path}   Stop Log    biptaf  test_scenario=data_traffic
    Run Keyword And Continue on Failure     Verify prbs in uldata_puschreceivereq     ${bip_path}[biptaf]/BIP_L1L2.pcap
    ...  ${longPucchStartDynPuschPrb}    ${longPucchStartPuschPrb}    ${TC37_cell_subgroup_id}
    Run Keyword And Continue on Failure    Validate PDSCH Multi UE stats for Given CC    ${sa_ue_id_cell4}    ${en_ue_id_cell4}    20    0
    Run Keyword And Continue on Failure    Validate PUSCH Multi UE stats for Given CC    ${sa_ue_id_cell4}    ${en_ue_id_cell4}    10    0
    Run Keyword And Continue on Failure    Validate PDSCH Multi UE stats for Given CC    ${sa_ue_id_cell5}    ${en_ue_id_cell5}    20    0
    Run Keyword And Continue on Failure    Validate PUSCH Multi UE stats for Given CC    ${sa_ue_id_cell5}    ${en_ue_id_cell5}    11    0
    ${cell4_UL_stats}=    Check cell level UL tput SA using ue_stats    ${sa_ue_id_cell4}    ${en_ue_id_cell4}
    ${cell5_UL_stats}=    Check cell level UL tput SA using ue_stats    ${sa_ue_id_cell5}    ${en_ue_id_cell5}
    Run Keyword and Continue on Failure    Should be True    ${cell5_UL_stats}>${cell4_UL_stats}
    MultiUE Deregister should be Successful   ${sa_ue_id_cell4}   ${en_ue_id_cell4}
    MultiUE Deregister should be Successful   ${sa_ue_id_cell5}   ${en_ue_id_cell5}
    Move File    ${LOG_PATH}/SYSCOM_NODECPRT_GNB.pcap    ${LOG_PATH}/SYSCOM_NODECPRT_feature_activation.pcap
##UL PRB blanking TC starts here
    CPRT Monitoring Start ASOE
    Start Log    cprt
    ta5g_commissioning.Send Delta Commissioning     ${TC37_delta_file_name1}
    sleep   2s
    ${path2}    Stop Log    cprt   test_scenario=feature_activation_prb_blank
    CPRT Monitoring Stop Collect ASOE    ${LOG_PATH}
#    ${longPucchStartPuschPrb_with_prb_blank}    ${longPucchStartDynPuschPrb_with_prb_blank}=    Verify UL PUSCH PRBs In CellSetupReq
#    ...  ${path2}
    ${longPucchStartPuschPrb_with_prb_blank}    ${longPucchStartDynPuschPrb_with_prb_blank}=    Verify Ul PUSCH PRBs In CellSetup for PRB Blank ASOH
    ...  ${LOG_PATH}/SYSCOM_NODECPRT_GNB.pcap    5    1
    sleep    60s
    MultiUE Register should be Successful    ${sa_ue_id_cell4}    ${en_ue_id_cell4}
    MultiUE Register should be Successful    ${sa_ue_id_cell5}    ${en_ue_id_cell5}
    MultiUE Trigger DL Traffic for SA    ${sa_ue_id_cell4}    ${en_ue_id_cell4}    mbps    100
    MultiUE Trigger UL Traffic for SA    ${sa_ue_id_cell4}    ${en_ue_id_cell4}    mbps    100
    MultiUE Trigger DL Traffic for SA    ${sa_ue_id_cell5}    ${en_ue_id_cell5}    mbps    100
    MultiUE Trigger UL Traffic for SA    ${sa_ue_id_cell5}    ${en_ue_id_cell5}    mbps    100
    sleep    10s
    Start Log    biptaf
    sleep   2s
    ${bip_path}   Stop Log    biptaf  test_scenario=data_traffic
    Run Keyword And Continue on Failure     Verify prbs in uldata_puschreceivereq     ${bip_path}[biptaf]/BIP_L1L2.pcap
    ...  ${longPucchStartDynPuschPrb_with_prb_blank}    ${longPucchStartPuschPrb_with_prb_blank}    ${TC37_cell_subgroup_id}
    Run Keyword And Continue on Failure     Verify prbs in uldata_puschreceivereq_prb_blank   ${bip_path}[biptaf]/BIP_L1L2.pcap
    ...  ${nbrOfBlankedPRBsLowEdgeUL}    ${TC37_cell_subgroup_id}
    Run Keyword And Continue on Failure    Validate PDSCH Multi UE stats for Given CC    ${sa_ue_id_cell4}    ${en_ue_id_cell4}    20    0
    Run Keyword And Continue on Failure    Validate PUSCH Multi UE stats for Given CC    ${sa_ue_id_cell4}    ${en_ue_id_cell4}    9    0
    Run Keyword And Continue on Failure    Validate PDSCH Multi UE stats for Given CC    ${sa_ue_id_cell5}    ${en_ue_id_cell5}    20    0
    Run Keyword And Continue on Failure    Validate PUSCH Multi UE stats for Given CC    ${sa_ue_id_cell5}    ${en_ue_id_cell5}    10    0
    ${cell4_UL_stats}=    Check cell level UL tput SA using ue_stats    ${sa_ue_id_cell4}    ${en_ue_id_cell4}
    ${cell5_UL_stats}=    Check cell level UL tput SA using ue_stats    ${sa_ue_id_cell5}    ${en_ue_id_cell5}
    Run Keyword and Continue on Failure    Should be True    ${cell5_UL_stats}>${cell4_UL_stats}
    Run Keyword And Continue on Failure    Link SCOUT SCF to Configuration ID for Reporting
    [Teardown]    Run Keywords
    ...           MultiUE Deregister should be Successful   ${sa_ue_id_cell4}   ${en_ue_id_cell4}
    ...           AND   MultiUE Deregister should be Successful   ${sa_ue_id_cell5}   ${en_ue_id_cell5}
    ...           AND   Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
    ...           AND   Stop Log   btslog   snapshot    sosreport
    ...           AND   ta5g_commissioning.Send Delta Commissioning     ${TC37_delta_file_name2}

CB013233-A#B501_ALT1_Successful early DRX setup for UE in SA mode with partial DRB admission (non-emtpy PDU)
    [Documentation]
    ...
    ...             author:           Mohan
    ...             maintainer:       mohanavel.p@nokia.com
    ...
    ...             INTRODUCTION:     The user scenario targets the DRX configuration for SA UE during ICS
    ...                               when gNB-DU partially admits DRBs. F1AP: UEContextSetupRequest message
    ...                               to gNB-DU to setup DRB, includes DRXCycle IE. gNB-DU partially admits
    ...                               DRBs and configures DRX considering admitted DRBs. First RRCReconfiguration
    ...                               to UE includes DRX configuration. After NGAP:InitialContextSetupResponse to
    ...                               AMF gNB does not send dedicated RRCReconfiguration to configure DRX to UE
    [Setup]      Testcase setup with delta Commissioning   ${alt1_delta_file_name}   ${wts_cfg_file_alt1}   ${no_of_cells_TC56}
    ${TEST_NAME}    Set Variable   13233_A_B501_ALT1
    set suite variable     ${TEST_NAME}
    set test variable      ${LOG_PATH}
    Wait until the next Measurement Period starts
#Step 1: Attach UE and check for Early DRX steup in UE contextsetup and start Data traffic
    log to console   "SA UE attach "
    Start Log    btslog
    CPRT Monitoring Start ASOE
    Register non-CA UE${sa_ue_id1} with multiple bearer traffic
    sleep     2s
    Stop Log   btslog
    CPRT Monitoring Stop Collect ASOE      ${LOG_PATH}
    Move File    ${LOG_PATH}/SYSCOM_NODECPRT_GNB.pcap    ${LOG_PATH}/SYSCOM_NODECPRT_GNB_UE_Attach_ALT1.pcap
    Move File    ${LOG_PATH}/External_NODECPRT_GNB.pcap    ${LOG_PATH}/External_NODECPRT_GNB_UE_Attach_ALT1.pcap
    Verify DRXcycle in F1AP_ICS   ${LOG_PATH}/SYSCOM_NODECPRT_GNB_UE_Attach_ALT1.pcap   ${crnti_1}
    Verify partial DRB admitted   ${LOG_PATH}/External_NODECPRT_GNB_UE_Attach_ALT1.pcap
    UE Deregister should be Successful    ${sa_ue_id1}
    Wait until the current Measurement Period stops
    ${pm_counter_file}=     Get Latest Unpacked Full Pm Counters File Classical  output_dirpath=${OUTPUT DIR}/pmcounter1
    Verify Any Counters In File
    ...  M55308C11001  >1000   SLOTS_UE_DRX_ACTIVE
    ...  M55308C11002  >100   SLOTS_UE_DRX_SLEEP
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL_ID}
    ...  file_path=${pm_counter_file}
    [Teardown]      Run Keywords
    ...             Run Keyword And Continue on Failure    Link SCOUT SCF to Configuration ID for Reporting
    ...             AND    Send Delta Commissioning     ${alt1_revert_changes}


CB013233-A#B101_Early_DRX_setup_MultiUE_SA_mode_during_ICS_with_PDU_TDD_different_DRX_profile
    [Documentation]
    ...             author:           Manasa
    ...             maintainer:       manasa.shankarappa@nokia.com
    ...
    ...             INTRODUCTION:     The user scenario targets the DRX configuration for SA UE during ICS.
    ...                               F1AP: UEContextSetupRequest message to gNB-DU to setup DRB, includes DRXCycle IE.
    ...                               First RRCReconfiguration to UE includes DRX configuration. After NGAP:InitialContextSetupResponse
    ...                               to AMF gNB does not send dedicated RRCReconfiguration to configure DRX to UE.
    ...
    [Setup]       Run Keywords   Start WTS Using WTS_Runner      ${13233_A_B101_basic_cfg}
    ...           AND     sleep    60s
#    ...           AND     Start Log   btslog
    ${TEST_NAME}    Set Variable   13233_A_B101
    set suite variable     ${TEST_NAME}
    set test variable      ${LOG_PATH}
    Send Delta Commissioning    ${13233_A_B101_delta_file_name}
    Wait until the next Measurement Period starts
    log to console   "SA UE attach "
#Step 1. Attach Multiple SA UE's with GBR and NON GBR Bearer
    CPRT Monitoring Start ASOE
    ${crnti_list}=    MultiUE Register should be Successful with DRX    ${sa_ue_id1}     ${sa_ue_id4}
    sleep     2s
    CPRT Monitoring Stop Collect ASOE    ${LOG_PATH}
#Step2: Check for early DRX in ICS ie, uecontextsetup request
    MoveFile    ${LOG_PATH}/SYSCOM_NODECPRT_GNB.pcap    ${LOG_PATH}/SYSCOM_NODECPRT_GNB_early_drx.pcap
    Verify DRXcycle in F1AP_UEContextSetupRequest for all UE   ${LOG_PATH}/SYSCOM_NODECPRT_GNB_early_drx.pcap   ${crnti_list}
    CPRT Monitoring Start ASOE
#Step3: Add 5QI-5 and 5Qi-1 VONR Bearer.
    Add new Bearer for Multiple SA UE    ${sa_ue_id1}    ${sa_ue_id4}    ${Pdu_session_ID}    ${QFI_ID2}
    Add new Bearer for Multiple SA UE    ${sa_ue_id1}    ${sa_ue_id4}    ${Pdu_session_ID}    ${QFI_ID3}
    CPRT Monitoring Stop Collect ASOE     ${LOG_PATH}
    MoveFile    ${LOG_PATH}/SYSCOM_NODECPRT_GNB.pcap    ${LOG_PATH}/SYSCOM_NODECPRT_GNB_VONR_drx.pcap
#Step4: VONR DRX profile is higher priority. Hence DRX gets released and setup with new values.
    Verify DRXcycle in F1AP_UEContextModificationRequest for all UE    ${LOG_PATH}/SYSCOM_NODECPRT_GNB_VONR_drx.pcap   ${crnti_list}
    CPRT Monitoring Start ASOE
#Step5: Add new GBR Bearer with DRX priority lower than VONR DRX
    Add new Bearer for Multiple SA UE    ${sa_ue_id1}    ${sa_ue_id4}    ${Pdu_session_ID}    ${QFI_ID4}
    CPRT Monitoring Stop Collect ASOE     ${LOG_PATH}
    MoveFile    ${LOG_PATH}/SYSCOM_NODECPRT_GNB.pcap    ${LOG_PATH}/SYSCOM_NODECPRT_GNB_5QI_2_drx.pcap
#Step6: Start bursty traffic only for UE-1 to hit DRX Sleep duration with 20Kbps
    MultiUE Trigger Bursty DL Traffic for SA    ${sa_ue_id1}    ${sa_ue_id1}   Traffic_rate=kbps   dl_rate=20    period_ms=1000ms
    ...   pdu_id=${Pdu_session_ID}   qfi_id=${QFI_ID}
    MultiUE Trigger bursty UL Traffic for SA    ${sa_ue_id1}    ${sa_ue_id1}   Traffic_rate=kbps   ul_rate=20    period_ms=1000ms
    ...   pdu_id=${Pdu_session_ID}   qfi_id=${QFI_ID}
    sleep   60s
    Run Keyword and continue on Failure       Validate DL Traffic For MultiUE for SA     ${sa_ue_id1}    ${sa_ue_id1}   dl_rate=0.02
    ...    pdu_id=${Pdu_session_ID}   qfi_id=${QFI_ID}
    Run Keyword and continue on Failure       Validate UL Traffic For MultiUE for SA     ${sa_ue_id1}    ${sa_ue_id1}   ul_rate=0.02
    ...    pdu_id=${Pdu_session_ID}   qfi_id=${QFI_ID}
    Wait until the current Measurement Period stops
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File Classical   output_dirpath=${OUTPUT DIR}/pmcounter1
#Step7: Check DRX Active and Sleep counters
    Verify Any Counters In File
    ...  M55308C11001  >1000   SLOTS_UE_DRX_ACTIVE
    ...  M55308C11002  >1000   SLOTS_UE_DRX_SLEEP
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL_ID}
    ...  file_path=${pm_counter_file}
#Step8: Trigger bursty traffic for other UE's
    MultiUE Trigger Bursty DL Traffic for SA    ${sa_ue_id2}    ${sa_ue_id4}   Traffic_rate=kbps   dl_rate=20    period_ms=1000ms
    ...   pdu_id=${Pdu_session_ID}   qfi_id=${QFI_ID}
    MultiUE Trigger bursty UL Traffic for SA    ${sa_ue_id2}    ${sa_ue_id4}   Traffic_rate=kbps   ul_rate=20    period_ms=1000ms
    ...   pdu_id=${Pdu_session_ID}   qfi_id=${QFI_ID}
    sleep   60s
#Step9: Validate UL and DL data traffic for all UE's.
    Run Keyword and continue on Failure       Validate DL Traffic For MultiUE for SA     ${sa_ue_id1}    ${sa_ue_id4}   dl_rate=0.02
    ...    pdu_id=${Pdu_session_ID}   qfi_id=${QFI_ID}
    Run Keyword and continue on Failure       Validate UL Traffic For MultiUE for SA     ${sa_ue_id1}    ${sa_ue_id4}   ul_rate=0.02
    ...    pdu_id=${Pdu_session_ID}   qfi_id=${QFI_ID}
#Step10: Testcase Teardown Deregister UE
    [Teardown]   Run Keywords     Run Keyword And Continue on Failure     Link SCOUT SCF to Configuration ID for Reporting
    ...           AND   MultiUE Deregister should be Successful    ${sa_ue_id1}     ${sa_ue_id4}
    ...           AND   Send Delta Commissioning    ${13233_A_B101_delta_file_name_1}
    ...           AND   Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
#    ...           AND   Stop Log   btslog   snapshot    sosreport
    ...           AND   ta5g_commissioning.Send Delta Commissioning     ${TC37_delta_file_name2}

