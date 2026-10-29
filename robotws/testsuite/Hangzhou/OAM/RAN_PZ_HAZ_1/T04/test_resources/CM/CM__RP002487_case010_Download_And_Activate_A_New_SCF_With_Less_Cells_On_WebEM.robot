*** Settings ***
Documentation       Test case for
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
# Delete vritual cells, only contains virtual RFs
${DELETE_CELL_PATH}    /home/ute/btsauto/hran_ta/config/${HW_LOCATION_CODE}/${TESTLINE_NAME}/commissioning/CM_Delete_Dummy_Cells.xml
${SKIP_PARAM_RELATION_ERRORS}    ${TRUE}    # Should relation errors be skipped (True, False)
${COMMISSIONING_TIMEOUT}    400    # Timeout for commissioning procedure (scf upload, reset indication, wait for reconnection after reset)
@{IGNORE_ALARMS}    {"faultId":"2403"}    {"faultId":"61524"}    {"faultId":"61652"}    {"faultId":"61649"}    {"faultId":"6450"}
...    {"faultId":"6286"}    # fault ids that should be ignored
# contains virtual RFs and virtual cells
${ADD_RMOD_AND_CELL_PATH}    /home/ute/btsauto/hran_ta/config/${HW_LOCATION_CODE}/${TESTLINE_NAME}/commissioning/CM_Add_Dummy_RMODs_And_Cells.xml
# only contains install RFs and cells
${COMMISSIONING_PATH}    /home/ute/btsauto/hran_ta/config/${HW_LOCATION_CODE}/${TESTLINE_NAME}/commissioning/SCF_01_SBTS18.xml
${ALARM_COUNT}    1    # The exepected quantity of alarms

*** Keywords ***
CM__RP002487_case010_Download_And_Activate_A_New_SCF_With_Less_Cells_On_WebEM
        [Documentation]
    ...  *****************
    ...  Basic information
    ...  *****************
    ...   For RP002487 case10. Commission SCF for less cells
    ...  The main steps performed for the test are:
    ...  - Get all cells distname
    ...  - Add dummy RMODs and Cells
    ...  - Delete dummy Cells
    ...  Pass criteria: SCF validate and activate success. All the cells are online execpt new added cells.
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 28.04.2021 - Commit to GIT
    ...  - 20.01.2022 - Modified by Kang Lixin  - https://jira3.ext.net.nokia.com/browse/TAT-22476 - Update according to status changes in CNI-61110
    ...  - 23.03.2022 - Modified by Kang Lixin - https://jira3.ext.net.nokia.com/browse/TAT-22847
    ...    - Update case for switching ute_admin to taf.sbts.oam.coam.admin

    Set Tags    CA-CM    OWNER-lixin.kang@nokia-sbell.com    MAINTAINER-lixin.kang@nokia-sbell.com     AUTHOR-yuyan.xu@nokia-sbell.com
    ...    PHASE-CRT    SW-SBTS21B    FEATURE-RP002487    GROUP_IN_CHARGE-SRAN_PROD_HZ1
    LOG    ${TEST_NAME} of ${SUITE_NAME} start.    console=${True}
    Step 1: Get all cells distname
    Step 2: Add dummy RMODs and Cells
    Step 3: Delete dummy Cells

Setup
    Common Test Setup SBTS    modules_check=${FALSE}    cells_check=${FALSE}    alarms_check=${FALSE}    scf_check=${FALSE}
    ${ignore_alarm_list}    Create List
    FOR    ${alarm}    IN    @{IGNORE_ALARMS}
        ${alarm_dic}    Evaluate    ${alarm}
        Append To List    ${ignore_alarm_list}    ${alarm_dic}
    END
    Set Test Variable    ${ignore_alarm_list}
    ${current_alarm_list}=    Get Current Active Alarms List
    Set Test Variable    ${ALARMS_BEFORE_TEST}    ${current_alarm_list}

Step ${index}: Get all cells distname
    Log    Step ${index}: Get all cells distname    console=True
    ${lncel}=    Admin Get IDs for all LTE cells
    Set test variable    ${lncel}
    ${wncel}=    coam.Get Ids For All    WNCEL
    Set test variable    ${wncel}
    ${gncel}=    coam.Get Ids For All    GNCEL
    Set test variable    ${gncel}
    ${nrcells}=    coam.Get Ids For All    NRCEL
    Set test variable    ${nrcells}
    ${rmods}=    coam.Get Ids For All    RMOD
    set test variable      ${rmods}
    ${smods}=    coam.Get Ids For All    SMOD
    set test variable      ${smods}

Step ${index}: Add Dummy RMODs and Cells
    Log    Step ${index}: Add Dummy RMODs and Cells    console=True
    SBTS commissioning    ${ADD_RMOD_AND_CELL_PATH}
    Check SBTS cells, modules and alarms    ${ALARM_COUNT}    13

