*** Settings ***
Documentation
...   feature keywords

Library       ute_admin_infomodel
Library       taf.sbts.oam.coam.admin
Library       ute_ue
Library       SSHLibrary
Resource      ../../../resources/preconditions.robot
Library       ../../../resources/rrm_fixture.py
Library       ../../../resources/webui/interface.py
Library      ta5g_cell_operations
Library      ta5g_admin_operations
Library      ../../../resources/etws_cmas/counters.py
Library      ../../5GC000747/resources/keywords_747.py
Library    ../../5GC000747/resources/EtwsBroadcaster.py


*** Keywords ***
################################### CMAS SUBFEATURE E #########################################
All Preconditions To Test
    Run Keyword And Ignore Error    UE_1.clear_all_alerts

All Postconditions To Test
    Run Keywords
    ...    Run Keyword And Ignore Error    UE_1.clear_all_alerts    AND
    ...    Detach UE    UE_1


Send Write-Replace And Cancel Script
    [Arguments]     ${cells}    ${alarm_id}
    start_cmas_notification    cells=${cells}    msg_id=${alarm_id}
    BuiltIn.Sleep    7    reason=Broadcast has to run few seconds before cancel script
    cancel_cmas_notification    cells=${cells}


Send Write Replace Script
    [Arguments]    ${cells}    ${alarm_id}=4370
    start_cmas_notification    cells=${cells}    msg_id=${alarm_id}

Activate CMAS
    update_parameter    param=actCMAS    value=true    distname=MRBTS-${mrbts_id}/NRBTS-${mrbts_id}

Deactivate CMAS
    update_parameter    param=actCMAS    value=false    distname=MRBTS-${mrbts_id}/NRBTS-${mrbts_id}

Block Target Cell
    [Arguments]   ${cell}
    WebUI.create_session
    WebUI.cell_lock   cell_id=${cell}
    Log To Console    \n Target cell, Global cell ID: ${cell} is BLOCKED
    [Teardown]  WebUI.teardown_session

Unblock Target Cell
    [Arguments]   ${cell}=${old_target_cell}
    WebUI.create_session
    WebUI.cell_unlock   cell_id=${cell}
    Log To Console    \n Target cell, Global cell ID: ${cell} is UNBLOCKED
    [Teardown]  WebUI.teardown_session
