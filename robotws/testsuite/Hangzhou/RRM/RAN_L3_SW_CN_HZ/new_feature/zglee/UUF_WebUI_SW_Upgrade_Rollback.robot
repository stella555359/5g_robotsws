*** Settings ***
Documentation
...                author: Zhang Yin
...                contact: yin.zhang@nokia-sbell.com
...                Test suite for basic UUF SW upgrade and rollback in loop

Library            Collections
Library            taf/rfrl/csv4all/CSV4AllTestCases.py
Resource           taf/rfrl/uuf4all/uuf4all_keywords.robot
Resource           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG8/resources/DevHZ5_resource_ST.robot

Library            taf.sbts.oam.coam.admin    WITH NAME    admin

Suite Setup        UUF Suite Setup
Test Setup         UUF Test Setup
Test Teardown      UUF Test Teardown

*** Variables ***
#@{CUSTOMERS}                      Generic
${target_version}                 ${None}
${UPGRADE_ITERATION}              5
#${QC_DOMAIN}                      MN_RAN
#${TEST_QC_ID}                     ${None}
#${QC_PROJECT}                     RAN_VRF
#${REPORT_COMMENT}                 ${None}
@{CUSTOM_ALLOWED}                  61649    4655    4654    61524    61652    62003    62001    6308    6202    6327
${stop_test_after_fail}            ${False}

*** Test Cases ***
UUF Webui SW Upgrade And Rollback
    [Timeout]   100h
    e2e_tl_sw_upgrade_rollback_with_oam_kpi
    ...    ${NODES}
    ...    ${NODE}
    ...    ${UPGRADE_ITERATION}
    ...    restore_to_target_sw=${False}
    ...    report=${False}
    ...    stop_test_after_fail=${stop_test_after_fail}
#    ...    report_comment=${REPORT_COMMENT}
#    ...    customers_list=${CUSTOMERS}
#    ...    qc_domain=${QC_DOMAIN}
#    ...    qc_id=${TEST_QC_ID}
#    ...    qc_project=${QC_PROJECT}

*** Keywords ***
UUF Suite Setup
    ${source_sw}=    Get Active SW
    ${target_sw}=    run keyword if  '${target_version}'=='${None}'  Get Target SW
    ...   ELSE  set variable  ${target_version}
    log    upgrade from ${source_sw} to ${target_sw}    level=WARN
    &{NODE}    create dictionary    node_alias=gnb
    ...                             testline_object=${tl.gnbs[0]}
    ...                             source_sw=${source_sw}
    ...                             target_sw=${target_sw}
    ...                             custom_allowed_alarms=${CUSTOM_ALLOWED}
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
    run keyword if test failed    Capture Snapshot For X times
    Run Keyword And Ignore Error    stop to capture infomodel log    timeout=1800

UUF Test Setup
    set test variable    ${SAVE LOG DIRECTORY}    ${OUTPUT_DIR}
    start to capture infomodel log
