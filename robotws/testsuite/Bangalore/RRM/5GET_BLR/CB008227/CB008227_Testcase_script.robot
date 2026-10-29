*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO   CRT  RAN_5G    5G_RAN_TDD    5G_RAN   SBTS00    CONFIGURED

Documentation    :copyright: Nokia
...              :author:
...              :contact:
...
...             INTRODUCTION:     This user scenario describes the  verification of Interface message with feature flag during
...                               1. cell setup, 2.Bearer setup,parameter range and PDL rule validations
...             TEST SET NAME:    CB008227
...             TESTING SPLIT:    Refer CB008227 Test Plan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB008227 CFAM
...             Requirement ID:   xxxxx



Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../resources/robot/Setup_Env.robot
Resource         ../resources/robot/Airphone.robot
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ../resources/robot/PM_Counters.robot
Resource       ../resources/ECEcommon/common_setup_teardown.robot
Resource         CB008227_Resource.robot
Resource         CB008227_keywords.robot
Library          ../resources/python/BIP_Capture.py
Library          ../resources/python/CPRT_Capture.py
Resource         ../resources/robot/configuration_id.robot

Suite Setup         Run Keyword and Ignore Error      Suite setup from scratch

*** Test Cases ***
CB008227-C#B5_TC32_Support_NBR_nonGBR_bearers_for_Intra-DU_PSCell_change_procedure_NSA
    [Documentation]
    ...             author:           Manasa
    ...             maintainer:       manasa.shankarappa@nokia.com
    ...
    ...             INTRODUCTION:     This user scenario describes the gNB behaviour for Admission control
    ...                               of NBR Non GBR DRB when NBR bearers Exceed Cell’s NBR max amount
    ...                               Limitation for Intra-DU PSCell change procedure (NSA)
    ...             TEST SET NAME:    CB008227
    ...             TESTING SPLIT:    Refer CB008227 Test Plan
    ...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
    ...             REFERENCES:       CB008227 CFAM
    ...             Requirement ID:   xxxxx
    [Setup]     Run Keywords
    ...         Start Log   btslog
    ...         AND     Start WTS Using WTS_Runner      ${wts_cfg_file_TC32}
    ${TEST_NAME}    Set Variable   C_B5_TC32
    set suite variable     ${TEST_NAME}
    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
#Perform Delta changes with maxNumOfNbrBearers set to "0"
    Perform SCF Delta Commissioning with ${TC32_delta_file_name}
    X2AP Link Should be UP
    Enable ENDC for LTE cell    ${LTE_cell_id1}
    Enable ENDC for LTE cell    ${LTE_cell_id2}
    Wait until the next Measurement Period starts
    log to console   "NSA UE attach trigerring now"
#Step 1. Attach NSA UE's
    Multiple NSA UE Register    ${TC32_nsa_ue_id1}     ${TC32_nsa_ue_id4}
    sleep     2s
    Add new LTE Bearer for Multiple UE    ${TC32_nsa_ue_id1}   ${TC32_nsa_ue_id4}    7     7
    Multiple NSA UE start DL Traffic   ${TC32_nsa_ue_id1}    ${TC32_nsa_ue_id4}   10
    Multiple NSA UE start UL Traffic   ${TC32_nsa_ue_id1}    ${TC32_nsa_ue_id4}   10
    Multiple NSA UE Start DL Traffic for new Bearer    ${TC32_nsa_ue_id1}    ${TC32_nsa_ue_id4}   7    10
    Multiple NSA UE Start UL Traffic for new Bearer    ${TC32_nsa_ue_id1}    ${TC32_nsa_ue_id4}   7    10
    sleep    60s
    Validate DL UL Traffic For all UEs TC32
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File   output_dirpath=${OUTPUT DIR}/pmcounter1
    Verify Any Counters In File
    ...  M55115C03506  4  NSA_DU_DRB_NBR_REQ
    ...  M55115C03507  4  NSA_DU_DRB_NBR_ADMIT_WITH_NBR
    ...  M55115C03508  0  NSA_DU_DRB_NBR_ADMIT_NOT_NBR
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL_ID}
    ...  file_path=${pm_counter_file}
    Wait until the next Measurement Period starts
    Start Log    cprt
    Perform Intra LTE HO    ${TC32_nsa_ue_id1}    ${LTE_cell_id2}
    ${path1}    Stop Log    cprt   test_scenario=LTE_INTRA_HO_max_nbr_bearer_0
##  Validate CPRT logs for UE context modification with NBR IE for sgnb modification for Inter MeNB INTRA cell HO
    Verify nbrDrbSpecificParams In usersetupreq with nbrdl and nbrul   ${path1}[cprt]/NODECPRT_GNB.pcap   sctp     ${TC32_nbr_dl_value}
    ...    ${TC32_nbr_ul_value}
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File   output_dirpath=${OUTPUT DIR}/pmcounter2
    Verify Any Counters In File
    ...  M55115C03509  1200  NSA_DU_DRB_NBR_DL
    ...  M55115C03510  1200  NSA_DU_DRB_NBR_UL
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL_ID}
    ...  file_path=${pm_counter_file}
    Multiple NSA UE Detach    ${TC32_nsa_ue_id1}    ${TC32_nsa_ue_id4}
## Set maxNumOfNbrBearers to 2
    Perform SCF Delta Commissioning with ${TC32_delta_file_name1}
    Wait until the next Measurement Period starts
    log to console   "NSA UE attach trigerring now"
