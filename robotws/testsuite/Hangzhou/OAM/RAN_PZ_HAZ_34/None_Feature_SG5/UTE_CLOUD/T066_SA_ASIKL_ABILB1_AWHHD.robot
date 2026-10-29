*** Settings ***
Suite Setup       SISO Coam Suite Setup
Suite Teardown    SISO Coam Suite Teardown
Test Setup
Test Teardown
Test Timeout      120 minutes

Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource     ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
#Resource     ${BASIC_PATH_5G}/General_Stability_Test_Case.robot
#Resource     ${BASIC_PATH_5G}/General_SiSo_RF_module_addition_in_BIM_and_WebUI.robot
#Resource     ${BASIC_PATH_5G}/General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot.robot
#Resource     ${BASIC_PATH_5G}/General_SiSo_SOAP_RP1_verification.robot
#Resource     ${BASIC_PATH_5G}/General_SiSo_RF_module_reset_from_GUI.robot
#Resource     ${BASIC_PATH_5G}/Cell/General_SiSo_Cell_lock_and_unlock.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource     testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/coam_resource.robot
#Resource     testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/5GC000470/Resource/5GC000470-E-5GC001082_common_KW.robot
#Resource     testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/5GC001178-A/Resource/5GC001178-A-5GC001082_common_KW.robot
Resource     Resource/T066_KW.robot
Resource     testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB009336/resource/CB009336_Common_KW.robot
Resource     testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB008278_B/resource/CB008278_Common_KW.robot
#Variables    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/5GC000470/TestData/variables.py

Resource     testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB006277/resource/resources_l3call.robot
Resource     testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB008952_SG05/resource/resource.robot
Resource     ${BASIC_PATH_5G}/E2E_SiSo_RU_lock_and_unlock_gNB.robot
#Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
#Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/cell_addition_deletion_online.robot
Resource     testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB009077/resource/CB009077_Common_KW.robot

Documentation
...    author: hu annie
...    contact: annie.hu@nokia-sbell.com
...    squad group: SG_05
...    CLOUD_5G_CLASSICAL_SA_ASIKL_ABILB1_AWHHD in TRUNK program

Force Tags    RAN_5G    RAN_5G_TDD    STATE_SW_UPLOADED    SBTS00    PY310    master_classicalbts_all

*** Variables ***
#${package_target_version}    SBTS00_ENB_9999_221227_000005
${total_loops}      ${3}
@{fault_list}       61074

*** Test Cases ***
### part-1: 5GC000470_N_5GC001541 - 7 TCs ###
#[1][1.0] 5GC000470-N-I&V-5GC001541_37_AWHHD_General_SiSo_RF_module_addition_in_BIM_and_WebUI
#    [Tags]    CLOUD_5G_CLASSICAL_SA_ASIKL_ABILB1_AWHHD   CRT_UTE
#    [Setup]    SISO Coam Test Setup
#    [Teardown]    SISO Coam Test Teardown
#    General_SiSo_RF_module_addition_in_BIM_and_WebUI

#[1][1.0] 5GC000470-N-I&V-5GC001541_35_AWHHD_General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
#    [Tags]    CLOUD_5G_CLASSICAL_SA_ASIKL_ABILB1_AWHHD   CRT_UTE
#    [Setup]    SISO Coam Test Setup
#    [Teardown]    SISO Coam Test Teardown
#    General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot

#[1][1.0] 5GC000470-N-I&V-5GC001541_31_AWHHD_General_SiSo_SOAP_RP1_verification
#    [Tags]    CLOUD_5G_CLASSICAL_SA_ASIKL_ABILB1_AWHHD   CRT_UTE
#    [Setup]    SISO Coam Test Setup
#    [Teardown]    SISO Coam Test Teardown
#    General_SiSo_SOAP_RP1_verification

