*** Settings ***
Documentation       Test case for
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${NEED_RECOVER}    ${False}    # whether the NE need to be recovered
${RMOD_TO_LOCK}    ${EMPTY}    # the RMOD to be locked
# full commission scf path
${COMMISSIONING_PATH}    /home/ute/btsauto/hran_ta/config/${HW_LOCATION_CODE}/${TESTLINE_NAME}/commissioning/SCF_01_SBTS18.xml

*** Keywords ***
CM__RP002956_Verify_BBMOD_Lock_Via_DeltaCommission
    [Documentation]
    ...  *****************
    ...  Basic information
    ...  *****************
    ...   - Verify BBMOD lock by delta commission from admin api for SRAN with 5G RAT SBTS
    ...  The main steps performed for the test are:
    ...  - Setup Relationship Between BBMOD And RMOD And Cells
    ...  - Get RMOD Active Cells Before BBMOD Locked
    ...  - Cycle Lock BBMOD And Check RMOD Active Cells
    ...  - Set RMOD AdministrativeState As Unlocked
    ...  Pass criteria: All operations are as expected.
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 08.06.2021 - Commit to GIT

    Set Tags    Maintainer–I_NSB_MN_RAN_RD_VRF_HAZ1_8@internal.nsn.com
    LOG    ${TEST_NAME} start.    console=${True}
    Step 1: Setup Relationship Between BBMOD And RMOD And Cells
    Step 2: Get RMOD Active Cells Before BBMOD Locked
    Step 3: Cycle Lock BBMOD And Check RMOD Active Cells

TC TearDown
    ${is_recovered}    Run Keyword If    ${NEED_RECOVER}    Run Keyword And Return Status    Set administrativeState Of MO_R
    ...    ${CUR_BBMOD_DN}    Unlocked
    Run Keyword If    '${is_recovered}' =='${False}'    Admin Get bts_id and perform commissioning    ${COMMISSIONING_PATH}    ${True}
    Wait Until Keyword Succeeds    20 min    15 sec    Check_SBTS_SMOD_RMOD_Cells_Alarms
    Common Test Teardown SBTS    never

Get Relative Cell List
    [Arguments]    ${BBMOD_R_DN}
    ${list_linked_RMOD_R}    Set Variable    ${BBMOD_R_LINKED_RMOD_R['${BBMOD_R_DN}']['RELATE_RMOD_R_DN']}
    ${activeNrCellsList}    Create List
    FOR    ${RMOD_R_DN}    IN    @{list_linked_RMOD_R}
        ${tmpList}    Get RMOD_R Related NRCells    ${RMOD_R_DN}
        Append To List    ${activeNrCellsList}    @{tmpList}
    END
    ${expect_offline_cell_list}    Create Dictionary    activeGsmCellsList=${BBMOD_R_MAP_TO_CELL['${BBMOD_R_DN}']['GSM']}
    ...    activeLteCellsList=${BBMOD_R_MAP_TO_CELL['${BBMOD_R_DN}']['LTE']}    activeWcdmaCellsList=${BBMOD_R_MAP_TO_CELL['${BBMOD_R_DN}']['WCDMA']}
    ...    activeNrCellsList=${BBMOD_R_MAP_TO_CELL['${BBMOD_R_DN}']['5G']}
    [Return]    ${expect_offline_cell_list}

