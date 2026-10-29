*** Settings ***
Documentation       Test case for
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${REPEAT_TIME}    1
${COMMISSIONING_PATH}    /home/ute/testline_configuration/${TESTLINE_NAME}/commissioning/SCF_01_SBTS18.xml
${SKIP_PARAM_RELATION_ERRORS}    ${TRUE}    # Should relation errors be skipped (True, False)
${COMMISSIONING_TIMEOUT}    600    # Timeout for commissioning procedure (scf upload, reset indication, wait for reconnection after reset)

*** Keywords ***
CM__Full_Commissioning
    [Documentation]    [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-xxx
    ...
    ...    *****************
    ...    Basic information
    ...    *****************
    ...
    ...    TC for SBTS commissioning from given SCF file via ADMIN API.
    ...
    ...    | *Parameters* | *Example* |
    ...    | COMMISSIONING_PATH | /home/ute/btsauto/hran_ta/config/Wroclaw/SBTS_18232_Skomiszon/commissioning/SCF_02_SBTS18.xml |
    ...    | COMMISSIONING_TIMEOUT | 600 |
    ...
    ...    ******************
    ...    History of changes
    ...    ******************

    ...    *******************
    ...    Test case flowchart
    ...    *******************
    ...
    ...    .. image:: http://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/TAT-4859_01.png
    Set Tags    CM    AUTHOR-lixin.kang@nokia-sbell.com     OWNER-II_NSB_MN_RAN_PZ_1_HAZ_11@internal.nsn.com
    LOG    ${TEST_NAME} start.    console=${True}
    Step 1: Repeat Full Commissioning

*** Keywords ***
Step 1: Repeat Full Commissioning
    FOR    ${index}    IN RANGE    1    ${${REPEAT_TIME}+1}
        SBTS commissioning
        Check SBTS state after commissioning
    END

SBTS commissioning
    [Timeout]    20 min
    Log    SBTS commissioning    console=True
    ${bts_id}    Admin Get BTS ID
    Log    Parameter bts_id: ${bts_id}    console=True
    Log    Commissioning via ADMIN will be performed    console=True
    coam.Perform Commissioning    ${bts_id}    ${COMMISSIONING_PATH}    skip_parameter_relation_errors=${SKIP_PARAM_RELATION_ERRORS}
    ...    timeout=${COMMISSIONING_TIMEOUT}
    Log    Commissioning done. Check BTS states will be performed    console=True

Check SBTS state after commissioning
    [Timeout]    30 minutes
    Log    Check SBTS state after commissioning    console=True
    Wait Until Keyword Succeeds    30 min    20 sec    Check SBTS SMOD RMOD Cells Alarms
