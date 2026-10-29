*** Settings ***
Documentation
...                author: Zhang Yin
...                contact: yin.zhang@nokia-sbell.com
...                Test suite for basic UUF Reset in loop

Library            Collections
Library            taf/rfrl/csv4all/CSV4AllTestCases.py
Resource           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG8/resources/DevHZ5_resource_ST.robot

Library            taf.sbts.oam.coam.admin    WITH NAME    admin

Suite Setup        UUF Suite Setup
Test Setup         UUF Test Setup
Test Teardown      UUF Test Teardown

*** Variables ***
#@{CUSTOMERS}                      Generic
#${CANDIDATE}                      ${EMPTY}
${RESET_ITERATION}                1
#${QC_DOMAIN}                      MN_RAN
#${TEST_QC_ID}                     ${None}
#${QC_PROJECT}                     RAN_VRF
#${REPORT_COMMENT}                 ${None}

*** Test Cases ***
E2E_TL_Activation_Reset_Test
    [Timeout]   100h
    e2e_tl_activation_reset_test
    ...    ${NODES}
    ...    ${NODE}
    ...    ${RESET_ITERATION}
    ...    report=${False}

*** Keywords ***
UUF Suite Setup
    ${active_sw}=    Get Active SW
    log    SW build is ${active_sw}    level=WARN
    &{NODE}    create dictionary    node_alias=gnb
    ...                             testline_object=${tl.gnbs[0]}
    ...                             source_sw=${active_sw}
    ...                             target_sw=${active_sw}
    @{NODES}    create list    ${NODE}
    set suite variable    ${NODE}
    set suite variable    ${NODES}

Get Active SW
    ${admin_conn}    admin.Connect To
    ${sw_info}    admin.get_software_info     connection=${admin_conn}
    ${sw_build}    set variable    ${sw_info['Active SW version']}
    ${sw_build}    set variable if   "_9999_" in '${sw_build}'
    ...    SBTS00_${sw_build.partition("_")[-1]}    ${sw_build}
    [Teardown]    admin.Teardown    ${admin_conn}
    [Return]    ${sw_build}


Capture Snapshot For X times
    FOR    ${i}    IN RANGE    1    6
        sleep    60s
        set test variable    ${SAVE LOG DIRECTORY}    ${OUTPUT_DIR}/snapshot_${i}
        execute cmd on pc    mkdir -p ${SAVE LOG DIRECTORY}
        Collect Snapshot BTS1
    END

UUF Test Teardown
    robot_common_operations.Common Case Teardown
    run keyword if test failed    Capture Snapshot For X times
    stop to capture infomodel log
    CI interface.Common Case Teardown


UUF Test Setup
    robot_common_operations.Common Case Setup
    set test variable    ${SAVE LOG DIRECTORY}    ${OUTPUT_DIR}
    start to capture infomodel log
