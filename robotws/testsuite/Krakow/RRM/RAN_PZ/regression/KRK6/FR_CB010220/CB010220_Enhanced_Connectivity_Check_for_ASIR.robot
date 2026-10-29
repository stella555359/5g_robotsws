*** Settings ***
Documentation
...  author:  Michal Jonczyk    Monika Myśliwiec   Szymon Mastalski   Mateusz Potoniec
...  contact: paulina.jedras@nokia.com    monika.mysliwiec@nokia.com    mateusz.potoniec@nokia.com

Resource    ./resources/suite_specific_keywords.robot


Suite Setup    Suite Setup


*** Test Cases ***
CB010220_17_C2_Ethernet_transport_counters_on_AirScale_and_ASiR_with_SOAP_RP1
    [Setup]                                                suite_specific_keywords.Test Setup
    Verify allowed faults on gNB                           SSH enabled
    ...                                                    R&D Service Port enabled
    ...                                                    LMP access via port 443
    ...                                                    Ethernet port security is disabled
    ...                                                    Service account root access is enabled
    ...                                                    LMP connectivity detected
    Log Action to Console                                  Change ruEthernetInterfaceStatisticsInterval to 15 min
    Change Counter Capture Interval Time                   15min
    Log Action to Console                                  Sleep 20 min
    Sleep                                                  20 min
    Check RU Counters
    Check BTS Counters
    [Teardown]                                             suite_specific_keywords.Test Teardown
