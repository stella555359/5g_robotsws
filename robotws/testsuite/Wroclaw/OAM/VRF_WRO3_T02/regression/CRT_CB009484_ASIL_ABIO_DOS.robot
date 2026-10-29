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
Resource        testsuite/Wroclaw/OAM/VRF_WRO3_T02/common_resources/preparation/setup_teardown.robot

Force Tags      CA_VRF_WRO3
...             AVG_EXE_TIME=40
...             RESPONSIBLE_TESTER=rozanski

Suite Setup     Suite Setup

Test Setup      Test Setup
Test Teardown   Test Teardown

*** Variables ***
${BTS_ID}=          ${tl.gnbs[0].instance_id}
${TEST NAME}=                       ASIL_ABIO_DOS

*** Test Cases ***

[1]CB009484_B_DOS_attack_using_Hping3_UDP_ICMP_protocol_with_enable_pti_and_spectre_v2_kernel_flag_Intel_Snowfish_ASIL_ABIO
    Enable actPtiAndSpectreV2KernelFlag and check flags
    Run Hping3    sudo hping3 --interval u300 -2 -n -q -S -p 123    #UDP
    Run Hping3    sudo hping3 --interval u300 -n -q -S -p 80        #TCP
    Run Hping3    sudo hping3 --interval u300 -1 -n -q -S           #ICMP

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
