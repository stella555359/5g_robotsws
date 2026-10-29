*** Settings ***
Documentation
...    This file is reference from HZ team


Resource  DevHZ5_startup.robot

*** Variables ***
${UE1}  1
${UE2}  2
${UE3}  3
${UE4}  4
${UE5}  5

*** Keywords ***
Bar Cell${number}
  Delta Commission Parameters  LNCELL-${number}:cellBarred=barred
  # can't check Barring status in WEBGUI or infomodel, it is totally different thing with LNCELL:cellBarred
  # PR CNNed: PR630295: [22R2][ASOE][FDD][CPRI]: cell Barring status is not correct
  Object Should Exist  LNCELL-${number}:cellBarred=barred

Notbar Cell${number}
  Delta Commission Parameters  LNCELL-${number}:cellBarred=notBarred
  Object Should Exist  LNCELL-${number}:cellBarred=notBarred

Disable S1 Link
    Delta Commission Parameters  LNMME-0:ipAddrPrim\=10.68.151.20

Enable S1 Link
    Delta Commission Parameters  LNMME-0:ipAddrPrim\=10.0.1.1

Lock Cell${number}
  Delta Commission Parameters  LNCELL-${number}:administrativeState=Locked
  Cell Should Be Locked  ${number}

Unlock Cell${number}
  Delta Commission Parameters  LNCELL-${number}:administrativeState=Unlocked
  Cell Should Be Unlocked  ${number}

Block Cell${number}
  ${nrcel_id}  Get cell id by configuration id  LTE  ${number}
  Block_cell  ${nrcel_id}
  Assert  NRCEL  ${nrcel_id}  blockingState=Blocked
  Sleep  10s

Unblock Cell${number}
  ${nrcel_id}  Get cell id by configuration id  LTE  ${number}
  Unblock_cell  ${nrcel_id}
  Assert  NRCEL  ${nrcel_id}  blockingState=Unblocked
  Cells Should Be OnAir  cell_id=${number}

Remove Blank Character
    [Arguments]    ${str}
    ${str}=    Remove String    ${str}    ${SPACE}
    ${str}=    Remove String    ${str}    \r\n
    ${str}=    Remove String    ${str}    \n
    ${str}=    Remove String    ${str}    \x1b[K
    [Return]    ${str}

Delta Commission Parameters And Wait Cells Onair
    [Arguments]    ${delta_params}    ${timeout}=360
    Delta Commission Parameters    ${delta_params}
    Cells Should Be Onair     timeout=${timeout}

Check pgw sgw and enb stats
    execute egate command    pgw_stats id=1,2 dir=dl    EGATE>
    execute egate command    sgw_stats id=1 dir=dl    EGATE>
    execute egate command    enb_stats id=7 type=s1u    EGATE>
    execute egate command    enb_stats id=7 type=x2u    EGATE>
    execute egate command    enb_stats id=7 type=pdcp    EGATE>
