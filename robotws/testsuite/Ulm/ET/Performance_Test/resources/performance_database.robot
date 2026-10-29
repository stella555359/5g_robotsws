
*** Settings ***
Documentation    SQLITE3 interface

Library    db/db_interface_insert.py
Library    db/db_interface_retrieve.py

Library    python/hasher.py

Resource     performance_commissioning.robot
Resource     performance_pmcounters.robot

*** Variables ***
${DB_TESTCASE_ID}=                 ${none}
${PREV_DB_TESTCASE_ID}=            ${none}
${PREV_DB_TESTCASE_ID_EMPERF}=     ${none}
${PREV_DB_TESTCASE_ID_KPI}=        ${none}
${PREV_DB_TESTCASE_ID_FLAGGED}=    ${none}

${DB_INTERFACE_RETRIEVE_ONLINE}=   ${False}
${DB_INTERFACE_INSERT_ONLINE}=     ${False}

*** Keywords ***
Initialize DB
    [Arguments]    ${db}=${TP.DB_SQLITE3_DATABASE}
    Connect to database    db_interface_retrieve    db=${db}
    Connect to database    db_interface_insert    db=${db}
    Log to Console     DB_INTERFACE_RETRIEVE_ONLINE: ${DB_INTERFACE_RETRIEVE_ONLINE}, DB_INTERFACE_INSERT_ONLINE: ${DB_INTERFACE_INSERT_ONLINE}

Initialize DB for Testcase
    [Arguments]    ${previous_testname}=${TEST NAME}
    IF    "${TP.DB_TCID_FILTER_TCFLAG_NAME}"!="null" and "${TP.DB_TCID_FILTER_TCFLAG_VALUE}"!="null"
    ...    Get Last Testcase ID from db filter with testcase flag name    ${TP.DB_TCID_FILTER_TCFLAG_NAME}
    ...                                                                   ${TP.DB_TCID_FILTER_TCFLAG_VALUE}
    ...                                                                   testname=${previous_testname}
    IF    "${TP.DB_TCID_FILTER}"!="null"
    ...    Set Suite Variable    $PREV_DB_TESTCASE_ID_FLAGGED    ${TP.DB_TCID_FILTER}

    Get Last Testcase ID from db                     testname=${previous_testname}
    Get Last Testcase ID from db with emperf data    testname=${previous_testname}
    Get Last Testcase ID from db with kpi data       testname=${previous_testname}
    Insert Testcase data
    Insert testline data
    Insert Software data
    Insert Jenkins data
    Insert Testcase flags data
    # Run Keyword And Warn On Failure    Insert SWconfigs data

Connect to database
    [Arguments]    ${module}    ${db}=${TP.DB_SQLITE3_DATABASE}
    ${_}    ${result}    Run Keyword And Warn On Failure    ${module}.connect_to_database    ${db}
    IF     ${result}
        Set Suite Variable    $${module.upper()}_ONLINE    ${True}
    ELSE
        Log    Unable to connect to ${module}: ${db}    level=WARN    console=${true}
    END

Update Testcase Pass data
    [Arguments]    ${testcase_id}=${DB_TESTCASE_ID}
    IF    not ${DB_INTERFACE_INSERT_ONLINE}   RETURN
    ${verdict}    Set Variable If    '${TEST_STATUS}'=='FAIL'    0    1
    db_interface_insert.update_testcase_pass    ${testcase_id}    verdict=${verdict}