#Step 1. Attach NSA UE's
    Change UE location    ${TC32_nsa_ue_id1}   ${1}    ${LTE_cell_id1}
    Multiple NSA UE Register    ${TC32_nsa_ue_id1}     ${TC32_nsa_ue_id4}
    sleep     2s
    Add new LTE Bearer for Multiple UE    ${TC32_nsa_ue_id1}   ${TC32_nsa_ue_id4}    7     7
    Multiple NSA UE start DL Traffic   ${TC32_nsa_ue_id1}    ${TC32_nsa_ue_id4}   10
    Multiple NSA UE start UL Traffic   ${TC32_nsa_ue_id1}    ${TC32_nsa_ue_id4}   10
    Multiple NSA UE Start DL Traffic for new Bearer    ${TC32_nsa_ue_id1}    ${TC32_nsa_ue_id4}   7    10
    Multiple NSA UE Start UL Traffic for new Bearer    ${TC32_nsa_ue_id1}    ${TC32_nsa_ue_id4}   7    10
    sleep    60s
    Validate DL UL Traffic For all UEs TC32
    Perform Intra LTE HO    ${TC32_nsa_ue_id1}    ${LTE_cell_id2}
#    Wait until the next Measurement Period starts
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File   output_dirpath=${OUTPUT DIR}/pmcounter3
    Verify Any Counters In File
    ...  M55115C03506  4  NSA_DU_DRB_NBR_REQ
    ...  M55115C03507  2  NSA_DU_DRB_NBR_ADMIT_WITH_NBR
    ...  M55115C03508  2  NSA_DU_DRB_NBR_ADMIT_NOT_NBR
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL_ID}
    ...  file_path=${pm_counter_file}
    Run Keyword And Continue on Failure    Link SCOUT SCF to Configuration ID for Reporting
    Multiple NSA UE Detach    ${TC32_nsa_ue_id1}    ${TC32_nsa_ue_id4}
    [Teardown]      Run Keywords
    ...             Perform SCF Delta Commissioning with ${TC32_revert_delta}
    ...             AND    Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
    ...             AND    Stop Log   btslog    snapshot    sosreport

CB008227-A#B4_TC15_Support_NBR_nonGBR_bearers_setup_with_SgNB_Modification_NSA_both_UL_DL
    [Documentation]
    ...
    ...             author:           Manasa
    ...             maintainer:       manasa.shankarappa@nokia.com
    ...
    ...             INTRODUCTION:     This user scenario describes the gNB behaviour for the successful setup of
    ...                               Non GBR bearer with configured DL/UL Nominal Bit Rate in DRB profile which
    ...                               is triggered by SgNB Modification (E-RABs To Be Added) procedure.
    ...
    ...                               This user scenario describes the gNB behaviour for Admission
    ...                               control of NBR Non GBR DRB when NBR bearers Exceed Cell’s
    ...                               NBR max amount Limitation for NSA SgNB Modification
    ...                               (E-RABs To Be Added) procedure.
    ...             TEST SET NAME:    CB008227
    ...             TESTING SPLIT:    Refer CB008227 Test Plan
    ...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
    ...             REFERENCES:       CB008227 CFAM
    ...             Requirement ID:   xxxxx
    [Setup]     Run Keywords
    ...         Start Log   btslog
    ...         AND     Start WTS Using WTS_Runner      ${wts_cfg_file_TC15}
    ${TEST_NAME}    Set Variable   A_B4_TC15
    set suite variable     ${TEST_NAME}
    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    Perform SCF Delta Commissioning with ${TC15_delta_file_name}
    X2AP Link Should be UP
    Enable ENDC for all Bearer
    Wait until the next Measurement Period starts
    log to console   "NSA UE attach trigerring now"
