*** Settings ***
Documentation    :copyright: Nokia

Resource     ../../../../resources/airphone/5G_SW_WRO_Keywords.robot
Library      CB013513_Keywords.py
Library      ta5g_testline_management
Library      ta5g_ue_measurements
Library      ta5g_cell_operations
Library      ta5g_throughput
Library      ta5g_delta
Library      ta5g_iphy
Library      ta5g_enb

*** Variables ***
${SCELL_ACTIVATION_REGEXP}=    SCellIndex 1 activated successfully at airphone.*SCellIndex 2 activated successfully at airphone.|
...                            SCellIndex 2 activated successfully at airphone.*SCellIndex 1 activated successfully at airphone.
${SCELL_DEACTIVATION_REGEXP}=    SCellIndex 1 deactivated successfully at airphone.*SCellIndex 2 deactivated successfully at airphone.|
...                              SCellIndex 2 deactivated successfully at airphone.*SCellIndex 1 deactivated successfully at airphone.

*** Keywords ***
Set Internal Traffic Type To UE
    [Arguments]    ${ue_id}    ${pdu_id}
    Execute Egate Command   cmd=set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
