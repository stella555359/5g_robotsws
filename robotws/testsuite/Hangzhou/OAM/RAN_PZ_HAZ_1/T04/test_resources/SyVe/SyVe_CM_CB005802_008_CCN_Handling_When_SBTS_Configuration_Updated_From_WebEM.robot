*** Settings ***
Documentation       Test case for xxx
...                 Author: xxx
...                 Contact: xxx.xx@nokia.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${SRNCLAB}      SRNCLAB1019    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
${PLAN_FILE_EXPROT_ACTUAL1}    open_api_actuals_exported_008_1.xml
${PLAN_FILE_EXPROT_ACTUAL2}    open_api_actuals_exported_008_2.xml
${DELTA_COMMISSION_TEMPLATE}    delta_commission_template.json
${SKIP_PARAM_RELATION_ERRORS}    ${True}    # Should relation errors be skipped (True, False)
# Absolute path to commissioning file
${FULL_COMMISSIONING_PATH}    /home/ute/btsauto/hran_ta/config/${HW_LOCATION_CODE}/${TESTLINE_NAME}/commissioning/SCF_01_SBTS18.xml
${TEST_DATA_PATH}     /home/ute/btsauto/hran_ta/config/${HW_LOCATION_CODE}/${TESTLINE_NAME}/testdata/TestDataNOM
${PARAMS_JSON}    params.json

*** Keywords ***
SyVe_CM_CB005802_008_CCN_Handling_When_SBTS_Configuration_Updated_From_WebEM
    [Documentation]     [CASE LINK]: https://jira3.ext.net.nokia.com/browse/TAT-22269
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    Test for performing cm parameter update and full commission from SBTS and check value from NOM
    ...
    ...    The main steps performed for the test are:
    ...    - Check initial BTS state
    ...    - DeltaCommission via ADMIN API
    ...    - Check CM Parameter Value From NOM Open API After Delta Commission
    ...    - FullCommission via ADMIN API
    ...    - Check CM Parameter Value From NOM Open API After Full Commissioon
    ...    - Check final BTS state
    ...
    ...    Pass criteria: Parameter value will be updated from NOM once changed from SBTS
    ...
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 26.11.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22269
    ...    - SyVe_CM_CCN_Handling_When_SBTS_Configuration_Updated_From_WebEM_CB005802_008
    ...    - 23.03.2022 - Modified by Kang Lixin - https://jira3.ext.net.nokia.com/browse/TAT-22847
    ...    - Update case for switching ute_admin to taf.sbts.oam.coam.admin
    ...
    ...    *******************
    ...    Test case flowchart
    ...    *******************
    ...    .. image:: https://jira3.ext.net.nokia.com/browse/
    ...    TAT-22269_SyVe_CM_CCN_Handling_When_SBTS_Configuration_Updated_From_WebEM_CB005802_008.png

    Set Tags    AUTHOR-lixin.kang@nokia-sbell.com    Maintainer–I_NSB_MN_RAN_PZ_1_HAZ_11@internal.nsn.com
    Step 1: Check initial BTS state
    Step 2: DeltaCommission via ADMIN API
    Step 3: Check CM Parameter Value From NOM Open API After Delta Commission
    Step 4: FullCommission via ADMIN API
    Step 5: Check CM Parameter Value From NOM Open API After Full Commissioon
    Step 6: Check final BTS state

Step ${index}: Check ${when} BTS state
    [Documentation]    BTS each RAT procedural state is checked to be OnAir (at least one cell operational)
    ...    BTS State is checked according to ute_admin get parameters for all BTS. The JSON returned contains informations
    ...    such as btsName, btsId, btsProceduralstate
    ...    KW checks if BTS State is onAir. If not, it will fail with received state.
    Log    Step ${index}: Check ${when} BTS state    console=True
    Wait Until Keyword Succeeds    3 min    10 sec    Check BTS RAT Procedural State
    Admin Check Overall BTS Procedural State TAF

Step ${index}: DeltaCommission via ADMIN API
    Log To Console    Step ${index}: DeltaCommission via ADMIN API
    Create Random Test Data JSON    ${TEST_DATA_PATH}/${PARAMS_JSON}
    coam.perform_delta_recommissioning    ${NOMLogs}/tmp_data.json    ${SKIP_PARAM_RELATION_ERRORS}

Step ${index}: FullCommission via ADMIN API
    Log To Console    Step ${index}: FullCommission via ADMIN API    console=True
    ${RECOVERY_PARAM_VALUE}=    Get Original Parameter Value From SCF    ${FULL_COMMISSIONING_PATH}    ${DN_NAME}    ${PARAM_NAME}
    Set Test Variable    ${RECOVERY_PARAM_VALUE}
    BuiltIn.Log  Commissioning via ADMIN will be performed  console=True
    coam.perform_commissioning   ${CM_NE_ID}  ${FULL_COMMISSIONING_PATH}  skip_parameter_relation_errors=${SKIP_PARAM_RELATION_ERRORS}
    ...     timeout=600
    Wait Until Keyword Succeeds    10m    10s    Check SBTS SMOD RMOD Cells Alarms

Step ${index}: Check CM Parameter Value From NOM Open API After Delta Commission
    Log To Console    Step ${index}: Check CM Parameter Value From NOM Open API
    Wait Until Keyword Succeeds    60s    20s    Check CM Parameter Value From NOM Actual Plan
    ...    ${NE_INTEGRATED_ID}    ${DN_NAME}    ${PARAM_NAME}=${PARAM_VALUE}

Step ${index}: Check CM Parameter Value From NOM Open API After Full Commissioon
    Log To Console    Step ${index}: Check CM Parameter Value From NOM Open API After Full Commission
    Wait Until Keyword Succeeds    180s    30s    Check CM Parameter Value From NOM Actual Plan
    ...    ${NE_INTEGRATED_ID}    ${DN_NAME}    ${PARAM_NAME}=${RECOVERY_PARAM_VALUE}

TC Setup
    [Arguments]     ${reIntegrateNeFlag}=${FALSE}
    NOM Common Test Setup    ReIntegrateNE=${reIntegrateNeFlag}

TC Teardown
    NOM Common Test Teardown
