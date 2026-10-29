*** Settings ***
Documentation
...    author: Bartosz Odziomek
...    contact: bartosz.odziomek@nokia.com,
...    Feature: 5GC001091-L

Resource      5GC001091_Keywords.robot

Suite Setup         Suite Setup
Suite Teardown      Suite Teardown
Test Setup          run keyword and continue on failure   Common Preconditions
Test Teardown       run keyword and continue on failure   Common Postconditions

*** Variables ***
@{EXPECTED_ANTENNA_TO_DISABLE}    ${2}
@{CUSTOM_ALLOWED_ALARMS}    Cooling fan broken    Diagnostic Files collected

*** Test Cases ***
[1]5GC001091_3_ASiR-ANT disconnection from ASiR-HUB
     AirScale.Connect To Gnb
     Connect To Webui Via Selenium
     Disable Screen Lock Via Selenium
     @{antennas_info}  gnb_asir.Get All Antennas Info
     ${number_of_ants}  Get length   ${antennas_info}
     Change Power State Of All Ants  ${number_of_ants}  off
     Wait Until Keyword Succeeds  10x  10s    gnb_asir.Verify Antennas Are Disabled   ${EXPECTED_ANTENNA_TO_DISABLE}
     Change Power State Of All Ants  ${number_of_ants}  on
     Wait Until Keyword Succeeds  10x  10s    gnb_asir.Verify Antennas Are Enabled    ${EXPECTED_ANTENNA_TO_DISABLE}
     sleep     5 min
     Wait For OnAir


