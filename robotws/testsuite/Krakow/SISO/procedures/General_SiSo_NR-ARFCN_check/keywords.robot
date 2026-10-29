*** Settings ***

Resource    taf/rfrl/bts/robot/gnb.robot
Library     nrarfcn_check.py
Library     nrarfcn_check.NrarfcnCheck

*** Variables ***

*** Keywords ***
Set Delta Values
    ${delta_min_values}    Get Delta Commissioning for Min Frequency
    Set Test Variable    ${delta_min_values}
    ${delta_mid_values}    Get Delta Commissioning for Mid Frequency
    Set Test Variable    ${delta_mid_values}
    ${delta_max_values}    Get Delta Commissioning for Max Frequency
    Set Test Variable    ${delta_max_values}

Change Delta Values for Min Frequency
    Perform Delta Commissioning On gNB    ${delta_min_values}    skip_parameter_relation_errors=true
    Wait Until Keyword Succeeds     900 sec     15 sec   Verify Setup Of All Cells

Change Delta Values for Max Frequency
    Perform Delta Commissioning On gNB    ${delta_max_values}    skip_parameter_relation_errors=true
    Wait Until Keyword Succeeds     900 sec     15 sec   Verify Setup Of All Cells

Change Delta Values for Mid Frequency
    Perform Delta Commissioning On gNB    ${delta_mid_values}    skip_parameter_relation_errors=true
    Wait Until Keyword Succeeds     900 sec     15 sec   Verify Setup Of All Cells