#[1][1.0] 5GC000470-N-I&V-5GC001541_27_AWHHD_General_SiSo_Cell_lock_and_unlock (under creation)
#    [Tags]    CLOUD_5G_CLASSICAL_SA_ASIKL_ABILB1_AWHHD   CRT_UTE
#    [Setup]    SISO Coam Test Setup
#    [Teardown]    Run Keywords   Perform cell unlock via rest api    AND
#    ...    wait until keyword succeeds    3min    10s    Verify all cells should be onair    AND
#    ...    SISO Coam Test Teardown
#    #General_SiSo_Cell_lock_and_unlock_under_creation
#    General_SiSo_Cell_lock_and_unlock    with_call=${False}    with_peak=${False}    4G_check=${False}

#[1][1.0] 5GC000470-N-I&V-5GC001541_24_AWHHD_General_SiSo_RU_block_unblock
#    [Tags]    CLOUD_5G_CLASSICAL_SA_ASIKL_ABILB1_AWHHD   CRT_UTE
#    [Setup]    SISO Coam Test Setup
#    [Teardown]    SISO Coam Test Teardown
##    General_SiSo_RU_block_unblock
#
#    Log To Console    \ntotal times:${total_loops}
#    General_Stability_Test_Case    case_name=General_SiSo_RU_block_unblock   times=${total_loops}   pass=${total_loops}
#    ...    common_setup_each_time=${False}   run_total_times=${True}    with_recovery=${False}

#[1][1.0] 5GC000470-N-I&V-5GC001541_02_AWHHD_General_SiSo_RF_module_reset_from_GUI
#    [Tags]    CLOUD_5G_CLASSICAL_SA_ASIKL_ABILB1_AWHHD   CRT_UTE
#    [Setup]    SISO Coam Test Setup
#    [Teardown]    SISO Coam Test Teardown
#    General_SiSo_RF_module_reset_from_GUI
#
#    #EDA 01675907: [5G20B SW FNI]RMOD snapshot collection stuck due to no result object created
#    FOR    ${itime}    IN RANGE    1    ${total_loops}+1
#        Run Keyword And Continue On Failure    Capture RU logs
#        Sleep   5s
#    END

##[1]5GC000470-N-I&V-5GC001541_22_AWHHD_General_SiSo_NR-ARFCN_check
#    #[Tags]    CLOUD_5G_CLASSICAL_SA_ASIKL_ABILB1_AWHHD   CRT_UTE
#    #[Setup]    SISO Coam Test Setup
#    #[Teardown]    SISO Coam Test Teardown
#    #General_SiSo_NR-ARFCN_check   variable_from_CFAM=${Variables_CFAM_470}

### part-2: 5GC000470-E-5GC001082-A - 4 TCs ###
#[1][1.0] 5GC000470-E-5GC001082-A-a_004_SWM supports Download SW build package which is same as active SW via WebUI
#    [Tags]    CLOUD_5G_CLASSICAL_SA_ASIKL_ABILB1_AWHHD   CRT_UTE
#    [Setup]   Run Keywords    cOAM Common Suite Setup    cOAM Common Test Setup    Case setup
#    [Teardown]   Run Keywords     Case teardown     Delete downloaded package    cOAM Common Suite Teardown
#    [Timeout]    120min
#    "step1" Login WebUI and check env
#    Select SW build and download to VM    select_type=Active
#    "step3" Start site upgrade without active
#    "step4" Check the update report
#    "step5" Logout webui

#[1][1.0] 5GC000470-E-5GC001082-A-b_008_SWM supports activation SW build package which is same as the active version via WebUI
#    [Tags]    CLOUD_5G_CLASSICAL_SA_ASIKL_ABILB1_AWHHD   CRT_UTE
#    [Setup]   Run Keywords    cOAM Common Suite Setup    cOAM Common Test Setup    Case setup
#    [Teardown]   Run Keywords     Case teardown     Delete downloaded package    cOAM Common Suite Teardown
#    [Timeout]    120min
#    "step1" Login WebUI and check env
#    Select SW build and download to VM    select_type=Active
#    "step3" Start site upgrade same as active version with active
#    Check the SW download or upgrade finished    b4_type=Active    after_type=Active
#    "step5" Check the update report
#    "step6" Logout webui

