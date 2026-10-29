*** Settings ***
Force Tags      CLOUD_5G_O_E_AP_LOOO   CRT  RAN_5G    5G_RAN_TDD    5G_RAN   SBTS00    CONFIGURED

Documentation    :copyright: Nokia
...              :author: Mohan
...              :contact: mohanavel.p@nokia.com
...
...             INTRODUCTION:     The test case scenario checks that a UE with a GBR bearer should
...                               send/receive scheduling priority for GBR traffic over non-GBR data
...                               transmissions from other UEs, with exhaustive scheduling enabled in RAT1.
...             TEST SET NAME:    CB014861
...             TESTING SPLIT:    Refer CB014861 Test Plan
...             CONTACTS:         I_MN_RAN_RD_VRF_BLR1_T11@internal.nsn.com
...             REFERENCES:       CB014861 CFAM
...             Requirement ID:   12548522,12534363,12535184,12535272,12535591


Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../../../resources/robot/Setup_Env.robot
Resource         ../../../resources/robot/Airphone.robot
Resource         ../../../resources/robot/WTS_Runner_Keywords.robot
Resource         ../../../resources/ECEcommon/common_setup_teardown.robot
Resource         ./resources/common_Resource.robot
Resource         ./resources/common_keywords.robot
#Library          ../../../resources/python/BIP_Capture.py
#Library          ../../../resources/python/CPRT_Capture.py
Resource         ../../../resources/robot/configuration_id.robot

Suite Setup         Run keywords    Suite setup from scratch
...                 AND     Modify IPHY File And Send to Airphone Custom    ${iphy_file_TC56}
...                 AND     Update bsr package
...                 AND     gnb.Perform gNB reboot
...                 AND     sleep    180s


*** Test Cases ***
USCB014861_A_B4_Multiple_UEs_with_multiple_DRBs_VoNR_5QI2_and_nonGBR_with_DL_RAT1
    [Documentation]   The test case scenario checks that a UE with a GBR bearer should
     ...              send/receive scheduling priority for GBR traffic over non-GBR data
     ...              transmissions from other UEs, with exhaustive scheduling enabled in RAT1.
    [Setup]      Testcase setup with delta Commissioning   ${TC04_delta_file_name}   ${wts_cfg_file_TC56}   ${no_of_cells_TC56}
#Disabled Exhaustive scheduling
    ${TEST_NAME}    Set Variable   CB014861_A_SUMIMO
    set suite variable     ${TEST_NAME}
    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    Wait until the next Measurement Period starts
    Start Log    btslog
#Step-1 Attach 30 UEs 5QI-7 for UE10-20,5QI-1,2&7 with different tcp traffic profile to TDD cell-1
    Attach 30 UEs with multiple PDU session
    sleep    20s
    Check UEs for zero traffic
    Start Log   ttitrace    cell_id=@{phy_id_tc56}
    sleep   5s
    ${path1}   Stop Log   ttitrace   test_scenario=wrr_scheduling
    Stop Log   btslog
    Wait until the current Measurement Period stops
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File   output_dirpath=${OUTPUT DIR}/pmcounter1
    ${ACC_SCHED_UE_PDSCH_WRR}=  ta5g_pm_counters.Get Pm Counter Value  ${ACC_SCHED_UE_PDSCH}  ${local_moid}-${CELL_ID}    ${pm_counter_file}
    Detach UEs   ${es_start_ue}   ${es_end_ue}
#Enabling Exhaustive scheduling
    Send Delta Commissioning    ${enable_exhaustive_scheduling}
    Wait until the next Measurement Period starts
#Step-1 Attach 30 UEs 5QI-7 for UE10-20,5QI-1,2&7 with different tcp traffic profile to TDD cell-1
    Attach 30 UEs with multiple PDU session
    Start Log    btslog
    sleep    20s
    Check UEs for zero traffic
    Start Log   ttitrace    cell_id=@{phy_id_tc56}
    sleep   5s
    ${path1}   Stop Log   ttitrace   test_scenario=es_scheduling
    Stop Log   btslog
    Wait until the current Measurement Period stops
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File   output_dirpath=${OUTPUT DIR}/pmcounter2
    ${ACC_SCHED_UE_PDSCH_ES}=  ta5g_pm_counters.Get Pm Counter Value  ${ACC_SCHED_UE_PDSCH}  ${local_moid}-${CELL_ID}    ${pm_counter_file}
    Detach UEs   ${es_start_ue}   ${es_end_ue}
#final check scheduled UE per slot will decrease with feature activation (expected)
    Run Keyword and continue on Failure     should be true  ${ACC_SCHED_UE_PDSCH_ES} < ${ACC_SCHED_UE_PDSCH_WRR}
    [Teardown]      Run Keywords
    ...             Run Keyword And Continue on Failure    Link SCOUT SCF to Configuration ID for Reporting
    ...             AND    Send Delta Commissioning     ${TC04_revert_changes}


