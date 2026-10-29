*** Settings ***
Documentation     CM__SBTS_Status_Is_OK
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${COMMISSIONING_PATH}    /home/ute/testline_configuration/${TESTLINE_NAME}/commissioning/SCF_01_SBTS18.xml
${COUNT_OF_GSM_CELL}    3
${COUNT_OF_WCDMA_CELL}    3
${COUNT_OF_LTE_CELL}    3
${COUNT_OF_NRBTS_CELL}    3

*** Keywords ***
CM__SBTS_Status_Is_OK
    [Documentation]    CM__SBTS_Status_Is_OK
    ...
    ...    *****************
    ...    Basic information
    ...    *****************
    ...
    ...    Check if SBTS status is onair and no critical/major alarms.
    ...
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 29.01.2024 - Bin.7.Liu - Commit to robotws.
    Step 1: Check SBTS Status is OK

Step ${index}: Check SBTS Status is OK
    LOG    Step ${index}: Check SBTS Status is OK    console=${True}
    SBTS WEM Logon    https://${MPLANE_IP}    skip_error=${True}    setup_param=${False}
    Wait Until Keyword Succeeds    10x    1m    Status Of RAT Should Be OK
    ${blocked_cell_name_list}    SBTS WEM Get Name Of All Blocked Cells
    Should Be Empty    ${blocked_cell_name_list}
    ${all_cell_name_list}    SBTS WEM Get All Cell Name
    ${count}    Get Length    ${all_cell_name_list}
    ${expect_count}    Evaluate    ${COUNT_OF_GSM_CELL}+${COUNT_OF_WCDMA_CELL}+${COUNT_OF_LTE_CELL}+${COUNT_OF_NRBTS_CELL}
    Should Be Equal As Integers    ${count}    ${expect_count}

Tear Down
    LOG    Tear Down    console=${True}
    Run Keyword If Test Failed    Capture Page Screenshot    ${TEST_NAME}_FAIL.JPEG
    Run Keyword If Test Failed    SBTS WEM Save Snapshot
    SBTS WEM Download Chrome Console Log
    Selenium2Library.Close Browser
    Run Keyword If Test Failed    Recover ENV

Recover ENV
    Start Admin    bts_host=${SMOD1['TRS_IP']}
    Admin Get bts_id and perform commissioning    ${COMMISSIONING_PATH}    ${True}
    Wait until keyword succeeds    15 min    15 sec    Check_SBTS_SMOD_RMOD_Cells_Alarms
    coam.Teardown All Aliases For Admin