Step ${index}: Delete Dummy Cells
    Log    Step ${index}: Delete Dummy Cells    console=True
    SBTS commissioning    ${DELETE_CELL_PATH}
    Check SBTS cells, modules and alarms    0    1

SBTS commissioning
    [Arguments]    ${SCF_PATH}
    [Timeout]    30 min
    Log    SBTS commissioning    console=True
    Admin Get bts_id and perform commissioning    ${SCF_PATH}    ${SKIP_PARAM_RELATION_ERRORS}    ${COMMISSIONING_TIMEOUT}
    Log    Commissioning done. Check BTS states will be performed    console=True

Check SBTS cells, modules and alarms
    [Arguments]    ${alarm_counts}    ${sleep_time}
    [Documentation]    KW for wrapping functions for checking SBTS SMODs, RMODs, cell states and presence of active alarms
    Wait Until Keyword Succeeds    7 min    60 sec    Check_SBTS_modules
    Sleep    ${sleep_time} min
    Wait Until Keyword Succeeds    20 min    60 sec    Check All Cells States
    ${current_alarm_list}=    Get Current Active Alarms List
    Set Test Variable    ${ALARMS_AFTER_TEST}    ${current_alarm_list}
    ${alarms_cleared}    ${alarms_raised}    Compare Alarm List    ${ALARMS_BEFORE_TEST}    ${ALARMS_AFTER_TEST}    ${ignore_alarm_list}
    Should Be Equal As Integers    ${alarms_raised.__len__()}    ${alarm_counts}
    FOR    ${index}    IN RANGE    0    ${alarm_counts}
        Should Be Equal As Strings    ${alarms_raised[${index}]['faultId']}    10
    END

Check_SBTS_modules
     ${are_smods_online}    Set Variable    True
     ${are_rmods_online}    Set Variable    True
     FOR    ${SMOD}    IN    @{smods}
         ${are_smods_online} =     Run Keyword And Return Status    coam.Assert    SMOD     ${SMOD}
         ...    administrativeState=${_Com_Unlocked_}, operationalState=${_Enabled_}
         Exit For Loop If     '${are_smods_online}'=='False'
     END
     FOR    ${RMOD}    IN    @{rmods}
         ${are_rmods_online} =     Run Keyword And Return Status    coam.Assert    RMOD     ${RMOD}
         ...    administrativeState=${_Com_Unlocked_}, operationalState=${_Enabled_}
         Exit For Loop If     '${are_rmods_online}'=='False'
     END
     Should be true    ${are_smods_online} and ${are_rmods_online}

Check All Cells States
     ${status_wcells}    Set Variable    True
     ${status_lcells}    Set Variable    True
     ${status_gcells}    Set Variable    True
     ${status_nrcells}    Set Variable    True
    FOR    ${Wcell}    IN    @{wncel}
        ${status_wcells} =     Run Keyword And Return Status    coam.Assert    WNCEL    ${Wcell}    ${cells_WCDMA_expected_state}
        Exit For Loop If     '${status_wcells}'=='False'
    END
    FOR    ${Lcell}    IN    @{lncel}
        ${status_lcells} =    Run Keyword And Return Status    coam.Assert    LNCEL    ${Lcell}    ${cells_LTE_expected_state}
        Exit For Loop If     '${status_lcells}'=='False'
    END
    FOR    ${Gcell}    IN    @{gncel}
        ${status_gcells} =    Run Keyword And Return Status    coam.Assert    GNCEL    ${Gcell}    ${cells_GSM_expected_state}
        Exit For Loop If     '${status_gcells}'=='False'
    END
    FOR    ${NRcell}    IN    @{nrcells}
        ${status_nrcells} =    Run Keyword And Return Status    coam.Assert    NRCEL    ${NRcell}    ${cells_NR_expected_state}
        Exit For Loop If     '${status_nrcells}'=='False'
    END
    ${status} =    Evaluate    ${status_lcells} and ${status_wcells} and ${status_gcells} and ${status_nrcells}
#    Run Keyword Unless    ${status}    Fail    Status of some cells does not as expected
    Run Keyword If    not ${status}    Fail    Status of some cells does not as expected

TearDown
    Log    TearDown    console=True
    SBTS commissioning    ${COMMISSIONING_PATH}
    Check SBTS cells, modules and alarms    0    1
    Common Test Teardown SBTS    collect_snapshot=never

Get Current Active Alarms List
    ${active_alarms}     coam.Get Alarms
    ${current_alarm_list}    Create List
    FOR    ${alarm}    IN    @{active_alarms}
        ${alarm_dic}    Evaluate    {"faultId":"${alarm}[faultId]"}
        Append To List    ${current_alarm_list}    ${alarm_dic}
    END
    [Return]    ${current_alarm_list}