#Step 1. Attach NSA UE's
    Start Log    cprt
    Multiple NSA UE Register    ${TC32_nsa_ue_id1}     ${TC32_nsa_ue_id4}
    sleep     10s
    ${path1}    Stop Log    cprt   test_scenario=usersetup
    Run Keyword and Continue on Failure    Multiple NSA UE start DL Traffic   ${TC32_nsa_ue_id1}    ${TC32_nsa_ue_id2}   100
    Start Log    cprt
    Add new LTE Bearer for Multiple UE    ${TC32_nsa_ue_id1}   ${TC32_nsa_ue_id2}    7     7
    sleep   2s
    ${path2}    Stop Log    cprt   test_scenario=bearersetup
    Run Keyword and Continue on Failure    Multiple NSA UE Start DL Traffic for new Bearer    ${TC32_nsa_ue_id1}    ${TC32_nsa_ue_id2}   7    500
    sleep   60s
    Validate DL Traffic For all UEs TC15
    Stop Data Traffic for NSA    ${TC32_nsa_ue_id1}
    Stop Data Traffic for NSA    ${TC32_nsa_ue_id2}
    sleep   5s
    Run Keyword and Continue on Failure    Multiple NSA UE start UL Traffic   ${TC32_nsa_ue_id1}    ${TC32_nsa_ue_id2}   50
    Run Keyword and Continue on Failure    Multiple NSA UE Start UL Traffic for new Bearer    ${TC32_nsa_ue_id1}    ${TC32_nsa_ue_id2}   7    80
    sleep   60s
    Validate UL Traffic For all UEs TC15
    Stop Data Traffic for NSA    ${TC32_nsa_ue_id1}
    Stop Data Traffic for NSA    ${TC32_nsa_ue_id2}
    Run Keyword and Continue on Failure    Multiple NSA UE start DL Traffic   ${TC32_nsa_ue_id1}    ${TC32_nsa_ue_id4}   10
    Run Keyword and Continue on Failure    Multiple NSA UE start UL Traffic   ${TC32_nsa_ue_id1}    ${TC32_nsa_ue_id4}   10
    Add new LTE Bearer for Multiple UE    ${TC32_nsa_ue_id3}   ${TC32_nsa_ue_id4}    7     7
    Run Keyword and Continue on Failure    Multiple NSA UE Start DL Traffic for new Bearer    ${TC32_nsa_ue_id1}    ${TC32_nsa_ue_id4}   7    10
    Run Keyword and Continue on Failure    Multiple NSA UE Start UL Traffic for new Bearer    ${TC32_nsa_ue_id1}    ${TC32_nsa_ue_id4}   7    10
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File   output_dirpath=${OUTPUT DIR}/pmcounter1
    Verify Any Counters In File
    ...  M55115C03506  4  NSA_DU_DRB_NBR_REQ
    ...  M55115C03507  2  NSA_DU_DRB_NBR_ADMIT_WITH_NBR
    ...  M55115C03508  2  NSA_DU_DRB_NBR_ADMIT_NOT_NBR
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL_ID}
    ...  file_path=${pm_counter_file}
    Wait until the current Measurement Period stops
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File   output_dirpath=${OUTPUT DIR}/pmcounter2
    Verify Any Counters In File
    ...  M55115C03509  600  NSA_DU_DRB_NBR_DL
    ...  M55115C03510  600  NSA_DU_DRB_NBR_UL
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL_ID}
    ...  file_path=${pm_counter_file}
    Run Keyword And Continue on Failure   Link SCOUT SCF to Configuration ID for Reporting
    Multiple NSA UE Detach    ${TC32_nsa_ue_id1}    ${TC32_nsa_ue_id4}
    [Teardown]      Run Keywords
    ...             Perform SCF Delta Commissioning with ${TC32_revert_delta}
    ...             AND    Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
    ...             AND    Stop Log   btslog    snapshot    sosreport

CB008227-B#B2_TC20_NBR_Allocation_Exceed_UEs_NBR_Resource_limit
    [Documentation]   This user scenario describes NBR allocations exceed UE's NBR Resource limit.
    [Setup]      Testcase Setup   ${IPHY_FILE}   ${scf_TC20}   ${wts_cfg_file}   ${no_of_cells}
    ${TEST_NAME}    Set Variable   B_B2_TC20
    set suite variable     ${TEST_NAME}
    Start Log    btslog   cprt
    Attach UE with GBR/NBR/non-NBR
    Sleep    10s    reason=wait to trigger DL and UL data succesfully all UEs
    Validate DL UL Traffic For all UEs with NBRPRB 90%
    Modify NIDD parameters        MRBTS-1/NRBTS-1/NRCELL-1       update      maxPrbsPerNbrUe      10
    Sleep    10s
    Validate DL UL Traffic For all UEs with NBRPRB 10%
    ${path1}    Stop Log    cprt   test_scenario=UE_NBR
    Deregister UEs
    Stop Log   btslog
    [Teardown]    Run Keywords   Link SCOUT SCF to Configuration ID for Reporting
    ...           AND   common Teardown

CB008227-A#B1_TC2_Feature_flag_activation_Interface_message_verification
    [Documentation]   This user scenario describes the  verification of Interface message with feature flag during
    ...               1. cell setup, 2.Bearer setup,parameter range and PDL rule validations
    [Setup]      Testcase Setup   ${IPHY_FILE}   ${scf_TC2}   ${wts_cfg_file}   ${no_of_cells}
    ${TEST_NAME}    Set Variable   A_B1_TC2_3_4
    set suite variable     ${TEST_NAME}
#Step 1. Verifying feature activation in usersetup message with Full recommissioning
    log to console   TC2 Verifying feature activation in Full recommissioning
    Verify actNbrForNonGbrBearers In CellSetupReq
#Step 2. SA ue attach with NBR enabled
    log to console   UE attach trigerring now...
    Start Log    btslog   cprt   bip
    UE Register with ICS+PDU should be Successful   ${sa_ue_id1}
    ${path1}    Stop Log    cprt   test_scenario=bearersetup
#Step 3. Verifying NBR parameters in bearersetup message
    Verify nbrDrbSpecificParams In bearersetupreq   ${path1}[cprt]/NODECPRT_GNB.pcap   sctp    9955   9955
    MultiUE Trigger DL Traffic for SA    ${sa_ue_id1}  ${sa_ue_id1}   Traffic_rate=mbps     dl_rate=50        pdu_id=1     trf_id=1     qfi_id=1
    sleep     5s
    Validate DL Traffic For MultiUE for SA   ${sa_ue_id1}  ${sa_ue_id1}   dl_rate=50   pdu_id=1   qfi_id=1
    Stop MultiUE Data Traffic for SA     ${sa_ue_id1}    ${sa_ue_id1}
    MultiUE Deregister should be Successful   ${sa_ue_id1}    ${sa_ue_id1}
    Stop Log   btslog   bip
#Step 4. Deactivating feature with delta commissioning
    log to console   TC3_4 Verifying feature activation : Online modification SA + NSA
    Perform SCF Delta Commissioning with ${delta_commissioning_off_json}
    sleep   5s
    Start Log    btslog   cprt
#Step 5. Activating feature with delta commissioning
    Perform SCF Delta Commissioning with ${delta_commissioning_on_json}
    sleep   5s
