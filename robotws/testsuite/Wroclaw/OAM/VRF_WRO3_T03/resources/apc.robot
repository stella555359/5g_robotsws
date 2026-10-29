*** Settings ***
Library         taf.hw.pdu

Documentation
...  AUTHORS:       RAN_PZ_WRO_3_SG03
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  Internal WRO1 resource library repetitive keywords in multiple tests.
...  ******************
...  History of changes
...  ******************
...  16.10.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-443 - adaptation to ASO(E/F/G/H) system modules
...  27.03.2025 - https://jiradc.ext.net.nokia.com/browse/FCA_VRF_OAM-11759 - new KW: REBOOT Radio on APC using SN
...  *******************
...  RAN PZ3 WRO1 TEMPLATE

*** Keywords ***
APC Control
    [Arguments]  ${state}=ON  ${modules}=ALL
    Run Keyword And Ignore Error  Set APC State 4G  ${state}  ${modules}

Set APC State 4G
    [Arguments]  ${state}=ON  ${modules}=ALL
    ${ASO[EFGH]}  Run Keyword And Return Status  Evaluate  re.search(r'ASO[EFGH]', '${tl.tl_cloud_topology}').group(0)  re
    FOR  ${enb}  IN  @{tl.enbs}
        Run Keyword If  ('${modules}'=='ALL' or '${modules}'=='SM') and '${ASO[EFGH]}'=='${True}'
                                                        ...        Set APC State On System Module  ${enb.system_module.core_units}    ${state}
                                                        ...  ELSE  Set APC State On System Module  ${enb.system_module.common_units}  ${state}
        Run Keyword If  '${modules}'=='ALL' or '${modules}'=='RM'  Set APC State On Radio Module   ${enb}  ${state}
    END

Set APC State On System Module
    [Arguments]  ${units}  ${state}
    FOR  ${system_module}  IN  @{units}
        ${status}=  Run Keyword And Return Status  SET APC STATE   ${system_module.pdu_port.pdu.addr}
                                                           ...     ${system_module.pdu_port.port_no}
                                                           ...     ${system_module.pdu_port.pdu.model}
                                                           ...     ${state}
        Log To Console With Time
        ...  ${system_module.pdu_port.pdu.addr} ${system_module.pdu_port.port_no} ${system_module.pdu_port.pdu.model} ${state} SM - ${status}
    END

Set APC State On Radio Module
    [Arguments]  ${testline}  ${state}
    ${key_name}=    Set Variable    rms
    FOR  ${radio_module}  IN  @{testline.${key_name}}
        ${status}=  Run Keyword And Return Status  SET APC STATE   ${radio_module.pdu_port.pdu.addr}
                                                           ...     ${radio_module.pdu_port.port_no}
                                                           ...     ${radio_module.pdu_port.pdu.model}
                                                           ...     ${state}
        Log To Console With Time
        ...  ${radio_module.pdu_port.pdu.addr} ${radio_module.pdu_port.port_no} ${radio_module.pdu_port.pdu.model} ${state} RM - ${status}
    END

SET APC STATE
    [Arguments]  ${apc_ip}  ${apc_port}  ${apc_model}  ${state}
    Setup PDU     model=${apc_model}    host=${apc_ip}    alias=pdu
    Run Keyword If  '${state}'=='ON'      power_on   port=${apc_port}  pdu_device=pdu
    Run Keyword If  '${state}'=='OFF'     power_off  port=${apc_port}  pdu_device=pdu
    Run Keyword If  '${state}'=='REBOOT'  power_off  port=${apc_port}  pdu_device=pdu
    Run Keyword If  '${state}'=='REBOOT'  Sleep  2sec
    Run Keyword If  '${state}'=='REBOOT'  power_on   port=${apc_port}  pdu_device=pdu
    [Teardown]  Teardown PDU  pdu_device=pdu

REBOOT Radio on APC using SN
    [Arguments]    ${rmodSerial}
    ${SN_rmods}=    Create Dictionary
    FOR  ${enb}    IN    @{tl.enbs}
        FOR  ${radio_module}  IN  @{enb.rms}
            ${radio_values} =    Create List    ${radio_module.pdu_port.pdu.addr}    ${radio_module.pdu_port.port_no}
            ...    ${radio_module.pdu_port.pdu.model}
            Set To Dictionary    ${SN_rmods}    ${radio_module.serial_number}    ${radio_values}
        END
    END
    ${retrieved_values} =    Get From Dictionary    ${SN_rmods}    ${rmodSerial}
    ${addr} =    Get From List    ${retrieved_values}    0
    ${port} =    Get From List    ${retrieved_values}    1
    ${apc_model} =    Get From List    ${retrieved_values}    2
    ${apc_model} =    Set Variable If    '${apc_model}'=='None'    APC    ${apc_model}
    Setup PDU    model=${apc_model}    host=${addr}    alias=pdu
    Run Keyword And Ignore Error    power_off  port=${port}  pdu_device=pdu
    Log To Console    Power Reset of RMOD that have serial number: ${rmodSerial} triggered!
    Sleep  2sec
    Run Keyword And Ignore Error    power_on   port=${port}  pdu_device=pdu
    [Teardown]    Teardown PDU  alias=pdu

Log To Console With Time
    [Documentation]  Keyword display,log output with time
    [Arguments]  ${output}
    @{time}=  Get Time  hour min sec  NOW
    ${time_now}=  Catenate  SEPARATOR=:  ${time}[0]  ${time}[1]  ${time}[2]
    Log  (${time_now}) ${output}  console=True
