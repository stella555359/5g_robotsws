*** Settings ***
Documentation    Keywords for ETWS 5GC000747 TCs
Library    ute_ue
Library    taf.transport.ssh    WITH NAME    ssh
Library    ta5g_cell_operations
Library    ta5g_admin_operations

Library    ../../../resources/rrm_fixture.py
Resource    ../../../resources/logs.robot
Library    ../../../resources/webUI_operations.py
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T04/5GC001167/resources/keywords_1167.py    WITH NAME    python_1167
Library    ../../../resources/etws_cmas/AlertChecker.py    ${UE_SN}    WITH NAME    UE_1
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/l1l2_collector.py

*** Variables ***
${CBC_HOST}=    10.9.202.153
${CBC_USER}=    cbctest
${CBC_PASS}=    cbctest
${L1L2_CAPTURE_TIME}=    100
${TIMER_IDLE}=    60
${TIMER_INACTIVE}=    30
${FIRST_UE}=     UE_1
${UE_1_CELL}=    100
${UE_SN}    0123456789ABCDEF
@{PDSCH_MESSAGES_FILTER}    0xE118    0xE126    0xE128

*** Keywords ***
Activate ETWS
    Log To Console    Activating ETWS
    update_parameter    param=actETWS    value=true    distname=MRBTS-${mrbts_id}/NRBTS-${mrbts_id}

Deactivate ETWS
    Log To Console    Deactivating ETWS
    update_parameter    param=actETWS    value=false    distname=MRBTS-${mrbts_id}/NRBTS-${mrbts_id}

Activate PWS Restart Indication
    Log To Console    Activating PWS Restart Indication
    update_parameter    param=pwsRestIndEnabled    value=true    distname=MRBTS-${mrbts_id}/NRBTS-${mrbts_id}

Deactivate PWS Restart Indication
    Log To Console    Deactivating PWS Restart Indication
    update_parameter    param=pwsRestIndEnabled    value=false    distname=MRBTS-${mrbts_id}/NRBTS-${mrbts_id}

Lock Cell
    [Arguments]    ${cell_id}
    Lock Single Cell    cell_id=${cell_id}    timeout=60
    Check Cell Is Locked    cell_id=${cell_id}

Unlock Cell
    [Arguments]    ${cell_id}
    Unlock Single Cell    cell_id=${cell_id}    timeout=60
    Check Cell Is Not Locked    cell_id=${cell_id}

Attach Ue To Selected Cell
    [Arguments]    ${ue}
    Require Ue If Not Reserved    ${ue}
    ute_ue.Attach Ue    ${ue}
