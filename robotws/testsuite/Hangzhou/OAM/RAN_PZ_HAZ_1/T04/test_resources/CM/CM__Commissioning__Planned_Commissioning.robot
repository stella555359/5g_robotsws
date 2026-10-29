*** Settings ***
Documentation       Test case for
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${COMMISSIONING_PATH}    /home/ute/btsauto/hran_ta/config/${HW_LOCATION_CODE}/${TESTLINE_NAME}/commissioning/SCF_01_SBTS18.xml
${SKIP_PARAM_RELATION_ERRORS}    ${TRUE}    # Should relation errors be skipped (True, False)
${COMMISSIONING_TIMEOUT}    600    # Timeout for commissioning procedure (scf upload, reset indication, wait for reconnection after reset)
${IS_COMMISSIONED}    ${True}

*** Keywords ***
CM__Commissioning__Planned_Commissioning
    [Documentation]    [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-4859
    ...
    ...    *****************
    ...    Basic information
    ...    *****************
    ...
    ...    TC for SBTS commissioning from given SCF file via ADMIN API. BTS should be in 'notCommissioned' state.
    ...
    ...    | *Parameters* | *Example* |
    ...    | COMMISSIONING_PATH | /home/ute/btsauto/hran_ta/config/Wroclaw/SBTS_18232_Skomiszon/commissioning/SCF_02_SBTS18.xml |
    ...    | COMMISSIONING_TIMEOUT | 600 |
    ...
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 20.12.2016 - https://jira3.int.net.nokia.com/browse/TAT-4859 - Test creation
    ...    - 06.03.2017 - https://jira3.int.net.nokia.com/browse/TAT-5741 - Resolve minor bugs
    ...    - 07.03.2017 - https://jira3.int.net.nokia.com/browse/TAT-5744 - Add manual method for SCF loading
    ...    - 21.03.2017 - https://jira3.int.net.nokia.com/browse/TAT-6040 - Minor modifications
    ...    - 03.07.2017 - https://jira3.int.net.nokia.com/browse/TAT-6846
    ...                 - Bug for Xpath error. Corrections for new SOAMIF (new KW signature, erase raw procedure)
    ...    - 12.07.2017 - https://jira3.int.net.nokia.com/browse/TAT-7116 - Add checking if BTS is in notCommisioned state according to InfoModel
    ...    - 14.08.2017 - https://jira3.int.net.nokia.com/browse/TAT-7017
    ...                 - Remove waiting for reset event in IM as ADMIN KW cover the BTS reconnection waiting
    ...    - 26.09.2017 - https://jira3.int.net.nokia.com/browse/TAT-7814 - Replace the postcondition check
    ...    - 02.10.2017 - https://jira3.int.net.nokia.com/browse/TAT-7902 - Correct not found KW bug
    ...    - 17.10.2017 - https://jira3.int.net.nokia.com/browse/TAT-8063 - Correct path for IM activeSWversion
    ...    - 02.11.2017 - https://jira3.int.net.nokia.com/browse/TAT-8071
    ...                 - add verify BTS proceduralState in Common Test Setup, delete Admin Check BTS state
    ...    - 07.04.2021 - Remove unused keyword and infomodel related steps.
    ...    - 17.05.2023 - Update due to CB007500
    ...    - 01.08.2023 - Update due to SW infor model changed
    ...    *******************
    ...    Test case flowchart
    ...    *******************
    ...
    ...    .. image:: http://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/TAT-4859_01.png
    Set Tags    CM    AUTHOR-lixin.kang@nokia-sbell.com     OWNER-II_NSB_MN_RAN_PZ_1_HAZ_11@internal.nsn.com
    LOG    ${TEST_NAME} start.    console=${True}
    Step 1: Check commissioning file presence
    Step 2: SBTS commissioning
    Step 3: Check SBTS state after commissioning

*** Keywords ***
Step ${index}: Check commissioning file presence
    [Timeout]    15 min
    Log    Step ${index}: Check commissioning file presence    console=True
    Set Test Variable    ${COMMISSIONING_PATH}    ${BTS_scf_initial}
    ${file_status}    Run keyword and return status    OperatingSystem.File should exist    ${COMMISSIONING_PATH}
#    Run keyword unless    ${file_status}    Fail    File ${COMMISSIONING_PATH} doesn't exist
    Run Keyword If    '${file_status}'!='${True}'    Fail    File ${COMMISSIONING_PATH} doesn't exist
    Log    Commissioning file exists at ${COMMISSIONING_PATH}    console=True

Step ${index}: SBTS commissioning
    [Timeout]    20 min
    Log    Step ${index}: SBTS commissioning    console=True
    ${bts_id}    Admin Get BTS ID
    Log    Parameter bts_id: ${bts_id}    console=True
    Log    Commissioning via ADMIN will be performed    console=True
    ${time}    BuiltIn.Get Time    time_=UTC + 8 hour
    Set Test Variable    ${COMMISSION_START_TIME}    ${time}
    coam.Perform Commissioning    ${bts_id}    ${COMMISSIONING_PATH}    skip_parameter_relation_errors=${SKIP_PARAM_RELATION_ERRORS}
    ...    timeout=${COMMISSIONING_TIMEOUT}
    Log    Commissioning done. Check BTS states will be performed    console=True
    Set Test Variable    ${IS_COMMISSIONED}    ${True}

Step ${index}: Check SBTS state after commissioning
    [Timeout]    30 minutes
    Log    Step ${index}: Check SBTS state after commissioning    console=True
    Wait Until Keyword Succeeds    30 min    60 sec    Check_SBTS_SMOD_RMOD_Cells_Alarms
    ${time}    BuiltIn.Get Time    time_=UTC + 8 hour
    Set Test Variable    ${SBTS_SETUP_TIME}    ${time}
    ${alarms_status}    ${alarms_msg}    Run Keyword And Ignore Error    Admin Check Active Alarms TAF    critical_patterns=${critical_patterns}
    ...    ignored_patterns=${ignored_patterns}

CaseSetUp
    Common Test Setup SBTS    scf_check=${FALSE}
    SBTS Admin Reset Configuration
    Set Test Variable    ${IS_COMMISSIONED}    ${False}
    ute_admin_infomodel.Query Infomodel    none //BTS_L-* is [storedRole=regex"Active|Single|Idle"]

CaseTearDown
    LOG    TestTearDown    console=${True}
    ${time}    Get Time    epoch
#    Run Keyword Unless    ${IS_COMMISSIONED}    Admin Get bts_id and perform commissioning
    Run Keyword If    '${IS_COMMISSIONED}'!='${True}'    Admin Get bts_id and perform commissioning
    ...    ${COMMISSIONING_PATH}    ${SKIP_PARAM_RELATION_ERRORS}    timeout=600
    Wait Until Keyword Succeeds    20 min    60 sec    Check_SBTS_SMOD_RMOD_Cells_Alarms
    Common Test Teardown SBTS

SBTS Admin Reset Configuration
    Log To Console    Starting Configuration Reset
    Run Keyword If    '${SMOD1['HW_TYPE']}'=='FSMF'    SBTS Admin Reset Configuration FSMF
    ...    ELSE    SBTS Admin Reset Configuration AirScale