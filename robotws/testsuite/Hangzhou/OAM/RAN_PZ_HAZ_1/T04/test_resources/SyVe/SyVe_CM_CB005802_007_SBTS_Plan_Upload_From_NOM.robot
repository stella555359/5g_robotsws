*** Settings ***
Documentation       Test case for xxx
...                 Author: xxx
...                 Contact: xxx.xx@nokia.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${SRNCLAB}      SRNCLAB1019    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
${integrate_plan_path}     /home/ute/btsauto/hran_ta/config/${HW_LOCATION_CODE}/${TESTLINE_NAME}/testdata/TestDataNOM/nontls_integrate_plan_IPV4.xml
${integrate_plan_name}    nom_auto_integrate_plan
${PLAN_FILE_EXPROT_ACTUAL}    open_api_actuals_exported_007.xml

*** Keywords ***
SyVe_CM_CB005802_007_SBTS_Plan_Upload_From_NOM
    [Documentation]    [CASE LINK]: https://jira3.ext.net.nokia.com/browse/TAT-22269
    ...
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    Test for performing CM plan upload from NOM
    ...
    ...    The main steps performed for the test are:
    ...     - Check initial BTS state
    ...     - CM Upload From NOM Open API
    ...     - Export Actual Configuration From NOM Open API
    ...     - Check Actual Configuration Content
    ...     - Check final BTS state
    ...
    ...    Pass criteria: CM Configuration upload success from NOM
    ...
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 26.11.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22269
    ...    - SyVe_CM_SBTS_Plan_Upload_From_NOM_CB005802_007
    ...    - 23.03.2022 - Modified by Kang Lixin - https://jira3.ext.net.nokia.com/browse/TAT-22847
    ...    - Update case for switching ute_admin to taf.sbts.oam.coam.admin
    ...
    ...    *******************
    ...    Test case flowchart
    ...    *******************
    ...    .. image:: http://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SYVE/
    ...    TAT-22269_SyVe_CM_SBTS_Plan_Upload_From_NOM_CB005802_007.png

    Set Tags    AUTHOR-lixin.kang@nokia-sbell.com    Maintainer–I_NSB_MN_RAN_PZ_1_HAZ_11@internal.nsn.com
    Step 1: Check initial BTS state
    Step 2: CM Upload From NOM Open API
    Step 3: Export Actual Configuration From NOM Open API
    Step 4: Check Actual Configuration Content
    Step 5: Check final BTS state

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
    CM Parameter Upload NOM Open API    ${NE_INTEGRATED_ID}

Step ${index}: Export Actual Configuration From NOM Open API
    Log To Console      Step ${index}: Export Actual Configuration From NOM Open API
    ${output_actuals_file}=    Set Variable     ${TestFiles}/${PLAN_FILE_EXPROT_ACTUAL}
    CM Export Actual Configuration NOM Open API    ${NE_INTEGRATED_ID}     ${TestFiles}/${PLAN_FILE_EXPROT_ACTUAL}

Step ${index}: Check Actual Configuration Content
    Log To Console      Step ${index}: Check Actual Configuration Content
    ${file_size}=    Get File Size    ${TestFiles}/${PLAN_FILE_EXPROT_ACTUAL}
    Should Be True    ${file_size}>100000
    ${actual_configuration}=    OperatingSystem.Get File    ${TestFiles}/${PLAN_FILE_EXPROT_ACTUAL}
    Should Contain     ${actual_configuration}    ${CM_NE_ID}

TC Setup
    [Arguments]     ${reIntegrateNeFlag}=${FALSE}
    NOM Common Test Setup    ReIntegrateNE=${reIntegrateNeFlag}

TC Teardown
    NOM Common Test Teardown