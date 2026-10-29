*** Settings ***
Library     ./gnbtl.py
Library     OperatingSystem
Resource    ../ute_workarounds.robot
Resource    ../wts_ue.robot
Resource    ../gnb.robot

*** Test Cases ***
Test Log TL Info as Metadata for UTE AP TL
    [TAGS]              UTEWA
    Log TL Info as Metadata for UTE AP TL

Test Patch testline configuration for UTE Cloud
    [TAGS]              UTEWA
    Patch testline configuration for UTE Cloud

Test Reset IP on VM
    [TAGS]              UTEWA
    Reset IP on VM                  interface=eth3
    Show IP Address Of Interface    interface=eth3

Test Modify SCTP Settings on Test-VM and AP
    [TAGS]              UTEWA
    Modify SCTP Settings on Test-VM and AP

Test Bring Airphone TL to F1 up status
    [TAGS]              UTEWA
    UTE Cloud Workaround
    Bring Airphone TL to F1 up status

Test Bring Airphone TL to on Air status without reboot
    [TAGS]              UTEWA
    UTE Cloud Workaround
    Kill WTS services
    Bring Airphone TL to on Air status without reboot
    ${cache_is_filled}   Get Variable Value  ${P_CACHED_CELL_STATUS}
    Log To Console  \nCheck the test variable P_CACHED_CELL_STATUS is reset to None
    Should Be True  ${P_CACHED_CELL_STATUS} == ${None}

Test gnb.Wait until Node to be onair state
    [TAGS]              UTEWA
    Log To Console  \Perform gNB reset and wait until gNB comes onAir again
    gnb.Perform gNB reboot
    Log To Console  \nAfter reboot the first cell check should fail
    Run Keyword And Expect Error    *   Wait until Node to be onair state    timeout=30s
    Wait until Node to be onair state

Test gnb.Wait until all gNBs to be onair state
    [TAGS]              UTEWA
    Log To Console  \nTest KW from gnb.robot which needs previous TC as precondition
    ${gnb_num}=    Get length    ${tl.gnbs}
    Return From Keyword If  ${gnb_num}>1   Skip these test as we only prepared gnb0!
    Wait until all gNBs have first X2 Link Status Available
    Wait until all gNBs to be onair state

Test Check gNB X2 Link Status is Available
    [TAGS]              UTEWA
    Log To Console  \nTest KW from gnb.robot which needs previous TC as precondition
    Check gNB X2 Link Status is Available

Test Prepare TL for TTITraces
    [TAGS]              UTEWA
    Log To Console  Save current directory path
    ${orgdir}       Evaluate    os.path.abspath(os.getcwd())    modules=os
    Prepare TL for TTITraces
    Log To Console  Compare current directory path with previous path
    ${curdir}       Evaluate    os.path.abspath(os.getcwd())    modules=os
    Should Be Equal As Strings  ${orgdir}   ${curdir}   Unexpected current directory after installation

Test Check TL connectivity and PDU status
    [TAGS]              UTEWA
    Log To Console  \nPower Off TL
    ${gnb_pdu_alias}=    pdu.setup pdu    ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu}
    pdu.power_off    port=${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}  pdu_device=${gnb_pdu_alias}
    ${ue_pdu_alias}=    pdu.setup pdu    ${tl.ues[0].l1.common_units[0].pdu_port.pdu}
    pdu.power_off    port=${tl.ues[0].l1.common_units[0].pdu_port.port_no}  pdu_device=${ue_pdu_alias}
    Sleep    5       reason=wait for TL down
    Check TL connectivity and PDU status
    Log To Console  \nPower On TL
    pdu.power_on     port=${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}  pdu_device=${gnb_pdu_alias}
    pdu.power_on     port=${tl.ues[0].l1.common_units[0].pdu_port.port_no}  pdu_device=${ue_pdu_alias}
    Sleep    3min    reason=wait for TL up
    Check TL connectivity and PDU status

*** Keywords ***
Show IP Address Of Interface
    [Arguments]     ${interface}
    ${output}       Run     ip addr show dev ${interface}
    Log To Console  \n${output}
