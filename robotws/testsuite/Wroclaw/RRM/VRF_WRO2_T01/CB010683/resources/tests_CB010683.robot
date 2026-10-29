*** Settings ***
Documentation
...  Description:   Feature CB010683

Resource      testsuite/Wroclaw/RRM/VRF_WRO2_T01/CB010683/resources/keywords.robot

*** Keywords ***
CB010683-A_TC1_actNrExtCellSOMethod activation deactivation for PSGs_RFU 64TRX
    [Documentation]  Main logic implementation for CB010683 feature. Code is written regrading to Test ID: 155955 test
    ...              decrtiption.
    Perform commissioning with CB010683 SCF
    Activate/Deactivate CB010683 with delta commissioning  actNrExtCellSOMethod=true
    Check alarms after activation/deactivation
    Wait for energy saving status
