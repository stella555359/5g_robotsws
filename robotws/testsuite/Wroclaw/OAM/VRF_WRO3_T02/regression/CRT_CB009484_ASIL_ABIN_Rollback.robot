*** Settings ***
Documentation
...              Suite for all CB009484-B testcases
...              test automation author: Robert Rozanski
...              contact: robert.rozanski@nokia.com

Resource        ../common_resources/logs/common_unit_logs.robot
Resource        ../common_resources/scout/scout_operations.robot
Resource        ../common_resources/alarms/alarm.robot
Resource        taf/rfrl/common_resources/common_step/interface.robot
Resource        taf/rfrl/scrambling_logs_collector/Keywords.robot
Resource        testsuite/Wroclaw/OAM/VRF_WRO3_T02/features/CB009484/TestCases/Keywords.robot

Force Tags      CA_VRF_WRO3
...             AVG_EXE_TIME=40
...             RESPONSIBLE_TESTER=rozanski

Suite Setup     Suite Setup

Test Setup      Test Setup
Test Teardown   Test Teardown

*** Variables ***
${BTS_ID}=          ${tl.gnbs[0].instance_id}

*** Test Cases ***
Update_from_N-1_to_N_release_and_rollback_next_check_pti_and_spectre_v2_kernel_flag_from_WebEM_prepare_TL
    Prepare_TL_for_rollback

CB009484_B_Update_from_N-1_to_N_release_and_rollback_next_check_pti_and_spectre_v2_kernel_flag_from_WebEM_Intel_Snowfish_ASIL_ABIN
    Update_from_N-1_to_N_release_and_rollback_next_check_pti_and_spectre_v2_kernel_flag_from_WebEM

*** Keywords ***
Suite Setup
    Create Suite Metadata

Test Setup
    Set Test Variable       ${TEST_OUTPUT_DIR}      ${OUTPUT_DIR}/${TEST_NAME}

Test Teardown
    No Faults Except Allowed Should Be Present On BTS
    run keyword if test failed    coam_admin.Setup Admin      bts_host=192.168.255.129            name=Connection_Webem
    run keyword if test failed    collect_snapshot            ${SW_path}/Snapshot_after_test_failed      connection=Connection_Webem
    run keyword if test failed    coam_admin.Teardown         Connection_Webem
