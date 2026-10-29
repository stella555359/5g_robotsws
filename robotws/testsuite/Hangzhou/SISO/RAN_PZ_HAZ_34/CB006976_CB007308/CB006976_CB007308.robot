*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup
Test Teardown        SISO Coam Test Teardown

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot.robot
Resource    ${BASIC_PATH_5G}/General_Stability_Test_Case.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RF_module_reset_from_GUI.robot
Resource    ${BASIC_PATH_5G}/OAM_KPI_61a_SiSo_Auto_BTS_site_reset.robot
Resource    Resources/CB006796_common_keywords.robot
Resource    Resources/CB007308_common_keywords.robot
Variables    TestData/variables_8013.py
Resource    Resources/CB007326_keywords.robot

Documentation
...    SISO Author: lanwen.cai SG_08
...    Contact: lanwen.cai@nokia-sbell.com
...    Feature CB006796  C5 C14 C15

...    OAM Author: zhenzhen.ren SG_08
...    Contact:zhenzhen.ren@nokia-sbell.com
...    Feature CB007308_5GC000614_5GC002452

Force Tags    5G_RAN_TDD    SBTS00    CRT_TRUNK    CRT_22R2    CRT_22R3    CRT_22R4    CRT_23R1
...    PY36

*** Variables ***
${MAX_LOOP}    3
${MAX_LOOP_celllock}  1

*** Test Cases ***
[1]CB007308-5G-AE-5GC000614_Initiate_SFP_Monitoring_from_WebEM_for_ASOE(dynamic_data)
    [Tags]    CRT_21A    CRT_TRUNK    CRT_21B
    ${links}    ${SMOD}    ${BBMOD}    ${RMOD}=    Get Information about SFP links
    ${dynamic_1}=    Check if dynamic parameters have a valid value for ports    links=${links}    dict_of_links=${SMOD}
    Sleep    120s
    ${links}    ${SMOD}    ${BBMOD}    ${RMOD}=    Get Information about SFP links
    ${dynamic_2}=    Check if dynamic parameters have a valid value for ports    links=${links}    dict_of_links=${SMOD}

[1]CB007308-5G-AE-5GC000614-Initiate_SFP_Monitoring_from_WebEM_for_ASOE(static_data-Temperature_parameters)
    [Tags]    CRT_21A    CRT_TRUNK    CRT_21B
    ${links}    ${SMOD}    ${BBMOD}    ${RMOD}=    Get Information about SFP links
    Check if temperature parameters have a valid value for ports    links=${links}    dict_of_links=${SMOD}

[1]CB007308-5G-AE-5GC000614_Dynamic_SFP_Parameters_saved_into_PM_counters_for_ASOE
    [Tags]    CRT_21A    CRT_TRUNK    CRT_21B
    SFP parameter preparation by coam
    Wait Until Keyword Succeeds    3x    120s    Check quantity of RD files on BTS
    ${parsed_files_list}=    Get snapshot and return RD files
    ${SMOD_SFP_dict}=    Get SMODs info
    set suite variable    ${measurementType}    SBTS_SFP_SMOD
    ${SMOD_SFP_dict_1}    Get Certain SMOD_SFP_Dict    SFP_dict=${SMOD_SFP_dict}     MOD_Seq=1
    Check counters from SFP monitoring- file iteration_2452    parsed_files=${parsed_files_list}    MOD_SFP_dict=${SMOD_SFP_dict_1}
    ...    measurementType=${measurementType}    SBTSmeasT=SBTS_SFPSM
    Remove Directory    ${unzipped}    recursive=True

[1]CB007308-5G-AG-5GC002452_Initiate_SFP_Monitoring_from_WebEM_for_RU(dynamic_data)
    [Tags]    CRT_21A    CRT_TRUNK    CRT_21B
	${links}    ${SMOD}    ${BBMOD}    ${RMOD}=    Get Information about SFP links
    ${dynamic_1}=    Check if dynamic parameters have a valid value for ports   links=${links}    dict_of_links=${RMOD}
    Sleep    120s
    ${links}    ${SMOD}    ${BBMOD}    ${RMOD}=    Get Information about SFP links
    ${dynamic_2}=    Check if dynamic parameters have a valid value for ports   links=${links}    dict_of_links=${RMOD}

[1]CB007308-5G-AG-5GC002452_Initiate_SFP_Monitoring_from_WebEM_for_RU(static_data-Temperature_parameters)
    [Tags]    CRT_21A    CRT_TRUNK    CRT_21B
    ${links}    ${SMOD}    ${BBMOD}    ${RMOD}=    Get Information about SFP links
    Check if temperature parameters have a valid value for ports    links=${links}    dict_of_links=${RMOD}

[1]CB007308-5G-AG-5GC002452_Dynamic_SFP_Parameters_saved_into_PM_counters_for_RU
    [Tags]    CRT_21A    CRT_TRUNK    CRT_21B
    SFP parameter preparation by coam
    Wait Until Keyword Succeeds    3x    120s    Check quantity of RD files on BTS
    ${parsed_files_list}=    Get snapshot and return RD files
    ${RMOD_SFP_dict}=    Get RMODs info
#    ${RMOD_SFP_dict_1}    Get Certain RMOD_SFP_Dict    SFP_dict=${RMOD_SFP_dict}     MOD_Seq=1    MOD_type=RMOD
    set suite variable    ${measurementType}    SBTS_SFP_RMOD
    Check counters from SFP monitoring- file iteration_2452    parsed_files=${parsed_files_list}    MOD_SFP_dict=${RMOD_SFP_dict}
    ...    measurementType=${measurementType}    SBTSmeasT=SBTS_SFPRM
    Remove Directory    ${unzipped}    recursive=True

#[1][1.0] General_SiSo_Commissioning_BTS_Template_Commissioning
#    General_SiSo_Commissioning_BTS_Template_Commissioning

#[1][2.0] General_SiSo_RF_module_power_reset
#    General_SiSo_RF_module_power_reset
#
#[1][2.0] General_SiSo_RU_module_reset_from_GUI
#    General_SiSo_RF_module_reset_from_GUI

[1][1.0] General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
    General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot

#[1][2.0] General_SiSo_RF_alarms_with_recovery
#    General_SiSo_RF_alarms_with_recovery

[1][1.0] General_SiSo_E2E_system_setup_with_data_transfer_conducted
    General_SiSo_E2E_system_setup_with_data_transfer_C5

[1][1.0] General_SiSo_RU_lock_unlock
    General_SiSo_RU_lock_unlock_C5

[1][1.0] General_SiSo_Cell_block_and_unblock
    General_SiSo_Cell_block_and_unblock_C5

#[1][1.0] General_SiSo_E2E_system_setup_with_data_transfer_conducted_60M
#    General_SiSo_E2E_system_setup_with_data_transfer_C5_60M

[1]OAM_KPI_651_SiSo_Auto_RF_reset_success_rate_from_WebUI_with_L3Call
    General_Stability_Test_Case    case_name=General_SiSo_RF_module_reset_from_GUI    times=${20}    pass=${19}

[1][1.0] OAM_KPI_61a_SiSo_Auto_BTS_site_reset
    OAM_KPI_61a_SiSo_Auto_BTS_site_reset

#[1][1.0] General_SiSo_Auto_Cell_lock_and_unlock_with_L3call
#    ${RU_nums}    ${cell_nums}    Get RU and cell numbers
#    ${C14_SCF}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_C14_
#    run keyword if    ${cell_nums}!=2    Commissioning SCF And Check On Air    scf_path=${C14_SCF}
#    General_Stability_Test_Case    case_name=General_SiSo_Cell_block_and_unblock    with_call=${False}    times=${20}    pass=${19}

#[2][1.0] General_SiSo_E2E_system_setup_with_data_transfer_conducted
#    ${RU_nums}    ${cell_nums}    Get RU and cell numbers
#    ${C14_SCF}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_C14_
#    run keyword if    ${cell_nums}!=2    Commissioning SCF And Check On Air    scf_path=${C14_SCF}
#    General_SiSo_E2E_system_setup_with_data_transfer_C14
#
#[2][1.0] General_SiSo_RU_lock_unlock
#    ${RU_nums}    ${cell_nums}    Get RU and cell numbers
#    ${C14_SCF}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_C14_
#    run keyword if    ${cell_nums}!=2    Commissioning SCF And Check On Air    scf_path=${C14_SCF}
#    General_SiSo_RU_lock_unlock_C14
#
#[2][1.0] General_SiSo_Cell_block_and_unblock
#    ${RU_nums}    ${cell_nums}    Get RU and cell numbers
#    ${C14_SCF}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_C14_
#    run keyword if    ${cell_nums}!=2    Commissioning SCF And Check On Air    scf_path=${C14_SCF}
#    General_SiSo_Cell_block_and_unblock_14

[3][1.0] General_SiSo_E2E_system_setup_with_data_transfer_conducted
    ${C15_SCF}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_C15_
    ${RU_nums}    ${cell_nums}    Get RU and cell numbers
    run keyword if  not ${RU_nums}==1 and ${cell_nums}==6    Commissioning SCF And Check On Air    scf_path=${C15_SCF}
    General_SiSo_E2E_system_setup_with_data_transfer_C15

#[3][1.0] General_SiSo_E2E_system_setup_with_data_transfer_conducted_100M
#    ${C15_SCF}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_C15_
#    ${RU_nums}    ${cell_nums}    Get RU and cell numbers
#    run keyword unless   ${RU_nums}==1 and ${cell_nums}==6    Commissioning SCF And Check On Air    scf_path=${C15_SCF}
#    General_SiSo_E2E_system_setup_with_data_transfer_C15_100M