#Step 6. SA ue attach with NBR enabled
    UE Register with ICS+PDU should be Successful   ${sa_ue_id1}
    MultiUE Trigger DL Traffic for SA    ${sa_ue_id1}  ${sa_ue_id1}   Traffic_rate=mbps     dl_rate=50        pdu_id=1     trf_id=1     qfi_id=1
    sleep     5s
    Validate DL Traffic For MultiUE for SA   ${sa_ue_id1}  ${sa_ue_id1}   dl_rate=50   pdu_id=1   qfi_id=1
    Stop MultiUE Data Traffic for SA     ${sa_ue_id1}    ${sa_ue_id1}
    MultiUE Deregister should be Successful   ${sa_ue_id1}    ${sa_ue_id1}
    sleep   5s
    X2AP Link Should be UP
    Multiple NSA UE Register   ${nsa_ue_id}    ${nsa_ue_id1}
    sleep     5s
    ${path2}    Stop Log    cprt   test_scenario=user_bearersetup
#Step 7. Verifying feature activation in usersetup & bearersetup message with online  modification
    Verify actNbrForNonGbrBearers In CellReconfigurationReq   ${path2}[cprt]/NODECPRT_GNB.pcap   sctp
    Verify nbrDrbSpecificParams In bearersetupreq   ${path2}[cprt]/NODECPRT_GNB.pcap   sctp    9955   9955
    Verify nbrDrbSpecificParams In usersetupreq   ${path2}[cprt]/NODECPRT_GNB.pcap   sctp    9955   9955
    Multiple NSA UE start and validate DL Traffic    ${nsa_ue_id}  ${nsa_ue_id1}   dl_rate=50
    Multiple NSA UE start and validate UL Traffic    ${nsa_ue_id}  ${nsa_ue_id1}   dl_rate=30
    sleep     5s
    Multiple NSA UE Detach   ${nsa_ue_id}  ${nsa_ue_id1}
    Stop Log   btslog
    [Teardown]    Run Keywords   Link SCOUT SCF to Configuration ID for Reporting
    ...           AND   common Teardown

CB008227-DA#B1_TC40_NBR congestion detection and handling with PDCCH DL only SANSA
    [Documentation]   This user scenario describes the gNB behavior related to NBR bearers
    ...               congestion detection and PDCCH DL congestion handling with PriorityLevel
    [Setup]      Testcase Setup   ${IPHY_FILE}   ${scf_TC40}   ${wts_cfg_file_TC40}   ${no_of_cells}
    ${TEST_NAME}    Set Variable   DA_B1_TC40
    set suite variable     ${TEST_NAME}
   log to console   UE attach trigerring now...
   X2AP Link Should be UP
   log to console   Wait for next PM to starts
   Wait until the next Measurement Period starts
   Start Log    btslog   cprt
   Attach multiple SA UEs with two NBR bearer traffic    ${sa_ue_id1}    ${sa_ue_id2}
   Perform SCF Delta Commissioning with ${Enable_congweight_json}
   Attach multiple SA UEs with two NBR bearer traffic    ${sa_ue_id3}    ${sa_ue_id4}
   Stop Log    cprt
   sleep   10s
   #Validate SA UEs Throughput
   log to console   Wait for next PM to stop
   Wait until the current Measurement Period stops
   ${pm_counter_file1}=    Get Next Unpacked Full Pm Counters File   output_dirpath=${OUTPUT DIR}/SA_PDCCH_Cong
   Verify Any Counters In File
    ...  M55139C03509  2400  SA_DU_DRB_NBR_DL
    ...  M55300C12010  > 800  ACC_DU_DRB_NBR_DL_DEPRIO_CONG
    ...  M55370C00041  > 1500  ACC_DU_DRB_NBR_UL_DEPRIO_CONG
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL_ID}
    ...  file_path=${pm_counter_file1}
   MultiUE Deregister should be Successful    ${sa_ue_id1}    ${sa_ue_id4}
   Stop Log    btslog
   Perform SCF Delta Commissioning with ${Disable_congweightjson}
   log to console   Wait for next PM stats
   Wait until the next Measurement Period starts
   Start Log    btslog   cprt
   X2AP Link Should be UP
   Multiple NSA UEs Register with NBR traffic   ${nsa_ue_id1}    ${nsa_ue_id2}
   Perform SCF Delta Commissioning with ${Enable_congweight_json}
   Multiple NSA UEs Register with NBR traffic   ${nsa_ue_id3}    ${nsa_ue_id4}
   Stop Log    cprt
   log to console   Wait for next PM to stop
   Wait until the current Measurement Period stops
   ${pm_counter_file2}=    Get Next Unpacked Full Pm Counters File   output_dirpath=${OUTPUT DIR}/NSA_PDCCH_Cong
   Verify Any Counters In File
    ...  M55115C03509  2400  NSA_DU_DRB_NBR_DL
    ...  M55300C12010  > 100  ACC_DU_DRB_NBR_DL_DEPRIO_CONG
    ...  M55370C00041  > 1500  ACC_DU_DRB_NBR_UL_DEPRIO_CONG
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL_ID}
    ...  file_path=${pm_counter_file2}
    Multiple NSA UE Detach   ${nsa_ue_id1}    ${nsa_ue_id4}
    Stop Log    btslog
    [Teardown]    Run Keywords   Link SCOUT SCF to Configuration ID for Reporting
    ...           AND   common Teardown