#[1][1.0] 5GC000470-E-5GC001082-A-a_002_SWM supports Download SW build package which is same as the passive version SW via WebUI
#    [Tags]    CLOUD_5G_CLASSICAL_SA_ASIKL_ABILB1_AWHHD   CRT_UTE
#    [Setup]   Run Keywords    cOAM Common Suite Setup    cOAM Common Test Setup    Case setup
#    [Teardown]   Run Keywords     Case teardown       Delete downloaded package    cOAM Common Suite Teardown
#    [Timeout]    120min
#    "step1" Login WebUI and check env
#    Select SW build and download to VM    select_type=Passive
#    "step3" Start site upgrade without active
#    "step5" Check the update report
#    "step6" Logout webui

#[1][1.0] 5GC000470-E-5GC001082-A-b_007_SWM supports activation SW build package which is same as the passive version via WebUI
#    [Tags]    CLOUD_5G_CLASSICAL_SA_ASIKL_ABILB1_AWHHD   CRT_UTE
#    [Setup]   Run Keywords    cOAM Common Suite Setup    cOAM Common Test Setup    Case setup
#    [Teardown]   Run Keywords     Case teardown       Delete downloaded package    cOAM Common Suite Teardown
#    [Timeout]    120min
#    "step1" Login WebUI and check env
#    Select SW build and download to VM    select_type=Passive
#    "step3" Start site upgrade with active
#    Check the SW download or upgrade finished    b4_type=Passive    after_type=Active
#    "step5" Check the update report
#    "step6" Logout webui

### part-3: 5GC001178-A-5GC001082-A - 1 TCs ###
## move to Hangzhou/OAM/RAN_PZ_HAZ_34/None_Feature_SG5/UTE_CLOUD/T066_OAM/T066_OAM_SA_ASIKL_ABILB1_AWHHD.robot
#[1][1.0] 5GC001178_A_5GC001082_01_12_Classical gNB Software Management Operation Cancellation via WebUI
#    [Tags]   CLOUD_5G_CLASSICAL_SA_ASIKL_ABILB1_AWHHD   CRT_UTE
#    [Setup]   Run Keywords    cOAM Common Suite Setup    Case setup
#    [Teardown]   Run Keywords     Case teardown    Delete downloaded package    cOAM Common Suite Teardown
#    Step1: Login WebUI
#    Step2: Upgrade site without active
#    Step3: Cancel during software update progress
#    Step4: Logout webui

[1]CB009336_5G_B1_Configuration_for_TDD_CPRI_FR1_NR+LTE_on_ASIB+ABIO_concurrent_mode_General_SiSo_RF_Lock_Unlock
    [Tags]    1S-2CC-NR70-LTE20   CLOUD_5G_CLASSICAL_SA_ASIKL_ABILB1_AWHHD   CRT_UTE    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    [Teardown]    SISO Coam Test Teardown
    Set Test Variable   ${gNb_CuType}   SA
    E2E_SiSo_RU_lock_and_unlock_gNB    with_call=${True}

[1]CB009336_A2_AWHHF_70Mhz_4DL_256QAM_4UL_64QAM_with_L3Call_Peak_5GC001116_3ms
    [Tags]    1S-2CC-NR70-NR70   CLOUD_5G_CLASSICAL_SA_ASIKL_ABILB1_AWHHD   CRT_UTE    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    [Teardown]    SISO Coam Test Teardown
    ${cell_list}    create list    ${1}
    Get UE From Init File and Make call    cell_list=${cell_list}  with_peak=${True}
    ...    suite_name=${SUITE NAME}    test_name=${TEST NAME}

[1]CB009336_A2_Common_SiSo_State Management_Cell block & unblock
    [Tags]    1S-2CC-NR70-NR70   CLOUD_5G_CLASSICAL_SA_ASIKL_ABILB1_AWHHD   CRT_UTE    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    [Teardown]    Run Keywords    Commissioning SCF And Check On Air      scf_path=${Golden_SCF_Path}
    ...    AND    add fault to allowed history fault list    faultId=${49}
    ...    AND    SISO Coam Test Teardown
    Common_SiSo_State_Management_Cell_block_unblock    with_call=${True}