Check Current RMOD Active Cells After BBMOD Locked
    [Arguments]    ${BBMOD_R_DN}    ${expect_offline_cell_list}    ${dic_RMOD_active_cell_before_lock}
    ${dic_RMOD_active_cell_after_lock}    Get RMODs Active Cell List
    Log Dictionary    ${dic_RMOD_active_cell_before_lock}
    Log Dictionary    ${dic_RMOD_active_cell_after_lock}
    FOR    ${RMOD_R}    IN    @{BBMOD_R_LINKED_RMOD_R['${BBMOD_R_DN}']['RELATE_RMOD_R_DN']}
        ${RMOD}    Get MO Name Of MO_R    ${RMOD_R}
        Remove Values From List    ${dic_RMOD_active_cell_before_lock['${RMOD}']['activeWcdmaCellsList']}
        ...    @{expect_offline_cell_list['activeWcdmaCellsList']}
        Remove Values From List    ${dic_RMOD_active_cell_before_lock['${RMOD}']['activeGsmCellsList']}
        ...    @{expect_offline_cell_list['activeGsmCellsList']}
        Remove Values From List    ${dic_RMOD_active_cell_before_lock['${RMOD}']['activeLteCellsList']}
        ...    @{expect_offline_cell_list['activeLteCellsList']}
        Remove Values From List    ${dic_RMOD_active_cell_before_lock['${RMOD}']['activeNrCellsList']}
        ...    @{expect_offline_cell_list['activeNrCellsList']}
        LOG Dictionary    ${dic_RMOD_active_cell_before_lock}
        LOG Dictionary    ${dic_RMOD_active_cell_after_lock}
        Lists Should Be Equal    ${dic_RMOD_active_cell_after_lock['${RMOD}']['activeWcdmaCellsList']}
        ...    ${dic_RMOD_active_cell_before_lock['${RMOD}']['activeWcdmaCellsList']}
        Lists Should Be Equal    ${dic_RMOD_active_cell_after_lock['${RMOD}']['activeGsmCellsList']}
        ...    ${dic_RMOD_active_cell_before_lock['${RMOD}']['activeGsmCellsList']}
        Lists Should Be Equal    ${dic_RMOD_active_cell_after_lock['${RMOD}']['activeLteCellsList']}
        ...    ${dic_RMOD_active_cell_before_lock['${RMOD}']['activeLteCellsList']}
        Lists Should Be Equal    ${dic_RMOD_active_cell_after_lock['${RMOD}']['activeNrCellsList']}
        ...    ${dic_RMOD_active_cell_before_lock['${RMOD}']['activeNrCellsList']}
    END
    FOR    ${RMOD_R}    IN    @{BBMOD_R_LINKED_RMOD_R['${BBMOD_R_DN}']['IRRESPECTIVE_RMOD_R_DN']}
        ${RMOD}    Get MO Name Of MO_R    ${RMOD_R}
        Remove Values From List    ${dic_RMOD_active_cell_before_lock['${RMOD}']['activeWcdmaCellsList']}
        ...    @{expect_offline_cell_list['activeWcdmaCellsList']}
        Remove Values From List    ${dic_RMOD_active_cell_before_lock['${RMOD}']['activeGsmCellsList']}
        ...    @{expect_offline_cell_list['activeGsmCellsList']}
        Remove Values From List    ${dic_RMOD_active_cell_before_lock['${RMOD}']['activeLteCellsList']}
        ...    @{expect_offline_cell_list['activeLteCellsList']}
        Remove Values From List    ${dic_RMOD_active_cell_before_lock['${RMOD}']['activeNrCellsList']}
        ...    @{expect_offline_cell_list['activeNrCellsList']}
        LOG Dictionary    ${dic_RMOD_active_cell_before_lock}
        LOG Dictionary    ${dic_RMOD_active_cell_after_lock}
        Lists Should Be Equal    ${dic_RMOD_active_cell_after_lock['${RMOD}']['activeWcdmaCellsList']}
        ...     ${dic_RMOD_active_cell_before_lock['${RMOD}']['activeWcdmaCellsList']}
        Lists Should Be Equal    ${dic_RMOD_active_cell_after_lock['${RMOD}']['activeGsmCellsList']}
        ...    ${dic_RMOD_active_cell_before_lock['${RMOD}']['activeGsmCellsList']}
        Lists Should Be Equal    ${dic_RMOD_active_cell_after_lock['${RMOD}']['activeLteCellsList']}
        ...     ${dic_RMOD_active_cell_before_lock['${RMOD}']['activeLteCellsList']}
        Lists Should Be Equal    ${dic_RMOD_active_cell_after_lock['${RMOD}']['activeNrCellsList']}
        ...    ${dic_RMOD_active_cell_before_lock['${RMOD}']['activeNrCellsList']}
    END

