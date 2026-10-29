*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
# Test Setup           SISO Coam Test Setup
# Test Teardown        SISO Coam Test Teardown
Test Timeout         2h

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG5/robot/optical_switch/optical_switch.robot
Resource      ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource      ${BASIC_PATH_5G}/BTS/Manual_SiSo_SM_NR_RAT_reset.robot
Resource      ${BASIC_PATH_5G}/Cell/E2E_SiSo_Cell_block_and_unblock_gNB.robot
Resource      ${BASIC_PATH_5G}/BTS/General_SiSo_RAT_Block_Unblock.robot
Resource      ${BASIC_PATH_5G}/General_SiSo_RF_alarms_with_recovery.robot
Resource      testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB009074_AEQV/Resource/CB009074_Common_KW.robot
Resource      testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/5GC001866/Resource/5GC001866-K_Common_KW.robot
Resource      testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB014138/Resource/CB014138_Common_KW.robot
Resource      testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB008952_SG05/resource/resource.robot

Documentation
...    Author: Zhang Xuewen
...    Contact: xuewen.zhang@nokia-sbell.com
...    squad group:SG_05
...
...    Feature CB015690: AVQO AirScale MAA 32T32R 256AE n78 320W in SBTS26R1 program

Force Tags    RAN_5G    RAN_5G_TDD    STATE_SW_UPLOADED    SBTS00    PY310    master_classicalbts_all


*** Variables ***
${File_path}      /home/ute/TA/BSR/BSR_AVQO-3400_Beamset#6_180AzOp_N01_N07_P00_P07_8Rx_IRC_Muting.zip


*** Test Cases ***
[1]CB015690-Manual_SiSo_Extreme_Deep_Sleep_RU_cells_lock_unlock_with_L3call
    [Tags]    3S-4CC_CB015690-AVQO    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    Log To Console    \n Start to run Extreme Deep Sleep RU cells lock unlock with L3call test case
    RU_returning_from_SLEEP_EXTREME_to_normal_operation_due_to_at_least_one_cell_unlocked
    # ${cell_list}    create list    ${1}
    # ${if_cpe3.2}    Run Keyword And Return Status   Should Contain Any   ${tl.ues[0].version}   3.2   cpe3.2   ignore_case=true
    # Run Keyword If    ${if_cpe3.2}    Get UE From Init File and Make call with cpe 3_2    cell_list=${cell_list}   with_peak=${False}
    # ...    ELSE   Get UE From Init File and Make call    cell_list=${cell_list}    with_peak=${False}    duration=${300}
    [Teardown]    SISO Coam Test Teardown

[1]CB015690-SR-A-General_SiSo_RAT_Reset
    [Tags]    3S-4CC_CB015690-AVQO    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    Manual_SiSo_SM_NR_RAT_reset    bbmod_index=${2}    with_call=${False}
    [Teardown]    SISO Coam Test Teardown

[1]CB015690-General_SiSo_RF_alarms_with_autonomous_reset
    [Tags]    3S-4CC_CB015690-AVQO    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    General_SiSo_RF_alarms_with_recovery    ru_index=${1}
    [Teardown]    SISO Coam Test Teardown

[1]CB015690-General_SiSo_SFP_lock_unlock_for_configuration_testing
    [Tags]    3S-4CC_CB015690-AVQO    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    optical_switch.General_SiSo_SFP_lock_unlock_for_configuration_testing    bbmode_id=${2}    is_optical_switch=${False}
    [Teardown]    SISO Coam Test Teardown
    # [Teardown]    Run Keywords    Run Keyword And Ignore Error   Connect to gnb coam via ssl
    # ...    AND    Commissioning SCF And Check On Air    scf_path=${Golden_SCF_Path}
    # ...    AND    SISO Coam Test Teardown

[1]CB015690-Manual_SiSo_TEST_RF_Sniffing_RF_Scanning_5G
    [Tags]    3S-2CC_CB015690-AVQO    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    #AVQO does not support Split Mode
#    Set RF to Split Mode   ru_index=${1}    ru_type=32TRX
#    All_RF_scan_test_with_Split_mode_in_online_mode   ru_index=${1}    antenna_panel=PHYANT-1 Top Array
    Set RF to Full Mode   ru_index=${1}    ru_type=32TRX
    All_RF_scan_test_with_full_mode_in_online_mode    ru_index=${1}    antenna_panel=PHYANT-1 Full Array
    [Teardown]    SISO Coam Test Teardown

[1]CB015690-General_SiSo_custom_beam_set_realization_to_gNB
    [Tags]    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    #${fault_list}    Create List    ${7529}
    #Allowed Watchdog additional alarms    fault_list=${fault_list}
    #"Step1" Download BSR package
    Log To Console    Step1 Download BSR package
    selenium_coam.load_software_package_from_local_drive    file_path=${File_path}
    sleep    3s
    selenium_coam.software_update    is_activate=${True}
    "Step2" Enable feature 1866
    "Step3" Activate BSR through WebEM
    "Step4" Check gNB and Cell onAir
    "Step5" Check Inused BSR
    "Step6" Check If there is new alarm
    [Teardown]    SISO Coam Test Teardown
    # [Teardown]    Run Keywords    Run Keyword And Ignore Error   Connect to gnb coam via ssl
    # ...    AND    Commissioning SCF And Check On Air    scf_path=${Golden_SCF_Path}
    # ...    AND    SISO Coam Test Teardown
