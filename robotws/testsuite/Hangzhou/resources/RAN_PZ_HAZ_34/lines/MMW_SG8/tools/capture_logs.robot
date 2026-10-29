*** Settings ***
Documentation
...    Author:yin zhang
...    contact:yin.zhang@nokia-sbell.com
...    squad group:VRF3_7
Suite Setup       DevHZ5_common_resource.Common Suite Setup
Suite Teardown    Common Suite Teardown
Test Setup        Test Setup
Test Teardown     Test Teardown
Resource          ../resources/DevHZ5_resource_ST.robot

*** Variables ***
${SNAPSHOT_FLAG}    pass:True,fail:True
${GNB_BIP_FLAG}    ${True}
${TTITRACE_FLAG}    ${True}
${EMIL_FLAG}    ${False}
${RRU_LMI_FLAG}    ${False}
${ERR_WRN_STATISTICS}    True

@{FAULTS_EXCLUDED_CHECKING}    8000

# don't change the following setting
${AUTO_ANALYSIS_FLAG}    ${False}
${ERR_WARN_ANALYSE_FLAG}    ${False}


*** Test Cases ***
Capture Logs
    Log To Console    ${EMPTY}
    Log To Console    \##########################
    Log To Console    You can start your testing now
    Log To Console    Press CTRL-C for only one time if finished...
    Sleep    10h

*** Keywords ***
Test Setup
    Common Test Setup And Start To Capture Logs
    Get Current Scf File    local_dir_path=${SAVE LOG DIRECTORY}
    ...  file_name=scf_before_test.xml  export_type=configurationAndRuntimeObjects

Test Teardown
    Common Test Teardown And Stop Capture Logs
