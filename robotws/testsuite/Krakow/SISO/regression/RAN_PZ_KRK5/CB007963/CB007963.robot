*** Settings ***
Documentation
...   Test suite for regression testing of feature CB007963
...   author: Przemyslaw Glod
...   contact: przemyslaw.glod@nokia.com
Resource     taf/rfrl/bts/robot/gnb.robot
Resource     taf/rfrl/bts/robot/common/gnb_bbu.robot
Resource     ./resources/common_keywords.robot

Variables    ./resources/common_variables.py

Suite Setup        Common Suite Setup With OnAir Test Line Preparation

Suite Teardown     Common Suite Teardown

*** Variables ***
@{Cell_IDs}     NRCELL-251
${capabilities}    REAL_UE
${deviation}       20%

*** Test Cases ***
CB007963_block_unblock_pRRHs_via_ASiR_WebEM
    [Setup]    Actions before test    alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[pRRH_block_unblock]
    Run Keyword And Continue On Failure    Call to selected cells    CellIDs=${All_cellIDs}    duration=120s    deviation=${deviation}
    SISO block unblock all pRRHs
    Call to selected cells    CellIDs=${All_cellIDs}    duration=120s    deviation=${deviation}
    ...                       prepareUE=False    index_run=2
    [Teardown]    Actions after test

