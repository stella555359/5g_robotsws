*** Settings ***
Documentation    Common resource about suite/test setup/teardown

*** Variables ***
${SCFC_path}      ${CURDIR}${/}configuration_file

*** Keywords ***
clean up env
    Run Keyword And Ignore Error    Teardown All Aliases For Syslog
    Run Keyword And Ignore Error    sbts_admin.Teardown Admin
    Run Keyword And Ignore Error    WebUI disconnection    suite

Common Suite Setup
    clean up env
    ${timestamp}    Evaluate    time.strftime('%Y%m%d%H%M')    time
    ${FILE_NAME} =    Replace String Using Regexp    ${SUITE_NAME[:50]}    \\s+$    ${EMPTY}
    ${SUITE_LOG_DIRECTORY} =    Catenate    SEPARATOR=${/}    ${OUTPUT_DIR}    ev_logs    ${FILE_NAME}_${timestamp}
    ${SUITE_LOG_DIRECTORY}    Replace String    ${SUITE_LOG_DIRECTORY}    ${SPACE}    _
    Set Suite Variable    ${SUITE_LOG_DIRECTORY}
    Create Directory    ${SUITE_LOG_DIRECTORY}
    Run Keyword And Ignore Error    Get the UE type and index
    ${build_info_dict}=    common_resource_bts.Get L3 build from TargetBD file
    ${ReleasePrefix}    Set Variable    ${build_info_dict['PackageName'].split('_')[0]}
    Set Suite Variable    ${SCFC_path}        ${CURDIR}${/}configuration_file${/}${ReleasePrefix}

Get the UE type and index
    FOR    ${ue}    IN    @{tl.ues}
        Run Keyword If    '4G' in ${ue.capabilities}    Set Suite Variable    ${UE_type_4G}    ${ue.capabilities[-1]}
        Run Keyword If    '5G' in ${ue.capabilities}    Set Suite Variable    ${UE_type_5G}    ${ue.capabilities[-1]}
        ${index_4} =    Run Keyword If    '4G' in ${ue.capabilities}    Get Index From List    ${tl.ues}    ${ue}
        ${index_5} =    Run Keyword If    '5G' in ${ue.capabilities}    Get Index From List    ${tl.ues}    ${ue}
        Run Keyword If    ${index_4}!=None    Set Suite Variable    ${index_4G}    ${index_4}
        Run Keyword If    ${index_5}!=None    Set Suite Variable    ${index_5G}    ${index_5}
    END

Common Suite Teardown
    clean_up_env
    Log to console    \n[INFO]:clean up the env successfully

Common Test Setup
    clean_up_env
    ${TEST_LOG_DIR}    Catenate    SEPARATOR=${/}    ${SUITE_LOG_DIRECTORY}    ${TEST_NAME[:50]}
    ${TEST_LOG_DIR}    Replace String    ${TEST_LOG_DIR}    ${SPACE}    _
    Set Test Variable    ${TEST_LOG_DIR}
    Create Directory    ${TEST_LOG_DIR}

    # generate and upload default swconfig.txt to bts
    modify swconfig file    flags_dict=${None}    local_path=${TEST_LOG_DIR}

    # initial bts connection
    Run Keyword And Ignore Error    WebUI disconnection    suite
    Run Keyword And Ignore Error    ADMIN CLI disconnection
    Run Keyword And Ignore Error    WebUI connection    iq_disable
    Run Keyword And Ignore Error    Disable IQ capture via webUI    sbts=iq_disable
    Run Keyword And Ignore Error    WebUI disconnection    iq_disable

    # Create connection via adminCLI
    Wait Until Keyword Succeeds    90 sec    30 sec    ADMIN CLI connection
    Wait Until Keyword Succeeds    90 sec    30 sec    WebUI connection    suite
    ${is_site_ready}=    run keyword and return status    wait until keyword succeeds    5 min    30 sec    Check SMOD and BBMOD
    run keyword if    '${is_site_ready}'=='False'    get coam alarms    alarm_management=Active
    run keyword if    '${is_site_ready}'=='False'    FAIL    [ERROR] BTS is not ready for commissioning
    ${TLstate}=    run keyword and return status    gNB in onAir state
    ${isCellsOnair}    Run Keyword And Return Status    Check If All Cells Are OnAir
    Run Keyword If    ${isCellsOnair}    Log To Console    \nINFO:❤ BTS is OnAir ❤
    ...    ELSE    Log    [ERROR]BTS is NOT OnAir    level=ERROR
    Start GNB Syslog    ${TEST_LOG_DIR}

Common Test Teardown
    [Arguments]    ${snapshotNeeded}=${True}
    ${L1_ERR_rt_message_num}=     Count Syslog messages    regexp=ERR/l1_application_rt    alias=enb_testSetup
    ${L1_ERR_nrt_message_num}=    Count Syslog messages    regexp=ERR/l1_application_nrt    alias=enb_testSetup
    ${L1_ERR_nrt_message_num}=    Count Syslog messages    regexp=ERR/l1_application    alias=enb_testSetup
    ${L1_WRN_rt_message_num}=     Count Syslog messages    regexp=WRN/l1_application_rt    alias=enb_testSetup
    ${L1_WRN_nrt_message_num}=    Count Syslog messages    regexp=WRN/l1_application_nrt    alias=enb_testSetup
    ${L1_WRN_nrt_message_num}=    Count Syslog messages    regexp=WRN/l1_application    alias=enb_testSetup
    Check L1 ERR and WRN in syslog
    Run Keyword And Ignore Error    Stop Collect GNB Syslog    ${TEST_LOG_DIR}
    Run Keyword And Ignore Error    ute_syslog.Teardown All Aliases For Syslog
    Get Alarms State    alarm_management=Active
    Get Alarms State    alarm_management=Historic
    Run Keyword And Ignore Error    sbts_admin.teardown    connection=${connection}
    Run Keyword And Ignore Error    WebUI disconnection    suite

    ${snapshot}=    Run Keyword If    ${snapshotNeeded}    Save Snapshot Via WebUI
    Run Keyword If    ${snapshotNeeded}    Run Keywords    Filter And Check DU L1 Journal Log    ${snapshot}
    ...    AND    Filter And Check RU L1 Runtime Log    ${snapshot}

Configure TL With Vendor Update
    [Arguments]    ${param_dict}    ${scf_file}    ${btsid}    ${wait_for_onair}=${True}
    vendor_update    ${SUITE_LOG_DIRECTORY}    ${param_dict}    ${scf_file}    ${btsid}
    Run Keyword If    ${wait_for_onair}    Run Keywords
    ...    Wait Until Keyword Succeeds    5 min    30 sec    sbts_admin.connect_to    name=vendor_update
    ...    AND    Wait Until Keyword Succeeds     600s    30s    Check If All Cells Are OnAir    connection=vendor_update
    ...    AND    Log To Console    [INFO]:Update vendor and ❤ BTS is OnAir ❤
    [Teardown]    Run Keyword If    ${wait_for_onair}    sbts_admin.teardown    connection=vendor_update
