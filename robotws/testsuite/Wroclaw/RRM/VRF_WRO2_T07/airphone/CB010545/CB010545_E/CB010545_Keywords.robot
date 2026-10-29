*** Settings ***
Documentation    :copyright: Nokia

Library    Collections
Library    ute_wtssim
Library    ute_fsmaccess
Library    ta5g_testline_management
Library    ta5g_iphy
Library    ta5g_enb
Library    ta5g_delta
Library    ta5g_pm_counters
Library    ta5g_file_system
Library    ta5g_ue_measurements
Library    ta5g_dcap
Library    ta5g_commissioning
Library    ta5g_egate
Library    ta5g_ue_mobility
Library    ta5g_throughput
Library    ta_pcmd.tshark_plugin_configurator
Library    ta_pcmd
Library    taf.sbts.oam.coam.admin  WITH NAME  coam

*** Keywords ***

Send getCellList Command and check active UEs from each cell
    [Arguments]    ${total_ues}
    ${cells_ues}    Set variable    0
    coam.connect to
    ${a}     coam.get cell list
    coam.teardown
    ${a_list}   Set variable   ${a['cells']['nr']}
    ${length}=   Get Length   ${a_list}
    ${cell_list_counters}=  create list
    ${cell_list_conf}=  create list
    ${get_bts_info}=  create list
    FOR  ${i}   IN RANGE   ${length}
        Append To List   ${cell_list_conf}   ${a_list[${i}]['id']['configuration']}
        Append To List   ${cell_list_counters}   ${a_list[${i}]['counters']['activeUEs']}
        ${cells_ues}=    Evaluate    ${cells_ues} + ${cell_list_counters}[${i}]
    END
    Should Be Equal As Integers     ${cells_ues}    ${total_ues}


Send getCellById Command and extract active UEs counter from each cell
    [Arguments]    ${total_ues}
    ${cells_ues}    Set variable    0
    coam.connect to
    ${b}    coam.get cell specific info     cell_id=MRBTS-1/NRBTS-1/NRCELL-1
    coam.teardown
    ${b_list}   Set variable   ${b['counters']}
    ${cell_list_counters}=  create list
    Append To List   ${cell_list_counters}   ${b_list['activeUEs']}
    ${cells_ues}=    Evaluate    ${cells_ues} + ${cell_list_counters}[0]
    Should Be Equal As Integers     ${cells_ues}    ${total_ues}

Send getCellById Command and expect error 70
    [Arguments]    ${dist_name_wrong}
    coam.connect to
    ${output}  run keyword and ignore error    coam.get cell specific info     cell_id=${dist_name_wrong}
    coam.teardown
#    Log to console  ${output}[1]
    Should contain   ${output}[1]   ErrorCode: 70


Send getBtsInfo Command and extract active UEs counter from each cell
    [Arguments]    ${total_ues}
    ${cells_ues}    Set variable    0
    coam.connect to
    ${get_bts_info}    coam.get bts info
    coam.teardown
    ${list_cels_bts_info}   Set variable   ${get_bts_info['cells']['nr']}
    ${length}=   Get Length   ${list_cels_bts_info}
    ${cell_list_counters}=  create list
    ${cell_list_conf}=  create list
    ${get_bts_info}=  create list
    FOR  ${i}   IN RANGE   ${length}
        Append To List   ${cell_list_conf}   ${list_cels_bts_info[${i}]['id']['configuration']}
        Append To List   ${cell_list_counters}   ${list_cels_bts_info[${i}]['counters']['activeUEs']}
        ${cells_ues}=    Evaluate    ${cells_ues} + ${cell_list_counters}[${i}]
    END
    Should Be Equal As Integers     ${cells_ues}    ${total_ues}


Start Xn And Ng Interfaces
    Start Vm Ethernet Interface    if_name=eth3:xn    ip_with_mask=10.0.1.101/24
    Start Vm Ethernet Interface    if_name=eth3:ng    ip_with_mask=10.0.1.102/24

Start Vm Ethernet Interfaces
    Start Vm Ethernet Interface    if_name=eth3:AMF2_NG_ADDR   ip_with_mask=10.0.1.3/24
    Start Vm Ethernet Interface    if_name=eth3:AMF3_NG_ADDR   ip_with_mask=10.0.1.4/24

Stop Vm Ethernet Interfaces
    Stop Vm Ethernet Interface    if_name=eth3:AMF2_NG_ADDR   ip_with_mask=10.0.1.3/24
    Stop Vm Ethernet Interface    if_name=eth3:AMF3_NG_ADDR   ip_with_mask=10.0.1.4/24

Attach Ue And Establish PDU Session
    [Arguments]    ${ue_id}    ${gw_id}
    Attach Ue    ue_id=${ue_id}
    Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Establish Pdu Session    ue_id=${ue_id}    gw_id=${gw_id}

Set PDU Param Internal Traffic
    [Arguments]    ${ue_id}    ${pdu_id}=1
    Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal







