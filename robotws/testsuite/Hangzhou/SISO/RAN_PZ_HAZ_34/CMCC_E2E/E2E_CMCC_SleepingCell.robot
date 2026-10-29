*** Settings ***
Documentation
...   Test suite for regression testing of CMCC
...   author: Chen Tong
...   contact: tong.chen@nokia-sbell.com
Force Tags        5G_SISO    CA_RAN_PZ_HAZ_4

Library      String
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_LTE.robot
Resource     taf/rfrl/uuf4all/uuf4all_test_cases.robot
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Resource    taf/rfrl/common_resources/robot/coam_selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Library     testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CMCC_E2E/Resources/delta.py
Resource    Resources/E2E_CMCC_common_keyword.robot
Library     testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CMCC_E2E/Resources/E2E_CMCC_get_cell_info.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot

Suite Setup       UUF4ALL common Suite Setup with alarm checking    if_commissioning=${True}
Suite Teardown    common_setups_and_teardowns.Common Suite Teardown

*** Variables ***
@{customers}             CMCC
#${5g_source_sw}
#${5g_target_sw}          ${target_version}
${runs_of_uuf_upgrade_withcall}   ${3}
${runs_of_uuf_reset}     ${17}
${runs_of_bbmod_reset}   ${7}
${runs_of_rmod_reset}    ${14}
${runs_of_uuf_reset_withcall}     ${3}
${runs_of_bbmod_reset_withcall}   ${3}
${runs_of_rmod_reset_withcall}    ${6}
${runs_of_nrcel_lock_withcall}    ${3}
${runs_of_nrcel_block_withcall}    ${6}
${runs_of_delta_commission_withcall}    ${3}
${runs_of_delta_commission}    ${1}
@{critical_faults}       10    16    1806    1868    4341    4352    4383
@{custom_alarms}         7312    7313
${testline_name}
${CONFIGURATION}    HGZ.${testline_name}
${delta_file}    delta.json

${UL_THROUGHPUT}    50Mbits/sec
${DL_THROUGHPUT}    50Mbits/sec

${DURATION}    6000
${UL_EXPECT_TP}    10
${DL_EXPECT_TP}    10

${apn1}    ${tl.core.pdns[0].apn}

*** Test Cases ***
E2E_TL_SW_upgrade_rollback_with_OAM_KPI
    [Setup]    Common CMCC Test Case Setup
    ${5G_pakage_path}      Get package link and Download to VM
    COAM Navigate to login page via webUI    download_dir=${OUTPUT DIR}
    ${current_version}    wait until keyword succeeds    2min    15s    selenium_coam.check_current_software_version
    ${current_version}    Replace String    ${current_version['Active']}    SBTS24R2    SBTS00
    Set Test Variable    ${5g_source_sw}    ${current_version}
    UUF4ALL_SW_UPGRADE_TEST
    ...    test_iteration=${runs_of_uuf_upgrade_withcall}
    ...    critical_faults=@{critical_faults}
    ...    customers_list=${customers}
    ...    5g_source_sw=${5g_source_sw}
    ...    5g_target_sw=${target_version}
    ...    5g_target_sw_path=${5G_pakage_path}
    ...    use_builds_storage=${False}
    ...    restore_to_target_sw=${True}
    ...    local_node_attach_test_keyword=UE Attach and Check traffic for Sleeping Cells
    [Teardown]    Clear SW Build

E2E_TL_Site_Reset_without_HWF_with_OAM_KPI
    [Tags]    CRT_TRUNK    CRT_22R2    CRT_22R3    CRT_22R4    CRT_23R1    ABIO
    [Setup]    Common CMCC Test Case Setup
    UUF4ALL_SITE_RESET_TEST
    ...    test_iteration=${runs_of_uuf_reset_withcall}
    ...    critical_faults=@{critical_faults}
    ...    customers_list=${customers}
    ...    attach_test_keyword=UE Attach and Check traffic for Sleeping Cells

E2E_TL_RU_Reset_with_OAM_KPI
    [Tags]    CRT_TRUNK    CRT_22R2    CRT_22R3    CRT_22R4    CRT_23R1    ABIO
    [Setup]    Common CMCC Test Case Setup
    OAM_RMOD_RESET
    ...    test_iteration=${runs_of_rmod_reset_withcall}
    ...    custom_alarms=@{custom_alarms}
    ...    critical_faults=@{critical_faults}
    ...    customers_list=${customers}
    ...    attach_test_keyword=UE Attach and Check traffic for Sleeping Cells

E2E_TL_Capacity_Module_Reset_with_OAM_KPI
    [Tags]    CRT_TRUNK    CRT_22R2    CRT_22R3    CRT_22R4    CRT_23R1    ABIO
    [Setup]    Common CMCC Test Case Setup
    OAM_BBMOD_RESET
    ...    test_iteration=${runs_of_bbmod_reset_withcall}
    ...    custom_alarms=@{custom_alarms}
    ...    critical_faults=@{critical_faults}
    ...    customers_list=${customers}
    ...    attach_test_keyword=UE Attach and Check traffic for Sleeping Cells

E2E_TL_Delta_Commissioning_With_Site_Reset_Required
    [Tags]    CRT_TRUNK    CRT_22R2    CRT_22R3    CRT_22R4    CRT_23R1    ABIO
    [Setup]    Common CMCC Test Case Setup
	${5G_flag}    Run keyword and return status    should contain    ${testline_name}    5G
    ${mrbtsid}    Run keyword if    ${5G_flag}     set variable    ${tl.gnbs[0].instance_id}
    ...    ELSE    set variable    ${tl.enbs[0].instance_id}
    ${nrbtsid}    Run keyword if    ${5G_flag}     set variable    ${tl.gnbs[0].global_bts_id}
    ...    ELSE    set variable    ${tl.enbs[0].global_bts_id}
	set test variable    ${mrbtsid}
	set test variable    ${nrbtsid}
	${parameter_to_modification}   Prepare Delta
    ...     filename=${delta_file}
    ...     parameter_type=site_reset
	...     mrbts_id=${mrbtsid}
	...     nrbts_id=${nrbtsid}
	DELTA_COMMISSIONING_WITH_SITE_RESET_REQUIRED
	...    delta_file=${delta_file}
    ...    test_iteration=${runs_of_delta_commission_withcall}
    ...    custom_alarms=@{custom_alarms}
    ...    critical_faults=@{critical_faults}
    ...    customers_list=${customers}
    ...    attach_test_keyword=UE Attach and Check traffic for Sleeping Cells

E2E_TL_Cell_Lock_Unlock_NR_with_OAM_KPI
    [Tags]    CRT_TRUNK    CRT_22R2    CRT_22R3    CRT_22R4    CRT_23R1    ABIO
    [Setup]    Common CMCC Test Case Setup
    OAM_NRCEL_LOCK
    ...    test_iteration=${runs_of_nrcel_lock_withcall}
    ...    custom_alarms=@{custom_alarms}
    ...    critical_faults=@{critical_faults}
    ...    customers_list=${customers}
    ...    attach_test_keyword=UE Attach and Check traffic for Sleeping Cells

E2E_TL_Cell_Block_Unblock_NR_with_OAM_KPI
    [Tags]    CRT_TRUNK    CRT_22R2    CRT_22R3    CRT_22R4    CRT_23R1    ABIO
    [Setup]    Common CMCC Test Case Setup
    OAM_NRCEL_BLOCK
    ...    test_iteration=${runs_of_nrcel_block_withcall}
    ...    custom_alarms=@{custom_alarms}
    ...    critical_faults=@{critical_faults}
    ...    customers_list=${customers}
    ...    attach_test_keyword=UE Attach and Check traffic for Sleeping Cells

[1.0] E2E_TL_Site_reset_without_HWF_with_OAM_KPI
    [Tags]    CRT_TRUNK    CRT_22R2    CRT_22R3    CRT_22R4    CRT_23R1    ABIO
    [Setup]    Common CMCC Test Case Setup
    UUF4ALL_SITE_RESET_TEST
    ...    test_iteration=${runs_of_uuf_reset}
    ...    critical_faults=@{critical_faults}
    ...    customers_list=${customers}

[1.0] E2E_TL_RU_Reset_with_OAM_KPI
    [Tags]    CRT_TRUNK    CRT_22R2    CRT_22R3    CRT_22R4    CRT_23R1    ABIO
    [Setup]    Common CMCC Test Case Setup
    OAM_RMOD_RESET
    ...    test_iteration=${runs_of_rmod_reset}
    ...    custom_alarms=@{custom_alarms}
    ...    critical_faults=@{critical_faults}
    ...    customers_list=${customers}

[1.0] E2E_TL_Capacity_Module_Reset_with_OAM_KPI
    [Tags]    CRT_TRUNK    CRT_22R2    CRT_22R3    CRT_22R4    CRT_23R1    ABIO
    [Setup]    Common CMCC Test Case Setup
    OAM_BBMOD_RESET
    ...    test_iteration=${runs_of_bbmod_reset}
    ...    custom_alarms=@{custom_alarms}
    ...    critical_faults=@{critical_faults}
    ...    customers_list=${customers}

E2E_TL_Delta_Commissioning_With_NR_Rat_Reset
    [Tags]    CRT_TRUNK    CRT_22R2    CRT_22R3    CRT_22R4    CRT_23R1    ABIO
    [Setup]    Common CMCC Test Case Setup
	set test variable    ${mrbtsid}    ${tl.gnbs[0].instance_id}
	set test variable    ${nrbtsid}    ${tl.gnbs[0].global_bts_id}
	${parameter_to_modification}   Prepare Delta
    ...     filename=${delta_file}
    ...     parameter_type=nr_rat_reset
	...     mrbts_id=${mrbtsid}
	...     nrbts_id=${nrbtsid}
	DELTA_COMMISSIONING_WITH_NR_RAT_RESET
	...    delta_file=${delta_file}
    ...    test_iteration=${runs_of_delta_commission}
    ...    custom_alarms=@{custom_alarms}
    ...    critical_faults=@{critical_faults}
    ...    customers_list=${customers}

E2E_TL_Delta_Commissioning_With_Online_Parameter_Modification
    [Tags]    CRT_TRUNK    CRT_22R2    CRT_22R3    CRT_22R4    CRT_23R1    ABIO
    [Setup]    Common CMCC Test Case Setup
    ${5G_flag}    Run keyword and return status    should contain    ${testline_name}    5G
    ${mrbtsid}    Run keyword if    ${5G_flag}     set variable    ${tl.gnbs[0].instance_id}
    ...    ELSE    set variable    ${tl.enbs[0].instance_id}
    ${nrbtsid}    Run keyword if    ${5G_flag}     set variable    ${tl.gnbs[0].global_bts_id}
    ...    ELSE    set variable    ${tl.enbs[0].global_bts_id}
    ${parameter_flag}    Run keyword if    ${5G_flag}     set variable    online_5G
    ...    ELSE    set variable    online_LTE
	set test variable    ${mrbtsid}
	set test variable    ${nrbtsid}
	${parameter_to_modification}   Prepare Delta
    ...     filename=${delta_file}
    ...     parameter_type=${parameter_flag}
	...     mrbts_id=${mrbtsid}
	...     nrbts_id=${nrbtsid}
	DELTA_COMMISSIONING_WITH_ONLINE_PARAMETER_MODIFICATION
	...    delta_file=${delta_file}
    ...    test_iteration=${runs_of_delta_commission}
    ...    custom_alarms=@{custom_alarms}
    ...    critical_faults=@{critical_faults}
    ...    customers_list=${customers}

*** Keywords ***
UUF4ALL common Suite Setup with alarm checking
    [Arguments]    ${if_commissioning}=${False}
	robot_common_operations.Common Suite Setup
	run keyword if     ${if_commissioning}    CI_interface.Common Suite Setup