[1]CB008278-B_002_UE_attach_and_peak_TP_at_5GC001116_3ms_long_PUCCH_4DL_256QAM_4UL_256QAM_NSA_Mode_for_10MHz_AWHHF
    [Tags]    CLOUD_5G_CLASSICAL_SA_ASIKL_ABILB1_AWHHD   CRT_UTE    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    [Teardown]    SISO Coam Test Teardown
    ${cell_list}    create list    ${1}
    Get UE From Init File and Make call    cell_list=${cell_list}  with_peak=${False}

[1]CB008278-B_005_cell_block_and_unblock_for_10MHz_AWHHF
    [Tags]    CLOUD_5G_CLASSICAL_SA_ASIKL_ABILB1_AWHHD   CRT_UTE    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    [Teardown]    Run Keywords    add fault to allowed history fault list    faultId=${49}   AND
    ...    SISO Coam Test Teardown
    General_SiSo_Cell_block_and_unblock    with_call=${False}

[1]CNI-106738-A_27_Cell_setup_timing_offset_parameters_TDD_LTE_NR_concurrent
    [Tags]    CNI-106738    CRT_UTE    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    log to console    recommissioning completed; Cell setup completed.
    [Teardown]    SISO Coam Test Teardown

[1]CNI-106738-A_30_data_transfer_conducted_TDD_LTE_NR_concurrent
    [Tags]    CNI-106738    CRT_UTE    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    E2E_SiSo_RU_lock_and_unlock_gNB    with_call=${False}
##   UE not ready
#    ${cell_list}    create list    ${1}
#    ${if_cpe3.2}    Run Keyword And Return Status   Should Contain Any   ${tl.ues[0].version}   3.2   cpe3.2   ignore_case=true
#    Run Keyword If    ${if_cpe3.2}    Get UE From Init File and Make call with cpe 3_2
#    ...    cell_list=${cell_list}    with_peak=${False}   4G_check=${False}
#    ...    ELSE    Get UE info and do L3 Call    cell_list=${cell_list}    with_peak=${False}
    [Teardown]    SISO Coam Test Teardown

[1]CB010904-SR-B1-1_AWHHD_SplitMode&ConcurrentMode_2CC_2DL_256QAM_2UL_256QAM_70MHz_40MHz_with_Peak_CB008953_7
    [Tags]    1S-2CC-2DL2UL_70MHz_40MHz    CRT_UTE    CRT_TRUNK    CRT_25R2    CRT_25R1
    [Setup]    SISO Coam Test Setup
    sleep    2min
    ${cell_list}    create list    ${1}
    Get UE From Init File and Make call    cell_list=${cell_list}    with_peak=${True}    4G_check=${False}
    ...    suite_name=${SUITE NAME}    test_name=${TEST NAME}
    [Teardown]    SISO Coam Test Teardown

[1]CB010904-SR-B3-2_AWHHD_Split&ConcurrentMode_SuperCell_Supercell_active_deactive_with_L3call_CB009542-G#1
    [Tags]   1S-1CC-2D2U_SuperCell    CRT_UTE    CRT_TRUNK    CRT_25R2    CRT_25R1
    [Setup]    SISO Coam Test Setup
    [Teardown]    SISO Coam Test Teardown
    Deactivate NR Supercell
    ${cell_list}    create list    ${1}
    Get UE From Init File and Make call    cell_list=${cell_list}    with_peak=${False}
    Activate NR Supercell
    Get UE From Init File and Make call    cell_list=${cell_list}    with_peak=${True}
    ...    suite_name=${SUITE NAME}    test_name=${TEST NAME}

[1]CB009077-SR-E-a_02_Storing_location_into_RU_NVM_5G_AWHHF
    [Tags]    1S-2CC-NR70-NR70   CRT_UTE    CRT_TRUNK    CRT_25R2    CRT_25R1
    [Setup]    Run keywords     Allowed Watchdog additional alarms    fault_list=${fault_list}
    ...    AND   SBTS Test Setup
    Storing_location_into_RU_NVM_5G_AWHHF    ru_index=1
