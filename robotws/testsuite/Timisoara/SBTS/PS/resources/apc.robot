*** Settings ***
Library  ute_pdu

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
...  xx.xx.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-xxx - xxx
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
        IF  ('${modules}'=='ALL' or '${modules}'=='SM') and '${ASO[EFGH]}'=='${True}'
            Set APC State On System Module  ${enb.system_module.core_units}  ${state}
        ELSE
            Set APC State On System Module  ${enb.system_module.common_units}  ${state}
        END
        IF  '${modules}'=='ALL' or '${modules}'=='RM'  Set APC State On Radio Module  ${enb}  ${state}  4G
    END


#Set APC State 4G
#    [Arguments]  ${state}=ON  ${modules}=ALL
#    FOR  ${enb}  IN  @{tl.enbs}
#        Run Keyword If  '${modules}'=='ALL' or '${modules}'=='SM'  Set APC State On System Module  ${enb.system_module.core_units}    ${state}
#        Run Keyword If  '${modules}'=='ALL' or '${modules}'=='SM'  Set APC State On System Module  ${enb.system_module.common_units}  ${state}
#        Run Keyword If  '${modules}'=='ALL' or '${modules}'=='RM'  Set APC State On Radio Module   ${enb}  ${state}  4G
#    END


Set APC State On System Module
    [Arguments]  ${units}  ${state}

    FOR  ${system_module}  IN  @{units}
        ${status}  Run Keyword And Return Status  SET APC STATE   ${system_module.pdu_port.pdu.addr}  ${system_module.pdu_port.port_no}
        ...  ${system_module.pdu_port.pdu.model}  ${state}
        Log To Console With Time
        ...  ${system_module.pdu_port.pdu.addr} ${system_module.pdu_port.port_no} ${system_module.pdu_port.pdu.model} ${state} SM - ${status}
    END


Set APC State On Radio Module
    [Arguments]  ${testline}  ${state}  ${testline_type}

    IF  '${testline_type}'=='4G'
        ${key_name}  Set Variable  rms
    ELSE
        ${key_name}  Set Variable  rus
    END
    FOR  ${radio_module}  IN  @{testline.${key_name}}
        ${status}  Run Keyword And Return Status  SET APC STATE  ${radio_module.pdu_port.pdu.addr}  ${radio_module.pdu_port.port_no}
        ...  ${radio_module.pdu_port.pdu.model}  ${state}
        Log To Console With Time
        ...  ${radio_module.pdu_port.pdu.addr} ${radio_module.pdu_port.port_no} ${radio_module.pdu_port.pdu.model} ${state} RM - ${status}
    END


SET APC STATE
    [Arguments]  ${apc_ip}  ${apc_port}  ${apc_model}  ${state}

    Setup PDU    host=${apc_ip}    model=${apc_model}  alias=pdu
    IF  '${state}'=='ON'  Pdu Outlet Off  outlet=${apc_port}  alias=pdu
    IF  '${state}'=='OFF'  Pdu Outlet On  outlet=${apc_port}  alias=pdu
    IF  '${state}'=='REBOOT'  Pdu Outlet On  outlet=${apc_port}  alias=pdu
    IF  '${state}'=='REBOOT'  Sleep  2sec
    IF  '${state}'=='REBOOT'  Pdu Outlet Off  outlet=${apc_port}  alias=pdu

    [Teardown]  Teardown PDU  alias=pdu


Log To Console With Time
    [Documentation]  Keyword display,log output with time
    [Arguments]  ${output}

    @{time}  Get Time  hour min sec  NOW
    ${time_now}  Catenate  SEPARATOR=:  @{time}[0]  @{time}[1]  @{time}[2]
    Log  (${time_now}) ${output}  console=True