Insert Testcase data
    [Arguments]    ${testname}=${TEST NAME}
    IF    not ${DB_INTERFACE_INSERT_ONLINE}   RETURN
    &{data}    Create dictionary    testname=${testname}
    ${DB_TESTCASE_ID}    db_interface_insert.insert_testcase    ${data}
    Set Suite Variable    $DB_TESTCASE_ID
    Append To File        ${WORKSPACE}/properties.txt    DB_TESTCASE_ID=${DB_TESTCASE_ID}\n
    Append To File        ${WORKSPACE}/properties.txt    PREV_DB_TESTCASE_ID=${PREV_DB_TESTCASE_ID}\n
    Append To File        ${WORKSPACE}/properties.txt    PREV_DB_TESTCASE_ID_FLAGGED=${PREV_DB_TESTCASE_ID_FLAGGED}\n
    Set Environment Variable    DB_TESTCASE_ID                   ${DB_TESTCASE_ID}
    Set Environment Variable    PREV_DB_TESTCASE_ID              ${PREV_DB_TESTCASE_ID}
    Set Environment Variable    PREV_DB_TESTCASE_ID_FLAGGED      ${PREV_DB_TESTCASE_ID_FLAGGED}
    ${msg}    Catenate    \n${bar_b}\nCurrent Testcase ID in Database:${DB_TESTCASE_ID}\n
    ...                   ${SPACE} - Previous: ${PREV_DB_TESTCASE_ID}\n
    ...                   ${SPACE} - flag: ${PREV_DB_TESTCASE_ID_FLAGGED}\n
    IF    "${TP.ENABLE_DB_CONSOLE_OUTPUT}"=="true"    Log to console    ${msg}

Insert Emperf data
    [Arguments]    ${data}    ${testcase_id}=${DB_TESTCASE_ID}
    IF    not ${DB_INTERFACE_INSERT_ONLINE}   RETURN
    ${dict}    Create Dictionary    emperf=${data}
    Run Keyword And Warn On Failure    db_interface_insert.insert_emperf_dict    ${testcase_id}     ${dict}

Insert Jenkins data
    [Arguments]    ${testcase_id}=${DB_TESTCASE_ID}
    IF    not ${DB_INTERFACE_INSERT_ONLINE}   RETURN
    &{data}    Create Dictionary          JOB_NAME=${TP.JOB_NAME}
    ...                                   JOB_URL=${TP.JOB_URL}
    ...                                   BUILD_ID=${TP.BUILD_ID}
    ...                                   JOB_DESCRIPTION=${TP.P_JOB_DESCRIPTION.replace("\'","").replace("\"","")}
    Run Keyword And Warn On Failure    db_interface_insert.insert_testcase_jenkins_data    ${testcase_id}     ${data}

Insert Software data
    [Arguments]    ${testcase_id}=${DB_TESTCASE_ID}
    ${sw_release_name} =    gnb . Get Release Name
    IF    not ${DB_INTERFACE_INSERT_ONLINE}   RETURN
    &{data}    Create Dictionary              gnb_load=${SUITE METADATA["gNB Software Info"]}
    ...                                         gnb_hw=${SUITE METADATA["gNB Hardware Info"]}
    ...                                        ap_load=${SUITE METADATA["AP Software Info"]}
    ...                                          ap_hw=${SUITE METADATA["AP Hardware Info"]}
    ...                                    duplex_mode=${SUITE METADATA["Duplex Mode Info"]}
    ...                                     sw_release=${sw_release_name}
    Run Keyword And Warn On Failure    db_interface_insert.insert_software    ${testcase_id}     ${data}

Insert Testcase flags data
    [Arguments]    ${testcase_id}=${DB_TESTCASE_ID}
    IF    not ${DB_INTERFACE_INSERT_ONLINE}   RETURN
    &{data}    Create Dictionary
    FOR     ${key}    IN    @{TSGNBP}
        Set to dictionary    ${data}    testcase_flags_name=${key}
        ...                            testcase_flags_value=${TP['${key}']}
        IF    "${TP['${key}']}"!="null" or "${TP['${key}']}"!="${None}"
        ...    Run Keyword And Warn On Failure    db_interface_insert.insert_testcase_flags    ${testcase_id}     ${data}
    END

