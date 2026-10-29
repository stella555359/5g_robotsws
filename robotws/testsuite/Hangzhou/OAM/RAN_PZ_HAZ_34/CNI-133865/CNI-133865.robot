*** Settings ***
Documentation
    ...    Author: ruiyu.han@nokia-sbell.com
    ...    to define CB012144 cases
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/CNI-133865/Resource/CNI133865_common.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG7/siso_common.robot
Variables    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/CB009499/Resource/resource.py
Variables    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/CNI-133865/Resource/resource.py

Test Setup     Append To List  ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}

Suite Setup  Run Keywords    CI_interface.Common Case Setup   AND  robot_common_operations.Common Suite Setup
Suite Teardown   robot_common_operations.Common Suite Teardown

*** Variables ***
@{ALL_TEST_STATUS}
${RMOD_FLAG}    ${True}

*** Test Cases ***
[1]CNI-133865_AEHC_CRT
    [Tags]   25R3
    run keyword and continue on failure   [1]AEHC_PM1-PM5_logs_verify_in_snapshot_after_bbmod_reset
    [Teardown]    robot_common_operations.Common Case Teardown



*** Keywords ***
[1]AEHC_PM1-PM5_logs_verify_in_snapshot_after_site_reset
    [Timeout]   25h
    Case Setup for CNI133865
    FOR   ${i}   IN RANGE    ${5}
        ###step1: site reset
        COAM Reset Site
        Wait Until Keyword Succeeds   20m   1m   COAM Check all cells should be onair
        ###step2: get snapshot
        ${curr_data}    DateTime.Get Current Date    UTC    + 8 hours    result_format=%Y-%m-%d-%H_%M_%S
        ${snapshot_path}     Catch Snapshot COAM
        ...    local_file_path=${OUTPUT_DIR}/${TESTNAME}/snapshot_coam_${filename}_${curr_data}.zip
        ###step3: verify pm1-pm5 in snapshot
        Verify Snapshot has pm logs    path=${snapshot_path}
        ...                            rmod_name_dic=${rmod_name_dic}
        ###step4: verify pm1-pm5 in snapshot
        RUN    rm ${snapshot_path}
    END
    [Teardown]    Case Teardown for CNI133865


[1]AEHC_PM1-PM5_logs_verify_in_snapshot_after_ru_reset
    [Timeout]   25h
    Case Setup for CNI133865
    FOR   ${i}   IN RANGE    ${5}
        ###step1: ru reset
        All RUs Reset
        Wait Until Keyword Succeeds   20m   1m   COAM Check all cells should be onair
        ###step2: get snapshot
        ${curr_data}    DateTime.Get Current Date    UTC    + 8 hours    result_format=%Y-%m-%d-%H_%M_%S
        ${snapshot_path}     Catch Snapshot COAM
        ...    local_file_path=${OUTPUT_DIR}/${TESTNAME}/snapshot_coam_${filename}_${curr_data}.zip
        ###step3: verify pm1-pm5 in snapshot
        Verify Snapshot has pm logs    path=${snapshot_path}
        ...                            rmod_name_dic=${rmod_name_dic}
        ###step4: verify pm1-pm5 in snapshot
        RUN    rm ${snapshot_path}
    END
    [Teardown]    Case Teardown for CNI133865


[1]AEHC_PM1-PM5_logs_verify_in_snapshot_after_bbmod_reset
    [Timeout]   25h
    Case Setup for CNI133865
    COAM Backup Full SCF    file_name=bbmod_reset
    ${bbmodreset_siso_scf_xml}    set variable    ${OUTPUT_DIR}/bbmod_reset.xml
    Set Suite Variable    ${bbmodreset_siso_scf_xml}

    FOR   ${i}   IN RANGE    ${5}
        ###step1: bbmod reset
        log to console    this is time:${i} bbmod reset...
        run keyword if  '${MRBTS_ID}' in @{BBMOD_TL.keys()}     Reset Defined BBMODs    bbmod_index_list=${BBMOD_TL["${MRBTS_ID}"]}
        ...   ELSE    All BBMODs Reset
        Wait Until Keyword Succeeds   20m   1m   COAM Check all cells should be onair
    END
    ###step2: get snapshot
    ${curr_data}    DateTime.Get Current Date    UTC    + 8 hours    result_format=%Y-%m-%d-%H_%M_%S
    ${snapshot_path}     Catch Snapshot COAM
    ...    local_file_path=${OUTPUT_DIR}/${TESTNAME}/snapshot_coam_${filename}_${curr_data}.zip
    ###step3: verify pm1-pm5 in snapshot
    Verify Snapshot has pm logs    path=${snapshot_path}
    ...                            rmod_name_dic=${rmod_name_dic}
    ###step4: rm snapshot
    RUN    rm ${snapshot_path}
    [Teardown]    Case Teardown for CNI133865


[1]AEHC_PM1-PM5_logs_check_RU_downtime
    [Timeout]   25h
    Case Setup for CNI133865
    FOR   ${i}   IN RANGE    ${5}
        ###step1: bbmod reset
        All RUs Reset and check downtime
        Wait Until Keyword Succeeds   20m   1m   COAM Check all cells should be onair
        ###step2: get snapshot
        ${curr_data}    DateTime.Get Current Date    UTC    + 8 hours    result_format=%Y-%m-%d-%H_%M_%S
        ${snapshot_path}     Catch Snapshot COAM
        ...    local_file_path=${OUTPUT_DIR}/${TESTNAME}/snapshot_coam_${filename}_${curr_data}.zip
        ###step3: verify pm1-pm5 in snapshot
        Verify Snapshot has pm logs    path=${snapshot_path}
        ...                            rmod_name_dic=${rmod_name_dic}
        ###step4: verify pm1-pm5 in snapshot
        RUN    rm ${snapshot_path}
    END
    [Teardown]    Case Teardown for CNI133865



[1]AEHC_site_reset_without_hwf
    [Timeout]   25h
    Case Setup for CNI133865
    Recovery At Case Setup if Fault Occurs
    Add HWF Flag at swconfig
    COAM Reset Site
    Wait Until Keyword Succeeds   20m   1m   COAM Check all cells should be onair
    FOR   ${i}   IN RANGE    ${5}
        ###step1: bbmod reset
        AEHC Single time Site Reset
        ###step2: get snapshot
        ${curr_data}    DateTime.Get Current Date    UTC    + 8 hours    result_format=%Y-%m-%d-%H_%M_%S
        ${snapshot_path}     Catch Snapshot COAM
        ...    local_file_path=${OUTPUT_DIR}/${TESTNAME}/snapshot_coam_${filename}_${curr_data}.zip
        ###step3: verify pm1-pm5 in snapshot
        Verify Snapshot has pm logs    path=${snapshot_path}
        ...                            rmod_name_dic=${rmod_name_dic}
        ###step4: verify pm1-pm5 in snapshot
        RUN    rm ${snapshot_path}
    END
    [Teardown]    run keywords    Remove HWF Flag at swconfig   AND   Case Teardown for CNI133865

