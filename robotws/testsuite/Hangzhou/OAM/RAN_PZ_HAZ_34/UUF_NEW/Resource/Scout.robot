*** Settings ***
Documentation
    ...    Author: yin.4.chen@nokia-sbell.com

Resource   Common.robot


*** Keywords ***
UUF Requset ConfigurationID
    ${TESTLINE_CONFIGURATION_MAPPING_JSON_PATH}   OperatingSystem.Join Path   ${OUTPUT_DIR}   TESTLINE_CONFIGURATION_MAPPING.json

    ${file_not_exist}   Run Keyword And Return Status
    ...   OperatingSystem.File Should Not Exist   ${TESTLINE_CONFIGURATION_MAPPING_JSON_PATH}
    Run Keyword If   ${file_not_exist}   OperatingSystem.Create File   ${TESTLINE_CONFIGURATION_MAPPING_JSON_PATH}   {}

    ${TESTLINE_CONFIGURATION_MAPPING_JSON}   OperatingSystem.Get File   ${TESTLINE_CONFIGURATION_MAPPING_JSON_PATH}
    ${TESTLINE_CONFIGURATION_MAPPING}   Evaluate   json.loads('${TESTLINE_CONFIGURATION_MAPPING_JSON}')   json

    # &{TESTLINE_CONFIGURATION_MAPPING}   Create Dictionary
    FOR   ${testline}   IN   @{ALL_GNB_LIST}   @{ALL_ENB_LIST}
        ${configuration_id}   Get Variable Value   ${TESTLINE_CONFIGURATION_MAPPING["${testline}"]}   ${EMPTY}
        Continue For Loop If   "${configuration_id}"!="${EMPTY}"

        ${configuration_id}   Single Testline Requset ConfigurationID   testline=${testline}
        Continue For Loop If   "${configuration_id}"=="${EMPTY}"

        Set To Dictionary   ${TESTLINE_CONFIGURATION_MAPPING}   ${testline}=${configuration_id}
    END
    Log To Console   ${TESTLINE_CONFIGURATION_MAPPING}
    Set Suite Variable   ${TESTLINE_CONFIGURATION_MAPPING}

    ${TESTLINE_CONFIGURATION_MAPPING_STR}   Evaluate   json.dumps(${TESTLINE_CONFIGURATION_MAPPING})   json
    OperatingSystem.Create File   ${TESTLINE_CONFIGURATION_MAPPING_JSON_PATH}   ${TESTLINE_CONFIGURATION_MAPPING_STR}


Single Testline Requset ConfigurationID
    [Arguments]   ${testline}
    ${scout_tl}   Get Variable Value   ${SCOUT_TESTLINE_MAPPING["${testline}"]}   ${EMPTY}
    Return From Keyword If   "${scout_tl}"=="${EMPTY}"   ${EMPTY}

    ${status}   ${configuration_id}   Run Keyword And Ignore Error
    ...   Wait Until Keyword Succeeds   3x   1m   UUF Request SCF By Scout   scout_tl=${scout_tl}
    ${configuration_id}   Set Variable If   "${status}"=="PASS"   ${configuration_id}   ${EMPTY}
    [Return]   ${configuration_id}


UUF Request SCF By Scout
    [Timeout]    3m
    [Arguments]    ${scout_tl}
    ${tl_on_scout}    Run Keyword And Return Status   scout.setup_scout   ${scout_tl}
    Return From Keyword If   '${tl_on_scout}'=='False'   ${EMPTY}
    ${configuration_id}   scout.request_scf   use_scout_internal_id=${True}
    [Return]   ${configuration_id}
    [Teardown]    Run Keyword If   ${tl_on_scout}   scout.teardown_scout_api

