*** Settings ***
Force Tags      CLOUD_5G_I_LOO_AP_LOOO   CRT  RAN_5G    5G_RAN_TDD    5G_RAN   SBTS00    CONFIGURED

Documentation    :copyright: Nokia
...              :author: Mohan
...              :contact: mohanavel.p@nokia.com
...
...             INTRODUCTION:     This user scenario is to verify the interworking of DL CA (e.g 2CCs (T+T)
...                               or 3CCs (T+T+T)) and DL Exhaustive Scheduling introduced by CB014861 by
...                               utilizing the functionalities of DL BF gain synchronization between Pcell
...                               and Scell(s) with multiple UEs which is introduced in CB008898
...             TEST SET NAME:    CB014861
...             TESTING SPLIT:    Refer CB014861 Test Plan
...             CONTACTS:         I_MN_RAN_RD_VRF_BLR1_T11@internal.nsn.com
...             REFERENCES:       CB014861 CFAM
...             Requirement ID:   12567230


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
...                 AND     Modify IPHY File And Send to Airphone Custom    ${iphy_file_iwk12}
...                 AND     gnb.Perform gNB reboot
...                 AND     sleep    200s


*** Test Cases ***
USCB014861-C#IWK12_Interworking with DL CA
    [Documentation]   Verify the interworking of DL CA (e.g 2CCs (T+T)
    ...               or 3CCs (T+T+T)) and DL Exhaustive Scheduling introduced by CB014861 by
    ...               utilizing the functionalities of DL BF gain synchronization between Pcell
    ...               and Scell(s) with multiple UEs which is introduced in CB008898
    [Setup]      Testcase setup with delta Commissioning   ${iwk12_delta_file_name}   ${wts_cfg_file_iwk12}   ${no_of_cells}
#Disabled Exhaustive scheduling
    ${TEST_NAME}    Set Variable   CB014861_C_DLMUMIMO_CA
    set suite variable     ${TEST_NAME}
    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    Wait until the next Measurement Period starts
    Start Log    btslog
#Step-1 Attach 20 UEs with DL CA + MUMIMO Pairing to TDD cell-1
    Attach 20 UEs with dedicated PDU session
    sleep    60s
    Check UEs scells for zero traffic
    Stop Log   btslog
    Wait until the current Measurement Period stops
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File   output_dirpath=${OUTPUT DIR}/pmcounter1
    ${ACC_SCHED_UE_PDSCH_WRR}=  ta5g_pm_counters.Get Pm Counter Value  ${ACC_SCHED_UE_PDSCH}  ${local_moid}-${CELL_ID}    ${pm_counter_file}
    ${MU_MIMO_PAIR_DL_SUCC_WRR}=  ta5g_pm_counters.Get Pm Counter Value  ${MU_MIMO_PAIR_DL_SUCC}  ${local_moid}-${CELL_ID}    ${pm_counter_file}
    Detach UEs   ${es_ca_start_ue}   ${es_ca_end_ue}
#Enabling Exhaustive scheduling
    Send Delta Commissioning    ${enable_exhaustive_scheduling}
    Wait until the next Measurement Period starts
#Step-1 Attach 20 UEs with DL CA + MUMIMO Pairing to TDD cell-1
    Start Log    btslog
    Attach 20 UEs with dedicated PDU session
    sleep    60s
    Check UEs scells for zero traffic
    Wait until the current Measurement Period stops
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File   output_dirpath=${OUTPUT DIR}/pmcounter2
    ${ACC_SCHED_UE_PDSCH_ES}=  ta5g_pm_counters.Get Pm Counter Value  ${ACC_SCHED_UE_PDSCH}  ${local_moid}-${CELL_ID}    ${pm_counter_file}
    ${MU_MIMO_PAIR_DL_SUCC_ES}=  ta5g_pm_counters.Get Pm Counter Value  ${MU_MIMO_PAIR_DL_SUCC}  ${local_moid}-${CELL_ID}    ${pm_counter_file}
    Detach UEs   ${es_ca_start_ue}   ${es_ca_end_ue}
#final check scheduled UE per slot will decrease with feature activation (expected)
    Run Keyword and continue on Failure     should be true  ${ACC_SCHED_UE_PDSCH_ES} < ${ACC_SCHED_UE_PDSCH_WRR}
    Run Keyword and continue on Failure     should be true  ${MU_MIMO_PAIR_DL_SUCC_ES} < ${MU_MIMO_PAIR_DL_SUCC_WRR}
    [Teardown]      Run Keywords
    ...             Run Keyword And Continue on Failure    Link SCOUT SCF to Configuration ID for Reporting
    ...             AND    Send Delta Commissioning     ${iwk12_revert_changes}