CB008227-E_B6_TC55_NBR_congestion_handling_with_multiBWPs_with_PowerSavingBWP
    [Documentation]   This user scenario describes behaviour of NBR congestion handling with multiple dedicated BWPs
    ...               with power saving BWP feature.
    [Setup]      Testcase Setup   ${IPHY_FILE_TC55}   ${scf_TC55}   ${wts_cfg_file_TC55}   ${no_of_cells}
    ${TEST_NAME}    Set Variable   E_B3_TC55
    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    Wait until the next Measurement Period starts
    Start Log    btslog
    Attach Multi-UE and trigger nNBR/VoNR/NBR data
    Verify PSBWP through TTI trace TC55
    Validate Throughput For UEs TC55
    Stop Log   btslog
    Wait until the current Measurement Period stops
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File   output_dirpath=${OUTPUT DIR}/pmcounter1
#Update counter values according to testing
    Verify Any Counters In File
    ...  M55139C03509  900  SA_DU_DRB_NBR_DL
    ...  M55300C12010  600  ACC_DU_DRB_NBR_DL_DEPRIO_CONG
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL_ID}
    ...  file_path=${pm_counter_file}
    MultiUE Deregister should be Successful   1   4
    [Teardown]    Run Keywords   Link SCOUT SCF to Configuration ID for Reporting
    ...           AND   common Teardown

CB008227-E_B7_TC56_NBR_IWK_DL_MUMIMO_Enhanced
    [Documentation]   This user scenario describes the gNB behavior that NBR service
    ...               works fine with enhanced DL MU-MIMO.
    [Setup]      Testcase Setup   ${IPHY_FILE_TC56}   ${scf_TC56}   ${wts_cfg_file_TC56}   ${no_of_cells_1}
    ${TEST_NAME}    Set Variable   E_B7_TC56
    Wait until the next Measurement Period starts
    Start Log    btslog   cprt
    Set UE1 and UE2 Pos
    #UE-1 with non-NBR bearer
    UE Register should be Success   ${ue_id1}   ${Pdu_ID}   ${nwslice_ID}   ${gw_ID}
    #UE-2 with NBR bearer
    UE Register should be Success   ${ue_id2}   ${Pdu_ID2}   ${nwslice_ID}   ${gw_ID}
    Modify PDU session for UE   ${ue_id2}   ${Pdu_ID2}
    Activate CSI Override command
    ${path1}    Stop Log    cprt   test_scenario=UE_NBR
    Send DL data to UEs and check throughput   ${ue_id1}   ${ue_id2}
    Start Log   ttitrace   ${cell_id_TC56}
    sleep   5s
    ${path2}   Stop Log   ttitrace   test_scenario=tti1
    Stop Log   btslog
    Verify DL_MUMIO Pairing     ${path2}
    Wait until the current Measurement Period stops
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File   output_dirpath=${OUTPUT DIR}/pmcounter1
#Update counter values according to testing
    Verify Any Counters In File
    ...  M55139C03509  300  SA_DU_DRB_NBR_DL
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL_ID}
    ...  file_path=${pm_counter_file}
    Deregister UEs TC56
    [Teardown]    Run Keywords   Link SCOUT SCF to Configuration ID for Reporting
    ...           AND   common Teardown

CB008227-EA#B1_TC64_NBR_congestion_handling_IWK_with_CB008954_3BWP
    [Documentation]   This user scenario describes behaviour of NBR congestion handling with CB008954 (3 BWPs)
    [Setup]      Testcase Setup   ${IPHY_FILE_TC64}   ${scf_TC64}   ${wts_cfg_file_TC64}   ${no_of_cells_1}
    ${TEST_NAME}    Set Variable   EA_B1_TC64
    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    Wait until the next Measurement Period starts
    Attach Multi-UE and trigger nNBR/NBR data
    Wait until the current Measurement Period stops
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File   output_dirpath=${OUTPUT DIR}/pmcounter1
    #Update counter values according to testing
    Verify Any Counters In File
    ...  M55139C03509  1800  SA_DU_DRB_NBR_DL
    ...  M55300C12010  >1000  ACC_DU_DRB_NBR_DL_DEPRIO_CONG
    ...  M55370C00041  >1000  ACC_DU_DRB_NBR_UL_DEPRIO_CONG
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL_ID}
    ...  file_path=${pm_counter_file}
    MultiUE Deregister should be Successful   ${start_ue_id} 	${end_ue_id}-1
    [Teardown]    Run Keywords   Link SCOUT SCF to Configuration ID for Reporting
    ...           AND   common Teardown

