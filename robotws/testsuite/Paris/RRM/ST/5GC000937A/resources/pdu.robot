*** Keywords ***
Power Reset ATEN
    [Arguments]    ${host}=None    ${pdu_port_num}=None
    Connect to ATEN    host=${host}
    run keyword and return    Switch off on port ${pdu_port_num}

Connect to ATEN
    [Arguments]    ${host}=None
    pdu.setup_pdu    model=aten    host=${host}    alias=ATEN_SWITCH

Switch off on port ${pdu_port_num}
    pdu.reset_ports                 ports=${pdu_port_num}    time_interval=10    pdu_device=ATEN_SWITCH
    Sleep    15
    ${port_status}    pdu.get_port_status    port=${pdu_port_num}    pdu_device=ATEN_SWITCH
    ${status}    run keyword if    "${port_status}" == "on"    set variable    ${True}
    ...             ELSE    set variable   ${False}
    Sleep    30
    [return]    ${status}