[3][1.0] General_SiSo_RU_lock_unlock
    ${C15_SCF}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_C15_
    ${RU_nums}    ${cell_nums}    Get RU and cell numbers
    run keyword if  not ${RU_nums}==1 and ${cell_nums}==6    Commissioning SCF And Check On Air    scf_path=${C15_SCF}
    General_SiSo_RU_lock_unlock_C15

[3][1.0] General_SiSo_Cell_block_and_unblock
    ${C15_SCF}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_C15_
    ${RU_nums}    ${cell_nums}    Get RU and cell numbers
    run keyword if  not ${RU_nums}==1 and ${cell_nums}==6    Commissioning SCF And Check On Air    scf_path=${C15_SCF}
    General_SiSo_Cell_block_and_unblock_15

[1]CB007326-5G-A-SyVe_ 5GC002083 Phase1_Detection
    [Tags]    CRT_TRUNK    CRT_22R1
    ${RU_nums}    ${cell_nums}    Get RU and cell numbers
    ${C14_SCF}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_C14_
    run keyword if    ${cell_nums}!=2    Commissioning SCF And Check On Air    scf_path=${C14_SCF}
    CB007326-5G-A-SyVe_ 5GC002083 Phase1_Detection

[1]CB007326-5G-A-SyVe_ 5GC002083 Phase1_Cancel
    [Tags]    CRT_TRUNK    CRT_22R1
    ${RU_nums}    ${cell_nums}    Get RU and cell numbers
    ${C14_SCF}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_C14_
    run keyword if    ${cell_nums}!=2    Commissioning SCF And Check On Air    scf_path=${C14_SCF}
    CB007326-5G-A-SyVe_ 5GC002083 Phase1_Cancel

[1]CB007326-5G-A-SyVe_ 5GC002083 Phase3_Detection
    [Tags]    CRT_TRUNK    CRT_22R1
    ${RU_nums}    ${cell_nums}    Get RU and cell numbers
    ${C14_SCF}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_C14_
    run keyword if    ${cell_nums}!=2    Commissioning SCF And Check On Air    scf_path=${C14_SCF}
    CB007326-5G-A-SyVe_ 5GC002083 Phase3_Detection

[1]CB007326-5G-A-SyVe_ 5GC002083 Phase3_Cancel
    [Tags]    CRT_TRUNK    CRT_22R1
    ${RU_nums}    ${cell_nums}    Get RU and cell numbers
    ${C14_SCF}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_C14_
    run keyword if    ${cell_nums}!=2    Commissioning SCF And Check On Air    scf_path=${C14_SCF}
    CB007326-5G-A-SyVe_ 5GC002083 Phase3_Cancel

[1]CB007326-5G-A-SyVe_5GC000431 Feature_5GC000431_Activation
    [Tags]    CRT_TRUNK    CRT_22R1
    ${RU_nums}    ${cell_nums}    Get RU and cell numbers
    ${C14_SCF}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_C14_
    run keyword if    ${cell_nums}!=2    Commissioning SCF And Check On Air    scf_path=${C14_SCF}
    CB007326-A Activate feature 5GC000431

[1]CB007326-5G-A-SyVe_5GC000431 Power_saving_conditions_met_before_and_during_start_power_saving_time_period
    [Tags]    CRT_TRUNK    CRT_22R1
    ${RU_nums}    ${cell_nums}    Get RU and cell numbers
    ${C14_SCF}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_C14_
    run keyword if    ${cell_nums}!=2    Commissioning SCF And Check On Air    scf_path=${C14_SCF}
    Power_saving_conditions_met_before_and_during_start_power_saving_time_period

[1]CB007326-5G-A-SyVe_5GC000431 PM_counter_M55601C00501
    [Tags]    CRT_TRUNK    CRT_22R1
    ${RU_nums}    ${cell_nums}    Get RU and cell numbers
    ${C14_SCF}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_C14_
    run keyword if    ${cell_nums}!=2    Commissioning SCF And Check On Air    scf_path=${C14_SCF}
    CB007326-5G-A-SyVe_5GC000431 PM_counter    counter_id=M55601C00501

[1]CB007326-5G-A-SyVe_5GC000431 PM_counter_M55601C00502
    [Tags]    CRT_TRUNK    CRT_22R1
    ${RU_nums}    ${cell_nums}    Get RU and cell numbers
    ${C14_SCF}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_C14_
    run keyword if    ${cell_nums}!=2    Commissioning SCF And Check On Air    scf_path=${C14_SCF}
    CB007326-5G-A-SyVe_5GC000431 PM_counter    counter_id=M55601C00502

*** Keywords ***
