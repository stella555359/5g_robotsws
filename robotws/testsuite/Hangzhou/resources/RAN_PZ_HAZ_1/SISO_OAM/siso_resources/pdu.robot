*** Settings ***
Documentation
...    Author:    Wu Amy;Zhou Qiang;Ding Lisa
...    Maintainer:    Wu Amy;Zhou Qiang;Ding Lisa

Library     taf.hw.pdu        WITH NAME    pdu
Library     Collections

*** Keywords ***
PDU Turn Off Unit
    [Arguments]    ${pdu_type}    ${pdu_ip}    ${pdu_port}
    [Documentation]    Verifies if specified PDU port is in 'off' state. If not, it switches it off.
    ...                Keyword returns True, if port has been switched.
    ...                Author: tomasz.blaszczyszyn@nokia.com
    ...                Maintainer: michal.szajkowski@nokia.com
    pdu.Setup Pdu         host=${pdu_ip}    model=${pdu_type}
    ${port_status}=                pdu.Get Port Status    port=${pdu_port}
    ${port_status_needs_change}=   Evaluate   "${port_status}"=="on"
    Return From Keyword If   not ${port_status_needs_change}  ${port_status_needs_change}
    ${out_action_status}=    Run Keyword And Return Status    pdu.Power Off   port=${pdu_port}
    Sleep  2 seconds
    ${out_port_status}=    pdu.Get Port Status    port=${pdu_port}
    Run Keyword If    not ${out_action_status}
    ...    Should Be Equal    ${out_port_status}    off
    [Return]      ${port_status_needs_change}

PDU Turn On Unit
    [Arguments]    ${pdu_type}    ${pdu_ip}    ${pdu_port}
    [Documentation]    Verifies if specified PDU port is in 'on' state. If not, it switches it on.
    ...                Keyword returns True, if port has been switched.
    ...                Author: tomasz.blaszczyszyn@nokia.com
    ...                Maintainer: michal.szajkowski@nokia.com
    pdu.Setup Pdu        host=${pdu_ip}    model=${pdu_type}
    ${port_status}=                pdu.Get Port Status    port=${pdu_port}
    ${port_status_needs_change}=   Evaluate   "${port_status}"=="off"
    Return From Keyword If   not ${port_status_needs_change}  ${port_status_needs_change}
    ${out_action_status}=    Run Keyword And Return Status    pdu.Power On    port=${pdu_port}
    Sleep  2 seconds
    ${out_port_status}=    pdu.Get Port Status    port=${pdu_port}
    Run Keyword If    not ${out_action_status}
    ...     Should Be Equal    ${out_port_status}    on
    [Return]      ${port_status_needs_change}

PDU Reset Unit
    [Arguments]    ${pdu_type}    ${pdu_ip}    ${pdu_port}    ${time_interval}=10
    [Documentation]    Perform power on and then off of single PDU port,
    ...                specified by the PDU device type, its IP address and outlet number
    ...                Author:      artur.dobosz@nokia.com
    ...                Maintainer:  Author
    pdu.Setup Pdu         host=${pdu_ip}        model=${pdu_type}
    pdu.Reset Ports       ports=${pdu_port}    time_interval=${time_interval}
    pdu.Get Port Status    port=${pdu_port}

PDU Turn Off All Devices From Serial Number List
    [Arguments]    ${fr_serial_number_list}    ${PDU_CONFIG}    ${EQM}=deprecated  ${verbose}=False
    [Documentation]    Turns off PDU outlets for all devices that are provided as a list of serial numbers.\n
    ...                This keyword requires a dictionary variable to be defined
    ...                with serial number as a name and with keys 'pdu_type', 'pdu_ip', 'pdu_port'
    ...     Arguments:
    ...     PDU_CONFIG - dictionary structure like for TL1 variable from \config\Wroclaw\GVE_WRO_CLOUD3601\__init__.py
    ...     EQM - deprecated parameter, keyword finds correct EQM by itself
    ...
    ...     Author:      tomasz.blaszczyszyn@nokia.com
    ...     Maintainer:  piotr.korczynski@nokia.com
    ${sn_list_powered_off}=  Create List
    FOR    ${sn}    IN    @{fr_serial_number_list}
       ${status}    Run Keyword And Return Status    dictionary should contain key    ${PDU_CONFIG['${eqm}']}    ${sn}
       continue for loop if    "${status}" == "False"
       pdu.Setup Pdu    model=${PDU_CONFIG['${eqm}']['${sn}']['pdu']['type']}
       ...    host=${PDU_CONFIG['${eqm}']['${sn}']['pdu']['ip_addr']}
       ${port_status}    pdu.Get Port Status    port=${PDU_CONFIG['${eqm}']['${sn}']['pdu']['port']}
       continue for loop if    "${port_status}" == "off"
       pdu.Power Off    ${PDU_CONFIG['${eqm}']['${sn}']['pdu']['port']}
       Log  ${sn} powered off.   console=${verbose}
       Append To List    ${sn_list_powered_off}    ${sn}
    END
    [Return]  ${sn_list_powered_off}

PDU Turn On All Devices From Serial Number List
    [Arguments]    ${fr_serial_number_list}    ${PDU_CONFIG}    ${eqm}=FR  ${verbose}=False
    ${sn_list_powered_on}=  Create List
    FOR    ${sn}    IN    @{fr_serial_number_list}
        ${status}    Run Keyword And Return Status    dictionary should contain key    ${PDU_CONFIG['${eqm}']}    ${sn}
        continue for loop if    "${status}" == "False"
        pdu.Setup Pdu    model=${PDU_CONFIG['${eqm}']['${sn}']['pdu']['type']}
        ...    host=${PDU_CONFIG['${eqm}']['${sn}']['pdu']['ip_addr']}
        ${port_status}    pdu.Get Port Status    port=${PDU_CONFIG['${eqm}']['${sn}']['pdu']['port']}
        continue for loop if    "${port_status}" == "on"
        pdu.Power On    ${PDU_CONFIG['${eqm}']['${sn}']['pdu']['port']}
        Log  ${sn} powered on.   console=${verbose}
        Append To List    ${sn_list_powered_on}    ${sn}
    END
    [Return]  ${sn_list_powered_on}

PDU Reset All Devices From Serial Number List
    [Arguments]    ${serial_number_list}    ${PDU_CONFIG}    ${time_interval}=10  ${verbose}=False
    ${eqm_list}=   Get Dictionary Keys  ${PDU_CONFIG}
    ${eqm_list}=   Evaluate  [eqm for eqm in $eqm_list if isinstance($PDU_CONFIG[eqm], dict)]
    FOR    ${sn}    IN    @{serial_number_list}
       ${eqm}=    Evaluate  [eqm if $sn in $PDU_CONFIG[eqm].keys() else '' for eqm in $eqm_list]
       ${eqm}=    Evaluate  [eqm for eqm in $eqm if eqm != ''][0]
       pdu.Setup Pdu    model=${PDU_CONFIG['${eqm}']['${sn}']['pdu']['type']}
       ...    host=${PDU_CONFIG['${eqm}']['${sn}']['pdu']['ip_addr']}
       pdu.Power Off    ${PDU_CONFIG['${eqm}']['${sn}']['pdu']['port']}
       Sleep    ${time_interval}
       pdu.Power On     ${PDU_CONFIG['${eqm}']['${sn}']['pdu']['port']}
    END
    Log   ${serial_number_list} have been reset  console=${verbose}
