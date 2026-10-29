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
CM__RP002956_Verify_RMOD_Lock_Via_DeltaCommission
    [Documentation]
    ...  *****************
    ...  Basic information
    ...  *****************
    ...   - Verify RMOD lock by delta commission from admin api for SRAN with 5G RAT SBTS
    ...  The main steps performed for the test are:
    ...  - Get Initial Data
    ...  - Set RMOD AdministrativeState As Locked
    ...  - Check Active Cells List After RMOD Locked
    ...  - Set RMOD AdministrativeState As Unlocked
    ...  - Check Active Cells List After RMOD Unlocked
    ...  Pass criteria: All operations are as expected.
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 08.06.2021 - Commit to GIT
    ...  - 23.03.2022 - Modified by Kang Lixin - https://jira3.ext.net.nokia.com/browse/TAT-22847
    ...    - Update case for switching ute_admin to taf.sbts.oam.coam.admin
    Set Tags    CA-CM    MAINTAINER-I_NSB_MN_RAN_RD_VRF_HAZ1_8@internal.nsn.com
    LOG    ${TEST_NAME} start.    console=${True}
    Step 1: Get Initial Data
    Step 2: Set RMOD AdministrativeState As Locked
    Step 3: Check Active Cells List After RMOD Locked
    Step 4: Set RMOD AdministrativeState As Unlocked
    Step 5: Check Active Cells List After RMOD Unlocked

TC TearDown
    ${is_recovered}    Run Keyword If    ${NEED_RECOVER}    Run Keyword And Return Status    coam.Perform parameter recommissioning
    ...    ${RMOD_TO_LOCK}    administrativeState    update    Unlocked    ${False}
    Run Keyword If    '${is_recovered}' =='${False}'    Admin Get bts_id and perform commissioning    ${COMMISSIONING_PATH}    ${True}
    Wait Until Keyword Succeeds    20 min    15 sec    Check_SBTS_SMOD_RMOD_Cells_Alarms
    Common Test Teardown SBTS    never

Step ${index}: Get Initial Data
    LOG    Step ${index}: Get Initial Data    console=${True}
    ${DIC_RMOD_ACTIVE_CELL}    Get RMODs Active Cell List
    ${RMODs}    Get Dictionary Keys    ${DIC_RMOD_ACTIVE_CELL}
    ${count}    Get Length    ${RMODs}
    ${index}    Evaluate    random.randint(0,${count-1})    modules=random, sys
    Set Test Variable    ${RMOD_TO_LOCK}    ${RMODs[${index}]}
    Set Test Variable    ${DIC_RMOD_ACTIVE_CELL}

Step ${index}: Set RMOD AdministrativeState As ${status}
    LOG    Step ${index}: Set RMOD AdministrativeState As ${status}    console=${True}
    Set Test Variable    ${NEED_RECOVER}    ${True}
    coam.Perform parameter recommissioning    ${RMOD_TO_LOCK}    administrativeState    update    ${status}    ${False}
    Wait Until Keyword Succeeds    1 minutes    5 secs    Query Infomodel
    ...    check //${RMOD_TO_LOCK.replace('-','_A-')} is [administrativeState="${status}"]

Step ${index}: Check Active Cells List After RMOD Locked
    LOG    Step ${index}: Check Active Cells List After RMOD Locked    console=${True}
    ${dic_RMOD_active_cell_after_lock}    Get RMODs Active Cell List
    ${RMOD_locked_active_cell_list}    Pop From Dictionary    ${dic_RMOD_active_cell_after_lock}    ${RMOD_TO_LOCK}
    Should Be Empty    ${RMOD_locked_active_cell_list['activeLteCellsList']}
    Should Be Empty    ${RMOD_locked_active_cell_list['activeGsmCellsList']}
    Should Be Empty    ${RMOD_locked_active_cell_list['activeNrCellsList']}
    Should Be Empty    ${RMOD_locked_active_cell_list['activeWcdmaCellsList']}
    ${rest_RMODs}    Get Dictionary Keys    ${dic_RMOD_active_cell_after_lock}
    FOR    ${RMOD}    IN    @{rest_RMODs}
        Lists Should Be Equal    ${dic_RMOD_active_cell_after_lock['${RMOD}']['activeLteCellsList']}
        ...    ${DIC_RMOD_ACTIVE_CELL['${RMOD}']['activeLteCellsList']}
        Lists Should Be Equal    ${dic_RMOD_active_cell_after_lock['${RMOD}']['activeGsmCellsList']}
        ...    ${DIC_RMOD_ACTIVE_CELL['${RMOD}']['activeGsmCellsList']}
        Lists Should Be Equal    ${dic_RMOD_active_cell_after_lock['${RMOD}']['activeNrCellsList']}
        ...    ${DIC_RMOD_ACTIVE_CELL['${RMOD}']['activeNrCellsList']}
        Lists Should Be Equal    ${dic_RMOD_active_cell_after_lock['${RMOD}']['activeWcdmaCellsList']}
        ...    ${DIC_RMOD_ACTIVE_CELL['${RMOD}']['activeWcdmaCellsList']}
    END

Step ${index}: Check Active Cells List After RMOD Unlocked
    LOG    Step ${index}: Check Active Cells List After RMOD Unlocked    console=${True}
    Wait Until Keyword Succeeds    20 min    15 sec    Check_SBTS_SMOD_RMOD_Cells_Alarms
    ${dic_RMOD_active_cell_after_lock}    Get RMODs Active Cell List
    ${rest_RMODs}    Get Dictionary Keys    ${dic_RMOD_active_cell_after_lock}
    FOR    ${RMOD}    IN    @{rest_RMODs}
        Lists Should Be Equal    ${dic_RMOD_active_cell_after_lock['${RMOD}']['activeLteCellsList']}
        ...    ${DIC_RMOD_ACTIVE_CELL['${RMOD}']['activeLteCellsList']}
        Lists Should Be Equal    ${dic_RMOD_active_cell_after_lock['${RMOD}']['activeGsmCellsList']}
        ...    ${DIC_RMOD_ACTIVE_CELL['${RMOD}']['activeGsmCellsList']}
        Lists Should Be Equal    ${dic_RMOD_active_cell_after_lock['${RMOD}']['activeNrCellsList']}
        ...    ${DIC_RMOD_ACTIVE_CELL['${RMOD}']['activeNrCellsList']}
        Lists Should Be Equal    ${dic_RMOD_active_cell_after_lock['${RMOD}']['activeWcdmaCellsList']}
        ...    ${DIC_RMOD_ACTIVE_CELL['${RMOD}']['activeWcdmaCellsList']}
    END
    Set Test Variable    ${NEED_RECOVER}    ${False}
