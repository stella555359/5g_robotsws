*** Settings ***
Documentation  This suite contains KPI__vDU__Enabling_and_Modifying_Antenna_Port_Remapping_for_4_Tx_Cell TC

Resource  ../test_resources/KPI__vDU__Enabling_and_Modifying_Antenna_Port_Remapping_for_4_Tx_Cell.robot


*** Test Cases ***
KPI__vDU__Enabling_and_Modifying_Antenna_Port_Remapping_for_4_Tx_Cell
    [Setup]  TC Setup
    TC__KPI__vDU__Enabling_and_Modifying_Antenna_Port_Remapping_for_4_Tx_Cell
    [Teardown]  TC Teardown
