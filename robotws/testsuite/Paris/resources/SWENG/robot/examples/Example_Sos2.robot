*** Settings ***
Documentation
...          Just an exemple on SOS during capture

Resource                            ../Tools.robot
Resource                            ../Setup.robot
Resource                            ../Topology.robot
Library                             ../../python/StringTool.py
Library                             ../../python/OsTool.py
Library                             ../../python/Setup.py

Suite Setup                         Suite Setup
#Suite Teardown                      Suite Teardown

*** Test Cases ***
Test Capture
    ${CaptureL1L2}                  Capture L1L2 Set Upon Config            airscale=${GNB_DU}

Test OK
    Dated log                       Start

Test Capture Complet
    ${CaptureBIP}                   Capture L1L2 Set Upon Config             airscale=${GNB_DU}
    Capture Init                    ${CaptureBIP}                            withTN=True
    Capture Start                   ${CaptureBIP}
    Sleep                           1s
    Capture Stop                    ${CaptureBIP}


Test KO
    Dated Log                       Test KO
    should be true                  ${False}

Test Depends
    [Setup]                         depends         Test KO
    Dated log                       Test Depends


*** Keywords ***
Check Airscale
    [Arguments]                     ${airscale}
    run keyword if                  '${airscale.hw}'=='GNB'
    ...                             Dated log                         Check ${airscale.name}:GNB
    run keyword if                  '${airscale.hw}'!='GNB'
    ...                             Dated log                         Check ${airscale.name}:NOT GNB
    ${isGNB}                        call method                       ${airscale}
    ...                             isGNB
    Dated log                       Check ${airscale.name} is GNB:${isGNB}
