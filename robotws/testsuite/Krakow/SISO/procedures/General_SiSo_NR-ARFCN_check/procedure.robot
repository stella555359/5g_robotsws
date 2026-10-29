*** Settings ***

Resource    ./keywords.robot


*** Keywords ***
General SiSo NR-ARFCN check
    Set Delta Values
    Change Delta Values for Min Frequency
    Change Delta Values for Max Frequency
    [Teardown]    Change Delta Values for Mid Frequency