USCB014861_B_B2_Exhaustive_scheduling_SUMIMO_MUMIMO_UEs_nonGBR_GBR_multiBWP
    [Documentation]   This case is to verify Exhaustive scheduling and FDM of multiple SU and MU-MIMO users
     ...              in the same slot in a cell configured with several BWP. The maximum DL layers can be
     ...              reached to 16. The DL slots are with or without common channels scheduling. For the slots
     ...              with common channels (SIB/Paging/OSI) or with users scheduled with DCI_1_0 (RA-msg2/msg4/Type-3 CSS messages)
     ...              the channel BW/dedicated BWP is fragmented into PDSCH sub-areas. The slots without
     ...              common channels or DCI_1_0 scheduling, there are no PDSCH sub-areas.
    [Setup]      Testcase setup with delta Commissioning   ${TC02_delta_file_name}   ${wts_cfg_file_TC56}   ${no_of_cells_TC56}
#Disabled Exhaustive scheduling
    ${TEST_NAME}    Set Variable   CB014861_B_MUMIMO
    set suite variable     ${TEST_NAME}
    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    Wait until the next Measurement Period starts
    Start Log    btslog
#Step-1 Attach 20 UEs(10:5QI-7,10:VoNR) tcp traffic profile to TDD cell-1
    Attach 20 UEs with multiple PDU session
    sleep    20s
    Check 20 UEs for zero traffic
    Start Log   ttitrace    cell_id=@{phy_id_tc56}
    sleep   3s
    ${path1}   Stop Log   ttitrace   test_scenario=wrr_mu_scheduling
    Stop Log   btslog
    Wait until the current Measurement Period stops
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File   output_dirpath=${OUTPUT DIR}/mu_pmcounter1
    ${ACC_SCHED_UE_PDSCH_WRR}=  ta5g_pm_counters.Get Pm Counter Value  ${ACC_SCHED_UE_PDSCH}  ${local_moid}-${CELL_ID}    ${pm_counter_file}
    ${MU_MIMO_PAIR_DL_SUCC_WRR}=  ta5g_pm_counters.Get Pm Counter Value  ${MU_MIMO_PAIR_DL_SUCC}  ${local_moid}-${CELL_ID}    ${pm_counter_file}
    Verify Any Counters In File
    ...  ${SA_DU_DRB_NBR_DL}   3000  SA_DU_DRB_NBR_DL
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL_ID}
    ...  file_path=${pm_counter_file}
    Detach UEs   ${es_mu_start_ue}   ${es_mu_end_ue}
#Enabling Exhaustive scheduling
    Send Delta Commissioning    ${enable_exhaustive_scheduling}
    Wait until the next Measurement Period starts
    Start Log    btslog
#Step-1 Attach 20 UEs(10:5QI-7,10:VoNR) tcp traffic profile to TDD cell-1
    Attach 20 UEs with multiple PDU session
    sleep    20s
    Check 20 UEs for zero traffic
    Start Log   ttitrace    cell_id=@{phy_id_tc56}
    sleep   3s
    ${path2}   Stop Log   ttitrace   test_scenario=es_mu_scheduling
    Stop Log   btslog
    Wait until the current Measurement Period stops
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File   output_dirpath=${OUTPUT DIR}/mu_pmcounter2
    ${ACC_SCHED_UE_PDSCH_ES}=  ta5g_pm_counters.Get Pm Counter Value  ${ACC_SCHED_UE_PDSCH}  ${local_moid}-${CELL_ID}    ${pm_counter_file}
    ${MU_MIMO_PAIR_DL_SUCC_ES}=  ta5g_pm_counters.Get Pm Counter Value  ${MU_MIMO_PAIR_DL_SUCC}  ${local_moid}-${CELL_ID}    ${pm_counter_file}
    Verify Any Counters In File
    ...  ${SA_DU_DRB_NBR_DL}   3000  SA_DU_DRB_NBR_DL
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL_ID}
    ...  file_path=${pm_counter_file}
    Detach UEs   ${es_mu_start_ue}   ${es_mu_end_ue}
#final check scheduled UE per slot will decrease with feature activation (expected)
    Run Keyword and continue on Failure     should be true  ${ACC_SCHED_UE_PDSCH_ES} < ${ACC_SCHED_UE_PDSCH_WRR}
    Run Keyword and continue on Failure     should be true  ${MU_MIMO_PAIR_DL_SUCC_ES} < ${MU_MIMO_PAIR_DL_SUCC_WRR}
    [Teardown]      Run Keywords
    ...             Run Keyword And Continue on Failure    Link SCOUT SCF to Configuration ID for Reporting
    ...             AND    Send Delta Commissioning     ${TC02_revert_changes}


