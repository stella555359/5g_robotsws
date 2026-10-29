*** Settings ***
Documentation       Test case for xxx
...                 Author: xxx
...                 Contact: xxx.xx@nokia.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${SRNCLAB}      SRNCLAB1019    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
${PLAN_FILE_IMPORT_NAME}    cm_plan_generated_for_nom_open_api_003.xml
${PLAN_FILE_EXPROT_ACTUAL}    open_api_actuals_exported_003.xml
${PLAN_FILE_GENERATED_NOM_OPEN_API}    cm_plan_generated_for_nom_open_api_003.xml
${TEST_DATA_PATH}     /home/ute/btsauto/hran_ta/config/${HW_LOCATION_CODE}/${TESTLINE_NAME}/testdata/TestDataNOM
${PARAMS_JSON}    params.json
${MULTI_PLAN_TEMPLATE}    multi_cm_plan_template_for_nom_open_api.xml
${CM_NE_ID2}    MRBTS-1816

*** Keywords ***
SyVe_CM_CB005802_003_SBTS_Plan_Download_And_Validation_From_NOM
    [Documentation]    [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-
    ...
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    Test for performing cm plan download and validate from NOM
    ...
    ...    The main steps performed for the test are:
    ...
    ...     - Check initial BTS state
    ...     - CM Upload From NOM Open API
    ...     - Export Actual Configuration From NOM Open API
    ...     - Generate XML File For Configuration Download Activate
    ...     - Import CM Plan With Multi NEs To NOM
    ...     - Download And Validate Plan From NOM Open API
    ...     - Check final BTS state
    ...
    ...    Pass criteria: cm plan download and validate success from NOM
    ...
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 26.11.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22269
    ...    - SyVe_CM_SBTS_Plan_Download_And_Validation_From_NOM_CB005802_003
    ...    - 23.03.2022 - Modified by Kang Lixin - https://jira3.ext.net.nokia.com/browse/TAT-22847
    ...    - Update case for switching ute_admin to taf.sbts.oam.coam.admin
    ...
    ...    *******************
    ...    Test case flowchart
    ...    *******************
    ...    .. image:: http://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SYVE/
    ...    TAT-22269_SyVe_CM_SBTS_Plan_Download_And_Validation_From_NOM_CB005802_003.png

    Set Tags    AUTHOR-lixin.kang@nokia-sbell.com    Maintainer–I_NSB_MN_RAN_PZ_1_HAZ_11@internal.nsn.com
    Step 1: Check initial BTS state
    Step 2: CM Upload From NOM Open API
    Step 3: Export Actual Configuration From NOM Open API
    Step 4: Generate XML File For Configuration Download Activate
    Step 5: Import CM Plan With Multi NEs To NOM
    Step 6: Download And Validate Plan From NOM Open API
    Step 7: Check final BTS state

Step ${index}: Check ${when} BTS state
    [Documentation]    BTS each RAT procedural state is checked to be OnAir (at least one cell operational)
    ...    BTS State is checked according to ute_admin get parameters for all BTS. The JSON returned contains informations
    ...    such as btsName, btsId, btsProceduralstate
    ...    KW checks if BTS State is onAir. If not, it will fail with received state.
    Log    Step ${index}: Check ${when} BTS state    console=True
    Wait Until Keyword Succeeds    3 min    10 sec    Check BTS RAT Procedural State
    Admin Check Overall BTS Procedural State TAF

Step ${index}: CM Upload From NOM Open API
    Log To Console      Step ${index}: CM Upload From NOM Open API
    Set Variable For Multi NE    ${CM_NE_ID2}
    CM Parameter Upload NOM Open API    ${NE_INTEGRATED_ID_MULTI}

Step ${index}: Export Actual Configuration From NOM Open API
    Log To Console      Step ${index}: Export Actual Configuration From NOM Open API
    ${output_actuals_file}=    Set Variable     ${NOMLogs}/${PLAN_FILE_EXPROT_ACTUAL}
    CM Export Actual Configuration NOM Open API    ${NE_INTEGRATED_ID_MULTI}     ${output_actuals_file}

Step ${index}: Import CM Plan With Multi NEs To NOM
    Log To Console      Step ${index}: Import CM Plan To NOM
    CM Plan Import NOM Open API    ${PLAN_FILE_IMPORT_PATH}    ${PLAN_FILE_GENERATED_NOM_OPEN_API_WITH_TIME}

Step ${index}: Download And Validate Plan From NOM Open API
    Log To Console      Step ${index}: Download And Validate Plan From NOM Open API
    CM Plan Download NOM Open API    ${PLAN_FILE_GENERATED_NOM_OPEN_API_WITH_TIME}
    CM Plan Validate NOM Open API    ${PLAN_FILE_GENERATED_NOM_OPEN_API_WITH_TIME}

Step ${index}: Generate XML File For Configuration Download Activate
    Log To Console     Step ${index}: Generate XML File For Configuration Download Activate
    Generate Random Test Data    ${NOMLogs}/${PLAN_FILE_EXPROT_ACTUAL}    ${TEST_DATA_PATH}/${PARAMS_JSON}
    Generate Random Test Data    ${NOMLogs}/${PLAN_FILE_EXPROT_ACTUAL}    ${TEST_DATA_PATH}/${PARAMS_JSON}   2
    Generate CM Plan With Timestamp from XML Template For NOM Open API    ${TEST_DATA_PATH}/${MULTI_PLAN_TEMPLATE}

TC Setup
    [Arguments]     ${reIntegrateNeFlag}=${FALSE}
    NOM Common Test Setup    ReIntegrateNE=${reIntegrateNeFlag}

TC Teardown
    NOM Common Test Teardown