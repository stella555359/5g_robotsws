*** Settings ***

Documentation
...   This is a test suite used in KW resourceCI running against real AP TL.
...   It verifies proper function of KWs in ute_workarounds.robot for classical deployments.


Library     OperatingSystem

Library     gnbtl.py

Resource    ../ute_workarounds.robot
Resource    ../wts_ue.robot
Resource    ../gnb.robot

Suite Setup   Setup For UTE Workaround Tests

*** Test Cases ***
Test Log TL Info as Metadata for UTE AP TL
    [TAGS]              UTEWA
    Log TL Info As Metadata For UTE AP TL

Test Reset IP on VM
    [TAGS]              UTEWA
    Reset IP On VM                  interface=eth3
    Show IP Address Of Interface    interface=eth3

Test Modify SCTP Settings on Test-VM and AP
    [TAGS]              UTEWA
    Modify SCTP Settings On Test-VM And AP

Test Bring Airphone TL to F1 up status
    [TAGS]              UTEWA
    Bring Airphone TL To F1 Up Status

Test Bring Airphone TL to on Air status without reboot
    [TAGS]              UTEWA
    [Setup]   Setup For Ute Workaround Tests
    Bring Airphone TL To On Air Status Without Reboot   capture_cell_setup_trace=${True}
    ${cache_is_filled}   Get Variable Value  ${P_CACHED_CELL_STATUS}
    Log To Console  \nCheck the test variable P_CACHED_CELL_STATUS is reset to None
    Should Be True  $cache_is_filled is None

Test Wait until Node to be onair state
    [TAGS]              UTEWA
    [Setup]   Setup For UTE Workaround Tests
    Log To Console  \Perform gNB reset and wait until gNB comes onAir again
    gnb.Perform GNB Reboot
    wts_ue.Kill WTS Services
    Log To Console  \nAfter reboot the first cell check should fail
    Run Keyword And Expect Error    *   gnb.Wait Until Node To Be Onair State    timeout=30s
    wts_ue.Start WTS For Airphone
    ute_workarounds.Modify SCTP Settings On Test-VM And AP
    gnb.Wait For Minimum Required State For Cell Setup For All GNBs
    ute_workarounds.Configure WTS For UTE Cloud Airphone TL
    Wait Until Node To Be Onair State

Test Wait until all gNBs to be onair state
    [TAGS]              UTEWA
    Log To Console  \nTest KW from gnb.robot which needs previous TC as precondition
    ${gnb_num}=    Get Length    ${tl.gnbs}
    IF  ${gnb_num}>1   Pass Execution   Skip these test as we only prepared gnb0!
    Wait Until All GNBs Have First X2 Link Status Available
    Wait Until All GNBs To Be Onair State
    Wait Until Node To Be Onair State For All Cells With Different Technologies

Test Check gNB X2 Link Status is Available
    [TAGS]              UTEWA
    Log To Console  \nTest KW from gnb.robot which needs previous TC as precondition
    Check GNB X2 Link Status Is Available


Test Check TL connectivity and PDU status
    [TAGS]              UTEWA
    Log To Console  \nPower Off TL
    ${gnb_pdu_alias}=    pdu.Setup Pdu    ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu}
    pdu.Power Off    port=${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}  pdu_device=${gnb_pdu_alias}
    ${ue_pdu_alias}=    pdu.Setup Pdu    ${tl.ues[0].l1.common_units[0].pdu_port.pdu}
    pdu.Power Off    port=${tl.ues[0].l1.common_units[0].pdu_port.port_no}  pdu_device=${ue_pdu_alias}
    Sleep    5       reason=wait for TL down
    Check TL Connectivity And PDU Status
    Log To Console  \nPower On TL
    pdu.Power On     port=${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}  pdu_device=${gnb_pdu_alias}
    pdu.Power On     port=${tl.ues[0].l1.common_units[0].pdu_port.port_no}  pdu_device=${ue_pdu_alias}
    Sleep    3min    reason=wait for TL up
    Check TL Connectivity And PDU Status

*** Keywords ***
Show IP Address Of Interface
    [Arguments]     ${interface}
    ${output}       Run     ip addr show dev ${interface}
    Log To Console  \n${output}

Setup For UTE Workaround Tests
    Patch Testline Configuration For UTE Cloud
    UTE Cloud Workaround