CB008227-C#B1_TC23_NBR bearers Exceed _Cells_NBR_max_amount_Limitation_with HPA_Initial Context Setup with PDU session
    [Documentation]
    ...              :author: Mundanad Vishnu
    ...              :contact: mundanad.vishnu@nokia.com
    ...
    ...             INTRODUCTION:     This user scenario describes the gNB behaviour for Admission control of NBR Non GBR DRB
    ...                               when NBR bearers Exceed Cells NBR max amount Limitation (SA) which is triggered by
    ...                               Initial Context Setup Request procedure with HPA
    ...             TEST SET NAME:    CB008227
    ...             TESTING SPLIT:    Refer CB008227 Test Plan
    ...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
    ...             REFERENCES:       CB008227 CFAM
    ...             Requirement ID:   5G_RAN_USR_RRM_20699

    [Setup]      Testcase Setup   ${IPHY_FILE}   ${scf_TC23}   ${wts_cfg_file}   ${no_of_cells}
    ${TEST_NAME}    Set Variable   C_B1_TC23
    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    Verify actNbrForNonGbrBearers In CellSetupReq
    Start Log    btslog   cprt
    Run Keyword And Continue On Failure       Link SCOUT SCF to Configuration ID for Reporting
    Register NBR UE and establish NBR Call      ${sa_ue_id1}
    sleep  5s
    ${path1}    Stop Log    cprt   test_scenario=bearersetupue1
    Verify nbrDrbSpecificParams In BearerSetupReq   ${path1}[cprt]/NODECPRT_GNB.pcap    sctp    300000   60000
    Start Log    cprt
    Register NBR UE and establish NBR Call      ${sa_ue_id2}
    sleep  5s
    ${path2}    Stop Log    cprt   test_scenario=bearersetupue2
    Verify nbrDrbSpecificParams In BearerSetupReq   ${path1}[cprt]/NODECPRT_GNB.pcap    sctp    300000   60000
    Start Log    cprt
    Attach NBR UE with HPA     ${sa_ue_id3}
    Sleep    5s    reason=wait to trigger DL and UL data succesfully
    ${path3}    Stop Log    cprt   test_scenario=bearersetuphpaue
    Verify nbrDrbSpecificParams In BearerSetupReq   ${path1}[cprt]/NODECPRT_GNB.pcap    sctp    300000   60000
    Validate DL UL Traffic For NBR UE TC23
    Deregister UEs TC23
    Stop Log   btslog
    [Teardown]   common Teardown

CB008227-C#B3_TC28_Support_Nominal_Bit_Rate_of_nonGBR_bearers_for_Intra-frequency_Inter_gNB_handover_SA
    [Documentation]
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

    [Setup]         Run Keywords      OperatingSystem.Run     sudo ip addr add 10.0.1.123/24 dev eth3
    ...                 AND     OperatingSystem.Run     sudo ip addr add 10.0.1.124/24 dev eth3
    ...                 AND     OperatingSystem.Run     sudo ip addr add 10.0.2.90/24 dev eth4
    ...                 AND     OperatingSystem.Run     sudo ip addr add 10.0.2.91/24 dev eth4
    ...                 AND    Testcase Setup   ${IPHY_FILE}   ${scf_TC28}   ${wts_cfg_file_TC31}   ${no_of_cells}
    ${TEST_NAME}    Set Variable   C_B1_TC28
    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
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
    MultiUE Trigger DL Traffic for SA    ${sa_ue_id1}  ${sa_ue_id2}   Traffic_rate=mbps     dl_rate=50        pdu_id=1     trf_id=1     qfi_id=1
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
    Validate DL Traffic For MultiUE for SA   ${sa_ue_id1}  ${sa_ue_id2}   dl_rate=50   pdu_id=1   qfi_id=1
    Stop MultiUE Data Traffic for SA     ${sa_ue_id1}    ${sa_ue_id2}
    MultiUE Deregister should be Successful   ${sa_ue_id1}    ${sa_ue_id2}
    Stop Log   btslog
    [Teardown]   common Teardown

CB008227-E#B3_TC49_Nominal_Bitrate_interworking_with_DL_CA_NSA
    [Documentation]     This user scenario describes Nominal Bitrate interworking with DL CA for NSA.
    ...             author:           Vishnu Mundanad
    ...             maintainer:       mundanad.vishnu@nokia.com
    ...
    ...             INTRODUCTION:     This user scenario describes Nominal Bitrate interworking with DL CA for NSA.
    ...                               2CC DL CA with NSA configured with below configuration :
    ...                               Cell 1 : TDD Cell, PCI-50, ChBW-60Mhz, Band-41, SCELL-1
    ...                               Cell 2 : FDD Cell, PCI-51, ChBW-10Mhz, Band-71, PCELL
    ...                               Step 1: Attach single NSA UE with 2CC capable and start data on nonGBR bearer
    ...                               Step 2: Add 1 NBR bearer to UE, verify CPRT for bearer addition and check throughput
    ...                               Step 3: Verify PM counters with resepect to NBR on both PCELL and SCELL
    ...                               Step 4: Detach NSA CA UE
    ...
    ...             TEST SET NAME:    CB008227
    ...             TESTING SPLIT:    Refer CB008227 Test Plan
    ...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
    ...             REFERENCES:       CB008227 CFAM
    ...             Requirement ID:   5G_RAN_USR_RRM_20682

    [Setup]      Testcase Setup   ${IPHY_FILE_TC49}   ${scf_TC49}   ${wts_cfg_file_TC49}   ${no_of_cells}
    ${TEST_NAME}    Set Variable   C_B1_TC28
    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    X2AP Link Should be UP
    Enable ENDC for all Bearer
    Start Log    cprt
    Perform SCF Delta Commissioning with ${delta_commissioning_on_json}
    sleep     10s
    ${cprt_log}     Stop Log  cprt  test_scenario=cellsetup
    Verify actNbrForNonGbrBearers In CellReconfigurationReq     ${cprt_log}[cprt]/NODECPRT_GNB.pcap      sctp
    Wait until the next Measurement Period starts
    log to console   "NSA UE attach trigerring now"
