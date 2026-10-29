*** Settings ***
Library     OperatingSystem
Library     Process
Library     Collections
Library     DateTime
Library     String

*** Keywords ***
Create Suite Directory
    [Documentation]    This keyword is to create a directory for storing suite level logs.
    ...
    ...    ${SUITE_LOG_DIRECTORY} is a suite variable.
    ...    before refine: Test_Suite_Folder_1605087516120
    ...    after refine: Test_Suite_Folder_20201112151625116
    Log To Console    Create Suite Directory...
    Log    ${SUITE_NAME}
    ${time_string}    DateTime.Get Current Date    result_format=timestamp
    ${time_string}    String.Replace String Using Regexp    ${time_string}    (-|:|\\.|\\s)    ${EMPTY}
    ${suite_name2}    String.Replace String    ${SUITE_NAME}    ${SPACE}    _
    Create Directory    ${OUTPUT_DIR}/${suite_name2}_${time_string}
    Set Suite Variable    ${SUITE_LOG_DIRECTORY}    ${OUTPUT_DIR}/${suite_name2}_${time_string}

Create Test Directory
    [Documentation]    This keyword is to create a directory for storing case level logs.
    ...
    ...        ${TEST_LOG_DIRECTORY} is a test variable.
    Log To Console    Create Case Directory...
    ${SUITE_LOG_DIRECTORY}    Get Variable Value    ${SUITE_LOG_DIRECTORY}    ${EMPTY}
    Run Keyword If    "${SUITE_LOG_DIRECTORY}"=="${EMPTY}"    Create Suite Directory
    ${test_name2}    string.Replace String    ${TEST_NAME[:50]}    ${space}    _
    Create Directory    ${SUITE_LOG_DIRECTORY}/${test_name2}
    Set Test Variable    ${TEST_LOG_DIRECTORY}    ${SUITE_LOG_DIRECTORY}/${test_name2}

Wait for Cell onair
    [Arguments]    ${gnb_index}=${0}
    # Full Commission With SCF File    ${scf_file}
    Check gNB RU status ready    gnb_index=${gnb_index}
    Check gNB cell status onair    gnb_index=${gnb_index}

# Full Commission With SCF File
#     [Arguments]    ${scf_file}    ${auto_update}=False
#     [Documentation]    This keyword is to update parameters
#     COAM.Setup Admin
#     COAM.Perform Commissioning
#     ...    scf_file=${scf_file}
#     ...    skip_parameter_relation_errors=True
#     ...    should_activate=True
#     ...    timeout=300
#     [Teardown]    Run Keyword And Ignore Error    COAM.Teardown

Check gNB RU status ready
    [Arguments]    ${gnb_index}=${0}
    wait until keyword succeeds    10min   30s    Connect to gnb coam via ssl   connection=GNB_OAM
    ...    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    wait until keyword succeeds    10min   30s    COAM Check GNB RU status
    [Teardown]    COAM Teardown gnb connections

Check gNB cell status onair
    [Arguments]    ${gnb_index}=${0}
    Connect to gnb coam via ssl   connection=GNB_OAM    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    wait until keyword succeeds    10min   30s    COAM Check GNB cell on air
    [Teardown]    COAM Teardown gnb connections
