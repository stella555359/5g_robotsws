*** Settings ***
Documentation
...   author: Adrianna Pienkowska, Jacek Kozmic, Agata Sidlo
...   contact: adrianna.pienkowska@nokia.com, jacek.kozmic@nokia.com, agata.sidlo@nokia.com
...   description: Krakow Verification Engineering team testcases for CB008746 feature

Resource    resources/common.robot
Resource    ../resources/common_configuration.robot

Variables   resources/variables.py
Variables   resources/delta_setups.py
Variables   resources/validation_dicts.py

Suite Setup      Suite Setup 8746
Test Teardown    Run Keywords    Send Configuration ID To Scout
    ...    AND    Test Teardown 8746

*** Variables ***
${expected_status}=    enhancedSliceAware

*** Test Cases ***
CB008746-A_B601_CellSetupReq_fields_check_FDD
    [Setup]    Test Setup 8746
    ...    tc=A_B601_CELLSETUPREQ_FDD
    ...    test_cell_tech=FDD
    Activate Feature And Start Basic Logs
    ...    delta=${DELTA_ACT_1_SPIDGRP_0_PMQAP}
    ...    delta_setup=${DELTA_DYN_KEYS_A_B601_OAM}
    ...    wts=${WTS_CFG_BASIC}
    BuiltIn.Sleep    30
    common.LOG SYSLOG BIP Stop
    common.SYSCOM Stop
    Validate CellSetupReq Pcap
    ...    ${DELTA_DYN_KEYS_A_B601_OAM_VALIDATION}
    ...    ${expected_status}
    suite__.Set Tc Status To Passed
    ...    tc=A_B601_CELLSETUPREQ_FDD

CB008746-A_B601_NSA_Slicing_Ues_with_no_SPID_TDD
    [Setup]    Test Setup 8746
    ...    tc=A_B601_no_SPID_TDD
    ...    test_cell_tech=TDD
    common.Activate Feature And Start Basic Logs
    ...    delta=${DELTA_ACT_5_SPIDGRP_3_PMQAP}
    ...    delta_setup=${DELTA_DYN_KEYS_5_SPIDGRP}
    ...    wts=${WTS_4_UE_3_PLMN}
    common.Attach Multiple Ues To Plmns And Start Traffic
    ...    nr_ues=4
    ...    spid=${UE_SPID_VALUES_A_B601_last}
    ...    plmn=${FOUR_UES_PLMNS}
    ...    dl_mbps=350
    ...    cell_id=${CELL_1_ID}
    common.SYSCOM Stop
    common__.Wait For Counters To Update
    wts__.Stop Data Traffic For Multiple Ues
    ...    number_of_ues=4
    ...    traffic_direction=dl
    ...    first_ue_id=11
    ...    net_arch=nsa
    common.SYSLOG Stop
    Validate Bip UserSetupReq ResourceGroupId Not Set
    ...    ues=${FOUR_UES_ID}
    Validate CellSetupReq Pcap
    ...    ${DELTA_DYN_KEYS_A_B601_NO_SPID_VALIDATION}
    ...    ${expected_status}
    suite__.Set Tc Status To Passed
    ...    tc=A_B601_no_SPID_TDD
