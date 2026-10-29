*** Settings ***
Documentation
...    Author:yin zhang
...    contact:yin.zhang@nokia-sbell.com
...    squad group:VRF3_7
Suite Setup       Common Suite Setup And Setup BTS env    scf=${GNB_CONFIG}
Suite Teardown    Common Suite Teardown
Resource          ../resources/DevHZ5_resource_ST.robot

*** Variables ***
${GNB_CONFIG}    SCFC_1.xml

*** Test Cases ***
Setup GNB
    log to console    Hello ST World!!!



