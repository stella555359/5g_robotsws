*** Settings ***
Documentation
...    author: Ulm SQD 65
...    Team: 'MN RAN L3 SW ULM L3NRT SQD 65'
...    Email: 'I_MN_RAN_L3_SW_ULM_SQD_65@internal.nsn.com'
...    Description: Keywords for CB008196

Resource          ../resources/SQD65/sqd65_keywords.robot
Library           Process

Library     taf.config.wts    WITH NAME     wts_conf
Library     taf.transport.ssh    WITH NAME    ssh

*** Keywords ***

Prepare TL for Ute Cloud Acceptance test
    Sqd65 Common Setup
    Bring Airphone TL to on Air status without reboot

Perform Preconditions of Test Case
    Start Logging    pmcounter_enabled=${False}

Perform Postconditions of Test Case
    run_keyword_and_warn_on_failure    Stop logging

Attach SA UEs
    [Arguments]  ${count}=1
    FOR    ${ue_id}    IN RANGE    1  ${${count}+1}
        UE Register  ue_id=${ue_id}
        Sleep  2s
        Set traffic type  ue_id=${ue_id}  pdu_id=1  trf_type=internal
        Sleep  2s
        UE PDU Session Setup    ue_id=${ue_id}  pdu=1  gw=${ue_id}
        Sleep  2s
    END

Attach NSA UEs
    [Arguments]  ${count}=1
    FOR    ${ue_id}    IN RANGE    ${SANSADELTA}+1  ${${count}+${SANSADELTA}+1}
        Attach UE to LTE    ue_id=${ue_id}
        Sleep  2s
        Trigger LTE-NR dual connectivity for bearers    ue_id=${ue_id}  target_cells=${${ue_id}-${SANSADELTA}}
        Sleep  2s
    END

Start Traffic on SA UEs
    [Arguments]  ${count}=1  ${DL}=10  ${UL}=5
    FOR    ${ue_id}    IN RANGE    1  ${${count}+1}
        Start data traffic in egate   ue_id=${ue_id}  direction=dl  protocol=udp   trf_id=1  pdu=1  qfi=1  mbps=${DL}
        Start data traffic in egate   ue_id=${ue_id}  direction=ul  protocol=udp   trf_id=1  pdu=1  qfi=1  mbps=${UL}
    END

Start Traffic on NSA UEs
    [Arguments]  ${count}=1  ${DL}=10  ${UL}=5
    FOR    ${ue_id}    IN RANGE    ${SANSADELTA}+1  ${${count}+${SANSADELTA}+1}
        Start data traffic in egate   ue_id=${ue_id}  direction=dl  protocol=udp   trf_id=1  id=2  mbps=${DL}
        Start data traffic in egate   ue_id=${ue_id}  direction=ul  protocol=udp   trf_id=1  id=2  mbps=${UL}
    END

Check Traffic for SA UEs
    [Arguments]  ${count}=1  ${DL}=10  ${UL}=5
    FOR    ${ue_id}    IN RANGE    1  ${${count}+1}
        ${ue_dl}=  Get Average Data Rate via Egate  ue_id=${ue_id}  pdu=1  trf_id=1  qfi=1  dir=dl
        ${ue_ul}=  Get Average Data Rate via Egate  ue_id=${ue_id}  pdu=1  trf_id=1  qfi=1  dir=ul
        ${dl_status}=    Evaluate  ${${DL}*1000000} * 0.9 <= ${ue_dl} <= ${${DL}*1000000} * 1.1
        ${ul_status}=    Evaluate  ${${UL}*1000000} * 0.9 <= ${ue_ul} <= ${${UL}*1000000} * 1.1
        IF    ${dl_status}    Log  DL speed of UE ${ue_id} OK
        ...  ELSE  Run Keyword And Continue On Failure    Fail  DL speed of UE ${ue_id} not OK
        IF    ${ul_status}    Log  UL speed of UE ${ue_id} OK
        ...  ELSE  Run Keyword And Continue On Failure    Fail  UL speed of UE ${ue_id} not OK
    END

Check Traffic for NSA UEs
    [Arguments]  ${count}=1  ${DL}=10  ${UL}=5
    FOR    ${ue_id}    IN RANGE    ${SANSADELTA}+1  ${${count}+${SANSADELTA}+1}
        ${ue_dl}=  Get Average Data Rate via Egate  ue_id=${ue_id}  id=2  trf_id=1  dir=dl
        ${ue_ul}=  Get Average Data Rate via Egate  ue_id=${ue_id}  id=2  trf_id=1  dir=ul
        ${dl_status}=    Evaluate  ${${DL}*1000000} * 0.9 <= ${ue_dl} <= ${${DL}*1000000} * 1.1
        ${ul_status}=    Evaluate  ${${UL}*1000000} * 0.9 <= ${ue_ul} <= ${${UL}*1000000} * 1.1
        IF    ${dl_status}    Log  DL speed of UE ${ue_id} OK
        ...  ELSE  Run Keyword And Continue On Failure    Fail  DL speed of UE ${ue_id} not OK
        IF    ${ul_status}    Log  UL speed of UE ${ue_id} OK
        ...  ELSE  Run Keyword And Continue On Failure    Fail  UL speed of UE ${ue_id} not OK
    END

Stop Traffic on SA UEs
    [Arguments]  ${count}=1
    FOR    ${ue_id}    IN RANGE    1  ${${count}+1}
        Stop data traffic in egate   ue_id=${ue_id}  direction=bi  trf_id=1  pdu=1  qfi=1
    END

Stop Traffic on NSA UEs
    [Arguments]  ${count}=1
    FOR    ${ue_id}    IN RANGE    ${SANSADELTA}+1  ${${count}+${SANSADELTA}+1}
        Stop data traffic in egate   ue_id=${ue_id}  direction=bi  trf_id=1  id=2
    END

Detach SA UEs
    [Arguments]  ${count}=1
    FOR    ${ue_id}    IN RANGE    1  ${${count}+1}
        UE Deregister  ${ue_id}
        Sleep  2s
    END

Detach NSA UEs
    [Arguments]  ${count}=1
    FOR    ${ue_id}    IN RANGE    ${SANSADELTA}+1  ${${count}+${SANSADELTA}+1}
        Detach UE from LTE  ue_id=${ue_id}
        Sleep  2s
    END