Insert testline data
    [Arguments]    ${testcase_id}=${DB_TESTCASE_ID}
    IF    not ${DB_INTERFACE_INSERT_ONLINE}   RETURN
    ${testline_type_id}    Get testline type id from db    ${TP.P_TOPOLOGY}    ${TP.P_VARIANT}
    &{data}    Create Dictionary        testline_name=${SUITE METADATA["Testline Info"]}
    ...                              testline_type_id=${testline_type_id}
    Run Keyword And Warn On Failure    db_interface_insert.insert_testline    ${testcase_id}     ${data}

Insert testcase parameter2
    [Arguments]    ${testcase_parameter2_name}    ${testcase_parameter2_value}    ${testcase_id}=${DB_TESTCASE_ID}
    IF    not ${DB_INTERFACE_INSERT_ONLINE}   RETURN
    Run Keyword And Warn On Failure    db_interface_insert.insert_testcase_parameter2_with_args    ${testcase_id}
    ...                                                                                            ${testcase_parameter2_name}
    ...                                                                                            ${testcase_parameter2_value}

Insert hash
    [Arguments]    ${hash_name}    ${hash_value}    ${hash_content}    ${overwrite}=${False}    ${compress}=${True}
    IF    not ${DB_INTERFACE_INSERT_ONLINE}   RETURN
    ${_}     ${status}    Run Keyword And Warn On Failure    db_interface_insert.insert_hash_if_not_exists      ${hash_name}
    ...                                                                                                         ${hash_value}
    ...                                                                                                         ${hash_content}
    ...                                                                                                         overwrite=${overwrite}
    ...                                                                                                         compress=${compress}
    RETURN    ${status}

Insert testcase results
    [Arguments]    ${testcase_results_name}    ${testcase_results_value}    ${testcase_id}=${DB_TESTCASE_ID}
    IF    not ${DB_INTERFACE_INSERT_ONLINE}   RETURN
    Run Keyword And Warn On Failure    db_interface_insert.insert_testcase_results_with_args    ${testcase_id}
    ...                                                                                         ${testcase_results_name}
    ...                                                                                         ${testcase_results_value}

Insert kpi results
    [Arguments]    ${kpi}    ${testcase_id}=${DB_TESTCASE_ID}
    IF    not ${DB_INTERFACE_INSERT_ONLINE}   RETURN
    Run Keyword And Warn On Failure    db_interface_insert.insert_kpi_dict                      ${testcase_id}
    ...                                                                                         ${kpi}

Insert PM Counters dictionary
    [Arguments]    ${data}    ${testcase_id}=${DB_TESTCASE_ID}
    IF    not ${DB_INTERFACE_INSERT_ONLINE}   RETURN
    Run Keyword And Warn On Failure    db_interface_insert.insert_pmcounters_dict    ${testcase_id}    ${data}

Get Emperf disps from db
    [Arguments]    ${testcase_id}=${PREV_DB_TESTCASE_ID}    ${container}=${None}    ${disp_number}=${None}    ${limit}=1
    IF    not ${DB_INTERFACE_RETRIEVE_ONLINE}   RETURN
    IF    "${testcase_id}"=="${None}"   RETURN     ${None}
    ${_}    ${data}    Run Keyword And Warn On Failure    db_interface_retrieve.get_emperf_disps    ${testcase_id}    container=${container}
    ...                                                                                             disp_number=${disp_number}    limit=${limit}
    RETURN    ${data}

Get pmcounter from db
    [Arguments]    ${piid}    ${distname}    ${testcase_id}=${PREV_DB_TESTCASE_ID}    ${limit}=1
    IF    not ${DB_INTERFACE_RETRIEVE_ONLINE}   RETURN
    ${_}    ${data}    Run Keyword And Warn On Failure    db_interface_retrieve.get_pmcounter
    ...                                           ${testcase_id}    piid_name=${piid}    distname=${distname}    limit=${limit}
    IF    "${testcase_id}"=="${None}"   RETURN     ${None}
    RETURN    ${data}

