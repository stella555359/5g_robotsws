*** Settings ***
Documentation
...    Author: sylwia.swiatkiewicz@nokia.com
...    Maintainer: sylwia.swiatkiewicz@nokia.com
...    Description: Common Keywords used in cOAM configurations
...    Team in charge: I_EXT_5G_IV_WRO_OAM3_GMS
...    !!! Problematic by now, statuses may change because feature is not yet implemented !!!!

Library    BuiltIn
Library    Collections
Library    taf.sbts.oam.coam.admin   WITH NAME   admin_cli

*** Keywords ***
Connect To ADMIN CLI And Get HW Detection
    [Documentation]
    ...    Setup should check HW detection against expected configuration.
    ...    Sets the connection towards the BTS as coam_admin
    Establish Connection To ADMIN
    Get RMOD Detection Results
    Get BBMOD Detection Results
    Get SMOD Detection Results
    Get GNSSE Detection Results
    Get BTS Statuses
    Get CABLINK Detection Results

Get RMOD Detection Results
    ${FRM_detection_response}=    admin_cli.get_frm
    Set Global Variable    ${FRM_DETECTION}    ${FRM_detection_response}

Assert That Status From ADMIN Is Equal To State For RMODs
    [Documentation]
    ...    get RMODs' statuses from get_frm KW, checks if ${status} is equal to ${state}
    ...    checks how many RMODs are connected and loop over all of them to assert states
    [Arguments]    ${status}
     ...           ${state}
    ${len}=    Get Length    ${FRM_DETECTION}
    FOR    ${index}    IN RANGE    ${len}
        ${response}=    Get From Dictionary    ${FRM_DETECTION[${index}]['status']}    ${status}
        Should Be Equal    ${response}    ${state}
    END

Get BBMOD Detection Results
    ${FBB_detection_response}=    admin_cli.get_fbb_info
    Set Global Variable	   ${FBB_DETECTION}    ${FBB_detection_response}

Assert That Status From ADMIN Is Equal To State For BBMODs
    [Documentation]
    ...    get BBMOD status from get_fbb_info KW, checks if ${status} is equal to ${state}
    ...    checks how many BBMODs are connected and loop over all of them to assert states
    [Arguments]    ${status}
    ...            ${state}
    ${len}=    Get Length    ${FBB_DETECTION}
    FOR    ${index}    IN RANGE    ${len}
        ${response}=    Get From Dictionary    ${FBB_DETECTION[${index}]['status']}    ${status}
        Should Be Equal    ${response}    ${state}
    END

Get SMOD Detection Results
    ${FSM_detection_response}=    admin_cli.get_fsm_info
    Set Global Variable    ${FSM_DETECTION}    ${FSM_detection_response}

Assert That Status From ADMIN Is Equal To State For SMODs
    [Documentation]
    ...    get SMOD status from get_fsm_info KW, checks if ${status} is equal to ${state}
    ...    checks how many SMODs are connected and loop over all of them to assert states
    [Arguments]    ${status}
    ...            ${state}
    ${len}=    Get Length    ${FSM_DETECTION}
    FOR    ${index}    IN RANGE   ${len}
        ${response}=    Get From Dictionary    ${FSM_DETECTION[${index}]['status']}    ${status}
        Should Be Equal    ${response}    ${state}
    END

Get GNSSE Detection Results
    ${GNSS_detection_response}=    admin_cli.get_gnsses_statuses
    Set Global Variable    ${GNSS_DETECTION}    ${GNSS_detection_response}

Assert That Status From ADMIN Is Equal To State For GNSS
    [Documentation]
    ...    get GNSSE status from get_gnsses_statuses KW, checks if ${status} is equal to ${state}
    ...    only one GNSS can be connected, no need for looping
    [Arguments]    ${status}
    ...            ${state}
    ${response}=    Get From Dictionary    ${GNSS_DETECTION['GNSSE_R-1']}    ${status}
   Should Be Equal    ${response}    ${state}

Get BTS Statuses
    ${BTS_statuses_response}=    admin_cli.get_bts_statuses
   Set Global Variable    ${BTS_STATUSES}    ${BTS_statuses_response}

Assert That Status From ADMIN Is Equal To State For BTS
    [Documentation]
    ...  get BTS status from get_bts_statuses, to check BTSs' state (OnAir, Commissioned, Uncommissioned etc)
    [Arguments]    ${status}
    ...            ${state}
    ${response}=    Get From Dictionary    ${BTS_STATUSES}    ${status}
    Should Be Equal    ${response}    ${state}

Get CABLINK Detection Results
    ${CABLINK_statuses_response}=    admin_cli.get_managed_objects    CABLINK_R
    Set Global Variable    ${CABLINK_STATUSES}    ${CABLINK_statuses_response}

Assert That Status From ADMIN Is Equal To State For CABLINK
    [Documentation]
    ...  gets all CABLINK-R* objects and:
    ...  1) checks if CABLINK is backplane or optical link
    ...  2) for optical links checks the status of link -
    ...  availabilityStatus: Online means link is detected between RMOD and BBMOD
    [Arguments]    ${status}
    ...            ${state}
    ${len}=    Get Length    ${CABLINK_STATUSES}
    FOR    ${index}    IN RANGE    ${len}
        ${response}=    Get From Dictionary    ${CABLINK_STATUSES[${index}]['parameters']['stateInfo']}    ${status}
        Run Keyword If    '${response}'=='None'    run keyword and ignore error    fail
    ...    ${CABLINK_STATUSES[${index}]['distName']} is BACKPLANE LINK
        ...  ELSE    Should Be Equal    ${response}    ${state}
    END

Get BTS name
    [Arguments]  ${mrbtsId}
    ${bts_name_dict}=  admin_cli.get_parameters     dist_name=/MRBTS-1/RAT-1/BTS_L-1/BTS_CONF-1/NP-1/SCF-1/MRBTS_A-${mrbtsId}
    ...                                             pattern=btsName
    ${bts_name}=    Get from dictionary    ${bts_name_dict}   btsName
    [Return]  ${bts_name}