#Step 1. Attach NSA CA UE
    Run Keyword And Continue On Failure       Link SCOUT SCF to Configuration ID for Reporting
    NSA CA UE Register    ${nsa_ue_id49}
    sleep     10s
    Trigger High DL Traffic for NSA   ue_id=${nsa_ue_id49}     Traffic_rate=Mbps     dl_rate=${400}       bearer_id=${2}
    Start Log    cprt
    Add new LTE Bearer for NSA CA UE    ${nsa_ue_id49}    7     7
    sleep   2s
    ${path2}    Stop Log    cprt   test_scenario=bearersetup
    Verify nbrDrbSpecificParams In bearersetupreq   ${path2}[cprt]/NODECPRT_GNB.pcap
    ...         itf_l2_ps_user_BearerSetupReq_t.nrCellIdentity == 16386    300000   30000
    Verify nbrDrbSpecificParams In bearersetupreq for Scells   ${path2}[cprt]/NODECPRT_GNB.pcap
    ...         itf_l2_ps_user_BearerSetupReq_t.nrCellIdentity == 16385    300000
    Run Keyword and Continue on Failure    NSA CA UE Start DL Traffic for new Bearer    ${nsa_ue_id49}   7    400
    sleep   60s
    Validate DL Traffic For NSA CA UE

#Validate PM counters in Pcell and Scell
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File   output_dirpath=${OUTPUT DIR}/pmcounter1
    Verify Any Counters In File
    ...  M55115C03506  1  NSA_DU_DRB_NBR_REQ
    ...  M55115C03507  1  NSA_DU_DRB_NBR_ADMIT_WITH_NBR
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL_ID1}
    ...  file_path=${pm_counter_file}
    Verify Any Counters In File
    ...  M55115C03506  1  NSA_DU_DRB_NBR_REQ
    ...  M55115C03507  1  NSA_DU_DRB_NBR_ADMIT_WITH_NBR
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL_ID2}
    ...  file_path=${pm_counter_file}
    Wait until the current Measurement Period stops
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File   output_dirpath=${OUTPUT DIR}/pmcounter2
    Verify Any Counters In File
    ...  M55115C03509  300  NSA_DU_DRB_NBR_DL
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL_ID1}
    ...  file_path=${pm_counter_file}
    Verify Any Counters In File
    ...  M55115C03509  300  NSA_DU_DRB_NBR_DL
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL_ID2}
    ...  file_path=${pm_counter_file}
    Stop Data Traffic for NSA    ${nsa_ue_id49}
    NSA CA UE Detach    ${nsa_ue_id49}
    [Teardown]   common Teardown

CB008227-E#B7_TC57_NBR_interworking_with_MU_MIMO_UL
    [Documentation]  This user scenario describes behaviour of NBR IWK with MU MIMO.
    ...             author:           Manasa
    ...             maintainer:       manasa.shankarappa@nokia.com
    ...
    ...             INTRODUCTION:     This user scenario describes behaviour of NBR IWK with MU MIMO.
    ...
    ...             TEST SET NAME:    CB008227
    ...             TESTING SPLIT:    Refer CB008227 Test Plan
    ...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
    ...             REFERENCES:       CB008227 CFAM
    ...             Requirement ID:   5G_RAN_USR_RRM_xxxxx

    [Setup]    Run keywords
    ...   Prepare TL with all config files New    ${SCFC_TC57}    ${AP_XML_TC57}
    ...        AND     Get and Update BSR SW via gitlab   ${BSR_SW_FILE}
    ...        AND     Start Log   btslog
    ...        AND     Start WTS Using WTS_Runner      ${wts_cfg_file_TC57}
    ...        AND     sleep   2s
    ${TEST_NAME}    Set Variable   EA_B7_TC57
    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    Set Test Variable     ${CELL_ID}   1
    sleep    160s
    Wait until the next Measurement Period starts
    log to console   "SA UE attach with NBR Bearers are trigerring now"
#Step 1. Attach SA UE's with 1 default Bearer and 3 NBR Beareres
    Start Log    cprt
    ${rnti_list}   MultiUE Register should be Successful    ${TC57_sa_ue_id1}     ${TC57_sa_ue_id3}
    sleep     2s
    Log to console   ${rnti_list}
    Add new Bearer for Multiple SA UE    ${TC57_sa_ue_id1}    ${TC57_sa_ue_id1}    ${Pdu_session_ID}    ${QFI_ID4}
    ${path1}    Stop Log    cprt   test_scenario=usersetup
    MultiUE Trigger UL Traffic for SA   ${TC57_sa_ue_id1}    ${TC57_sa_ue_id1}    Traffic_rate=mbps   ul_rate=150
    ...   pdu_id=1     trf_id=1     qfi_id=2
    MultiUE Trigger UL Traffic for SA   ${TC57_sa_ue_id2}    ${TC57_sa_ue_id3}    Traffic_rate=mbps   ul_rate=150
    ...   pdu_id=1     trf_id=1     qfi_id=1
    sleep   2s
    Set And Activate Srs beam position   ${TC57_sa_ue_id1}    ${TC57_sa_ue_id3}
    sleep   10s
    Validate UL Traffic For all UEs   42   42   42
#   Validate UL MuMIMO Pairing either in TTI or BIP traces
    Start Log   biptaf
    Sleep   10s
    ${bip_path1}   Stop Log    biptaf    test_scenario=UL_MuMIMO
    Verify UE Pairing     ${bip_path1}[biptaf]/BIP_L1L2.pcap   ${rnti_list}