Get testline type id from db
    [Arguments]    ${topology}    ${variant}
    IF    not ${DB_INTERFACE_RETRIEVE_ONLINE}   RETURN
    ${_}    ${testline_type_id}    Run Keyword And Warn On Failure    db_interface_retrieve.get_testline_type_id    ${topology}    ${variant}
    ${_}    ${new_testline_type_id}    IF    "${testline_type_id}"=="${None}"
    ...    Run Keyword And Warn On Failure    db_interface_insert.insert_testline_type
    ...                                       ${topology}    ${variant}
    IF    "${testline_type_id}"=="${None}"
    ...    Log To Console    New Testline Type Detected ${topology} ${variant}, assigned id: ${new_testline_type_id}
    IF    "${testline_type_id}"=="${None}"   RETURN    ${new_testline_type_id}
    RETURN    ${testline_type_id}

Get Last Testcase ID from db
    [Arguments]    ${testname}=${TEST NAME}
    IF    not ${DB_INTERFACE_RETRIEVE_ONLINE}   RETURN
    ${_}    ${tc_id}    Run Keyword And Warn On Failure    db_interface_retrieve.get_last_testcase_id    ${testname}
    ${tc_id}    IF    "${PREV_DB_TESTCASE_ID_FLAGGED}"!="${None}"    Set Variable    ${PREV_DB_TESTCASE_ID_FLAGGED}
    ...                                                      ELSE    Set Variable    ${tc_id}
    Set Suite Variable    $PREV_DB_TESTCASE_ID    ${tc_id}
    RETURN    ${PREV_DB_TESTCASE_ID}

Get Last Testcase ID from db with emperf data
    [Arguments]    ${testname}=${TEST NAME}
    IF    not ${DB_INTERFACE_RETRIEVE_ONLINE}   RETURN
    ${_}    ${tc_id}    Run Keyword And Warn On Failure    db_interface_retrieve.get_last_testcase_id_with_emperf_data    ${testname}
    ${tc_id}    IF    "${PREV_DB_TESTCASE_ID_FLAGGED}"!="${None}"    Set Variable    ${PREV_DB_TESTCASE_ID_FLAGGED}
    ...                                                      ELSE    Set Variable    ${tc_id}
    Set Suite Variable    $PREV_DB_TESTCASE_ID_EMPERF    ${tc_id}
    RETURN    ${PREV_DB_TESTCASE_ID_EMPERF}

Get Last Testcase ID from db with kpi data
    [Arguments]    ${testname}=${TEST NAME}
    IF    not ${DB_INTERFACE_RETRIEVE_ONLINE}   RETURN
    ${_}    ${tc_id}    Run Keyword And Warn On Failure    db_interface_retrieve.get_last_testcase_id_with_kpi_data    ${testname}
    ${tc_id}    IF    "${PREV_DB_TESTCASE_ID_FLAGGED}"!="${None}"    Set Variable    ${PREV_DB_TESTCASE_ID_FLAGGED}
    ...                                                      ELSE    Set Variable    ${tc_id}
    Set Suite Variable    $PREV_DB_TESTCASE_ID_KPI    ${tc_id}
    RETURN    ${PREV_DB_TESTCASE_ID_KPI}

Get Last Testcase ID from db filter with testcase flag name
    [Arguments]    ${testcase_flags_name}    ${testcase_flags_value}    ${testname}=${TEST NAME}
    Log to console    DB Filter Set testcase_flag_name: ${testcase_flags_name}=${testcase_flags_value}
    IF    not ${DB_INTERFACE_RETRIEVE_ONLINE}   RETURN
    ${_}    ${tc_id}    Run Keyword And Warn On Failure    db_interface_retrieve.get_testcase_id_fiter_with_testcase_flag_name
    ...                                                ${testname}    ${testcase_flags_name}
    ...                                                ${testcase_flags_value}
    Set Suite Variable    $PREV_DB_TESTCASE_ID_FLAGGED    ${tc_id}
    RETURN    ${PREV_DB_TESTCASE_ID_FLAGGED}


