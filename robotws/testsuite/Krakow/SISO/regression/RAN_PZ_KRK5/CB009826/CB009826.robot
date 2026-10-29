*** Settings ***
Documentation
...   Test suite for regression testing of feature CB009826

Resource     taf/rfrl/bts/robot/gnb.robot
Resource     testsuite/Krakow/resources/RAN_VRF_KRK5/robot/call_procedure/call_procedure_keywords.robot
Resource     ./resources/common_keywords.robot

Library      taf.ue     WITH NAME   ue
Library      Collections

Variables    ./resources/call_variables.py
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Suite Setup       Common Suite Setup With OnAir Test Line Preparation
...               increase_timeout_for_update_sw=3600
Suite Teardown     Common Suite Teardown

*** Variables ***
@{All_cellIDs_FR1}     NRCELL-11    NRCELL-41    NRCELL-32    NRCELL-51    NRCELL-61    LNCEL-1
@{All_cellIDs_FR2}     LNCEL-5

${capabilities_FR1}    REAL_UE_FR1
${capabilities_FR2}    REAL_UE_FR2

*** Test Cases ***
CB009826_SR_A_BTS_Site_Reset
    [Setup]    Actions before test    alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[BTS_reset]
    ${traffic_matrix}    Convert To Dictionary    ${TPUT_MATRIX}
    FOR     ${iteration}    IN RANGE    1   4
       logger.log_info_to_console      Resetting gNB iteration=${iteration}
       Reset gNB
       Wait Until Keyword Succeeds     900 sec     30 sec   Verify gNB is onAir
       Wait Until Keyword Succeeds     900 sec     30 sec   gnbcell.Verify All Cells Are Onair
       Run Keyword And Continue On Failure   Call To Selected Cells    cells_list=${All_cellIDs_FR2}    duration=120s
       ...                                   traffic_matrix=${traffic_matrix}    ue_capabilities=${capabilities_FR2}
       ...                                   reboot_ue=${False}    recall=${True}    run_num=${iteration}    alias=UE_2
       Run Keyword And Continue On Failure   Call To Selected Cells    cells_list=${All_cellIDs_FR1}    duration=120s
       ...                                   traffic_matrix=${traffic_matrix}    ue_capabilities=${capabilities_FR1}
       ...                                   reboot_ue=${False}    recall=${True}    run_num=${iteration}    alias=UE_1
    END
    [Teardown]    Actions after test