#Check Counters
    Wait until the current Measurement Period stops
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File   output_dirpath=${OUTPUT DIR}/pmcounter1
    Verify Any Counters In File
    ...  M55139C03509  300  SA_DU_DRB_NBR_DL
    ...  M55139C03510  300  SA_DU_DRB_NBR_UL
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-2/NRCELL-${CELL_ID}
    ...  file_path=${pm_counter_file}
    Run Keyword And Continue on Failure    Link SCOUT SCF to Configuration ID for Reporting
    MultiUE Deregister should be Successful    ${TC57_sa_ue_id1}    ${TC57_sa_ue_id3}
    [Teardown]   Run keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
    ...          AND     Stop Log   btslog    snapshot    sosreport

CB008227-E#B1_TC42_NBR_interworking_with_slice_Aware_Scheduler
    [Documentation]
    ...
    ...             author:           Manasa
    ...             maintainer:       manasa.shankarappa@nokia.com
    ...
    ...             INTRODUCTION:     This user scenario describes the gNB behavior that slice aware scheduler
    ...                               works fine with NBR services
    ...                                     SLICE       MINquota    Maxquota    PLMN
    ...                               UE1   SNSSAI-1    30          80          311,489
    ...                               UE2   SNSSAI-2    20          20          311,490
    ...                               UE3   SNSSAI-3    40          60          311,491
    ...
    ...                               Bearer1: 5QI-6 : NRDRB_MAC-5 : NBR Bearer, nbrdl: 200 , nbrul: 40, PLMN1: 311,489
    ...                               Bearer2: 5QI-7 : NRDRB_MAC-2 : nonGBR Bearer, PLMN2: 311,490
    ...                               Bearer2: 5QI-8 : NRDRB_MAC-2 : nonGBR Bearer, PLMN3: 311,491
    ...
    ...                               NRDRB-1 ---> NRDRB_MAC-1 : nbrdl: 100 , nbrul: 40
    ...
    ...                               UE1 with 5QI-6 and 5QI-7
    ...                               UE2 with 5QI-6 and 5QI-7
    ...                               UE3 with 5QI-6 and 5QI-7
    ...
    ...                               NRDRB-1 ---> NRDRB_MAC-1 : nbrdl: 100 , nbrul: 40
    ...                               UE1
    ...                               5QI-6 ---> nrDrbDN:NRDRB-11 --> nrDrbMacDN: NRDRB_MAC-5(with nbr configuration)
    ...                               5QI-7 ---> use default: NRDRB-1 due to cannot find nrDrb5Qi for 5QI: 7
    ...
    ...                               UE2
    ...                               5QI-6 ---> use default: NRDRB-1 due to cannot find nrDrb5Qi for 5QI: 6
    ...                               5QI-7 ---> nrDrbDN:NRDRB-12 --> nrDrbMacDN: NRDRB_MAC-2 (without nbr cofiguration)
    ...
    ...                               UE3
    ...                               5QI-6 ---> use default: NRDRB-1 due to cannot find nrDrb5Qi for 5QI: 6
    ...                               5Qi-7 ---> use default: NRDRB-1 due to cannot find nrDrb5Qi for 5QI: 7
    ...
    ...
    ...
    ...             TEST SET NAME:    CB008227
    ...             TESTING SPLIT:    Refer CB008227 Test Plan
    ...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
    ...             REFERENCES:       CB008227 CFAM
    ...             Requirement ID:   5G_RAN_USR_RRM_xxxxx

    [Setup]   Run keywords
    ...       Prepare TL with all config files New    ${SCFC_TC42}    ${AP_XML_TC42}
    ...        AND     Start Log   btslog
    ...        AND     Start WTS Using WTS_Runner      ${wts_cfg_file_TC42}
    ...        AND     sleep   2s
    ${TEST_NAME}    Set Variable   EA_B1_TC42
    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    Set Test Variable     ${CELL_ID}   3
    Wait until the next Measurement Period starts
    log to console   "SA UE attach with NBR Bearers are trigerring now"
#Step 1. Attach SA UE's with 1 default Bearer and 3 NBR Beareres
    Start Log    cprt
    MultiUE Register should be Successful with diff slice    ${sa_ue_id1}     ${sa_ue_id3}
    sleep     2s
    Add new Bearer for Multiple SA UE    ${sa_ue_id1}    ${sa_ue_id3}    ${Pdu_session_ID}    ${QFI_ID2}
    ${path1}    Stop Log    cprt   test_scenario=usersetup
    MultiUE Trigger DL Traffic for SA   ${sa_ue_id1}    ${sa_ue_id3}    Traffic_rate=mbps   dl_rate=150
    ...   pdu_id=1     trf_id=1     qfi_id=1
    MultiUE Trigger UL Traffic for SA   ${sa_ue_id1}    ${sa_ue_id3}    Traffic_rate=mbps   ul_rate=150
    ...   pdu_id=1     trf_id=1     qfi_id=1
    sleep   10s
    Validate DL Traffic For all UEs TC42   86   40    85
    Validate UL Traffic For all UEs TC42   80   51    80
    Wait until the current Measurement Period stops
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File   output_dirpath=${OUTPUT DIR}/pmcounter1
#Update counter values according to testing
    Verify Any Counters In File
    ...  M55139C03509  1500  SA_DU_DRB_NBR_DL
    ...  M55139C03510  1500  SA_DU_DRB_NBR_UL
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL_ID}
    ...  file_path=${pm_counter_file}
    Run Keyword and Continue on Failure   Link SCOUT SCF to Configuration ID for Reporting
    MultiUE Deregister should be Successful    ${sa_ue_id1}    ${sa_ue_id3}
    [Teardown]   Run keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
    ...          AND     Stop Log   btslog    snapshot    sosreport