Get Hashes
    ${tp_hash}    ${tp_json}    hasher.Get Rf Dictionary Sha256sum    ${TP}

    ${hash_scf}   ${hash_scf_db}    performance_commissioning.Store SCF Hash    ${TS_UPDATED_SCF}
    ${hash_iphy}   ${hash_iphy_db}    performance_commissioning.Store Current Iphy Hash

    ${hash_gnb_swconfig}    hasher.Get Swconfig Sha256sum    ${S_GNB_SWCONFIG}
    ${hash_ap_swconfig}     hasher.Get Swconfig Sha256sum    ${S_AP_SWCONFIG}
    ${hash_vendor}          hasher.Get Vendor Sha256sum      ${TS_VENDOR_MOD}
    IF    "${hash_vendor}"!="null"
        ${vendor_content}    Get File    ${TS_VENDOR_MOD}
    ELSE
        ${vendor_content}    Set Variable    null
    END

    ${hash_all}=           Catenate    SEPARATOR=;
    ...                    ${TC_ARGS_HASH}    ${tp_hash}    ${hash_ap_swconfig}
    ...                    ${hash_gnb_swconfig}    ${hash_iphy}    ${hash_scf}    ${hash_vendor}
    ${hash_testcase}=      hasher.Get Sha256sum From Str    ${hash_all}

    performance_database.Insert Testcase Parameter2    hash_testsuite_parameters     ${tp_hash}
    performance_database.Insert Testcase Parameter2    hash_testcase                 ${hash_testcase}
    performance_database.Insert Testcase Parameter2    hash_gnb_swconfig             ${hash_gnb_swconfig}
    performance_database.Insert Testcase Parameter2    hash_ap_swconfig              ${hash_ap_swconfig}
    performance_database.Insert Testcase Parameter2    hash_vendor                   ${hash_vendor}

    ${hash_testcase_db}        performance_database.Insert Hash    hash_testcase     ${hash_testcase}
    ...                                                                              tcid:${DB_TESTCASE_ID}, ${TEST_NAME}, ${P_JOB_DESCRIPTION}
    ...                                                                                          overwrite=${True}
    ...                                                                                          compress=${False}
    ${tp_hash_db}              performance_database.Insert Hash    hash_testsuite_parameters     ${tp_hash}              ${tp_json}
    ${hash_gnb_swconfig_db}    performance_database.Insert Hash    hash_gnb_swconfig             ${hash_gnb_swconfig}    ${S_GNB_SWCONFIG}
    ${hash_ap_swconfig_db}     performance_database.Insert Hash    hash_ap_swconfig              ${hash_ap_swconfig }    ${S_AP_SWCONFIG}
    ${hash_vendor_db}          performance_database.Insert Hash    hash_vendor                   ${hash_vendor}          ${vendor_content}

    ${hash_info_fmt}    Catenate    \n${bar_b}\nHashes:\n{: >20}: {}\n{: >20}: {}\n{: >20}: {}\n{: >20}: {}
    ...                             \n{: >20}: {}\n{: >20}: {}\n{: >20}: {}\n{: >20}: {}
    ${hash_info}    Format String    ${hash_info_fmt}
    ...    Test Case        ${hash_testcase} (${hash_testcase_db})
    ...    Run Args         ${TC_ARGS_HASH} (${TC_ARGS_HASH_DB})
    ...    Test Suite       ${tp_hash} (${tp_hash_db})
    ...    ap swconfig      ${hash_ap_swconfig} (${hash_ap_swconfig_db})
    ...    gNB swconfig     ${hash_gnb_swconfig} (${hash_gnb_swconfig_db})
    ...    iphy             ${hash_iphy} (${hash_iphy_db})
    ...    scf              ${hash_scf} (${hash_scf_db})
    ...    vendor           ${hash_vendor} (${hash_vendor_db})
    Log To Console    ${hash_info}