Check Current RMOD Active Cells After BBMOD Unlocked
    [Arguments]    ${dic_RMOD_active_cell_before_lock}
    ${dic_RMOD_active_cell_after_unlock}    Get RMODs Active Cell List
    LOG Dictionary    ${dic_RMOD_active_cell_before_lock}
    LOG Dictionary    ${dic_RMOD_active_cell_after_unlock}
    ${RMODs}    Get Dictionary Keys    ${dic_RMOD_active_cell_before_lock}
    FOR    ${RMOD_R}    IN    @{RMODs}
        Lists Should Be Equal    ${dic_RMOD_active_cell_before_lock['${RMOD_R}']['activeLteCellsList']}
        ...    ${dic_RMOD_active_cell_after_unlock['${RMOD_R}']['activeLteCellsList']}
        Lists Should Be Equal    ${dic_RMOD_active_cell_before_lock['${RMOD_R}']['activeGsmCellsList']}
        ...    ${dic_RMOD_active_cell_after_unlock['${RMOD_R}']['activeGsmCellsList']}
        Lists Should Be Equal    ${dic_RMOD_active_cell_before_lock['${RMOD_R}']['activeNrCellsList']}
        ...    ${dic_RMOD_active_cell_after_unlock['${RMOD_R}']['activeNrCellsList']}
        Lists Should Be Equal    ${dic_RMOD_active_cell_before_lock['${RMOD_R}']['activeWcdmaCellsList']}
        ...    ${dic_RMOD_active_cell_after_unlock['${RMOD_R}']['activeWcdmaCellsList']}
    END

Step ${index}: Get RMOD Active Cells Before BBMOD Locked
    LOG    Step ${index}: Get RMOD Active Cells Before BBMOD Locked    console=${True}
    ${INITIAL_RMOD_ACTIVE_CELL}    Get RMODs Active Cell List
    LOG Dictionary    ${INITIAL_RMOD_ACTIVE_CELL}
    Set Test Variable    ${INITIAL_RMOD_ACTIVE_CELL}

Step ${index}: Cycle Lock BBMOD And Check RMOD Active Cells
    LOG    Step ${index}: Cycle Lock BBMOD And Check RMOD Active Cells    console=${True}
    FOR    ${BBMOD_R_DN}    IN    @{BBMOD_R_MOs_TO_RESET}
        ${expect_offline_cell_list}    Get Relative Cell List    ${BBMOD_R_DN}
        Set Test Variable    ${NEED_RECOVER}    ${True}
        Set Test Variable    ${CUR_BBMOD_DN}    ${BBMOD_R_DN}
        Set administrativeState Of MO_R    ${BBMOD_R_DN}    Locked
        ${dic_RMOD_active_cell_before_lock}    Copy Dictionary    ${INITIAL_RMOD_ACTIVE_CELL}    ${True}
        Check Current RMOD Active Cells After BBMOD Locked    ${BBMOD_R_DN}    ${expect_offline_cell_list}    ${dic_RMOD_active_cell_before_lock}
        Set administrativeState Of MO_R    ${BBMOD_R_DN}    Unlocked
        Wait Until Keyword Succeeds    10 min    15 sec    Check_SBTS_SMOD_RMOD_Cells_Alarms
        Set Test Variable    ${NEED_RECOVER}    ${False}
        ${dic_RMOD_active_cell_before_lock}    Copy Dictionary    ${INITIAL_RMOD_ACTIVE_CELL}    ${True}
        Check Current RMOD Active Cells After BBMOD Unlocked    ${dic_RMOD_active_cell_before_lock}
    END

Step ${index}: Setup Relationship Between BBMOD And RMOD And Cells
    LOG    Step ${index}: Setup Relationship Between BBMOD And RMOD And Cells    console=${True}
    ${BBMOD_R_MAP_TO_CELL}    Create Dictionary
    ${BBMOD_R_LINKED_RMOD_R}    Create Dictionary
    ${BBMOD_R_MOs_TO_RESET}    Get Sole MO DN    //EQM_R-*//BBMOD_R-*    productName
    FOR    ${MO}    IN    @{BBMOD_R_MOs_to_reset}
        ${cell_dic}    Get BBMOD_R Related Cells    ${MO}
        Set To Dictionary    ${BBMOD_R_MAP_TO_CELL}    ${MO}    ${cell_dic}
        ${RMOD_R_MO_DNs}    Get DN Of RMOD_R Related To BBMOD_R    ${MO}
        Set To Dictionary    ${BBMOD_R_LINKED_RMOD_R}    ${MO}    ${RMOD_R_MO_DNs}
    END
    Set Test Variable    ${BBMOD_R_LINKED_RMOD_R}
    Set Test Variable    ${BBMOD_R_MAP_TO_CELL}
    Set Test Variable    ${BBMOD_R_MOs_TO_RESET}
    Log Dictionary    ${BBMOD_R_LINKED_RMOD_R}
    Log Dictionary    ${BBMOD_R_MAP_TO_CELL}
